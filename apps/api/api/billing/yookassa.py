from fastapi import APIRouter, Request, HTTPException, Depends, Security
from fastapi.security.api_key import APIKeyHeader
from sqlmodel import Session, select
import json
import logging
import hmac
import hashlib
from sqlalchemy.exc import IntegrityError
from ..core.database import engine
from ..core.models import PurchaseIntent, Purchase, Entitlement, EntitlementGrant, AuditLog
from ..core.config import config
import uuid
from datetime import datetime

router = APIRouter()
logger = logging.getLogger(__name__)

# Security Header for Authenticity Verification
WEBHOOK_KEY_NAME = "X-Yookassa-Signature" # or standard Authorization
webhook_key_header = APIKeyHeader(name=WEBHOOK_KEY_NAME, auto_error=False)

def get_session():
    with Session(engine) as session:
        yield session

async def verify_webhook_authenticity(key: str = Security(webhook_key_header)):
    """
    Verified authenticity using YOOKASSA_WEBHOOK_SECRET.
    Fail-fast if secret is missing in environment.
    """
    if not config.YOOKASSA_WEBHOOK_SECRET:
         logger.error("CRITICAL: YOOKASSA_WEBHOOK_SECRET is not configured. Webhooks disabled.")
         raise HTTPException(status_code=500, detail="Configuration Error")
         
    if key != config.YOOKASSA_WEBHOOK_SECRET:
        logger.warning(f"Unauthorized webhook attempt with key: {key}")
        raise HTTPException(status_code=401, detail="Unauthorized")
    return True

@router.post("/v1/billing/yookassa/webhook")
async def yookassa_webhook(
    request: Request, 
    session: Session = Depends(get_session),
    authenticated: bool = Depends(verify_webhook_authenticity)
):
    """
    Handles YooKassa payment notifications.
    Strictly follows: confirm -> grant entitlement_grant -> record purchase.
    Idempotency: Enforced at DB level by source_ref (payment_id).
    """
    try:
        body = await request.body()
        data = json.loads(body)
    except Exception as e:
        logger.error(f"Webhook parse error: {e}")
        raise HTTPException(status_code=400, detail="Invalid JSON")

    event = data.get("event")
    obj = data.get("object", {})
    payment_id = obj.get("id")
    
    # Structured JSON log (simplified for MVP)
    log_extra = {"payment_id": payment_id, "event": event}
    logger.info(f"YooKassa Webhook Received", extra=log_extra)

    if event == "payment.succeeded":
        metadata = obj.get("metadata", {})
        intent_id_str = metadata.get("intent_id")
        
        if not intent_id_str:
            logger.error("Missing intent_id in metadata", extra=log_extra)
            return {"status": "ignored_missing_metadata"}

        try:
            intent_id = uuid.UUID(intent_id_str)
        except ValueError:
            return {"status": "ignored_invalid_uuid"}

        intent = session.get(PurchaseIntent, intent_id)
        if not intent:
            return {"status": "ignored_not_found"}

        if intent.status == "SUCCEEDED":
            return {"status": "already_processed"}

        # Atomic Operation: Purchase + EntitlementGrant + Intent Update
        try:
            # 1. Map to Entitlement SKU
            # We assume a naming convention or a lookup. 
            # For MVP, we look for an entitlement that matches the tour_id or city_slug
            sku_ref = str(intent.tour_id)
            entitlement = session.exec(select(Entitlement).where(Entitlement.ref == sku_ref)).first()
            
            if not entitlement:
                logger.error(f"No Entitlement SKU found for ref {sku_ref}")
                return {"status": "error_sku_missing"}

            # 2. Grant Access
            grant = EntitlementGrant(
                device_anon_id=intent.device_anon_id,
                entitlement_id=entitlement.id,
                source="yookassa",
                source_ref=payment_id, # DB UNIQUE constraint
                granted_at=datetime.utcnow()
            )
            session.add(grant)

            # 3. Record Purchase
            purchase = Purchase(
                intent_id=intent.id,
                store="yookassa",
                store_transaction_id=payment_id,
                purchased_at=datetime.utcnow(),
                status="VALID"
            )
            session.add(purchase)

            # 4. Update Intent
            intent.status = "SUCCEEDED"
            session.add(intent)

            # 5. Audit
            audit = AuditLog(
                action="ENTITLEMENT_GRANTED",
                target_id=grant.id,
                actor_type="system",
                actor_fingerprint="yookassa_webhook",
                trace_id=payment_id
            )
            session.add(audit)

            session.commit()
            logger.info("EntitlementGrant successful", extra={"grant_id": str(grant.id), **log_extra})
            return {"status": "accepted"}

        except IntegrityError:
            session.rollback()
            logger.warning("Duplicate webhook transaction ignored (Idempotency)", extra=log_extra)
            return {"status": "already_processed_idempotent"}
        except Exception as e:
            session.rollback()
            logger.exception("Failed to process payment success", extra=log_extra)
            raise HTTPException(status_code=500, detail="Internal Processing Error")

    return {"status": "ignored_event"}
