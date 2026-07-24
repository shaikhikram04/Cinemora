from fastapi import APIRouter, Depends, Query

from engine.acclaimed import get_critically_acclaimed
from engine.pick_of_week import get_pick_of_week
from engine.similar import get_similar
from engine.taste_vector import get_because_you_ranked
from routes.deps import get_user_id, require_internal_secret

router = APIRouter(dependencies=[Depends(require_internal_secret)])

_VALID_TYPES = {"all", "movie", "tv", "anime"}


@router.get("/internal/recommendations/home")
async def home(type: str = Query("all"), user_id: str | None = Depends(get_user_id)) -> dict:
    cinema_type = type if type in _VALID_TYPES and type != "all" else None
    acclaimed = await get_critically_acclaimed(cinema_type, user_id)
    because_you_ranked = (
        await get_because_you_ranked(user_id, cinema_type)
        if user_id
        else {"anchor": None, "items": []}
    )
    pick_of_week = await get_pick_of_week(user_id, cinema_type) if user_id else []
    return {
        "pickOfWeek": pick_of_week,
        "becauseYouRanked": because_you_ranked,
        "criticallyAcclaimed": acclaimed,
    }


@router.get("/internal/recommendations/similar/{cinema_type}/{source_id}")
async def similar(
    cinema_type: str, source_id: int, user_id: str | None = Depends(get_user_id)
) -> list[dict]:
    return await get_similar(cinema_type, source_id, user_id)
