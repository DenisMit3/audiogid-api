import logging
import datetime
import uuid
from sqlmodel import Session, select
from sqlalchemy.exc import IntegrityError

from ..core.models import EntitlementGrant, Entitlement, AuditLog

logger = logging.getLogger(__name__)

async def grant_entitlement(
    session: Session, 
    source: str, 
    source_ref: str, 
    product_id: str, 
    device_anon_id: str,
    trace_id: str
) -> tuple[EntitlementGrant, bool]:
    """
    Maps SKU -> Entitlement and grants it. Idempotent and race-safe.
    Returns: (grant, is_new) - is_new=False means idempotent hit.
    """
    
    # 1. Resolve SKU to Entitlement
    entitlement = session.exec(select(Entitlement).where(Entitlement.slug == product_id)).first()
    if not entitlement:
        # Fallback mapping for store SKUs
        if "kaliningrad_city" in product_id:
             entitlement = session.exec(select(Entitlement).where(Entitlement.slug == "kaliningrad_city_access")).first()
        
    if not entitlement:
        logger.warning(f"[{trace_id}] Unknown Product ID during grant: {product_id}")
        raise ValueError(f"Unknown Product ID: {product_id}")

    # 2. Try to create grant (race-safe via DB unique constraint)
    grant = EntitlementGrant(
        device_anon_id=device_anon_id,
        entitlement_id=entitlement.id,
        source=source,
        source_ref=source_ref,
        granted_at=datetime.datetime.utcnow()
    )
    
    try:
        session.add(grant)
        session.flush()  # Trigger constraint check before commit
        
        # Success: new grant created
        audit = AuditLog(
            action="ENTITLEMENT_GRANTED",
            target_id=grant.id,
            actor_type=source,
            actor_fingerprint=source_ref[:10],
            trace_id=trace_id
        )
        session.add(audit)
        session.commit()
        session.refresh(grant)
        logger.info(f"[{trace_id}] New grant created: {grant.id}")
        return grant, True
        
    except IntegrityError:
        # Unique constraint violation: grant already exists
        session.rollback()
        
        # Fetch existing grant
        existing = session.exec(select(EntitlementGrant).where(
            EntitlementGrant.source == source,
            EntitlementGrant.source_ref == source_ref
        )).first()
        
        if existing:
            # Audit idempotent hit
            # Optionally log audit here or skip to reduce noise
            return existing, False
        else:
            # Should not happen
            logger.error(f"[{trace_id}] Integrity error but no existing grant found")
            raise ValueError("Grant conflict but no existing record")
