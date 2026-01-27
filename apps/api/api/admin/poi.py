from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlmodel import Session, select
from pydantic import BaseModel
from geoalchemy2.elements import WKTElement
import uuid
import vercel_blob

from ..core.models import Poi, PoiBase, PoiMedia, City
from ..core.config import config
from ..auth.deps import get_current_admin, get_session

router = APIRouter()

# --- DTOs ---
class PoiCreate(PoiBase):
    pass

class PoiUpdate(BaseModel):
    title_ru: Optional[str] = None
    description_ru: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    city_slug: Optional[str] = None
    is_active: Optional[bool] = None
    
class PoiRead(PoiBase):
    id: uuid.UUID
    # media: List[PoiMedia] = [] 
    
    class Config:
        orm_mode = True

@router.get("/admin/pois", response_model=List[PoiRead])
def list_pois(
    city_slug: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
    session: Session = Depends(get_session),
    admin = Depends(get_current_admin)
):
    query = select(Poi)
    if city_slug:
        query = query.where(Poi.city_slug == city_slug)
    
    query = query.order_by(Poi.updated_at.desc()).offset(offset).limit(limit)
    return session.exec(query).all()

@router.post("/admin/pois", response_model=PoiRead)
def create_poi(
    poi_in: PoiCreate,
    session: Session = Depends(get_session),
    admin = Depends(get_current_admin)
):
    db_poi = Poi.from_orm(poi_in)
    
    # Sync Geo
    if db_poi.lat is not None and db_poi.lon is not None:
        db_poi.geo = WKTElement(f"POINT({db_poi.lon} {db_poi.lat})", srid=4326)
        
    session.add(db_poi)
    session.commit()
    session.refresh(db_poi)
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

@router.post("/admin/pois/{poi_id}/media_upload")
async def upload_poi_media(
    poi_id: uuid.UUID,
    file: UploadFile = File(...),
    media_type: str = Query("image"), # image or audio
    session: Session = Depends(get_session),
    admin = Depends(get_current_admin)
):
    # Check POI
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404, "POI not found")

    # Upload to Vercel Blob
    if not config.VERCEL_BLOB_READ_WRITE_TOKEN:
        raise HTTPException(500, "Blob storage not configured")
        
    filename = f"poi/{poi_id}/{media_type}/{file.filename}"
    
    try:
        # put returns { url, ... }
        # file.file is SpooledTemporaryFile
        blob = vercel_blob.put(filename, file.file, options={'access': 'public', 'token': config.VERCEL_BLOB_READ_WRITE_TOKEN})
    except Exception as e:
         raise HTTPException(500, f"Upload failed: {e}")
    
    media_entry = {
         "url": blob['url'],
         "media_type": media_type,
         "license_type": "own",
         "author": "admin", 
         "source_page_url": ""
    }
    
    # Update JSONB
    # Create new list to force update
    current_media = list(poi.media) if poi.media else []
    current_media.append(media_entry)
    poi.media = current_media
    
    session.add(poi)
    session.commit()
    
    return {"status": "uploaded", "url": blob['url'], "media": media_entry}
