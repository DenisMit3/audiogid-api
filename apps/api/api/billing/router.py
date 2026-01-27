from fastapi import APIRouter, Depends, HTTPException, Header, Query, Request
from sqlmodel import Session, select
from typing import Dict, Any, List, Optional
from pydantic import BaseModel
import logging
import datetime
import uuid
import json
from qstash import QStash

from ..core.database import engine
from ..core.models import EntitlementGrant, Entitlement, AuditLog, Job
from ..core.config import config
from .apple import verify_apple_receipt
from .google import verify_google_purchase
from .service import grant_entitlement as _grant_entitlement

logger = logging.getLogger(__name__)
router = APIRouter()

qstash = QStash(token=config.QSTASH_TOKEN)

def get_session():
    with Session(engine) as session:
        yield session

# --- DTOs ---

class AppleVerifyReq(BaseModel):
    receipt: str
    product_id: str
    idempotency_key: str
    device_anon_id: str

class GoogleVerifyReq(BaseModel):
    package_name: str
    product_id: str
    purchase_token: str
    idempotency_key: str
    device_anon_id: str

class GooglePurchaseItem(BaseModel):
    package_name: str | None = None
    product_id: str | None = None
    purchase_token: str


class EntitlementGrantRead(BaseModel):
    id: uuid.UUID
    entitlement_slug: str
    scope: str
    ref: str
    granted_at: datetime.datetime
    expires_at: datetime.datetime | None
    is_active: bool

class RestoreRequest(BaseModel):
    platform: str = "auto"
    idempotency_key: str
    device_anon_id: str
    apple_receipt: str | None = None
    google_purchases: List[GooglePurchaseItem] | None = None # PR-40 Batch
    google_purchase_token: str | None = None # Legacy
    product_id: str | None = None # Legacy
    package_name: str | None = None # Legacy

# --- Helper Logic ---
# (Moved to service.py)

# --- Endpoints ---

@router.post("/billing/apple/verify")
async def apple_verify(req: AppleVerifyReq, request: Request, session: Session = Depends(get_session)):
    trace_id = request.headers.get("x-request-id", str(uuid.uuid4()))
    
    # 1. Verify
    try:
        result = await verify_apple_receipt(req.receipt, req.product_id)
    except Exception as e:
        logger.error(f"[{trace_id}] Apple Verify Exception: {e}")
        return {"verified": False, "granted": False, "trace_id": trace_id, "error": "Provider Error"}
        
    if not result.get("verified"):
        # Audit failure
        session.add(AuditLog(action="RECEIPT_VERIFY_FAILED", target_id=uuid.uuid4(), actor_type="apple", actor_fingerprint="fail", trace_id=trace_id))
        session.commit()
        return {"verified": False, "granted": False, "trace_id": trace_id, "error": result.get("error")}
        
    # 2. Grant
    try:
        grant, is_new = await _grant_entitlement(
            session, 
            source="apple", 
            source_ref=result["transaction_id"], 
            product_id=req.product_id, 
            device_anon_id=req.device_anon_id,
            trace_id=trace_id
        )
        return {
            "verified": True, 
            "granted": True, 
            "entitlement_grant_id": str(grant.id),
            "order_id": result.get("transaction_id"),
            "trace_id": trace_id
        }
    except ValueError as e:
         return {"verified": True, "granted": False, "trace_id": trace_id, "error": str(e)}

@router.post("/billing/google/verify")
async def google_verify(req: GoogleVerifyReq, request: Request, session: Session = Depends(get_session)):
    trace_id = request.headers.get("x-request-id", str(uuid.uuid4()))
    
    try:
        result = await verify_google_purchase(req.package_name, req.product_id, req.purchase_token)
    except Exception as e:
        logger.error(f"[{trace_id}] Google Verify Exception: {e}")
        return {"verified": False, "granted": False, "trace_id": trace_id, "error": "Provider Error"}
        
    if not result.get("verified"):
        session.add(AuditLog(action="RECEIPT_VERIFY_FAILED", target_id=uuid.uuid4(), actor_type="google", actor_fingerprint="fail", trace_id=trace_id))
        session.commit()
        return {"verified": False, "granted": False, "trace_id": trace_id, "error": result.get("error")}
        
    try:
        grant, is_new = await _grant_entitlement(
            session,
            source="google",
            source_ref=result["transaction_id"],
            product_id=req.product_id,
            device_anon_id=req.device_anon_id,
            trace_id=trace_id
        )
        return {
            "verified": True, 
            "granted": True, 
            "entitlement_grant_id": str(grant.id),
            "order_id": result.get("transaction_id"),
            "trace_id": trace_id
        }
    except ValueError as e:
        return {"verified": True, "granted": False, "trace_id": trace_id, "error": str(e)}

@router.get("/billing/entitlements")
def get_user_entitlements(device_anon_id: str = Query(...), session: Session = Depends(get_session)):
    grants = session.exec(select(EntitlementGrant).where(
        EntitlementGrant.device_anon_id == device_anon_id,
        EntitlementGrant.revoked_at == None
    )).all()
    
    res = []
    for g in grants:
        if g.entitlement:
            res.append({
                "id": g.id,
                "entitlement_slug": g.entitlement.slug,
                "scope": g.entitlement.scope,
                "ref": g.entitlement.ref,
                "granted_at": g.granted_at,
                "expires_at": None, # Future: subscription support
                "is_active": True
            })
    return res

# --- Restore ---

@router.post("/billing/restore")
async def restore_purchases(req: RestoreRequest, request: Request, session: Session = Depends(get_session)):
    trace_id = request.headers.get("x-request-id", str(uuid.uuid4()))
    
    # Validation (PR-40 Fail Fast)
    if req.platform == "google":
        has_batch = bool(req.google_purchases)
        has_legacy = bool(req.google_purchase_token)
        if not has_batch and not has_legacy:
             raise HTTPException(status_code=400, detail="platform=google requires google_purchases (batch) or google_purchase_token")
    elif req.platform == "apple":
        if not req.apple_receipt:
             raise HTTPException(status_code=400, detail="platform=apple requires apple_receipt")

    # Check Idempotency (if job with this idempotency key already exists)
    existing_job = session.exec(select(Job).where(Job.idempotency_key == req.idempotency_key)).first()
    
    job_id = str(uuid.uuid4())
    
    if existing_job:
        job_id = str(existing_job.id)
        # If job failed, we might want to allow retry?
        # Standard idempotency says return same processing resource.
        # Check if we should re-enqueue? No, let's keep simple.
        return {"job_id": job_id, "status": existing_job.status, "trace_id": trace_id}
        
    # Create Job
    # Create and Enqueue Job via Utility (handles QStash URL resolution correctly)
    try:
        from ..core.async_utils import enqueue_job
        job = await enqueue_job(
            job_type="billing_restore",
            payload=json.dumps(req.model_dump()),
            session=session,
            idempotency_key=req.idempotency_key
        )
    except Exception as e:
        logger.error(f"Detailed Restore Enqueue Error: {e}")
        # enqueue_job logs details before raising.
        raise HTTPException(status_code=500, detail=f"Failed to enqueue restore job: {e}")
        
    return {"job_id": str(job.id), "status": "PENDING", "trace_id": trace_id}

@router.get("/billing/restore/{job_id}")
def get_restore_status(job_id: uuid.UUID, session: Session = Depends(get_session)):
    job = session.get(Job, job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
        
    res = {
        "id": job.id,
        "status": job.status,
        "result": None,
        "last_error": job.error,
        "trace_id": job.idempotency_key or "unknown"
    }
    
    if job.result:
        try:
             res["result"] = json.loads(job.result)
        except:
             res["result"] = job.result
             
    return res
