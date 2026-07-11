from collections import defaultdict
from datetime import datetime, timezone

from pymongo.errors import DuplicateKeyError

from config.settings import get_settings
from db.mongo import content_catalog_collection, ingestion_locks_collection
from engine.genre_map import canonicalize_genres
from tmdb import jikan_client, tmdb_client

_LOCK_ID = "catalog_ingest"
_LOCK_LEASE_SECONDS = 30 * 60

_TMDB_MEDIA_TYPES = ["movie", "tv"]
_JIKAN_FILTERS = ["bypopularity", "favorite"]


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


def _accumulate_jikan_item(items: dict[int, dict], r: dict) -> None:
    source_id = r.get("mal_id")
    if not source_id:
        return
    raw_genres = [g.get("name") for g in (r.get("genres") or [])]
    raw_genres += [g.get("name") for g in (r.get("themes") or [])]
    aired_from = (r.get("aired") or {}).get("from") or ""
    year = aired_from.split("-")[0] if aired_from else (str(r["year"]) if r.get("year") else None)
    items[source_id] = {
        "source": "jikan",
        "sourceId": source_id,
        "cinemaType": "anime",
        "title": r.get("title") or "Untitled",
        "posterPath": ((r.get("images") or {}).get("jpg") or {}).get("image_url"),
        "year": year,
        "genres": canonicalize_genres([g for g in raw_genres if g]),
        "rawRating": float(r.get("score") or 0.0),
        "voteCount": int(r.get("scored_by") or 0),
        # Jikan/MAL is anime-specific — original audio is Japanese by convention.
        "originalLanguage": "ja",
    }


async def _collect_jikan(page_limit: int) -> list[dict]:
    items: dict[int, dict] = {}
    for filt in _JIKAN_FILTERS:
        for page in range(1, page_limit + 1):
            data = await jikan_client.fetch_top(filt, page, limit=25)
            entries = data.get("data", [])
            if not entries:
                break
            for r in entries:
                _accumulate_jikan_item(items, r)
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
        raw_items += await _collect_jikan(settings.catalog_page_limit)

        scored = _apply_bayesian_scores(raw_items)
        upserted = await _upsert_catalog(scored)
        return {
            "status": "ok",
            "itemsUpserted": upserted,
            "finishedAt": datetime.now(timezone.utc).isoformat(),
        }
    finally:
        await _release_lock()
