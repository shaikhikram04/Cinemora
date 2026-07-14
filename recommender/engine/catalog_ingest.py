from collections import defaultdict
from datetime import datetime, timezone

from pymongo.errors import DuplicateKeyError

from config.settings import get_settings
from db.mongo import content_catalog_collection, ingestion_locks_collection
from engine.genre_map import canonicalize_genres
from tmdb import anilist_client, tmdb_client

_LOCK_ID = "catalog_ingest"
_LOCK_LEASE_SECONDS = 30 * 60

_TMDB_MEDIA_TYPES = ["movie", "tv"]
_ANILIST_SORTS = ["POPULARITY_DESC", "FAVOURITES_DESC"]

# TMDB's trending/top_rated for movie & tv include Japanese anime (TMDB has
# no separate "anime" media_type) — Genre 16 is "Animation". Anime already
# has a dedicated, better-fitted pipeline via AniList (_collect_anilist) with
# its own genres and MAL-linked score, so TMDB anime hits are skipped here
# rather than reclassified, to avoid ending up with the same title twice in
# the catalog under two different sources.
_TMDB_ANIMATION_GENRE_ID = 16


def _is_tmdb_anime(r: dict) -> bool:
    return _TMDB_ANIMATION_GENRE_ID in (r.get("genre_ids") or []) and r.get("original_language") == "ja"


async def _acquire_lock() -> bool:
    """Atomic mutex via a single doc: upsert fails with DuplicateKeyError if
    someone else already holds a live lease, since _id collides on insert.
    Cheap insurance against overlapping scheduled + manual ingestion runs."""
    coll = ingestion_locks_collection()
    now = datetime.now(timezone.utc).timestamp()
    lease_until = now + _LOCK_LEASE_SECONDS
    try:
        result = await coll.update_one(
            {"_id": _LOCK_ID, "$or": [{"leaseUntil": {"$lt": now}}, {"leaseUntil": {"$exists": False}}]},
            {"$set": {"leaseUntil": lease_until, "startedAt": now}},
            upsert=True,
        )
    except DuplicateKeyError:
        return False
    return result.matched_count > 0 or result.upserted_id is not None


async def _release_lock() -> None:
    await ingestion_locks_collection().update_one({"_id": _LOCK_ID}, {"$set": {"leaseUntil": 0}})


async def _build_tmdb_genre_map(media_type: str) -> dict[int, str]:
    data = await tmdb_client.fetch_genres(media_type)
    return {g["id"]: g["name"] for g in data.get("genres", [])}


def _accumulate_tmdb_item(items: dict[int, dict], r: dict, media_type: str, genre_map: dict[int, str]) -> None:
    source_id = r.get("id")
    if not source_id:
        return
    if _is_tmdb_anime(r):
        return
    title = r.get("title") or r.get("name") or "Untitled"
    date = r.get("release_date") or r.get("first_air_date") or ""
    genre_names = [genre_map.get(gid) for gid in r.get("genre_ids", [])]
    items[source_id] = {
        "source": "tmdb",
        "sourceId": source_id,
        "cinemaType": media_type,
        "title": title,
        "posterPath": r.get("poster_path"),
        "year": date.split("-")[0] if date else None,
        "genres": canonicalize_genres([g for g in genre_names if g]),
        "rawRating": float(r.get("vote_average") or 0.0),
        "voteCount": int(r.get("vote_count") or 0),
        "originalLanguage": r.get("original_language"),
    }


async def _collect_tmdb(media_type: str, genre_map: dict[int, str], page_limit: int) -> list[dict]:
    items: dict[int, dict] = {}
    for page in range(1, page_limit + 1):
        trending = await tmdb_client.fetch_trending(media_type, "week", page)
        for r in trending.get("results", []):
            _accumulate_tmdb_item(items, r, media_type, genre_map)
    for page in range(1, page_limit + 1):
        top_rated = await tmdb_client.fetch_top_rated(media_type, page)
        for r in top_rated.get("results", []):
            _accumulate_tmdb_item(items, r, media_type, genre_map)
    return list(items.values())


def _accumulate_anilist_item(items: dict[int, dict], r: dict) -> None:
    # idMal is what LibraryEntry/ranking entries store in tmdbId for anime
    # (see tmdbId-not-globally-unique convention) — entries AniList carries
    # that have no MAL mapping (manhwa/donghua typed as ANIME) can't be
    # cross-referenced against user data, so they're skipped.
    source_id = r.get("idMal")
    if not source_id:
        return
    title_obj = r.get("title") or {}
    title = title_obj.get("english") or title_obj.get("romaji") or "Untitled"
    year = (r.get("startDate") or {}).get("year")
    cover = r.get("coverImage") or {}
    items[source_id] = {
        "source": "anilist",
        "sourceId": source_id,
        "cinemaType": "anime",
        "title": title,
        "posterPath": cover.get("extraLarge") or cover.get("large"),
        "year": str(year) if year else None,
        "genres": canonicalize_genres(r.get("genres") or []),
        # averageScore is 0-100 on AniList; normalize to the 0-10 scale used
        # by TMDB's vote_average so Bayesian scoring can compare fairly.
        "rawRating": float(r.get("averageScore") or 0.0) / 10,
        # AniList doesn't expose a "number of scorers" — popularity (list
        # adds) is the closest confidence proxy for the Bayesian prior.
        "voteCount": int(r.get("popularity") or 0),
        # AniList/MAL anime — original audio is Japanese by convention.
        "originalLanguage": "ja",
    }


async def _collect_anilist(page_limit: int) -> list[dict]:
    items: dict[int, dict] = {}
    for sort in _ANILIST_SORTS:
        for page in range(1, page_limit + 1):
            data = await anilist_client.fetch_top(sort, page, per_page=25)
            entries = ((data.get("data") or {}).get("Page") or {}).get("media", [])
            if not entries:
                break
            for r in entries:
                _accumulate_anilist_item(items, r)
    return list(items.values())


def _apply_bayesian_scores(raw_items: list[dict]) -> list[dict]:
    """IMDB-style Bayesian rating, with the (m, C) prior derived per
    (source, cinemaType) from that group's own ingested subset rather than
    hardcoded — TMDB movie vote counts (tens of thousands) and Jikan anime
    vote counts (hundreds-to-low-thousands) are on wildly different scales,
    so one fixed prior would either starve anime out of the mix or let noisy
    low-sample TMDB entries through."""
    groups: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for item in raw_items:
        groups[(item["source"], item["cinemaType"])].append(item)

    for group in groups.values():
        rated = [i for i in group if i["voteCount"] > 0]
        if not rated:
            for i in group:
                i["normalizedRating"] = i["rawRating"]
                i["bayesianScore"] = i["rawRating"]
            continue
        vote_counts = sorted(i["voteCount"] for i in rated)
        m = vote_counts[len(vote_counts) // 2]  # median vote count as the minimum-votes prior
        c = sum(i["rawRating"] for i in rated) / len(rated)
        for i in group:
            v = i["voteCount"]
            r = i["rawRating"]
            i["normalizedRating"] = r
            i["bayesianScore"] = (v / (v + m)) * r + (m / (v + m)) * c if (v + m) > 0 else c
    return raw_items


async def _upsert_catalog(items: list[dict]) -> int:
    coll = content_catalog_collection()
    now = datetime.now(timezone.utc)
    for item in items:
        await coll.update_one(
            {"source": item["source"], "sourceId": item["sourceId"], "cinemaType": item["cinemaType"]},
            {"$set": {**item, "updatedAt": now}, "$setOnInsert": {"similarIds": []}},
            upsert=True,
        )
    return len(items)


async def run_ingestion() -> dict:
    if not await _acquire_lock():
        return {"status": "skipped", "reason": "ingestion already in progress"}
    try:
        settings = get_settings()
        raw_items: list[dict] = []
        for media_type in _TMDB_MEDIA_TYPES:
            genre_map = await _build_tmdb_genre_map(media_type)
            raw_items += await _collect_tmdb(media_type, genre_map, settings.catalog_page_limit)
        raw_items += await _collect_anilist(settings.catalog_page_limit)

        scored = _apply_bayesian_scores(raw_items)
        upserted = await _upsert_catalog(scored)
        return {
            "status": "ok",
            "itemsUpserted": upserted,
            "finishedAt": datetime.now(timezone.utc).isoformat(),
        }
    finally:
        await _release_lock()
