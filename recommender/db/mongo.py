from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase

from config.settings import get_settings

_client: AsyncIOMotorClient | None = None
_db: AsyncIOMotorDatabase | None = None


def get_db() -> AsyncIOMotorDatabase:
    global _client, _db
    if _db is None:
        settings = get_settings()
        _client = AsyncIOMotorClient(settings.mongo_uri)
        _db = _client.get_default_database()
    return _db


async def close_db() -> None:
    global _client, _db
    if _client is not None:
        _client.close()
        _client = None
        _db = None


# ── Collections owned by Node (backend/models/*.js) ─────────────────────────
# NOTE: local dev Mongo has no auth enabled, so this boundary is enforced by
# code discipline, not by a Mongo role. Only ever read from these — never
# insert/update/delete. See plan doc for the real-RBAC follow-up once a
# staging/prod DB with auth exists.
def users_collection(db: AsyncIOMotorDatabase = None):
    return (db or get_db())["users"]


def library_entries_collection(db: AsyncIOMotorDatabase = None):
    return (db or get_db())["libraryentries"]


def ranking_lists_collection(db: AsyncIOMotorDatabase = None):
    return (db or get_db())["rankinglists"]


# ── Collections owned by the recommender (read-write) ───────────────────────
def content_catalog_collection(db: AsyncIOMotorDatabase = None):
    return (db or get_db())["content_catalog"]


def recommendation_cache_collection(db: AsyncIOMotorDatabase = None):
    return (db or get_db())["recommendation_cache"]


def ingestion_locks_collection(db: AsyncIOMotorDatabase = None):
    return (db or get_db())["ingestion_locks"]


def mood_sessions_collection(db: AsyncIOMotorDatabase = None):
    return (db or get_db())["mood_sessions"]
