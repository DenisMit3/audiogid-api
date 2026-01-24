from typing import List, Optional
from fastapi import APIRouter, Depends, Response, Query
from sqlmodel import Session, select
from pydantic import BaseModel

from .core.database import engine
from .core.models import HelperPlace
from .core.caching import check_etag

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
    
    # ETag Check
    check_etag(response.request, response, data)
    
    return data

@router.get("/public/helpers")
def get_helpers(
    response: Response,
    city: str = Query(..., description="Tenant slug"),
    category: Optional[str] = Query(None, description="Filter by category (toilet, water, cafe)"),
    session: Session = Depends(get_session)
):
    query = select(HelperPlace).where(HelperPlace.city_slug == city)
    
    if category:
        query = query.where(HelperPlace.type == category)
        
    helpers = session.exec(query).all()
    # Read last persisted data, returns empty list if none exist
    data = [helper.model_dump() for helper in helpers]
    
    check_etag(response.request, response, data)
    
    return data
