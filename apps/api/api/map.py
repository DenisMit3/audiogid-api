from typing import List, Optional
import hashlib
from fastapi import APIRouter, Depends, Response, Query, Request
from sqlmodel import Session, select
from pydantic import BaseModel

from .core.database import engine
from .core.models import HelperPlace
from .core.caching import check_etag_versioned, generate_version_marker

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

class AttributionResponse(BaseModel):
    attribution_text: str
    attribution_url: Optional[str] = None
    data_provider: str = "OpenStreetMap contributors"

@router.get("/public/map/attribution")
def get_map_attribution(
    request: Request,
    response: Response, 
    city: str = Query(..., description="Tenant slug"), 
    session: Session = Depends(get_session)
):
    # Attribution Logic for OSM ODbL compliance
    data = {
        "attribution_text": "© OpenStreetMap contributors",
        "attribution_url": "https://www.openstreetmap.org/copyright",
        "data_provider": "OpenStreetMap",
        "license": "ODbL 1.0"
    }
    
    # Static ETag for attribution (rarely changes)
    etag = 'W/"osm-attribution-v1"'
    check_etag_versioned(request, response, etag, is_public=True)
    
    return data

@router.get("/public/helpers")
def get_helpers(
    request: Request,
    response: Response,
    city: str = Query(..., description="Tenant slug"),
    category: Optional[str] = Query(None, description="Filter by category (toilet, water, cafe)"),
    session: Session = Depends(get_session)
):
    query = select(HelperPlace).where(HelperPlace.city_slug == city)
    
    if category:
        query = query.where(HelperPlace.type == category)
        
    helpers = session.exec(query).all()
    data = [helper.model_dump() for helper in helpers]
    
    # Generate ETag from data
    etag = generate_version_marker(session, HelperPlace, city)
    check_etag_versioned(request, response, etag, is_public=True)
    
    return data
