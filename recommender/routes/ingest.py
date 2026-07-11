from fastapi import APIRouter, Depends

from engine.catalog_ingest import run_ingestion
from routes.deps import require_internal_secret

router = APIRouter(dependencies=[Depends(require_internal_secret)])


@router.post("/internal/ingest/run")
async def trigger_ingest() -> dict:
    return await run_ingestion()
