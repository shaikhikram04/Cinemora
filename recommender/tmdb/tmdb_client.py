import httpx

from config.settings import get_settings

_BASE_URL = "https://api.themoviedb.org/3"
_client: httpx.AsyncClient | None = None


def _get_client() -> httpx.AsyncClient:
    global _client
    if _client is None:
        _client = httpx.AsyncClient(base_url=_BASE_URL, timeout=10.0)
    return _client


async def close_client() -> None:
    global _client
    if _client is not None:
        await _client.aclose()
        _client = None


async def _get(path: str, params: dict | None = None) -> dict:
    settings = get_settings()
    resp = await _get_client().get(path, params={**(params or {}), "api_key": settings.tmdb_api_key})
    resp.raise_for_status()
    return resp.json()


async def fetch_genres(media_type: str) -> dict:
    return await _get(f"/genre/{media_type}/list")


async def fetch_trending(media_type: str, time_window: str = "week", page: int = 1) -> dict:
    return await _get(f"/trending/{media_type}/{time_window}", {"page": page})


async def fetch_top_rated(media_type: str, page: int = 1) -> dict:
    return await _get(f"/{media_type}/top_rated", {"page": page})


async def fetch_recommendations(media_type: str, item_id: int) -> dict:
    # TMDB's /similar is a weak genre/keyword match (total_results can run
    # into the hundreds of thousands — effectively noise). /recommendations
    # is TMDB's actually curated "users who liked X also liked Y" signal.
    return await _get(f"/{media_type}/{item_id}/recommendations")
