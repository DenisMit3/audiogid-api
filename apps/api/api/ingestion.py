from datetime import datetime
import json
import uuid
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Header, Query
from sqlmodel import Session, select
from pydantic import BaseModel

from .core.database import engine
from .core.models import Job, IngestionRun, AuditLog
from .core.async_utils import enqueue_job
from .core.config import config

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

def verify_admin_token(x_admin_token: str = Header(...)):
    if x_admin_token != config.ADMIN_API_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid Admin Token")

class OsmImportRequest(BaseModel):
    city_slug: str
    # boundary_ref removed (using internal config)

class HelpersImportRequest(BaseModel):
    city_slug: str

@router.post("/admin/ingestion/osm/enqueue", status_code=202, dependencies=[Depends(verify_admin_token)])
async def enqueue_osm_import(
    req: OsmImportRequest, 
    session: Session = Depends(get_session)
):
    if not config.QSTASH_TOKEN:
        raise HTTPException(status_code=503, detail="Ingestion service not configured (Missing QSTASH_TOKEN)")

    date_str = datetime.utcnow().strftime("%Y-%m-%d")
    date_str = datetime.utcnow().strftime("%Y-%m-%d-%H-%M")
    key = f"osm_import|{req.city_slug}|{date_str}"
    
    payload_dict = req.model_dump() if hasattr(req, "model_dump") else req.dict()
    payload = json.dumps(payload_dict)
    
    existing = session.exec(select(Job).where(Job.idempotency_key == key)).first()
    if existing:
        return {
            "job_id": existing.id,
            "status": existing.status,
            "idempotency_key": key,
            "message": "Job already exists for today"
        }
        
    try:
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Enqueue Failed: {str(e)}")

@router.post("/admin/ingestion/helpers/enqueue", status_code=202, dependencies=[Depends(verify_admin_token)])
async def enqueue_helpers_import(
    req: HelpersImportRequest,
    session: Session = Depends(get_session)
):
    if not config.QSTASH_TOKEN:
        raise HTTPException(status_code=503, detail="Ingestion service not configured (Missing QSTASH_TOKEN)")

    date_str = datetime.utcnow().strftime("%Y-%m-%d")
    key = f"helpers_import|{req.city_slug}|{date_str}"
    
    existing = session.exec(select(Job).where(Job.idempotency_key == key)).first()
    if existing:
        return {"job_id": existing.id, "status": existing.status, "idempotency_key": key}

    payload_dict = req.model_dump() if hasattr(req, "model_dump") else req.dict()
    job = await enqueue_job(
        job_type="helpers_import",
        payload=json.dumps(payload_dict),
        session=session
    )
    return {"job_id": job.id, "status": job.status, "idempotency_key": key}

# Define Response Model
class IngestionRunRead(BaseModel):
    id: uuid.UUID
    city_slug: str
    started_at: datetime
    finished_at: Optional[datetime] = None
    status: str
    stats_json: Optional[str] = None
    last_error: Optional[str] = None
    # Enrichment fields
    trace_id: Optional[str] = None
    last_audit_action: Optional[str] = None
    last_audit_at: Optional[datetime] = None

@router.get("/admin/ingestion/runs", response_model=List[IngestionRunRead], dependencies=[Depends(verify_admin_token)])
def get_ingestion_runs(
    city: str = Query(None),
    session: Session = Depends(get_session)
):
    query = select(IngestionRun).order_by(IngestionRun.started_at.desc()).limit(20)
    if city:
        query = query.where(IngestionRun.city_slug == city)
        
    runs = session.exec(query).all()
    
    # Enrich with Trace ID from Audit Logs (Batch fetch)
    if not runs:
        return []
        
    run_ids = [r.id for r in runs]
    
    # P0: Fetch all ingestion audits related to these runs, ORDERED BY timestamp DESC
    # Restrict to known Ingestion Actions (Whitelist)
    ingestion_actions = ["OSM_IMPORT_SUCCESS", "OSM_IMPORT_FAILED", "HELPERS_IMPORT_SUCCESS", "HELPERS_IMPORT_FAILED"]
    
    stmt = (
        select(AuditLog)
        .where(AuditLog.target_id.in_(run_ids))
        .where(AuditLog.action.in_(ingestion_actions))
        .order_by(AuditLog.timestamp.desc())
    )
    audits = session.exec(stmt).all()
    
    # Map run_id -> audit info (Latest Only)
    audit_map = {}
    for a in audits:
        # Since we ordered DESC, the first time we see a target_id, it is the latest.
        if a.target_id not in audit_map:
             audit_map[a.target_id] = {
                 "trace_id": a.trace_id, 
                 "action": a.action, 
                 "created_at": a.timestamp
             }
    
    # Construct response objects
    result = []
    for r in runs:
        meta = audit_map.get(r.id, {})
        # Map fields manually or via simple dict
        result.append(IngestionRunRead(
            id=r.id,
            city_slug=r.city_slug,
            started_at=r.started_at,
            finished_at=r.finished_at,
            status=r.status,
            stats_json=r.stats_json,
            last_error=r.last_error,
            trace_id=meta.get("trace_id"),
            last_audit_action=meta.get("action"),
            last_audit_at=meta.get("created_at")
        ))
        
    return result

class PreviewGenRequest(BaseModel):
    poi_id: str

@router.post("/admin/ingestion/preview/enqueue", status_code=202, dependencies=[Depends(verify_admin_token)])
async def enqueue_preview_gen(
    req: PreviewGenRequest,
    session: Session = Depends(get_session)
):
    if not config.QSTASH_TOKEN:
        raise HTTPException(status_code=503, detail="Ingestion service not configured (Missing QSTASH_TOKEN)")

    key = f"preview|{req.poi_id}"
    
    # Allow retries if previous failed (don't block strictly on key existence if failed)
    # For simplicity, we just create a new job if not pending
    # existing = session.exec(select(Job).where(Job.idempotency_key == key)).first()
    # if existing and existing.status in ["PENDING", "RUNNING"]: ...
    
    job = await enqueue_job(
        job_type="generate_preview",
        payload=json.dumps({"poi_id": req.poi_id}),
        session=session
    )
    return {"job_id": job.id, "status": job.status, "key": key}
