from datetime import date, datetime, timezone

from bson import ObjectId
from bson.errors import InvalidId

from db.mongo import recommendation_cache_collection
from engine.taste_vector import score_candidates

# Hero row on Home — a small, personalized, mixed-type set that refreshes
# once a week (Monday). Kept deliberately short so it reads as a curated
# "here's what to watch this week" pick rather than an endless feed.
_PICK_SIZE = 6

# The mixed "For You" hero (cinema_type=None) follows a fixed type layout so
# it doesn't read as an anime or tv binge list just because those scored
# highest, and so the row always opens on movies. Type-scoped tabs skip this
# since the catalog query already constrains them to one type.
_PICK_SEQUENCE = ["movie", "movie", "tv", "anime", "movie", "tv"]


def _fill_pick_sequence(ranked_items: list[dict], sequence: list[str]) -> list[dict]:
    """Fill each slot in `sequence` with the highest-scored unused item of
    that slot's type. Slots whose type ran dry (e.g. too few anime in the
    pool) are backfilled in place with the best remaining items of any type,
    so the row under-fills only when the whole pool is exhausted."""
    used: set[int] = set()

    def take(cinema_type: str | None) -> dict | None:
        for i, item in enumerate(ranked_items):
            if i not in used and (cinema_type is None or item["cinemaType"] == cinema_type):
                used.add(i)
                return item
        return None

    slots = [take(cinema_type) for cinema_type in sequence]
    slots = [slot if slot is not None else take(None) for slot in slots]
    return [slot for slot in slots if slot is not None]


def current_week_key(today: date | None = None) -> str:
    """ISO year-week, Monday-anchored (isocalendar weeks start Monday). The
    key rolls over every Monday, so a new week is automatically a cache miss
    that triggers recompute — no batch job iterating all users needed."""
    d = today or datetime.now(timezone.utc).date()
    iso = d.isocalendar()
    return f"{iso.year}-W{iso.week:02d}"


def _cache_key(week_key: str, cinema_type: str | None) -> str:
    # Each Home tab (all / movie / tv / anime) caches its own weekly pick, so
    # a type-scoped hero doesn't collide with the mixed "For You" hero.
    return f"{week_key}:{cinema_type or 'all'}"


def _to_object_id(user_id: str) -> ObjectId | None:
    try:
        return ObjectId(user_id)
    except (InvalidId, TypeError):
        return None


async def get_pick_of_week(user_id: str, cinema_type: str | None = None) -> list[dict]:
    """Compute-on-read with a durable weekly cache. First request for a given
    (ISO week, tab type) computes and stores; the rest of that week serves the
    cached doc. Monday's key change invalidates naturally. cinema_type=None is
    the mixed "For You" hero; a type scopes it to that Home tab."""
    oid = _to_object_id(user_id)
    if oid is None:
        return []

    week_key = _cache_key(current_week_key(), cinema_type)
    coll = recommendation_cache_collection()

    cached = await coll.find_one({"userId": oid, "weekKey": week_key})
    if cached is not None:
        return cached.get("items", [])

    if cinema_type is None:
        ranked = await score_candidates(user_id, None, limit=None)
        items = _fill_pick_sequence(ranked, _PICK_SEQUENCE)
    else:
        items = await score_candidates(user_id, cinema_type, limit=_PICK_SIZE)

    await coll.update_one(
        {"userId": oid, "weekKey": week_key},
        {"$set": {"items": items, "computedAt": datetime.now(timezone.utc)}},
        upsert=True,
    )
    return items
