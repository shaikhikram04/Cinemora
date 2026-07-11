import json

from bson import ObjectId
from bson.errors import InvalidId

from db.mongo import library_entries_collection
from db.redis import get_redis
from tmdb import jikan_client, tmdb_client

# Live-proxy TMDB's `/recommendations` endpoint (movie/tv — curated
# "users who liked X also liked Y", not TMDB's `/similar`, which is a weak
# genre/keyword match with total_results running into the hundreds of
# thousands, i.e. effectively noise) and Jikan's crowd-voted
# `/recommendations` endpoint (anime — a different shape, own mapper).
# Deliberately not routed through Node even though Node already fetches
# TMDB's `similar` field and discards it: that field is the noisy one, it
# skips anime entirely, and it splits recommendation logic across services.
#
# The external call is cached in Redis per title (below). A catalog-native V2
# was considered but rejected: the catalog is only ~500 items, so joining a
# title's similar IDs against it would miss most candidates and degrade to
# low-quality genre-overlap — worse than these curated live results. Caching
# gets V2's real wins (no repeated external calls, low latency on hot detail
# pages) with zero quality loss.
_RATING_FLOOR = 5.0
_CACHE_TTL_SECONDS = 24 * 60 * 60


def _public_tmdb(r: dict, media_type: str) -> dict:
    date = r.get("release_date") or r.get("first_air_date") or ""
    return {
        "source": "tmdb",
        "sourceId": r.get("id"),
        "cinemaType": media_type,
        "title": r.get("title") or r.get("name") or "Untitled",
        "posterPath": r.get("poster_path"),
        "year": date.split("-")[0] if date else None,
        "rating": round(float(r.get("vote_average") or 0.0), 1),
        "genres": [],
    }


def _public_jikan(entry: dict) -> dict:
    anime = entry.get("entry") or entry
    return {
        "source": "jikan",
        "sourceId": anime.get("mal_id"),
        "cinemaType": "anime",
        "title": anime.get("title") or "Untitled",
        "posterPath": ((anime.get("images") or {}).get("jpg") or {}).get("image_url"),
        "year": None,
        "rating": None,
        "genres": [],
    }


async def _exclude_library_items(candidates: list[dict], user_id: str) -> list[dict]:
    try:
        oid = ObjectId(user_id)
    except (InvalidId, TypeError):
        return candidates
    coll = library_entries_collection()
    ids = [c["sourceId"] for c in candidates if c.get("sourceId") is not None]
    if not ids:
        return candidates
    cursor = coll.find({"userId": oid, "tmdbId": {"$in": ids}}, {"tmdbId": 1, "cinemaType": 1})
    seen = {(doc["tmdbId"], doc["cinemaType"]) async for doc in cursor}
    return [c for c in candidates if (c["sourceId"], c["cinemaType"]) not in seen]


async def _fetch_candidates(cinema_type: str, source_id: int) -> list[dict]:
    """The expensive external call + normalization, cached in Redis per title.
    Cached BEFORE the per-user library filter so the entry is shared across
    all users — exclusion is a cheap Mongo lookup applied per request in
    get_similar()."""
    redis = get_redis()
    cache_key = f"similar:{cinema_type}:{source_id}"
    cached = await redis.get(cache_key)
    if cached is not None:
        return json.loads(cached)

    if cinema_type == "anime":
        data = await jikan_client.fetch_recommendations(source_id)
        candidates = [_public_jikan(e) for e in data.get("data", [])]
    else:
        data = await tmdb_client.fetch_recommendations(cinema_type, source_id)
        candidates = [
            _public_tmdb(r, cinema_type)
            for r in data.get("results", [])
            if float(r.get("vote_average") or 0.0) >= _RATING_FLOOR
        ]

    await redis.set(cache_key, json.dumps(candidates), ex=_CACHE_TTL_SECONDS)
    return candidates


async def get_similar(cinema_type: str, source_id: int, user_id: str | None, limit: int = 15) -> list[dict]:
    candidates = await _fetch_candidates(cinema_type, source_id)

    if user_id:
        candidates = await _exclude_library_items(candidates, user_id)

    return candidates[:limit]
