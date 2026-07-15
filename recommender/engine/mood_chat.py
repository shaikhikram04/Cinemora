import uuid
from datetime import datetime, timezone
from functools import lru_cache

from google import genai
from google.genai import errors, types

from config.settings import get_settings
from db.mongo import content_catalog_collection, mood_sessions_collection
from engine.genre_map import canonicalize_genres
from engine.taste_vector import excluded_catalog_keys

# Conversational mood-based recommender. The model never invents titles — it must
# call search_catalog (which queries our real content_catalog) and then
# present_recommendations with the exact items it chose, so the UI renders real
# cards. Persisted history is user/assistant *text* only; the tool-use loop
# runs fresh each turn, which keeps conversation context without replaying
# tool-call parts across requests.

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
    types.Tool(
        function_declarations=[
            types.FunctionDeclaration(
                name="search_catalog",
                description=(
                    "Search Watchary's catalog for real titles matching genres/type/rating. "
                    "Returns candidate items with their ids, titles, ratings, and genres."
                ),
                parameters_json_schema={
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
            ),
            types.FunctionDeclaration(
                name="present_recommendations",
                description=(
                    "Present the final picks to the user. Pass the ids of items from "
                    "search_catalog results. These render as cards in the app."
                ),
                parameters_json_schema={
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
            ),
        ]
    )
]


@lru_cache
def _client() -> genai.Client:
    return genai.Client(
        api_key=get_settings().gemini_api_key,
        # The SDK does NOT retry unless retry_options is set (it defaults to
        # stop_after_attempt(1)). Free-tier Gemini returns transient 503s under
        # load, so retry those. 429 is deliberately excluded: it means the
        # per-minute quota is spent, and retrying seconds later just fails again
        # and stalls the request — that one goes straight to "busy".
        http_options=types.HttpOptions(
            retry_options=types.HttpRetryOptions(
                attempts=3,
                initial_delay=1.0,
                max_delay=8.0,
                http_status_codes=[408, 500, 502, 503, 504],
            )
        ),
    )


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


async def _search_catalog(
    genres: list[str],
    cinema_type: str | None,
    min_rating: float | None,
    excluded: set[tuple[str, int, str]],
) -> list[dict]:
    canonical = canonicalize_genres(genres)
    query: dict = {}
    if canonical:
        query["genres"] = {"$in": canonical}
    if cinema_type in ("movie", "tv", "anime"):
        query["cinemaType"] = cinema_type
    if min_rating is not None:
        query["normalizedRating"] = {"$gte": float(min_rating)}
    if excluded:
        # Anything already in the library — watched or merely watchlisted — is
        # filtered out of the candidate pool rather than being listed in the
        # prompt: the model can only present ids search_catalog handed it, so
        # excluding here is enforcement, not a request it could ignore.
        query["$nor"] = [
            {"source": s, "sourceId": sid, "cinemaType": ct} for (s, sid, ct) in excluded
        ]
    cursor = content_catalog_collection().find(query).sort("bayesianScore", -1).limit(12)
    return [doc async for doc in cursor]


class MoodLimitError(Exception):
    def __init__(self, kind: str):
        self.kind = kind  # "turns" | "sessions" | "not_configured" | "busy"


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

    # Deliberately NOT written yet. send_message upserts it only after the model
    # turn succeeds — otherwise a transient upstream 503 persists an empty
    # session and silently burns one of the user's 2 daily sessions.
    return {
        "_id": session_id or uuid.uuid4().hex,
        "userId": user_id,
        "dayKey": day,
        "turnCount": 0,
        "messages": [],
        "createdAt": datetime.now(timezone.utc),
    }


def _reply_text(response: types.GenerateContentResponse) -> str:
    if not response.candidates:
        return ""
    parts = response.candidates[0].content.parts or []
    return "".join(p.text for p in parts if p.text).strip()


async def send_message(user_id: str, session_id: str | None, text: str) -> dict:
    settings = get_settings()
    if not settings.gemini_api_key:
        raise MoodLimitError("not_configured")

    session = await _load_or_create_session(user_id, session_id)

    # Rebuild conversation from stored text turns, then add this turn's message.
    # Stored roles are user/assistant; Gemini calls the assistant side "model".
    contents: list[types.Content] = [
        types.Content(
            role="model" if m["role"] == "assistant" else "user",
            parts=[types.Part.from_text(text=m["text"])],
        )
        for m in session["messages"]
    ]
    contents.append(types.Content(role="user", parts=[types.Part.from_text(text=text)]))

    config = types.GenerateContentConfig(
        system_instruction=_SYSTEM_PROMPT,
        tools=_TOOLS,
        automatic_function_calling=types.AutomaticFunctionCallingConfig(disable=True),
    )

    # Fetched once per turn, not per tool call — the model can search several
    # times in one turn as it refines.
    excluded = await excluded_catalog_keys(user_id)

    presented_ids: list[str] = []
    last_search: dict[str, dict] = {}  # id -> catalog doc, for resolving presented ids
    reply_chunks: list[str] = []
    model = settings.gemini_model

    async def _generate() -> types.GenerateContentResponse:
        """Primary model, cascading to a lighter one when it won't serve us.

        Two things knock the primary out, and the free tier meters BOTH per
        model (quota id `...PerProjectPerModel`), so the fallback has its own
        separate budget in each case:
          - 429: the primary's daily quota is spent. It's small — gemini-3.5-flash
            allows ~20 requests/day, i.e. only a handful of chat turns.
          - 5xx: the primary is shedding free-tier load, which can persist for
            minutes, not seconds.
        Once switched we stay switched for the rest of the turn, so the remaining
        tool round-trips don't each re-pay the failed attempt.
        """
        nonlocal model
        try:
            return await _client().aio.models.generate_content(
                model=model, contents=contents, config=config
            )
        except errors.APIError as e:
            exhausted_or_down = e.code == 429 or e.code >= 500
            if (
                not exhausted_or_down
                or not settings.gemini_fallback_model
                or model == settings.gemini_fallback_model
            ):
                raise
            model = settings.gemini_fallback_model
            return await _client().aio.models.generate_content(
                model=model, contents=contents, config=config
            )

    # Manual tool loop — the SDK's automatic function calling can't run our async
    # Motor queries, and we need the structured tool inputs (which items were
    # presented) rather than just the final text.
    try:
        for _ in range(6):  # bound tool round-trips
            response = await _generate()

            # Gemini usually emits the substance of its reply in the SAME
            # response as the present_recommendations call, then only a short
            # sign-off (or nothing) afterwards. Reading just the final response
            # therefore drops the actual message — collect text from every
            # round-trip of the turn.
            chunk = _reply_text(response)
            if chunk:
                reply_chunks.append(chunk)

            calls = response.function_calls or []
            if not calls:
                break

            contents.append(response.candidates[0].content)

            result_parts = []
            for call in calls:
                args = call.args or {}
                if call.name == "search_catalog":
                    docs = await _search_catalog(
                        args.get("genres", []),
                        args.get("cinema_type"),
                        args.get("min_rating"),
                        excluded,
                    )
                    for d in docs:
                        last_search[_item_id(d)] = d
                    payload = {"items": [{"id": _item_id(d), **_public(d)} for d in docs]}
                elif call.name == "present_recommendations":
                    presented_ids = [i for i in args.get("ids", []) if i in last_search]
                    payload = {"status": f"Presented {len(presented_ids)} recommendations to the user."}
                else:
                    payload = {"error": "unknown tool"}
                result_parts.append(
                    types.Part.from_function_response(name=call.name, response=payload)
                )

            contents.append(types.Content(role="tool", parts=result_parts))
    except errors.APIError as e:
        # 429 = free-tier's ~10 req/min ceiling, tripped long before the
        # per-user caps above. 5xx = Gemini overloaded (common on the free tier;
        # already retried by the client's retry_options before landing here).
        # Both are transient and the user's move is the same: wait, retry. A 4xx
        # that isn't 429 is our bug (bad schema, bad key) — let it 500 loudly.
        if e.code == 429 or e.code >= 500:
            raise MoodLimitError("busy") from e
        raise

    reply = " ".join(reply_chunks).strip()
    recommendations = [_public(last_search[i]) for i in presented_ids]

    # Persist only the text turns; increment the turn counter. Upsert because a
    # brand-new session is first written here, on success (see
    # _load_or_create_session) — $setOnInsert is a no-op for an existing one.
    coll = mood_sessions_collection()
    await coll.update_one(
        {"_id": session["_id"]},
        {
            "$setOnInsert": {
                "userId": user_id,
                "dayKey": session["dayKey"],
                "createdAt": session["createdAt"],
            },
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
        upsert=True,
    )

    new_turn_count = session.get("turnCount", 0) + 1
    return {
        "sessionId": session["_id"],
        "reply": reply,
        "recommendations": recommendations,
        "turnsRemaining": max(0, settings.mood_max_turns_per_session - new_turn_count),
    }
