from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from engine.mood_chat import MoodLimitError, send_message
from routes.deps import get_user_id, require_internal_secret

router = APIRouter(dependencies=[Depends(require_internal_secret)])


class MoodMessageBody(BaseModel):
    sessionId: str | None = None
    message: str


_LIMIT_STATUS = {
    "turns": (status.HTTP_429_TOO_MANY_REQUESTS, "This mood chat has reached its message limit. Start a new one."),
    "sessions": (status.HTTP_429_TOO_MANY_REQUESTS, "You've used all your mood chats for today. Try again tomorrow."),
    "not_configured": (status.HTTP_503_SERVICE_UNAVAILABLE, "Mood chat isn't available right now."),
    "busy": (status.HTTP_429_TOO_MANY_REQUESTS, "Mood chat is busy right now. Try again in a moment."),
}


@router.post("/internal/mood/message")
async def mood_message(body: MoodMessageBody, user_id: str | None = Depends(get_user_id)) -> dict:
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="missing user")
    if not body.message.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="empty message")
    try:
        return await send_message(user_id, body.sessionId, body.message.strip())
    except MoodLimitError as e:
        code, detail = _LIMIT_STATUS.get(e.kind, (status.HTTP_400_BAD_REQUEST, "Mood chat error"))
        raise HTTPException(status_code=code, detail=detail)
