from datetime import datetime
import json
from fastapi import APIRouter, Depends, HTTPException, Header
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

def verify_admin_token(x_admin_token: str = Header(...)):
    if x_admin_token != config.ADMIN_API_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid Admin Token")

class OsmImportRequest(BaseModel):
    city_slug: str
    boundary_ref: str

class HelpersImportRequest(BaseModel):
    city_slug: str

@router.post("/admin/ingestion/osm/enqueue", status_code=202, dependencies=[Depends(verify_admin_token)])
async def enqueue_osm_import(
    req: OsmImportRequest, 
    session: Session = Depends(get_session)
):
    # Idempotency: {type}|{city}|{boundary_ref}|{date}
    date_str = datetime.utcnow().strftime("%Y-%m-%d")
    key = f"osm_import|{req.city_slug}|{req.boundary_ref}|{date_str}"
    
    payload = json.dumps(req.model_dump())
    
    existing = session.exec(select(Job).where(Job.idempotency_key == key)).first()
    if existing:
        return {
            "job_id": existing.id,
            "status": existing.status,
            "idempotency_key": key,
            "message": "Job already exists for today"
        }
        
    job = await enqueue_job(
        job_type="osm_import",
        payload=payload,
        session=session
    )
    
    return {
        "job_id": job.id, 
        "status": job.status,
        "idempotency_key": key
    }

@router.post("/admin/ingestion/helpers/enqueue", status_code=202, dependencies=[Depends(verify_admin_token)])
async def enqueue_helpers_import(
    req: HelpersImportRequest,
    session: Session = Depends(get_session)
):
    # Idempotency: {type}|{city}|{date} (Helpers are city-wide)
    date_str = datetime.utcnow().strftime("%Y-%m-%d")
    key = f"helpers_import|{req.city_slug}|{date_str}"
    
    existing = session.exec(select(Job).where(Job.idempotency_key == key)).first()
    if existing:
        return {"job_id": existing.id, "status": existing.status, "idempotency_key": key}

    job = await enqueue_job(
        job_type="helpers_import",
        payload=json.dumps(req.model_dump()),
        session=session
    )
    
    return {"job_id": job.id, "status": job.status, "idempotency_key": key}
