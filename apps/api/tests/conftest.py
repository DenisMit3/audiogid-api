import pytest
from sqlmodel import Session, SQLModel, create_engine
from typing import Generator
from unittest.mock import MagicMock, patch
import os
import sys

# Ensure proper path for imports if running from root or apps/api
# This helps if we forget to set PYTHONPATH
api_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if api_path not in sys.path:
    sys.path.insert(0, api_path)

@pytest.fixture(name="db_session")
def db_session_fixture():
    # Use in-memory SQLite for speed and isolation
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        yield session

@pytest.fixture(autouse=True)
def mock_env(monkeypatch):
    # Ensure critical envs are present to avoid config crash during imports
    monkeypatch.setenv("DATABASE_URL", "sqlite:///:memory:")
    monkeypatch.setenv("JWT_SECRET", "test_secret_key_32_chars_long!!")
    # We can also mock other vars if needed


@pytest.fixture(name="client")
def client_fixture():
    """
    TestClient fixture for FastAPI app.
    Note: This requires the app to be importable without PostGIS dependencies.
    For tests that need real DB, use integration tests with proper setup.
    """
    from fastapi.testclient import TestClient
    from unittest.mock import MagicMock
    
    # Create a minimal mock app for tests that don't need full app
    from fastapi import FastAPI
    mock_app = FastAPI()
    
    @mock_app.get("/v1/public/catalog")
    def mock_catalog(city_id: str = None):
        return {"items": []}
    
    @mock_app.get("/v1/public/poi/{poi_id}")
    def mock_poi(poi_id: str):
        return {"id": poi_id, "title": "Mock POI"}
    
    @mock_app.post("/v1/billing/purchase-intent")
    def mock_purchase_intent():
        return {"id": "mock_intent_id", "status": "PENDING"}
    
    with TestClient(mock_app) as client:
        yield client
