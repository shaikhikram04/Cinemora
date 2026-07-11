import asyncio

import httpx

_BASE_URL = "https://api.jikan.moe/v4"

# Jikan v4 has no API key but a hard rate limit (~3 req/s, 60/min). A serialized
# min-interval throttle keeps a daily full-catalog sweep well under that
# instead of racing concurrent requests into 429s.
_MIN_INTERVAL_SECONDS = 0.4
_lock = asyncio.Lock()
_last_call_at = 0.0

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


async def _throttle() -> None:
    global _last_call_at
    async with _lock:
        loop = asyncio.get_event_loop()
        now = loop.time()
        wait = _MIN_INTERVAL_SECONDS - (now - _last_call_at)
        if wait > 0:
            await asyncio.sleep(wait)
        _last_call_at = loop.time()


async def _get(path: str, params: dict | None = None) -> dict:
    await _throttle()
    client = _get_client()
    resp = await client.get(path, params=params or {})
    if resp.status_code == 429:
        await asyncio.sleep(2.0)
        resp = await client.get(path, params=params or {})
    resp.raise_for_status()
    return resp.json()


async def fetch_top(filter_: str = "bypopularity", page: int = 1, limit: int = 25) -> dict:
    return await _get("/top/anime", {"filter": filter_, "page": page, "limit": limit})


async def fetch_recommendations(mal_id: int) -> dict:
    return await _get(f"/anime/{mal_id}/recommendations")
