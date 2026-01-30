from fastapi.testclient import TestClient
import pytest
from ..index import app
from ..api.core.config import config

client = TestClient(app)

def test_public_health():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_get_cities():
    response = client.get("/v1/public/cities")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_catalog_missing_city():
    response = client.get("/v1/public/catalog")
    assert response.status_code == 422 # Validation Error

def test_get_map_attribution():
    response = client.get("/v1/public/map/attribution")
    assert response.status_code == 200
    data = response.json()
    assert "attribution_text" in data
