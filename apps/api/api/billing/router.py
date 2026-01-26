from fastapi import APIRouter, Depends, HTTPException, Header, Query, Request
from sqlmodel import Session, select
from typing import Dict, Any, List
from pydantic import BaseModel
import logging
import datetime
import uuid

from ..core.database import engine
from ..core.models import EntitlementGrant, Entitlement, AuditLog
from ..core.config import config
from .apple import verify_apple_receipt
from .google import verify_google_purchase

logger = logging.getLogger(__name__)
router = APIRouter()

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

class EntitlementGrantRead(BaseModel):
    id: uuid.UUID
    entitlement_slug: str
    scope: str
    ref: str
    granted_at: datetime.datetime
    expires_at: datetime.datetime | None
    is_active: bool

# --- Helper Logic ---

async def _grant_entitlement(
    session: Session, 
    source: str, 
    source_ref: str, 
    product_id: str, 
    device_anon_id: str,
    trace_id: str
) -> EntitlementGrant:
    """
    Maps SKU -> Entitlement and grants it. Idempotent.
    """
    
    # 1. Resolve SKU to Entitlement
    # MVP: Simple mapping convention or DB lookup
    # Assumption: product_id MATCHES entitlement slug for now, or we have a map.
    # We will try to find Entitlement by slug == product_id.
    
    entitlement = session.exec(select(Entitlement).where(Entitlement.slug == product_id)).first()
    if not entitlement:
        # Fallback: maybe internal map if stores use different IDs than our internal slugs
        # e.g. "com.audiogid.kaliningrad.full" -> "kaliningrad_city_access"
        # For Day 1, we assume 1:1 or manual map here
        if "kaliningrad_city" in product_id:
             entitlement = session.exec(select(Entitlement).where(Entitlement.slug == "kaliningrad_city_access")).first()
        
    if not entitlement:
        logger.error(f"[{trace_id}] Unknown Product ID: {product_id}")
        raise ValueError(f"Unknown Product ID: {product_id}")

    # 2. Check Idempotency (Existing grant for this transaction)
    existing = session.exec(select(EntitlementGrant).where(
        EntitlementGrant.source == source,
        EntitlementGrant.source_ref == source_ref
    )).first()
    
    if existing:
        logger.info(f"[{trace_id}] Grant already exists: {existing.id}")
        return existing
        
    # 3. Create Grant
    grant = EntitlementGrant(
        device_anon_id=device_anon_id,
        entitlement_id=entitlement.id,
        source=source,
        source_ref=source_ref,
        granted_at=datetime.datetime.utcnow()
    )
    session.add(grant)
    
    # 4. Audit Log
    audit = AuditLog(
        action="ENTITLEMENT_GRANTED",
        target_id=grant.id,
        actor_type=source,
        actor_fingerprint=source_ref[:10], # partial ref
        trace_id=trace_id
    )
    session.add(audit)
    
    session.commit()
    session.refresh(grant)
    return grant


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
        grant = await _grant_entitlement(
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
        grant = await _grant_entitlement(
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
