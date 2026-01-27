import pytest
import json
from unittest.mock import AsyncMock, patch
from sqlmodel import Session
from apps.api.api.core.models import Job, Entitlement
from apps.api.api.core.worker import _process_billing_restore
from apps.api.api.billing.router import restore_purchases, RestoreRequest

# Mock response for Apple
MOCK_APPLE_RESPONSE = {
    "verified": True,
    "transactions": [
        {"product_id": "test_product_1", "transaction_id": "tx_100"},
        {"product_id": "test_product_2", "transaction_id": "tx_200"},
    ]
}

@pytest.mark.asyncio
async def test_billing_restore_apple_flow(db_session: Session):
    # Setup Data
    db_session.add(Entitlement(slug="test_product_1", title_ru="T1", ref="x", is_active=True))
    db_session.add(Entitlement(slug="test_product_2", title_ru="T2", ref="y", is_active=True))
    db_session.commit()
    
    # Create Job
    job = Job(
        type="billing_restore",
        idempotency_key="trace_restore_1",
        payload=json.dumps({
            "platform": "apple",
            "apple_receipt": "fake_receipt",
            "device_anon_id": "device_1"
        })
    )
    db_session.add(job)
    db_session.commit()
    
    # Mock External Specifics
    # We patch at the import level where worker.py imports them
    with patch("apps.api.api.core.worker.restore_apple_receipt", new_callable=AsyncMock) as mock_restore:
        mock_restore.return_value = MOCK_APPLE_RESPONSE
        
        # Run Worker Logic Directly
        await _process_billing_restore(db_session, job)
        
        # Verify
        assert job.status == "COMPLETED"
        res = json.loads(job.result)
        assert res["platform"] == "apple"
        assert res["grants_created"] == 2
        
        # Verify call args
        mock_restore.assert_called_once_with("fake_receipt")

@pytest.mark.asyncio
async def test_billing_restore_idempotency_run(db_session: Session):
    # If run twice, second time grants_existing += 1
    
    db_session.add(Entitlement(slug="test_product_1", title_ru="T1", ref="x", is_active=True))
    db_session.commit()
    
    job = Job(
        type="billing_restore",
        idempotency_key="trace_restore_2",
        payload=json.dumps({
            "platform": "apple",
            "apple_receipt": "fake_receipt",
            "device_anon_id": "device_1"
        })
    )
    db_session.add(job)
    db_session.commit()

    MOCK_SINGLE = {
        "verified": True,
        "transactions": [
            {"product_id": "test_product_1", "transaction_id": "tx_100"}
        ]
    }
    
    with patch("apps.api.api.core.worker.restore_apple_receipt", new_callable=AsyncMock) as mock_restore:
         mock_restore.return_value = MOCK_SINGLE
         
         # 1st Run
         await _process_billing_restore(db_session, job)
         res1 = json.loads(job.result)
         assert res1["grants_created"] == 1
         
         # 2nd Run (Simulate re-queue or new job with same payload)
         # Re-reset job status
         job.status = "PENDING"
         await _process_billing_restore(db_session, job)
         res2 = json.loads(job.result)
         assert res2["grants_created"] == 0
         assert res2["grants_existing"] == 1

@pytest.mark.asyncio
async def test_billing_restore_google_batch(db_session: Session):
    db_session.add(Entitlement(slug="sku_1", title_ru="T1", ref="x", is_active=True))
    db_session.add(Entitlement(slug="sku_2", title_ru="T2", ref="y", is_active=True))
    db_session.commit()
    
    payload = {
        "platform": "google",
        "device_anon_id": "d_g_1",
        "google_purchases": [
            {"product_id": "sku_1", "purchase_token": "token_1"},
            {"product_id": "sku_2", "purchase_token": "token_2"},
        ]
    }
    
    job = Job(type="billing_restore", idempotency_key="trace_g_1", payload=json.dumps(payload))
    db_session.add(job)
    db_session.commit()
    
    # Mock verify_google_purchase to succeed for both
    # We need side_effect to return different results based on token
    async def mock_verify(pkg, prod, token):
        return {"verified": True, "transaction_id": f"order_{token}"}
        
    with patch("apps.api.api.core.worker.verify_google_purchase", side_effect=mock_verify) as m:
        await _process_billing_restore(db_session, job)
        
        assert job.status == "COMPLETED"
        res = json.loads(job.result)
        assert res["grants_created"] == 2
        assert len(res["items"]) == 2
        assert res["items"][0]["status"] == "created"
        assert res["items"][0]["order_id"] == "order_token_1"

@pytest.mark.asyncio
async def test_billing_restore_google_resilience(db_session: Session):
    # Test PR-47 hardening: one item crashes (exception), job completes
    db_session.add(Entitlement(slug="sku_ok", title_ru="T1", ref="x", is_active=True))
    db_session.commit()
    
    payload = {
        "platform": "google",
        "device_anon_id": "d_g_crash",
        "google_purchases": [
            {"product_id": "sku_ok", "purchase_token": "token_ok"},
            {"product_id": "sku_bad", "purchase_token": "token_crash"},
        ]
    }
    job = Job(type="billing_restore", idempotency_key="trace_g_crash", payload=json.dumps(payload))
    db_session.add(job)
    db_session.commit()
    
    async def mock_verify_crash(pkg, prod, token):
        if token == "token_crash":
            raise RuntimeError("Google API Connection Reset")
        return {"verified": True, "transaction_id": "order_ok"}

    with patch("apps.api.api.core.worker.verify_google_purchase", side_effect=mock_verify_crash):
        await _process_billing_restore(db_session, job)
        
        assert job.status == "COMPLETED" # Must succeed partially
        res = json.loads(job.result)
        assert res["grants_created"] == 1
        assert res["failed_count"] == 1
        
        # Check items
        items = res["items"]
        ok_item = next(i for i in items if i["product_id"] == "sku_ok")
        bad_item = next(i for i in items if i["product_id"] == "sku_bad")
        
        assert ok_item["status"] == "created"
        assert bad_item["status"] == "failed"
        assert "Google API Connection Reset" in bad_item["error_code"]

