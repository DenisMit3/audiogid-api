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

# --- Input Models ---
class CreateSourceReq(BaseModel):
    name: str 
    url: str | None = None

class CreateMediaReq(BaseModel):
    url: str
    media_type: str
    license_type: str
    author: str
    source_page_url: str

class CreatePoiReq(BaseModel):
    title_ru: str
    city_slug: str

# --- Endpoints ---

@router.post("/admin/pois", status_code=201, dependencies=[Depends(verify_admin_token)])
def create_poi(
    req: CreatePoiReq, 
    session: Session = Depends(get_session)
):
    # Minimal Endpoint for Testing (Cloud-Only Validation)
    poi = Poi(
        title_ru=req.title_ru,
        city_slug=req.city_slug
        # published_at is None by default
    )
    session.add(poi)
    session.commit()
    return {"id": str(poi.id), "status": "created_unpublished"}

@router.post("/admin/pois/{poi_id}/sources", status_code=201, dependencies=[Depends(verify_admin_token)])
def add_poi_source(
    poi_id: uuid.UUID,
    req: CreateSourceReq,
    session: Session = Depends(get_session)
):
    poi = session.get(Poi, poi_id)
    if not poi:
        raise HTTPException(status_code=404, detail="POI not found")
        
    source = PoiSource(poi_id=poi_id, name=req.name, url=req.url)
    session.add(source)
    session.commit()
    return {"status": "created", "id": str(source.id)}

@router.post("/admin/pois/{poi_id}/media", status_code=201, dependencies=[Depends(verify_admin_token)])
def add_poi_media(
    poi_id: uuid.UUID,
    req: CreateMediaReq,
    session: Session = Depends(get_session)
):
    poi = session.get(Poi, poi_id)
    if not poi:
        raise HTTPException(status_code=404, detail="POI not found")
        
    media = PoiMedia(
        poi_id=poi_id,
        url=req.url,
        media_type=req.media_type,
        license_type=req.license_type,
        author=req.author,
        source_page_url=req.source_page_url
    )
    session.add(media)
    session.commit()
    return {"status": "created", "id": str(media.id)}

@router.get("/admin/pois/{poi_id}/publish_check", dependencies=[Depends(verify_admin_token)])
def check_publish(
    poi_id: uuid.UUID,
    session: Session = Depends(get_session)
):
    poi = session.get(Poi, poi_id)
    if not poi:
        raise HTTPException(status_code=404, detail="POI not found")
        
    issues = []
    
    if len(poi.sources) == 0:
        issues.append("Missing Sources")
        
    count_valid_media = 0
    for m in poi.media:
        if m.license_type and m.author and m.source_page_url:
            count_valid_media += 1
            
    if count_valid_media == 0:
        issues.append("Missing Licensed Media")

    return {
        "can_publish": len(issues) == 0,
        "issues": issues
    }

@router.post("/admin/pois/{poi_id}/publish")
def publish_poi(
    poi_id: uuid.UUID,
    token: str = Depends(verify_admin_token),
    session: Session = Depends(get_session)
):
    # Re-run checks
    check = check_publish(poi_id, session)
    if not check["can_publish"]:
        raise HTTPException(status_code=422, detail={"error": "Gates Failed", "issues": check["issues"]})
        
    poi = session.get(Poi, poi_id)
    if poi.published_at:
        return {"status": "already_published"}
        
    poi.published_at = datetime.utcnow()
    
    # Audit (Secure Fingerprint)
    fingerprint = get_token_fingerprint(token)
    audit = AuditLog(
        action="PUBLISH", 
        target_id=poi_id,
        actor_type="admin_token",
        actor_fingerprint=fingerprint
    )
    session.add(audit)
    session.add(poi)
    session.commit()
    
    return {"status": "published"}

@router.post("/admin/pois/{poi_id}/unpublish")
def unpublish_poi(
    poi_id: uuid.UUID,
    token: str = Depends(verify_admin_token),
    session: Session = Depends(get_session)
):
    poi = session.get(Poi, poi_id)
    if not poi:
        raise HTTPException(status_code=404, detail="POI not found")
        
    if not poi.published_at:
        return {"status": "already_unpublished"}
        
    poi.published_at = None
    
    fingerprint = get_token_fingerprint(token)
    audit = AuditLog(
        action="UNPUBLISH",
        target_id=poi_id,
        actor_type="admin_token",
        actor_fingerprint=fingerprint
    )
    session.add(audit)
    session.add(poi)
    session.commit()
    
    return {"status": "unpublished"}
