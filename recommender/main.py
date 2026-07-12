from contextlib import asynccontextmanager

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from fastapi import FastAPI

from config.settings import get_settings
from db.mongo import (
    close_db,
    content_catalog_collection,
    mood_sessions_collection,
    recommendation_cache_collection,
)
from db.redis import close_redis
from engine.catalog_ingest import run_ingestion
from routes import health, ingest, mood, recommendations
from tmdb import anilist_client, tmdb_client

scheduler = AsyncIOScheduler()


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    await content_catalog_collection().create_index(
        [("source", 1), ("sourceId", 1), ("cinemaType", 1)], unique=True
    )
    rec_cache = recommendation_cache_collection()
    await rec_cache.create_index([("userId", 1), ("weekKey", 1)], unique=True)
    # Old weekly picks self-expire ~30 days after compute so the collection
    # doesn't grow unbounded one doc per user per week.
    await rec_cache.create_index("computedAt", expireAfterSeconds=30 * 24 * 60 * 60)
    mood_coll = mood_sessions_collection()
    await mood_coll.create_index([("userId", 1), ("dayKey", 1)])
    # Sessions self-expire after 48h — long enough to keep a conversation alive,
    # short enough that the per-day session count stays meaningful.
    await mood_coll.create_index("createdAt", expireAfterSeconds=48 * 60 * 60)
    scheduler.add_job(run_ingestion, "cron", hour=settings.ingestion_hour_utc, id="daily_catalog_ingest")
    scheduler.start()
    yield
    scheduler.shutdown(wait=False)
    await tmdb_client.close_client()
    await anilist_client.close_client()
    await close_db()
    await close_redis()


app = FastAPI(title="Watchary Recommender", lifespan=lifespan)
app.include_router(health.router)
app.include_router(ingest.router)
app.include_router(recommendations.router)
app.include_router(mood.router)
