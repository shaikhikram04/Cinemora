from fastapi import APIRouter

from db.mongo import get_db
from db.redis import get_redis

router = APIRouter()


@router.get("/internal/health")
async def health() -> dict:
    mongo_ok = True
    redis_ok = True
    try:
        await get_db().command("ping")
    except Exception:
        mongo_ok = False
    try:
        await get_redis().ping()
    except Exception:
        redis_ok = False
    return {"status": "ok" if (mongo_ok and redis_ok) else "degraded", "mongo": mongo_ok, "redis": redis_ok}
