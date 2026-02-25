from datetime import datetime
import uuid
import hashlib
from fastapi import APIRouter, Depends, Query, HTTPException, Header
from sqlmodel import Session, select
from pydantic import BaseModel

from .core.database import engine
from .core.models import Poi, PoiSource, PoiMedia, AuditLog
# caching import removed - not used in this module
from .core.config import config

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

def verify_admin_token(x_admin_token: str = Header(...)):
    if x_admin_token != config.ADMIN_API_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid Admin Token")
    return x_admin_token

def get_token_fingerprint(token: str) -> str:
    # SHA256 Hash of the token for audit trails (never store raw token)
    return hashlib.sha256(token.encode()).hexdigest()

# NOTE: All POI endpoints (create, sources, media, publish_check, publish, unpublish) 
# have been moved to admin/poi.py to use JWT auth instead of x-admin-token.
# This file is kept for backward compatibility but should not define any /admin/pois routes.
