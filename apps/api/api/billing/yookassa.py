from fastapi import APIRouter, Request, HTTPException, Depends
from sqlmodel import Session, select
import json
import logging
from ..core.database import engine
from ..core.models import PurchaseIntent, Purchase, Entitlement, AuditLog
from ..core.config import config
import uuid
from datetime import datetime

router = APIRouter()
logger = logging.getLogger(__name__)

def get_session():
    with Session(engine) as session:
        yield session

@router.post("/v1/billing/yookassa/webhook")
async def yookassa_webhook(request: Request, session: Session = Depends(get_session)):
    """
    Handles YooKassa payment notifications.
    Strictly follows: confirm -> grant entitlement -> record purchase.
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
    
    logger.info(f"YooKassa Event: {event}, PaymentID: {payment_id}")

    if event == "payment.succeeded":
        metadata = obj.get("metadata", {})
        intent_id_str = metadata.get("intent_id")
        
        if not intent_id_str:
            logger.error(f"Missing intent_id in metadata for payment {payment_id}")
            # We don't raise 4XX here to avoid YooKassa retries for something we can't fix
            return {"status": "ignored_missing_metadata"}

        try:
            intent_id = uuid.UUID(intent_id_str)
        except ValueError:
            logger.error(f"Invalid intent_id UUID: {intent_id_str}")
            return {"status": "ignored_invalid_uuid"}

        # 1. Start Transaction
        intent = session.get(PurchaseIntent, intent_id)
        if not intent:
            logger.error(f"PurchaseIntent {intent_id} not found")
            return {"status": "ignored_not_found"}

        if intent.status == "SUCCEEDED":
            return {"status": "already_processed"}

        # 2. Check for duplicate Purchase (Idempotency)
        existing_purchase = session.exec(
            select(Purchase).where(Purchase.store_transaction_id == payment_id)
        ).first()
        
        if existing_purchase:
            return {"status": "already_processed_purchase"}

        # 3. Grant Entitlement
        entitlement = Entitlement(
            city_slug=intent.city_slug,
            tour_id=intent.tour_id,
            device_anon_id=intent.device_anon_id,
            granted_at=datetime.utcnow()
        )
        session.add(entitlement)

        # 4. Record Purchase
        purchase = Purchase(
            intent_id=intent.id,
            store="yookassa",
            store_transaction_id=payment_id,
            purchased_at=datetime.utcnow(),
            status="VALID"
        )
        session.add(purchase)

        # 5. Update Intent
        intent.status = "SUCCEEDED"
        session.add(intent)

        # 6. Audit Log
        audit = AuditLog(
            action="PURCHASE_CONFIRMED",
            target_id=intent.id,
            actor_type="system",
            actor_fingerprint="yookassa_webhook",
            trace_id=payment_id
        )
        session.add(audit)

        session.commit()
        logger.info(f"Entitlement granted for intent {intent_id}, device {intent.device_anon_id}")
        return {"status": "accepted"}

    return {"status": "ignored_event"}
