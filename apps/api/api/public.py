from typing import List
from fastapi import APIRouter, Depends, Response, Query
from sqlmodel import Session, select

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
    
    # ETag Check (will raise 304 if match)
    check_etag(response.request, response, data)
    
    return data

@router.get("/public/tours")
def get_tours(
    response: Response, 
    city: str = Query(..., description="Tenant slug"), 
    session: Session = Depends(get_session)
):
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
    pois = session.exec(
        select(Poi)
        .where(Poi.city_slug == city)
        .where(Poi.is_published == True)
    ).all()
    data = [poi.model_dump() for poi in pois]
    
    check_etag(response.request, response, data)
    
    return data
