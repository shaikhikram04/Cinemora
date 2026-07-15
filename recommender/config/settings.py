from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    port: int = 8000

    mongo_uri: str = "mongodb://localhost:27017/watchary"
    redis_url: str = "redis://localhost:6379/0"

    tmdb_api_key: str = ""
    internal_service_secret: str = "dev-secret-change-me"

    # Ingestion tuning
    ingestion_hour_utc: int = 3  # daily sweep time
    catalog_page_limit: int = 5  # ~20 items/page from TMDB -> up to ~100-500 items per list

    # Mood chat (Gemini-powered, rate-limited)
    gemini_api_key: str = ""
    gemini_model: str = "gemini-3.5-flash"
    # Used when the primary is shedding free-tier load (503). Keep this a
    # smaller/less contended model — it's the one that's still up when the
    # headline model isn't.
    gemini_fallback_model: str = "gemini-3.1-flash-lite"
    mood_max_turns_per_session: int = 8
    mood_max_sessions_per_day: int = 2


@lru_cache
def get_settings() -> Settings:
    return Settings()
