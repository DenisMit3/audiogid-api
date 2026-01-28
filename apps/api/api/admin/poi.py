
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlmodel import Session, select
from pydantic import BaseModel
from geoalchemy2.elements import WKTElement
import uuid
import json

from ..core.models import Poi, PoiVersion, AuditLog, User, AppEvent

# ...

# Bulk Publish (line 70)
@router.post("/admin/pois/bulk-publish", dependencies=[Depends(require_permission('poi:bulk'))])
def bulk_publish_pois(
    action: BulkAction,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin) # Access admin-user for logging
):
    pois = session.exec(select(Poi).where(Poi.id.in_(action.ids))).all()
    count = 0
    from datetime import datetime
    now = datetime.utcnow()
    
    for poi in pois:
        if not poi.published_at:
            poi.published_at = now
            session.add(poi)
            count += 1
            
            # Analytics
            session.add(AppEvent(event_type="poi_published", entity_id=poi.id, user_id=user.id, payload_json=json.dumps({"title": poi.title_ru})))
            
    if count > 0:
        session.commit()
    return {"count": count, "status": "published"}

# ...

# Create POI (line 111)
@router.post("/admin/pois", response_model=PoiRead, dependencies=[Depends(require_permission('poi:write'))])
def create_poi(
    poi_in: PoiCreate,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin) 
):
    # ... (existing creation logic)
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
        
        # Initial Version
        v = PoiVersion(
             poi_id=db_poi.id,
             changed_by=user.id,
             title_ru=db_poi.title_ru,
             description_ru=db_poi.description_ru,
             lat=db_poi.lat,
             lon=db_poi.lon,
             full_snapshot_json=db_poi.json()
        )
        session.add(v)
        
        # Analytics
        session.add(AppEvent(event_type="poi_created", user_id=user.id, payload_json=json.dumps({"id": str(db_poi.id), "title": db_poi.title_ru})))
        
        session.commit()
        session.refresh(db_poi)
    except Exception as e:
        session.rollback()
        import traceback
        error_msg = f"DB Error: {str(e)}\n{traceback.format_exc()}"
        print(error_msg)
        raise HTTPException(500, f"Database Commit Failed: {e}")

# ...

# Update POI (line 162)
@router.patch("/admin/pois/{poi_id}", response_model=PoiRead, dependencies=[Depends(require_permission('poi:write'))])
def update_poi(
    poi_id: uuid.UUID,
    data: PoiUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin)
):
    # ...
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
    
    # Versioning
    v = PoiVersion(
         poi_id=poi.id,
         changed_by=user.id,
         title_ru=poi.title_ru,
         description_ru=poi.description_ru,
         lat=poi.lat,
         lon=poi.lon,
         full_snapshot_json=poi.json()
    )
    session.add(v)
    
    # Analytics
    session.add(AppEvent(event_type="poi_edited", user_id=user.id, payload_json=json.dumps({"id": str(poi.id), "changes": list(poi_data.keys())})))

    session.commit()
    session.refresh(poi)
    return poi

# --- Media Upload (Vercel Blob Stub) ---
# Since we might not have `vercel_blob` package installed or keys,
# we will verify if `VERCEL_BLOB_READ_WRITE_TOKEN` is present.
# If not, we return a mock URL.


@router.post("/admin/media/upload-token")
def get_upload_token(
    filename: str,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('poi:write')) # Adjusted permission
):
    # ... (existing code)
    token = config.VERCEL_BLOB_READ_WRITE_TOKEN
    if token and len(token) > 10:
        pass
    
    return {
        "url": f"https://placehold.co/600x400?text={filename}",
        "method": "PUT",
        "fields": {}
    }

class PublishCheckResult(BaseModel):
    can_publish: bool
    issues: List[str]

@router.get("/admin/pois/{poi_id}/publish_check", response_model=PublishCheckResult)
def check_poi_publish_status(
    poi_id: uuid.UUID,
    session: Session = Depends(get_session),
     user: User = Depends(require_permission('poi:read'))
):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404, "POI not found")
    
    issues = []
    if not poi.description_ru or len(poi.description_ru) < 10:
        issues.append("Description too short")
    if poi.lat is None or poi.lon is None:
        issues.append("Coordinates missing")
        
    # Check media if we had the relation loaded
    # if not poi.media: issues.append("No media")
    
    return PublishCheckResult(can_publish=len(issues)==0, issues=issues)


