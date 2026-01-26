import pytest
import json
from unittest.mock import AsyncMock, patch, MagicMock
from apps.api.api.core.models import Job
from apps.api.api.core.worker import _process_billing_restore

@pytest.mark.asyncio
async def test_billing_restore_google_batch_logic_only():
    # Mock Session
    mock_session = MagicMock()
    
    # Create Job
    job = Job(
        type="billing_restore",
        idempotency_key="trace_google_batch_1",
        payload=json.dumps({
            "platform": "google",
            "device_anon_id": "device_google_1",
            "google_purchases": [
                {"package_name": "com.app", "product_id": "product_A", "purchase_token": "token_A"},
                {"package_name": "com.app", "product_id": "product_B", "purchase_token": "token_B"}
            ]
        })
    )
    
    # Mock grant_entitlement to avoid DB calls inside it
    # We patch it where it is imported in worker.py
    # worker.py: from apps.api.api.billing.service import grant_entitlement
    
    with patch("apps.api.api.core.worker.verify_google_purchase", new_callable=AsyncMock) as mock_verify, \
         patch("apps.api.api.core.worker.grant_entitlement", new_callable=AsyncMock) as mock_grant:
         
        # Setup mocks
        mock_verify.side_effect = [
            {"verified": True, "transaction_id": "tx_A"}, # 1st call
            {"verified": True, "transaction_id": "tx_B"}  # 2nd call
        ]
        
        # grant_entitlement returns (grant_obj, is_new_bool)
        mock_grant.return_value = (MagicMock(), True)
        
        await _process_billing_restore(mock_session, job)
        
        assert job.status == "COMPLETED"
        res = json.loads(job.result)
        
        assert res["platform"] == "google"
        assert res["grants_created"] == 2
        assert len(res["items"]) == 2
        assert res["items"][0]["order_id"] == "tx_A"
        assert res["items"][1]["order_id"] == "tx_B"
        
        assert mock_verify.call_count == 2
        assert mock_grant.call_count == 2

@pytest.mark.asyncio
async def test_billing_restore_google_legacy_logic_only():
    mock_session = MagicMock()
    job = Job(
        type="billing_restore",
        idempotency_key="trace_legacy",
        payload=json.dumps({
            "platform": "google",
            "device_anon_id": "dev",
            "google_purchase_token": "tok_L",
            "product_id": "prod_L"
        })
    )
    
    with patch("apps.api.api.core.worker.verify_google_purchase", new_callable=AsyncMock) as mock_verify, \
         patch("apps.api.api.core.worker.grant_entitlement", new_callable=AsyncMock) as mock_grant:
         
        mock_verify.return_value = {"verified": True, "transaction_id": "tx_L"}
        mock_grant.return_value = (MagicMock(), True)
        
        await _process_billing_restore(mock_session, job)
        
        assert job.status == "COMPLETED"
        res = json.loads(job.result)
        assert res["items"][0]["product_id"] == "prod_L"
