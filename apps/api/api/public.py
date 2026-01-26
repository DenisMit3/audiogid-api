import logging
import uuid
import hashlib
from typing import List, Optional
from fastapi import APIRouter, Depends, Response, Query, HTTPException, Request
from sqlmodel import Session, select, text
from slowapi import Limiter
from slowapi.util import get_remote_address

from .core.database import engine
from .core.models import City, Tour, Poi, HelperPlace, Entitlement, EntitlementGrant
from .core.caching import check_etag_versioned, generate_version_marker, SCHEMA_VERSION
from .core.security import sign_asset_url

logger = logging.getLogger(__name__)
router = APIRouter()
limiter = Limiter(key_func=get_remote_address) # Local instance for decorators

def get_session():
    with Session(engine) as session:
        yield session

def check_access(session: Session, city: str, device_anon_id: str, tour_id: Optional[uuid.UUID] = None) -> bool:
    if not device_anon_id: return False
    if tour_id:
        grant = session.exec(select(EntitlementGrant).join(Entitlement).where(
            EntitlementGrant.device_anon_id == device_anon_id,
            EntitlementGrant.revoked_at == None,
            Entitlement.scope == "tour",
            Entitlement.ref == str(tour_id)
        )).first()
        if grant: return True
    city_grant = session.exec(select(EntitlementGrant).join(Entitlement).where(
        EntitlementGrant.device_anon_id == device_anon_id,
        EntitlementGrant.revoked_at == None,
        Entitlement.scope == "city",
        Entitlement.ref == city
    )).first()
    return city_grant is not None

@router.get("/public/tours/{tour_id}/manifest")
@limiter.limit("20/minute") # Heavy bundle data
def get_tour_manifest(
    response: Response, request: Request, tour_id: uuid.UUID, city: str = Query(...), 
    device_anon_id: str = Query(...), session: Session = Depends(get_session)
):
    """Gated Manifest: private, no-store."""
    if not check_access(session, city, device_anon_id, tour_id):
        raise HTTPException(status_code=403, detail="Payment Required", headers={"Cache-Control": "private, no-store"})
    
    tour = session.get(Tour, tour_id)
    if not tour or tour.city_slug != city or not tour.published_at:
        raise HTTPException(status_code=404, detail="Tour not found", headers={"Cache-Control": "private, no-store"})
    
    # Manifest is heavy, use no-store to avoid stale local cache of sensitive URLs
    response.headers["Cache-Control"] = "private, no-store"
    
    data = tour.model_dump(include={'id', 'city_slug', 'title_ru', 'description_ru', 'duration_minutes', 'published_at'})
    pois_data = []
    assets = []
    for m in tour.media: assets.append({"url": sign_asset_url(m.url), "type": m.media_type, "owner_id": str(tour.id)})
    for item in sorted(tour.items, key=lambda i: i.order_index):
        if item.poi:
            p = item.poi.model_dump(include={'id', 'title_ru', 'description_ru', 'lat', 'lon'})
            pois_data.append({"order_index": item.order_index, **p})
            for n in item.poi.narrations:
                assets.append({"url": sign_asset_url(n.url), "type": "audio", "owner_id": str(item.poi.id), "locale": n.locale, "duration": n.duration_seconds})
            for m in item.poi.media:
                assets.append({"url": sign_asset_url(m.url), "type": m.media_type, "owner_id": str(item.poi.id)})
    return {"tour": data, "pois": pois_data, "assets": assets}

@router.get("/public/tours")
def get_tours(response: Response, request: Request, city: str = Query(...), session: Session = Depends(get_session)):
    etag = generate_version_marker(session, Tour, city)
    check_etag_versioned(request, response, etag)
    tours = session.exec(select(Tour).where(Tour.city_slug == city, Tour.published_at != None)).all()
    return [t.model_dump(include={'id', 'city_slug', 'title_ru', 'description_ru', 'duration_minutes', 'published_at'}) for t in tours]

@router.get("/public/tours/{tour_id}")
def get_tour_detail(response: Response, request: Request, tour_id: uuid.UUID, city: str = Query(...), device_anon_id: Optional[str] = Query(None), session: Session = Depends(get_session)):
    tour = session.get(Tour, tour_id)
    if not tour or tour.city_slug != city or not tour.published_at: raise HTTPException(status_code=404, detail="Not Found")
    
    has_access = check_access(session, city, device_anon_id, tour_id)
    etag = f"{SCHEMA_VERSION}|{tour.id}|{tour.updated_at}|{has_access}"
    check_etag_versioned(request, response, f'W/"{hashlib.md5(etag.encode()).hexdigest()}"', is_public=not has_access)
    
    items = []
    for item in sorted(tour.items, key=lambda i: i.order_index):
        if item.poi:
             items.append({"id": str(item.id), "order_index": item.order_index, "poi": item.poi.model_dump(include={'id', 'title_ru', 'lat', 'lon', 'preview_audio_url', 'preview_bullets'})})
    return {**tour.model_dump(exclude={'items', 'sources', 'media'}), "items": items, "sources": [s.model_dump() for s in tour.sources], "media": [m.model_dump() for m in tour.media], "has_access": has_access}

@router.get("/public/poi/{poi_id}")
def get_poi_detail(response: Response, request: Request, poi_id: uuid.UUID, city: str = Query(...), device_anon_id: Optional[str] = Query(None), session: Session = Depends(get_session)):
    poi = session.get(Poi, poi_id)
    if not poi or poi.city_slug != city or not poi.published_at: raise HTTPException(status_code=404, detail="Not Found")
    
    has_access = check_access(session, city, device_anon_id)
    # Individual POI might change, but updated_at is the master marker
    etag = f"{SCHEMA_VERSION}|{poi.id}|{poi.updated_at}|{has_access}"
    check_etag_versioned(request, response, f'W/"{hashlib.md5(etag.encode()).hexdigest()}"', is_public=not has_access)
    
    data = poi.model_dump(exclude={'geo'})
    data["sources"] = [s.model_dump() for s in poi.sources]
    data["media"] = [m.model_dump() for m in poi.media]
    data["has_access"] = has_access
    if not has_access:
        data["narrations"] = [] 
    else:
        data["narrations"] = [{"id": str(n.id), "url": sign_asset_url(n.url), "locale": n.locale} for n in poi.narrations]
    return data



@router.get("/public/nearby")
@limiter.limit("50/minute") # Geo-postgis is somewhat expensive
def get_nearby(response: Response, city: str = Query(...), lat: float = Query(...), lon: float = Query(...), radius_m: int = Query(1000, le=5000), session: Session = Depends(get_session)):
    poi_sql = text("SELECT id, 'poi' as type, title_ru, lat, lon, ST_Distance(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography) as dist FROM poi WHERE city_slug = :city AND published_at IS NOT NULL AND ST_DWithin(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)")
    results = []
    for row in session.exec(poi_sql, params={"city": city, "lat": lat, "lon": lon, "radius": radius_m}).all():
        results.append({"id": row[0], "type": "poi", "title": row[2], "lat": row[3], "lon": row[4], "distance_m": int(row[5])})
    results.sort(key=lambda x: x["distance_m"])
    response.headers["Cache-Control"] = "public, max-age=10" # Nearby is very reactive
    return results[:50]

@router.get("/public/cities")
def get_cities(response: Response, request: Request, session: Session = Depends(get_session)):
    etag = generate_version_marker(session, City)
    check_etag_versioned(request, response, etag)
    cities = session.exec(select(City).where(City.is_active == True)).all()
    return [city.model_dump(exclude={'pois', 'tours'}) for city in cities]

@router.get("/public/catalog")
def get_catalog(response: Response, request: Request, city: str = Query(...), session: Session = Depends(get_session)):
    etag = generate_version_marker(session, Tour, city)
    check_etag_versioned(request, response, etag)
    tours = session.exec(select(Tour).where(Tour.city_slug == city, Tour.published_at != None)).all()
    return [t.model_dump(include={'id', 'title_ru', 'city_slug', 'duration_minutes'}) for t in tours]

@router.get("/public/map/attribution")
def get_map_attribution(response: Response):
    response.headers["Cache-Control"] = "public, max-age=3600"
    return {"attribution_text": "© OpenStreetMap contributors", "attribution_url": "https://www.openstreetmap.org/copyright"}

@router.get("/public/helpers")
def get_helpers(response: Response, request: Request, city: str = Query(...), category: Optional[str] = Query(None), session: Session = Depends(get_session)):
    q = select(HelperPlace).where(HelperPlace.city_slug == city)
    if category: q = q.where(HelperPlace.type == category)
    helpers = session.exec(q).all()
    return [h.model_dump(exclude={'geo'}) for h in helpers]
