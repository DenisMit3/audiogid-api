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
from ..auth.deps import get_current_user, get_current_user_optional
from ..core.models import User, Poi, Tour, PurchaseIntent, Entitlement

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
async def apple_verify(req: AppleVerifyReq, request: Request, session: Session = Depends(get_session), user: Optional[User] = Depends(get_current_user_optional)):
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
            trace_id=trace_id,
            user_id=user.id if user else None
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
async def google_verify(req: GoogleVerifyReq, request: Request, session: Session = Depends(get_session), user: Optional[User] = Depends(get_current_user_optional)):
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
            trace_id=trace_id,
            user_id=user.id if user else None
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
def get_user_entitlements(device_anon_id: str = Query(...), session: Session = Depends(get_session), user: Optional[User] = Depends(get_current_user_optional)):
    
    # Bind to user if present
    query = select(EntitlementGrant).where(EntitlementGrant.revoked_at == None)
    
    if user:
         query = query.where((EntitlementGrant.user_id == user.id) | (EntitlementGrant.device_anon_id == device_anon_id))
    else:
         query = query.where(EntitlementGrant.device_anon_id == device_anon_id)

    grants = session.exec(query).all()
    
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

class BatchPurchaseRequest(BaseModel):
    poi_ids: List[str] = []
    tour_ids: List[str] = []
    device_anon_id: str

class BatchPurchaseResponse(BaseModel):
    product_ids: List[str]
    already_owned: List[str]

@router.post("/billing/batch-purchase")
async def batch_purchase(req: BatchPurchaseRequest, session: Session = Depends(get_session), user: Optional[User] = Depends(get_current_user_optional)):
    """
    Returns list of product_ids (SKUs) to purchase for the given POIs/Tours,
    filtering out items already owned by the user/device.
    """
    # 1. Resolve Ref IDs
    target_refs = []
    # Normalize UUIDs to strings
    for pid in req.poi_ids:
        target_refs.append(str(pid))
    for tid in req.tour_ids:
        target_refs.append(str(tid))
        
    if not target_refs:
        return BatchPurchaseResponse(product_ids=[], already_owned=[])

    # 2. Check Entitlements (What is already owned)
    query = select(EntitlementGrant).where(EntitlementGrant.revoked_at == None)
    
    if user:
        query = query.where((EntitlementGrant.device_anon_id == req.device_anon_id) | (EntitlementGrant.user_id == user.id))
    else:
        query = query.where(EntitlementGrant.device_anon_id == req.device_anon_id)
    
    existing_grants = session.exec(query).all()
    
    # Map grants to refs
    owned_refs = set()
    for grant in existing_grants:
        if grant.entitlement:
             owned_refs.add(grant.entitlement.ref)

    # 3. Find Products for requested items that are NOT owned
    needed_refs = [ref for ref in target_refs if ref not in owned_refs]
    already_owned_refs = [ref for ref in target_refs if ref in owned_refs]
    
    if not needed_refs:
        return BatchPurchaseResponse(product_ids=[], already_owned=already_owned_refs)

    # Fetch Entitlements for needed refs to get product_ids (slugs)
    entitlements = session.exec(select(Entitlement).where(Entitlement.ref.in_(needed_refs))).all()
    
    product_ids = []
    for ent in entitlements:
        if ent.slug: 
            product_ids.append(ent.slug)

    return BatchPurchaseResponse(
        product_ids=product_ids, 
        already_owned=already_owned_refs
    )


