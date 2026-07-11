import uuid
from datetime import datetime, timezone

from anthropic import AsyncAnthropic

from config.settings import get_settings
from db.mongo import content_catalog_collection, mood_sessions_collection
from engine.genre_map import canonicalize_genres

# Conversational mood-based recommender. Claude never invents titles — it must
# call search_catalog (which queries our real content_catalog) and then
# present_recommendations with the exact items it chose, so the UI renders real
# cards. Persisted history is user/assistant *text* only; the tool-use loop
# runs fresh each turn, which keeps conversation context without replaying
# thinking/tool blocks across requests.

_SYSTEM_PROMPT = """You are Watchary's mood-based cinema concierge. The user tells you \
how they feel or what they're in the mood for, and you recommend movies, series, or anime \
that fit.

Rules:
- NEVER invent titles or ratings. Use the search_catalog tool to find real candidates, \
then call present_recommendations with the ids of the 2-4 you're recommending.
- Map the user's mood to genres yourself (e.g. heartbroken -> drama, romance; need a laugh \
-> comedy; want a thrill -> thriller, action). Pass natural genre names to search_catalog.
- Keep replies warm, short, and specific about WHY each pick fits their mood. Two or three \
sentences, no long lists in prose — the picks render as cards from present_recommendations.
- If the user refines ("something shorter", "less dark"), search again with adjusted criteria.
- Stay on cinema recommendations. If asked something unrelated, gently redirect."""

_TOOLS = [
    {
        "name": "search_catalog",
        "description": (
            "Search Watchary's catalog for real titles matching genres/type/rating. "
            "Returns candidate items with their ids, titles, ratings, and genres."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "genres": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Genre names to match, e.g. ['Drama', 'Comedy']. Any-match.",
                },
                "cinema_type": {
                    "type": "string",
                    "enum": ["movie", "tv", "anime"],
                    "description": "Optional. Restrict to one cinema type.",
                },
                "min_rating": {
                    "type": "number",
                    "description": "Optional. Minimum normalized rating 0-10.",
                },
            },
            "required": ["genres"],
        },
    },
    {
        "name": "present_recommendations",
        "description": (
            "Present the final picks to the user. Pass the ids of items from "
            "search_catalog results. These render as cards in the app."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "ids": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Item ids (as returned by search_catalog) to recommend.",
                }
            },
            "required": ["ids"],
        },
    },
]


def _item_id(doc: dict) -> str:
    return f"{doc['source']}:{doc['sourceId']}:{doc['cinemaType']}"


def _public(doc: dict) -> dict:
    return {
        "source": doc["source"],
        "sourceId": doc["sourceId"],
        "cinemaType": doc["cinemaType"],
        "title": doc["title"],
        "posterPath": doc.get("posterPath"),
        "year": doc.get("year"),
        "rating": round(doc.get("normalizedRating", 0.0), 1),
        "genres": doc.get("genres", []),
    }


async def _search_catalog(genres: list[str], cinema_type: str | None, min_rating: float | None) -> list[dict]:
    canonical = canonicalize_genres(genres)
    query: dict = {}
    if canonical:
        query["genres"] = {"$in": canonical}
    if cinema_type in ("movie", "tv", "anime"):
        query["cinemaType"] = cinema_type
    if min_rating is not None:
        query["normalizedRating"] = {"$gte": float(min_rating)}
    cursor = content_catalog_collection().find(query).sort("bayesianScore", -1).limit(12)
    return [doc async for doc in cursor]


class MoodLimitError(Exception):
    def __init__(self, kind: str):
        self.kind = kind  # "turns" | "sessions" | "not_configured"


def _day_key(now: datetime | None = None) -> str:
    d = (now or datetime.now(timezone.utc)).date()
    return d.isoformat()


async def _load_or_create_session(user_id: str, session_id: str | None) -> dict:
    coll = mood_sessions_collection()
    settings = get_settings()

    if session_id:
        session = await coll.find_one({"_id": session_id, "userId": user_id})
        if session is not None:
            if session.get("turnCount", 0) >= settings.mood_max_turns_per_session:
                raise MoodLimitError("turns")
            return session

    # New session — enforce per-day cap.
    day = _day_key()
    todays = await coll.count_documents({"userId": user_id, "dayKey": day})
    if todays >= settings.mood_max_sessions_per_day:
        raise MoodLimitError("sessions")

    session = {
        "_id": session_id or uuid.uuid4().hex,
        "userId": user_id,
        "dayKey": day,
        "turnCount": 0,
        "messages": [],
        "createdAt": datetime.now(timezone.utc),
    }
    await coll.insert_one(session)
    return session


async def send_message(user_id: str, session_id: str | None, text: str) -> dict:
    settings = get_settings()
    if not settings.anthropic_api_key:
        raise MoodLimitError("not_configured")

    session = await _load_or_create_session(user_id, session_id)

    # Rebuild conversation from stored text turns, then add this turn's message.
    messages = [{"role": m["role"], "content": m["text"]} for m in session["messages"]]
    messages.append({"role": "user", "content": text})

    client = AsyncAnthropic(api_key=settings.anthropic_api_key)
    presented_ids: list[str] = []
    last_search: dict[str, dict] = {}  # id -> catalog doc, for resolving presented ids

    # Manual tool loop — captures structured tool outputs (which items were
    # presented) and runs async Motor queries, which the tool_runner doesn't expose.
    for _ in range(6):  # bound tool round-trips
        resp = await client.messages.create(
            model=settings.anthropic_model,
            max_tokens=2048,
            system=_SYSTEM_PROMPT,
            thinking={"type": "adaptive"},
            output_config={"effort": "low"},
            tools=_TOOLS,
            messages=messages,
        )

        if resp.stop_reason != "tool_use":
            break

        tool_results = []
        for block in resp.content:
            if block.type != "tool_use":
                continue
            if block.name == "search_catalog":
                docs = await _search_catalog(
                    block.input.get("genres", []),
                    block.input.get("cinema_type"),
                    block.input.get("min_rating"),
                )
                for d in docs:
                    last_search[_item_id(d)] = d
                payload = [{"id": _item_id(d), **_public(d)} for d in docs]
                tool_results.append(
                    {"type": "tool_result", "tool_use_id": block.id, "content": str(payload)}
                )
            elif block.name == "present_recommendations":
                presented_ids = [i for i in block.input.get("ids", []) if i in last_search]
                tool_results.append(
                    {
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": f"Presented {len(presented_ids)} recommendations to the user.",
                    }
                )
            else:
                tool_results.append(
                    {"type": "tool_result", "tool_use_id": block.id, "content": "unknown tool", "is_error": True}
                )

        messages.append({"role": "assistant", "content": resp.content})
        messages.append({"role": "user", "content": tool_results})

    reply = next((b.text for b in resp.content if b.type == "text"), "")
    recommendations = [_public(last_search[i]) for i in presented_ids]

    # Persist only the text turns; increment the turn counter.
    coll = mood_sessions_collection()
    await coll.update_one(
        {"_id": session["_id"]},
        {
            "$push": {
                "messages": {
                    "$each": [
                        {"role": "user", "text": text},
                        {"role": "assistant", "text": reply},
                    ]
                }
            },
            "$inc": {"turnCount": 1},
        },
    )

    new_turn_count = session.get("turnCount", 0) + 1
    return {
        "sessionId": session["_id"],
        "reply": reply,
        "recommendations": recommendations,
        "turnsRemaining": max(0, settings.mood_max_turns_per_session - new_turn_count),
    }
