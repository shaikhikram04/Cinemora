import asyncio

import httpx

_BASE_URL = "https://graphql.anilist.co"

# AniList's official rate limit is 90 req/min per IP, no API key. The Node
# backend (backend/config/anilist.js) also calls AniList and may share the
# same outbound IP, so we throttle well under the full budget rather than
# assuming it's ours alone.
_MIN_INTERVAL_SECONDS = 0.7
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


async def _post(query: str, variables: dict) -> dict:
    await _throttle()
    client = _get_client()
    resp = await client.post("", json={"query": query, "variables": variables})
    # 429 (rate limit) and 5xx (AniList has occasional transient blips, seen
    # in practice) both get one retry with backoff before giving up.
    if resp.status_code == 429 or resp.status_code >= 500:
        await asyncio.sleep(2.0)
        resp = await client.post("", json={"query": query, "variables": variables})
    resp.raise_for_status()
    return resp.json()


# coverImage.large is AniList's *medium* file (~230px wide) despite the name —
# too soft for the Pick-of-the-Week hero. extraLarge (~460px+) is the largest
# cover AniList serves; large stays as the fallback.
_TOP_QUERY = """
query ($page: Int, $perPage: Int, $sort: [MediaSort]) {
  Page(page: $page, perPage: $perPage) {
    media(type: ANIME, sort: $sort) {
      idMal
      title { english romaji }
      coverImage { extraLarge large }
      genres
      averageScore
      popularity
      startDate { year }
    }
  }
}
"""


async def fetch_top(sort: str = "POPULARITY_DESC", page: int = 1, per_page: int = 25) -> dict:
    return await _post(_TOP_QUERY, {"page": page, "perPage": per_page, "sort": [sort]})


_RECOMMENDATIONS_QUERY = """
query ($malId: Int) {
  Media(idMal: $malId, type: ANIME) {
    recommendations(sort: RATING_DESC, perPage: 15) {
      nodes {
        mediaRecommendation {
          idMal
          title { english romaji }
          coverImage { extraLarge large }
          averageScore
          startDate { year }
        }
      }
    }
  }
}
"""


async def fetch_recommendations(mal_id: int) -> dict:
    return await _post(_RECOMMENDATIONS_QUERY, {"malId": mal_id})
