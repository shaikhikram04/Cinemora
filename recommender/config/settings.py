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

    # Mood chat (Claude-powered, rate-limited)
    anthropic_api_key: str = ""
    anthropic_model: str = "claude-opus-4-8"
    mood_max_turns_per_session: int = 8
    mood_max_sessions_per_day: int = 2


@lru_cache
def get_settings() -> Settings:
    return Settings()
