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

@router.get("/public/tours")
def get_tours(
    response: Response, 
    city: str = Query(..., description="Tenant slug"), 
    session: Session = Depends(get_session)
):
    tours = session.exec(
        select(Tour)
        .where(Tour.city_slug == city)
        .where(Tour.published_at != None)
    ).all()
    
    data = [tour.model_dump(include={'id', 'city_slug', 'title_ru', 'description_ru', 'duration_minutes', 'published_at'}) for tour in tours]
    
    # Caching Headers
    response.headers["Cache-Control"] = "public, max-age=60"
    check_etag(response.request, response, data)
    
    return data

@router.get("/public/tours/{tour_id}")
def get_tour_detail(
    response: Response,
    tour_id: uuid.UUID,
    city: str = Query(..., description="Tenant slug"),
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour or tour.city_slug != city or not tour.published_at:
        raise HTTPException(status_code=404, detail="Not Found or Unpublished")
    
    items_sorted = sorted(tour.items, key=lambda i: i.order_index)
    items_data = []
    for item in items_sorted:
        if item.poi:
             items_data.append({
                 "id": str(item.id),
                 "order_index": item.order_index,
                 "poi": item.poi.model_dump(include={'id', 'title_ru', 'lat', 'lon'})
             })

    data = {
        **tour.model_dump(exclude={'items', 'sources', 'media'}),
        "items": items_data,
        "sources": [s.model_dump() for s in tour.sources],
        "media": [m.model_dump() for m in tour.media]
    }
    
    # Caching Headers
    response.headers["Cache-Control"] = "public, max-age=60"
    check_etag(response.request, response, data)
    
    return data

@router.get("/public/nearby")
def get_nearby(
    response: Response,
    city: str = Query(..., description="Tenant slug"),
    lat: float = Query(...),
    lon: float = Query(...),
    radius_m: int = Query(1000, le=5000), 
    session: Session = Depends(get_session)
):
    if radius_m > 5000: raise HTTPException(status_code=422, detail="Radius limit exceeded")
    
    logger.info("Nearby Query", extra={"city": city, "radius": radius_m, "types": "poi,helper"})

    results = []
    # 1. POI
    poi_sql = text("""
        SELECT id, 'poi' as type, title_ru, lat, lon, 
               ST_Distance(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography) as dist
        FROM poi
        WHERE city_slug = :city AND published_at IS NOT NULL AND ST_DWithin(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)
    """)
    for row in session.exec(poi_sql, params={"city": city, "lat": lat, "lon": lon, "radius": radius_m}).all():
         results.append({"id": row[0], "type": "poi", "subtype": None, "title": row[2], "lat": row[3], "lon": row[4], "distance_m": int(row[5])})

    # 2. Helpers
    helper_sql = text("""
        SELECT id, 'helper' as type, type as subtype, name_ru, lat, lon,
               ST_Distance(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography) as dist
        FROM helper_places
        WHERE city_slug = :city AND ST_DWithin(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)
    """)
    for row in session.exec(helper_sql, params={"city": city, "lat": lat, "lon": lon, "radius": radius_m}).all():
        results.append({"id": row[0], "type": "helper", "subtype": row[2], "title": row[3], "lat": row[4], "lon": row[5], "distance_m": int(row[6])})
    
    results.sort(key=lambda x: x["distance_m"])
    results = results[:50]
    response.headers["Cache-Control"] = "private, max-age=10"
    return results

# ... (Previous endpoints) ...
@router.get("/public/cities")
def get_cities(response: Response, session: Session = Depends(get_session)):
    cities = session.exec(select(City).where(City.is_active == True)).all()
    data = [city.model_dump(exclude={'pois', 'tours'}) for city in cities]
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
    response.headers["Cache-Control"] = "public, max-age=60"
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
    
    response.headers["Cache-Control"] = "public, max-age=60"
    check_etag(response.request, response, data)
    return data

@router.get("/public/map/attribution")
def get_map_attribution(response: Response, city: str = Query(...)):
    data = {"attribution_text": "© OpenStreetMap contributors", "attribution_url": "https://www.openstreetmap.org/copyright", "data_provider": "OpenStreetMap", "license": "ODbL 1.0"}
    response.headers["Cache-Control"] = "public, max-age=3600"
    check_etag(response.request, response, data)
    return data

@router.get("/public/helpers")
def get_helpers(response: Response, city: str = Query(...), category: Optional[str] = Query(None), session: Session = Depends(get_session)):
    q = select(HelperPlace).where(HelperPlace.city_slug == city)
    if category: q = q.where(HelperPlace.type == category)
    helpers = session.exec(q).all()
    data = [helper.model_dump(exclude={'geo'}) for helper in helpers]
    
    response.headers["Cache-Control"] = "public, max-age=60"
    check_etag(response.request, response, data)
    return data
