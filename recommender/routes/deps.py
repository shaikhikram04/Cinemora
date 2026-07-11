from fastapi import Header, HTTPException, status

from config.settings import get_settings


async def require_internal_secret(x_internal_secret: str | None = Header(default=None)) -> None:
    settings = get_settings()
    if not x_internal_secret or x_internal_secret != settings.internal_service_secret:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="invalid internal secret")


async def get_user_id(x_user_id: str | None = Header(default=None)) -> str | None:
    return x_user_id
