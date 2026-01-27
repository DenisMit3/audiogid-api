import pytest
from sqlmodel import Session, SQLModel, create_engine
from typing import Generator
from unittest.mock import MagicMock
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
    # We can also mock other vars if needed
