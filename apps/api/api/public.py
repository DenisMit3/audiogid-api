import logging
from typing import List, Optional
from fastapi import APIRouter, Depends, Response, Query, HTTPException
from sqlmodel import Session, select, text
import uuid

from ..core.database import engine
from ..core.models import City, Tour, Poi, HelperPlace
from ..core.caching import check_etag

logger = logging.getLogger(__name__)
router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

@router.get("/public/nearby")
def get_nearby(
    response: Response,
    city: str = Query(..., description="Tenant slug"),
    lat: float = Query(...),
    lon: float = Query(...),
    radius_m: int = Query(1000, le=5000), 
    session: Session = Depends(get_session)
):
    """
    Unified Nearby Search using PostGIS Geography type.
    """
    if radius_m > 5000:
        raise HTTPException(status_code=422, detail="Radius limit exceeded (max 5000m)")
        
    # Observability: Structured Log without User Coordinates
    logger.info("Nearby Query", extra={
        "city": city,
        "radius": radius_m,
        "types": "poi,helper"
    })

    results = []

    # 1. POIs (Published Only)
    # Geo column is geography. ST_MakePoint returns geometry. We cast param to geography.
    # ST_Distance / ST_DWithin on (geography, geography) uses meters.
    
    poi_sql = text("""
        SELECT id, 'poi' as type, title_ru, lat, lon, 
               ST_Distance(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography) as dist
        FROM poi
        WHERE city_slug = :city
          AND published_at IS NOT NULL
          AND ST_DWithin(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)
    """)
    
    pois = session.exec(poi_sql, params={"city": city, "lat": lat, "lon": lon, "radius": radius_m}).all()
    
    for row in pois:
         results.append({
             "id": row[0], # uuid
             "type": "poi",
             "subtype": None,
             "title": row[2],
             "lat": row[3],
             "lon": row[4],
             "distance_m": int(row[5])
         })

    # 2. Helpers
    helper_sql = text("""
        SELECT id, 'helper' as type, type as subtype, name_ru, lat, lon,
               ST_Distance(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography) as dist
        FROM helper_places
        WHERE city_slug = :city
          AND ST_DWithin(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)
    """)
    
    helpers = session.exec(helper_sql, params={"city": city, "lat": lat, "lon": lon, "radius": radius_m}).all()
    
    for row in helpers:
        results.append({
            "id": row[0],
            "type": "helper",
            "subtype": row[2], 
            "title": row[3],
            "lat": row[4],
            "lon": row[5],
            "distance_m": int(row[6])
        })
    
    results.sort(key=lambda x: x["distance_m"])
    results = results[:50]
    
    response.headers["Cache-Control"] = "private, max-age=10"
    return results

# ... Existing Endpoints ...
@router.get("/public/cities")
def get_cities(response: Response, session: Session = Depends(get_session)):
    cities = session.exec(select(City).where(City.is_active == True)).all()
    data = [city.model_dump(exclude={'pois', 'tours'}) for city in cities]
    check_etag(response.request, response, data)
    return data

@router.get("/public/tours")
def get_tours(
    response: Response, 
    city: str = Query(..., description="Tenant slug"), 
    session: Session = Depends(get_session)
):
    tours = session.exec(select(Tour).where(Tour.city_slug == city, Tour.is_published == True)).all()
    data = [tour.model_dump() for tour in tours]
    check_etag(response.request, response, data)
    return data

@router.get("/public/catalog")
def get_catalog(
    response: Response, 
    city: str = Query(..., description="Tenant slug"), 
    session: Session = Depends(get_session)
):
    pois = session.exec(select(Poi).where(Poi.city_slug == city, Poi.published_at != None)).all()
    data = [poi.model_dump(exclude={'geo'}) for poi in pois] 
    check_etag(response.request, response, data)
    return data

@router.get("/public/poi/{poi_id}")
def get_poi_detail(
    response: Response,
    poi_id: uuid.UUID,
    city: str = Query(..., description="Tenant slug"),
    session: Session = Depends(get_session)
):
    poi = session.get(Poi, poi_id)
    if not poi or poi.city_slug != city or not poi.published_at:
        raise HTTPException(status_code=404, detail="Not Found")
    
    sources = [s.model_dump() for s in poi.sources]
    media = [m.model_dump() for m in poi.media]
    data = {**poi.model_dump(exclude={'geo'}), "sources": sources, "media": media}
    check_etag(response.request, response, data)
    return data
