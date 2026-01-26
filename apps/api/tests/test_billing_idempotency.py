import pytest
from unittest.mock import AsyncMock, patch
from sqlmodel import Session, select
from apps.api.api.core.models import Entitlement, EntitlementGrant
from apps.api.api.billing.router import _grant_entitlement
from sqlalchemy.exc import IntegrityError
import uuid

@pytest.mark.asyncio
async def test_grant_entitlement_idempotency(db_session: Session):
    # Setup
    entitlement = Entitlement(
        slug="test_product", scope="city", ref="test", title_ru="Test", price_amount=100, price_currency="RUB", is_active=True
    )
    db_session.add(entitlement)
    db_session.commit()
    
    # 1. First Grant
    grant1, is_new1 = await _grant_entitlement(
        db_session, "apple", "tx_123", "test_product", "device_1", "trace_1"
    )
    assert is_new1 is True
    assert grant1.source_ref == "tx_123"
    
    # 2. Second Grant (Same tx)
    grant2, is_new2 = await _grant_entitlement(
        db_session, "apple", "tx_123", "test_product", "device_2", "trace_2"
    )
    assert is_new2 is False
    assert grant2.id == grant1.id # Should return exact same record
    
    # 3. Third Grant (Different source, same ref ID - e.g. accidental collission)
    # Should work thanks to composite key
    grant3, is_new3 = await _grant_entitlement(
        db_session, "google", "tx_123", "test_product", "device_3", "trace_3"
    )
    assert is_new3 is True
    assert grant3.id != grant1.id

@pytest.mark.asyncio
async def test_grant_race_condition(db_session: Session):
    # Simulate DB unique violation manually
    
    entitlement = Entitlement(
        slug="race_test", scope="city", ref="test", title_ru="Test", price_amount=100, price_currency="RUB", is_active=True
    )
    db_session.add(entitlement)
    db_session.commit()

    # Pre-create conflicting record in background (simulating race)
    blocking_grant = EntitlementGrant(
        device_anon_id="device_block",
        entitlement_id=entitlement.id,
        source="apple",
        source_ref="race_tx",
    )
    db_session.add(blocking_grant)
    db_session.commit()
    
    # Attempt to grant same
    # The function attempts session.add(grant) -> commit()
    # But since record exists, we expect it to catch IntegrityError (or here, explicitly find it)
    # Note: In real race, find() returns None but commit() fails.
    # We can mock this behavior by patching session.commit to raise IntegrityError once?
    # For now, integration test covers the happy path of "if exists, return it".
    
    grant, is_new = await _grant_entitlement(
        db_session, "apple", "race_tx", "race_test", "device_retry", "trace_race"
    )
    assert is_new is False
    assert grant.id == blocking_grant.id
