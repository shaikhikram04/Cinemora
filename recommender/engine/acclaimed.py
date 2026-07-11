import json

from db.mongo import content_catalog_collection
from db.redis import get_redis

# Slightly over the daily ingestion cadence so a slow/failed ingestion run
# doesn't immediately blank the section — it just serves slightly stale data.
_CACHE_TTL_SECONDS = 25 * 60 * 60
_TOP_K_PER_TYPE = 10
_CINEMA_TYPES = ["movie", "tv", "anime"]


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


async def _top_for_type(cinema_type: str, limit: int) -> list[dict]:
    coll = content_catalog_collection()
    cursor = coll.find({"cinemaType": cinema_type}).sort("bayesianScore", -1).limit(limit)
    return [_public(doc) async for doc in cursor]


def _interleave(per_type: dict[str, list[dict]]) -> list[dict]:
    out: list[dict] = []
    idx = 0
    while True:
        added = False
        for t in _CINEMA_TYPES:
            items = per_type.get(t, [])
            if idx < len(items):
                out.append(items[idx])
                added = True
        if not added:
            break
        idx += 1
    return out


async def get_critically_acclaimed(cinema_type: str | None) -> list[dict]:
    """cinema_type=None is the mixed 'For You' view: rank within each type
    first, then interleave — avoids cross-source z-score normalization
    (a statistical assumption we can't cheaply verify) while still
    guaranteeing every type is represented in the mix."""
    redis = get_redis()
    cache_key = f"acclaimed:{cinema_type or 'all'}"
    cached = await redis.get(cache_key)
    if cached:
        return json.loads(cached)

    if cinema_type:
        result = await _top_for_type(cinema_type, _TOP_K_PER_TYPE)
    else:
        per_type = {t: await _top_for_type(t, _TOP_K_PER_TYPE) for t in _CINEMA_TYPES}
        result = _interleave(per_type)

    await redis.set(cache_key, json.dumps(result), ex=_CACHE_TTL_SECONDS)
    return result
