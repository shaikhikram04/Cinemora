from collections import defaultdict

from bson import ObjectId
from bson.errors import InvalidId

from db.mongo import (
    content_catalog_collection,
    library_entries_collection,
    ranking_lists_collection,
    users_collection,
)
from engine.genre_map import canonicalize_genres
from engine.language_map import to_iso_codes
from engine.similar import get_similar

# Weighted heuristic, not ML — deliberately simple enough to eyeball and
# explain. Weights are a starting point to tune by feel, not load-bearing
# constants. Explicit curation (rankings) counts far more than passive
# watching, which counts more than a one-time onboarding pick.
_ONBOARDING_GENRE_WEIGHT = 2.0
_LIBRARY_STATUS_BASE = {
    "watched": 3.0,
    "watchlist": 0.5,
    "dropped": -2.0,
}
_RANKING_WEIGHT_MULTIPLIER = 3.0

# era_match is deliberately absent from the scoring formula. Favorite era is no
# longer a stored preference at all — it's derived from the user's library on the
# client for display only (frontend/lib/core/utils/era_insight.dart, which mirrors
# the status/rating/rewatch weights above). Era is real signal now, so an era term
# here is finally possible; it's held back until the derived era proves itself,
# since scoring on it narrows every personalized row toward one decade. Its weight
# stays folded into genre affinity for now.
_WEIGHT_GENRE_AFFINITY = 0.6
_WEIGHT_RATING = 0.2
_WEIGHT_LANGUAGE = 0.2


def _to_object_id(user_id: str) -> ObjectId | None:
    try:
        return ObjectId(user_id)
    except (InvalidId, TypeError):
        return None


async def _user_doc(user_id: str) -> dict | None:
    oid = _to_object_id(user_id)
    if oid is None:
        return None
    return await users_collection().find_one({"_id": oid})


async def _library_entries(user_id: str) -> list[dict]:
    oid = _to_object_id(user_id)
    if oid is None:
        return []
    return [doc async for doc in library_entries_collection().find({"userId": oid})]


async def _ranking_lists(user_id: str) -> list[dict]:
    oid = _to_object_id(user_id)
    if oid is None:
        return []
    return [doc async for doc in ranking_lists_collection().find({"userId": oid})]


def _rewatch_multiplier(watched_at: list) -> float:
    extra = max(len(watched_at) - 1, 0)
    return 1 + 0.5 * min(extra, 3)


def _rating_multiplier(user_rating: float | None) -> float:
    if user_rating is None:
        return 1.0
    return max(-1.0, min(1.0, (user_rating - 2.5) / 2.5))


def _rank_weight(rank: int) -> float:
    if rank <= 10:
        return max(0.0, 11 - rank)
    return 0.5


def _catalog_key(cinema_type: str, tmdb_id: int) -> tuple[str, int, str]:
    source = "anilist" if cinema_type == "anime" else "tmdb"
    return (source, tmdb_id, cinema_type)


async def _catalog_genres_for_keys(keys: set[tuple[str, int, str]]) -> dict[tuple[str, int, str], list[str]]:
    """Ranking entries don't carry genres (unlike LibraryEntry) — join against
    content_catalog to look them up."""
    if not keys:
        return {}
    or_clauses = [{"source": s, "sourceId": sid, "cinemaType": ct} for (s, sid, ct) in keys]
    cursor = content_catalog_collection().find(
        {"$or": or_clauses}, {"source": 1, "sourceId": 1, "cinemaType": 1, "genres": 1}
    )
    out: dict[tuple[str, int, str], list[str]] = {}
    async for doc in cursor:
        out[(doc["source"], doc["sourceId"], doc["cinemaType"])] = doc.get("genres", [])
    return out


async def compute_genre_affinity(user_id: str) -> dict[str, float]:
    """Returns a per-genre score normalized to [0, 1]. Empty dict means no
    signal at all (brand-new user, empty onboarding/library/rankings)."""
    user = await _user_doc(user_id)
    onboarding_genres = ((user or {}).get("preferences") or {}).get("genres") or []

    library = await _library_entries(user_id)
    ranking_lists = await _ranking_lists(user_id)
    ranking_entries = [e for rl in ranking_lists for e in rl.get("entries", [])]

    ranking_keys = {
        _catalog_key(e.get("cinemaType"), e.get("tmdbId"))
        for e in ranking_entries
        if e.get("cinemaType") and e.get("tmdbId") is not None
    }
    ranking_genre_map = await _catalog_genres_for_keys(ranking_keys)

    scores: dict[str, float] = defaultdict(float)

    for g in canonicalize_genres(onboarding_genres):
        scores[g] += _ONBOARDING_GENRE_WEIGHT

    for entry in library:
        base = _LIBRARY_STATUS_BASE.get(entry.get("status", "watchlist"), 0.0)
        mult = _rewatch_multiplier(entry.get("watchedAt") or [])
        rating_mult = (
            _rating_multiplier(entry.get("userRating")) if entry.get("status") == "watched" else 1.0
        )
        contribution = base * mult * rating_mult
        for g in canonicalize_genres(entry.get("genres") or []):
            scores[g] += contribution

    for entry in ranking_entries:
        cinema_type, tmdb_id = entry.get("cinemaType"), entry.get("tmdbId")
        if not cinema_type or tmdb_id is None:
            continue
        genres = ranking_genre_map.get(_catalog_key(cinema_type, tmdb_id), [])
        weight = _rank_weight(entry.get("rank", 999)) * _RANKING_WEIGHT_MULTIPLIER
        for g in genres:
            scores[g] += weight

    if not scores:
        return {}

    values = list(scores.values())
    lo, hi = min(values), max(values)
    if hi == lo:
        return {g: 1.0 for g in scores}
    return {g: (v - lo) / (hi - lo) for g, v in scores.items()}


async def excluded_catalog_keys(user_id: str) -> set[tuple[str, int, str]]:
    """Every library status (including watchlist) is excluded from
    personalized candidate pools — resurfacing something the user already
    watchlisted reads as the algorithm not knowing the user, and watchlist
    itself is one tap away in its own tab."""
    library = await _library_entries(user_id)
    return {
        _catalog_key(e["cinemaType"], e["tmdbId"])
        for e in library
        if e.get("cinemaType") and e.get("tmdbId") is not None
    }


def _public(doc: dict) -> dict:
    return {
        "source": doc["source"],
        "sourceId": doc["sourceId"],
        "cinemaType": doc["cinemaType"],
        "title": doc["title"],
        "posterPath": doc.get("posterPath"),
        "year": doc.get("year"),
        "rating": round(doc.get("normalizedRating", 0.0), 1),
        "genres": doc.get("genres", []),
    }


async def score_candidates(user_id: str, cinema_type: str | None, limit: int | None = 20) -> list[dict]:
    """General personalized candidate scorer — the shared engine behind both
    'Because You Ranked' (live, Phase 2a) and 'Pick of the Week' (weekly
    precompute, Phase 2b). cinema_type=None scores across the whole catalog.
    limit=None returns the full ranked list, unsliced — used by callers that
    need to apply their own selection on top of the ranking (e.g. Pick of the
    Week's type-mix cap)."""
    user = await _user_doc(user_id)
    language_codes = to_iso_codes(((user or {}).get("preferences") or {}).get("languages") or [])

    affinity = await compute_genre_affinity(user_id)
    excluded = await excluded_catalog_keys(user_id)

    query: dict = {"cinemaType": cinema_type} if cinema_type else {}
    candidates = [doc async for doc in content_catalog_collection().find(query)]

    scored: list[tuple[float, dict]] = []
    for doc in candidates:
        key = (doc["source"], doc["sourceId"], doc["cinemaType"])
        if key in excluded:
            continue

        genre_scores = [affinity.get(g, 0.0) for g in doc.get("genres", [])]
        genre_affinity = max(genre_scores) if genre_scores else 0.0
        rating_component = doc.get("normalizedRating", 0.0) / 10
        language_match = 1.0 if doc.get("originalLanguage") in language_codes else 0.0

        score = (
            _WEIGHT_GENRE_AFFINITY * genre_affinity
            + _WEIGHT_RATING * rating_component
            + _WEIGHT_LANGUAGE * language_match
        )
        scored.append((score, doc))

    scored.sort(key=lambda pair: pair[0], reverse=True)
    ranked = scored if limit is None else scored[:limit]
    return [_public(doc) for _, doc in ranked]


def _matches_type(entry: dict, cinema_type: str | None) -> bool:
    return cinema_type is None or entry.get("cinemaType") == cinema_type


async def _top_ranking_anchor(user_id: str, cinema_type: str | None) -> dict | None:
    """Rank #1 (or the highest-ranked matching-type entry) from the user's
    largest ranking list — a bigger list is a stronger signal that it's a
    real curated list rather than a one-off."""
    lists = await _ranking_lists(user_id)
    if not lists:
        return None
    lists.sort(key=lambda rl: len(rl.get("entries", [])), reverse=True)
    for rl in lists:
        matching = [e for e in rl.get("entries", []) if _matches_type(e, cinema_type)]
        if matching:
            return min(matching, key=lambda e: e.get("rank", 999))
    return None


async def _top_watched_anchor(user_id: str, cinema_type: str | None) -> dict | None:
    library = await _library_entries(user_id)
    watched = [
        e
        for e in library
        if e.get("status") == "watched" and e.get("userRating") and _matches_type(e, cinema_type)
    ]
    if not watched:
        return None
    watched.sort(
        key=lambda e: (e.get("userRating", 0), len(e.get("watchedAt") or [])),
        reverse=True,
    )
    top = watched[0]
    return {"tmdbId": top.get("tmdbId"), "cinemaType": top.get("cinemaType"), "title": top.get("title")}


async def get_because_you_ranked(
    user_id: str, cinema_type: str | None = None, limit_per_anchor: int = 8
) -> dict:
    """Anchor-based rather than a generic genre-soup carousel: pick a concrete
    title the user has explicitly signaled they love (a #1 ranking, their
    top-rated rewatch), and reuse the same item-similarity engine as the
    detail-screen 'Similar Content' section to build the carousel. Far more
    explainable than 'because you like Drama'. On a type-scoped Home tab the
    anchor is constrained to that type so the row stays on-theme; if the user
    has no matching-type anchor, the section is simply omitted."""
    anchor = await _top_ranking_anchor(user_id, cinema_type) or await _top_watched_anchor(
        user_id, cinema_type
    )
    if not anchor:
        return {"anchor": None, "items": []}

    anchor_type, tmdb_id = anchor.get("cinemaType"), anchor.get("tmdbId")
    if not anchor_type or tmdb_id is None:
        return {"anchor": None, "items": []}

    items = await get_similar(anchor_type, tmdb_id, user_id, limit=limit_per_anchor)
    return {
        "anchor": {
            "cinemaType": anchor_type,
            "sourceId": tmdb_id,
            "title": anchor.get("title"),
        },
        "items": items,
    }
