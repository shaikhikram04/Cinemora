from collections import defaultdict
from datetime import date, datetime, timezone

from bson import ObjectId
from bson.errors import InvalidId

from db.mongo import recommendation_cache_collection
from engine.taste_vector import score_candidates

# Hero row on Home — a small, personalized, mixed-type set that refreshes
# once a week (Monday). Kept deliberately short so it reads as a curated
# "here's what to watch this week" pick rather than an endless feed.
_PICK_SIZE = 6

# The mixed "For You" hero (cinema_type=None) is capped so it doesn't read as
# an anime or tv binge list just because those scored highest — movies fill
# whatever the cap leaves open. Type-scoped tabs skip this since the catalog
# query already constrains them to one type.
_MIX_TYPE_CAPS = {"anime": 2, "tv": 2}


def _apply_type_caps(ranked_items: list[dict], limit: int, caps: dict[str, int]) -> list[dict]:
    """Walk the score-ranked list and take items in order, skipping (not
    dropping) any that would push a capped type over its limit. Skipped items
    are kept as a fallback so, if the pool runs dry before `limit` is filled
    (e.g. too few movies), they still get used rather than under-filling."""
    counts: dict[str, int] = defaultdict(int)
    selected: list[dict] = []
    skipped: list[dict] = []
    for item in ranked_items:
        if len(selected) >= limit:
            break
        cap = caps.get(item["cinemaType"])
        if cap is not None and counts[item["cinemaType"]] >= cap:
            skipped.append(item)
            continue
        selected.append(item)
        counts[item["cinemaType"]] += 1
    for item in skipped:
        if len(selected) >= limit:
            break
        selected.append(item)
    return selected


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
        items = _apply_type_caps(ranked, _PICK_SIZE, _MIX_TYPE_CAPS)
    else:
        items = await score_candidates(user_id, cinema_type, limit=_PICK_SIZE)

    await coll.update_one(
        {"userId": oid, "weekKey": week_key},
        {"$set": {"items": items, "computedAt": datetime.now(timezone.utc)}},
        upsert=True,
    )
    return items
