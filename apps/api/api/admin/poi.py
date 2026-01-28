from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlmodel import Session, select
from pydantic import BaseModel
from geoalchemy2.elements import WKTElement
import uuid

from ..core.models import Poi
from ..core.config import config
from ..auth.deps import get_current_admin, get_session

router = APIRouter()

# --- Pydantic Schemas ---
class PoiCreate(BaseModel):
    title_ru: str
    description_ru: Optional[str] = None
    city_slug: str
    lat: Optional[float] = None
    lon: Optional[float] = None
    is_active: Optional[bool] = True

class PoiUpdate(BaseModel):
    title_ru: Optional[str] = None
    description_ru: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    is_active: Optional[bool] = None

class PoiRead(BaseModel):
    id: uuid.UUID
    title_ru: str
    description_ru: Optional[str]
    city_slug: str
    lat: Optional[float]
    lon: Optional[float]
    is_active: bool
    
    class Config:
        orm_mode = True

# --- Endpoints ---
@router.get("/admin/pois", response_model=List[PoiRead])
def list_pois(
    city_slug: Optional[str] = None,
    limit: int = Query(50, le=200),
    offset: int = 0,
    session: Session = Depends(get_session),
    admin = Depends(get_current_admin)
):
    try:
        query = select(Poi)
        if city_slug:
            query = query.where(Poi.city_slug == city_slug)
        query = query.order_by(Poi.updated_at.desc()).offset(offset).limit(limit)
        return session.exec(query).all()
    except Exception as e:
        import traceback
        raise HTTPException(500, f"List Error: {e}\n{traceback.format_exc()}")

@router.post("/admin/pois", response_model=PoiRead)
def create_poi(
    poi_in: PoiCreate,
    session: Session = Depends(get_session),
    admin = Depends(get_current_admin)
):
    db_poi = Poi.from_orm(poi_in)
    db_poi.id = uuid.uuid4()
    
    # Set geo if lat/lon provided
    if db_poi.lat is not None and db_poi.lon is not None:
        try:
            db_poi.geo = WKTElement(f"POINT({db_poi.lon} {db_poi.lat})", srid=4326)
        except Exception as e:
            raise HTTPException(500, f"Geo Error: {e}")
    
    try:
        session.add(db_poi)
        session.commit()
        session.refresh(db_poi)
    except Exception as e:
        session.rollback()
        import traceback
        error_msg = f"DB Error: {str(e)}\n{traceback.format_exc()}"
        print(error_msg) # Log to Vercel logs if possible
        raise HTTPException(500, f"Database Commit Failed: {e}")
        
    return db_poi

@router.get("/admin/pois/{poi_id}", response_model=PoiRead)
def get_poi(
    poi_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin = Depends(get_current_admin)
):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404, "POI not found")
    return poi

@router.patch("/admin/pois/{poi_id}", response_model=PoiRead)
def update_poi(
    poi_id: uuid.UUID,
    data: PoiUpdate,
    session: Session = Depends(get_session),
    admin = Depends(get_current_admin)
):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404, "POI not found")
    
    poi_data = data.dict(exclude_unset=True)
    for key, value in poi_data.items():
        setattr(poi, key, value)
    
    # Sync Geo if changed
    if data.lat is not None or data.lon is not None:
        lat = data.lat if data.lat is not None else poi.lat
        lon = data.lon if data.lon is not None else poi.lon
        if lat is not None and lon is not None:
            poi.geo = WKTElement(f"POINT({lon} {lat})", srid=4326)
            poi.lat = lat
            poi.lon = lon
    
    session.add(poi)
    session.commit()
    session.refresh(poi)
    return poi

# Media upload temporarily disabled (vercel_blob not available)
# @router.post("/admin/pois/{poi_id}/media_upload")
# async def upload_poi_media(...):
#     pass
