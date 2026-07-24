import json

from db.mongo import content_catalog_collection
from db.redis import get_redis
from engine.taste_vector import excluded_catalog_keys

# Slightly over the daily ingestion cadence so a slow/failed ingestion run
# doesn't immediately blank the section — it just serves slightly stale data.
_CACHE_TTL_SECONDS = 25 * 60 * 60
# What we ultimately show per type…
_RESULT_PER_TYPE = 10
# …vs the wider user-independent pool we cache and share across all users, so a
# full row of 10 still survives after each user's own library is filtered out.
# A static top-rated leaderboard never rotates on its own, so a user who has
# logged the top titles would otherwise see the same row forever.
_POOL_PER_TYPE = 50
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


async def _acclaimed_pool(cinema_type: str) -> list[dict]:
    """The user-independent ranked pool for one type — the only part of this
    module that touches Mongo, so it stays cached globally and shared by every
    user. Cached BEFORE any per-user filtering (same split as similar.py) so
    one user's library can never leak into another user's row."""
    redis = get_redis()
    cache_key = f"acclaimed:pool:{cinema_type}"
    cached = await redis.get(cache_key)
    if cached:
        return json.loads(cached)

    pool = await _top_for_type(cinema_type, _POOL_PER_TYPE)
    await redis.set(cache_key, json.dumps(pool), ex=_CACHE_TTL_SECONDS)
    return pool


async def get_critically_acclaimed(
    cinema_type: str | None, user_id: str | None = None
) -> list[dict]:
    """cinema_type=None is the mixed 'For You' view: rank within each type
    first, then interleave — avoids cross-source z-score normalization
    (a statistical assumption we can't cheaply verify) while still
    guaranteeing every type is represented in the mix.

    Anything already in the user's library (watched / watchlist / dropped) is
    pruned from the shared pool per request, reusing the same exclusion set as
    Pick of the Week so all three personalized rows agree on what "already
    seen" means. user_id=None (unauthenticated) keeps the plain global list."""
    excluded = await excluded_catalog_keys(user_id) if user_id else set()

    def _prune(pool: list[dict]) -> list[dict]:
        if not excluded:
            return pool[:_RESULT_PER_TYPE]
        kept = [
            item
            for item in pool
            if (item["source"], item["sourceId"], item["cinemaType"]) not in excluded
        ]
        return kept[:_RESULT_PER_TYPE]

    if cinema_type:
        return _prune(await _acclaimed_pool(cinema_type))

    per_type = {t: _prune(await _acclaimed_pool(t)) for t in _CINEMA_TYPES}
    return _interleave(per_type)
