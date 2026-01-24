from typing import List
from fastapi import APIRouter, Depends, Response, Query, HTTPException
from sqlmodel import Session, select
import uuid

from ..core.database import engine
from ..core.models import City, Tour, Poi
from ..core.caching import check_etag

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

@router.get("/public/cities")
def get_cities(response: Response, session: Session = Depends(get_session)):
    cities = session.exec(select(City).where(City.is_active == True)).all()
    data = [city.model_dump() for city in cities]
    check_etag(response.request, response, data)
    return data

@router.get("/public/tours")
def get_tours(
    response: Response, 
    city: str = Query(..., description="Tenant slug"), 
    session: Session = Depends(get_session)
):
    # Only published
    tours = session.exec(
        select(Tour)
        .where(Tour.city_slug == city)
        .where(Tour.is_published == True)
    ).all()
    data = [tour.model_dump() for tour in tours]
    check_etag(response.request, response, data)
    return data

@router.get("/public/catalog")
def get_catalog(
    response: Response, 
    city: str = Query(..., description="Tenant slug"), 
    session: Session = Depends(get_session)
):
    # PR-5: STRICT VISIBILITY GATE
    # Only return POIs where published_at IS NOT NULL
    pois = session.exec(
        select(Poi)
        .where(Poi.city_slug == city)
        .where(Poi.published_at != None)
    ).all()
    data = [poi.model_dump() for poi in pois]
    check_etag(response.request, response, data)
    return data

@router.get("/public/poi/{poi_id}")
def get_poi_detail(
    response: Response,
    poi_id: uuid.UUID,
    city: str = Query(..., description="Tenant slug"),
    session: Session = Depends(get_session)
):
    # PR-5: Detail View with strict gate
    poi = session.get(Poi, poi_id)
    
    if not poi:
        raise HTTPException(status_code=404, detail="Not Found")
        
    # Tenant Check
    if poi.city_slug != city:
        raise HTTPException(status_code=404, detail="Not Found in City")
        
    # Gate Check
    if not poi.published_at:
        # We 404 on unpublished items to hide existence? Or 403?
        # Standard: 404 to avoid leaking valid IDs.
        raise HTTPException(status_code=404, detail="Not Found")
    
    # ETag on loaded relationships too?
    # We must ensure sources/media are loaded.
    sources = [s.model_dump() for s in poi.sources]
    media = [m.model_dump() for m in poi.media]
    
    data = {
        **poi.model_dump(),
        "sources": sources,
        "media": media
    }
    
    check_etag(response.request, response, data)
    return data
