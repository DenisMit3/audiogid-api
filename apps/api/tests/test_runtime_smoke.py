import os

os.environ.setdefault("DATABASE_URL", "sqlite:///:memory:")
os.environ.setdefault("JWT_SECRET", "test_secret_key_32_chars_long_12345")

from fastapi import FastAPI
from fastapi.testclient import TestClient

from api.auth import router as auth_router
from api.billing import router as billing_router
from api.offline import router as offline_router
from api.core.config import config


class _ExecResult:
    def __init__(self, first_value=None, all_value=None):
        self._first_value = first_value
        self._all_value = all_value if all_value is not None else []

    def first(self):
        return self._first_value

    def all(self):
        return self._all_value


class _FakeSession:
    def exec(self, *_args, **_kwargs):
        return _ExecResult(first_value=None, all_value=[])

    def get(self, *_args, **_kwargs):
        return None



def _override_session():
    yield _FakeSession()



def _build_smoke_client() -> TestClient:
    app = FastAPI()
    app.include_router(auth_router.router, prefix="/v1")
    app.include_router(billing_router.router, prefix="/v1")
    app.include_router(offline_router.router, prefix="/v1")

    app.dependency_overrides[auth_router.get_session] = _override_session
    app.dependency_overrides[billing_router.get_session] = _override_session
    app.dependency_overrides[offline_router.get_session] = _override_session

    return TestClient(app)


def test_smoke_auth_login_email_invalid_credentials():
    client = _build_smoke_client()
    response = client.post(
        "/v1/auth/login/email",
        json={"email": "missing@example.com", "password": "wrong"},
    )
    assert response.status_code == 401


def test_smoke_billing_restore_google_payload_validation():
    client = _build_smoke_client()
    response = client.post(
        "/v1/billing/restore",
        json={
            "platform": "google",
            "idempotency_key": "smoke-restore-1",
            "device_anon_id": "device-1",
        },
    )
    assert response.status_code == 400


def test_smoke_billing_entitlements_empty_list():
    client = _build_smoke_client()
    response = client.get("/v1/billing/entitlements", params={"device_anon_id": "device-1"})
    assert response.status_code == 200
    assert response.json() == []


def test_smoke_offline_build_returns_503_without_qstash(monkeypatch):
    monkeypatch.setattr(config, "QSTASH_TOKEN", "")

    client = _build_smoke_client()
    response = client.post(
        "/v1/offline/bundles:build",
        json={
            "city_slug": "kaliningrad_city",
            "idempotency_key": "smoke-offline-1",
            "type": "full_city",
        },
    )
    assert response.status_code == 503
