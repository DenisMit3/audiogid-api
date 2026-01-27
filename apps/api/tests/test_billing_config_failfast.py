from fastapi.testclient import TestClient
from unittest.mock import patch
from apps.api.index import app
from apps.api.api.core.config import config

client = TestClient(app)

def test_yookassa_webhook_fail_fast_missing_secret():
    """
    PR-47: Verify that YooKassa webhook returns 503 Service Unavailable
    if YOOKASSA_WEBHOOK_SECRET is not configured.
    """
    # Patch the config instance attribute directly since it's loaded at startup
    with patch.object(config, "YOOKASSA_WEBHOOK_SECRET", None):
        # Scenario 1: No header, auto_error=False -> checking implementation
        res = client.post(
            "/v1/billing/yookassa/webhook",
            json={"event": "payment.succeeded", "object": {"id": "test"}},
            headers={"X-Yookassa-Signature": "fake"}
        )
        
        assert res.status_code == 503
        assert "Secret is not configured" in res.json()["detail"]

def test_yookassa_webhook_auth_failure():
    """
    Verify 401 if secret is set but signature mismatch
    """
    # Force set the secret on the imported config instance
    with patch.object(config, "YOOKASSA_WEBHOOK_SECRET", "valid_secret"):
        res = client.post(
            "/v1/billing/yookassa/webhook",
            json={"event": "test"},
            headers={"X-Yookassa-Signature": "wrong"}
        )
        assert res.status_code == 401
