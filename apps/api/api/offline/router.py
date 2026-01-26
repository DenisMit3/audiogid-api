from datetime import datetime
import json
import uuid
import hashlib
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, Request
from sqlmodel import Session, select
from pydantic import BaseModel

from ..core.database import engine
from ..core.models import Job
from ..core.async_utils import enqueue_job
from ..core.config import config

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

# --- Request/Response Models ---

class BuildBundleRequest(BaseModel):
    city_slug: str
    idempotency_key: str
    type: str = "full_city"

class OfflineJobRead(BaseModel):
    id: uuid.UUID
    status: str
    result: Optional[dict] = None
    last_error: Optional[str] = None
    
# --- Endpoints ---

@router.post("/offline/bundles:build", status_code=202)
async def build_offline_bundle(
    req: BuildBundleRequest,
    session: Session = Depends(get_session)
):
    if not config.QSTASH_TOKEN:
        raise HTTPException(status_code=503, detail="Offline service not configured (Missing QSTASH_TOKEN)")
        
    # Idempotency check
    key = f"offline_bundle|{req.city_slug}|{req.type}|{req.idempotency_key}"
    
    existing = session.exec(select(Job).where(Job.idempotency_key == key)).first()
    if existing:
        return {
            "job_id": existing.id,
            "status": existing.status,
            "message": "Job already exists"
        }

    # Create Job
    payload = json.dumps({
        "city_slug": req.city_slug,
        "bundle_type": req.type,
        "tenant": "default", # Placeholder for future multitenancy
        "trace_id": str(uuid.uuid4()) # Initiate trace
    })
    
    try:
        job = await enqueue_job(
            job_type="build_offline_bundle",
            payload=payload,
            session=session,
            idempotency_key=key
        )
        return {
            "job_id": job.id,
            "status": job.status
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Enqueue Failed: {str(e)}")

@router.get("/offline/bundles/{job_id}", response_model=OfflineJobRead)
def get_offline_bundle_status(
    job_id: uuid.UUID,
    session: Session = Depends(get_session)
):
    job = session.get(Job, job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
        
    # Map Job generic fields to specific OfflineJobRead
    result_data = None
    if job.result:
        try:
            result_data = json.loads(job.result)
        except:
            pass
            
    return OfflineJobRead(
        id=job.id,
        status=job.status,
        result=result_data,
        last_error=job.error
    )
