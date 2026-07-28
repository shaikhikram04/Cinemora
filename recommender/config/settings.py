from functools import lru_cache

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Values that were once shipped as defaults, or that appear verbatim in
# .env.example. Any of them reaching a running process means the real secret
# was never set — and since they're readable in the repo, they authenticate
# nobody. Rejected outright rather than trusted.
_PLACEHOLDER_SECRETS = {
    "dev-secret-change-me",
    "change-me-shared-with-node-backend",
    "change-me-shared-with-recommender",
}


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    port: int = 8000

    mongo_uri: str = "mongodb://localhost:27017/watchary"
    redis_url: str = "redis://localhost:6379/0"

    tmdb_api_key: str = ""

    # Deliberately has NO default. This is the only thing standing between the
    # /internal/* routes and the internet: they trust the X-User-Id header
    # outright, so anyone who can authenticate can read any user's data. A
    # default would mean a missing env var silently downgrades to a secret
    # published in this repo — so the service refuses to boot instead.
    internal_service_secret: str

    @field_validator("internal_service_secret")
    @classmethod
    def _reject_placeholder_secret(cls, v: str) -> str:
        if v.strip() in _PLACEHOLDER_SECRETS or len(v.strip()) < 16:
            raise ValueError(
                "INTERNAL_SERVICE_SECRET must be set to a real, unpublished "
                "value of at least 16 characters (generate one with "
                "`openssl rand -hex 32`), and must match the backend's."
            )
        return v

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
