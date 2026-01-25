import logging
from typing import List, Optional
from fastapi import APIRouter, Depends, Response, Query, HTTPException, Request
from sqlmodel import Session, select, text
import uuid

from .core.database import engine
from .core.models import City, Tour, Poi, HelperPlace, Entitlement, EntitlementGrant
from .core.caching import check_etag
from .core.security import sign_asset_url

logger = logging.getLogger(__name__)
router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

def check_access(session: Session, city: str, device_anon_id: str, tour_id: Optional[uuid.UUID] = None) -> bool:
    """
    Checks if a device has an active EntitlementGrant for the city or specific tour.
    """
    if not device_anon_id:
        return False
        
    # Check for specific tour grant first
    if tour_id:
        grant = session.exec(select(EntitlementGrant).join(Entitlement).where(
            EntitlementGrant.device_anon_id == device_anon_id,
            EntitlementGrant.revoked_at == None,
            Entitlement.scope == "tour",
            Entitlement.ref == str(tour_id)
        )).first()
        if grant: return True

    # Check for city-wide grant
    city_grant = session.exec(select(EntitlementGrant).join(Entitlement).where(
        EntitlementGrant.device_anon_id == device_anon_id,
        EntitlementGrant.revoked_at == None,
        Entitlement.scope == "city",
        Entitlement.ref == city
    )).first()
    
    return city_grant is not None

@router.get("/public/tours/{tour_id}/manifest")
def get_tour_manifest(
    response: Response,
    request: Request,
    tour_id: uuid.UUID,
    city: str = Query(..., description="Tenant slug"),
    device_anon_id: str = Query(..., description="Device binding for entitlement check"),
    session: Session = Depends(get_session)
):
    """
    Offline Manifest: Full tour data. Gated by EntitlementGrant.
    """
    response.headers["Cache-Control"] = "no-store"

    if not check_access(session, city, device_anon_id, tour_id):
        raise HTTPException(status_code=403, detail="Payment Required", headers={"Cache-Control": "no-store"})
        
    tour = session.get(Tour, tour_id)
    if not tour or tour.city_slug != city or not tour.published_at:
        raise HTTPException(status_code=404, detail="Tour not found", headers={"Cache-Control": "no-store"})
        
    manifest_tour = tour.model_dump(include={'id', 'city_slug', 'title_ru', 'description_ru', 'duration_minutes', 'published_at'})
    manifest_pois = []
    assets = []
    
    def add_asset(url, type_hint, owner_id):
        assets.append({"url": url, "type": type_hint, "owner_id": str(owner_id)})

    for media in tour.media:
        add_asset(sign_asset_url(media.url), media.media_type, tour.id)
        
    items_sorted = sorted(tour.items, key=lambda i: i.order_index)
    for item in items_sorted:
        if item.poi:
            p_data = item.poi.model_dump(include={'id', 'title_ru', 'description_ru', 'lat', 'lon'})
            manifest_pois.append({"order_index": item.order_index, **p_data})
            for narr in item.poi.narrations:
                assets.append({
                    "url": sign_asset_url(narr.url), 
                    "type": "audio", 
                    "owner_id": str(item.poi.id),
                    "locale": narr.locale,
                    "duration": narr.duration_seconds
                })
            for m in item.poi.media:
                add_asset(sign_asset_url(m.url), m.media_type, item.poi.id)
    
    return {"tour": manifest_tour, "pois": manifest_pois, "assets": assets}

@router.get("/public/tours")
def get_tours(response: Response, request: Request, city: str = Query(...), session: Session = Depends(get_session)):
    tours = session.exec(select(Tour).where(Tour.city_slug == city, Tour.published_at != None)).all()
    data = [tour.model_dump(include={'id', 'city_slug', 'title_ru', 'description_ru', 'duration_minutes', 'published_at'}) for tour in tours]
    response.headers["Cache-Control"] = "public, max-age=60"
    check_etag(request, response, data)
    return data

@router.get("/public/tours/{tour_id}")
def get_tour_detail(
    response: Response,
    request: Request,
    tour_id: uuid.UUID,
    city: str = Query(...),
    device_anon_id: Optional[str] = Query(None),
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour or tour.city_slug != city or not tour.published_at:
        raise HTTPException(status_code=404, detail="Not Found")
    
    has_access = check_access(session, city, device_anon_id, tour_id)
    items_sorted = sorted(tour.items, key=lambda i: i.order_index)
    items_data = []
    
    for item in items_sorted:
        if item.poi:
             poi_data = item.poi.model_dump(include={'id', 'title_ru', 'lat', 'lon', 'preview_audio_url', 'preview_bullets'})
             items_data.append({"id": str(item.id), "order_index": item.order_index, "poi": poi_data})
             
    data = {
        **tour.model_dump(exclude={'items', 'sources', 'media'}),
        "items": items_data,
        "sources": [s.model_dump() for s in tour.sources],
        "media": [m.model_dump() for m in tour.media],
        "has_access": has_access
    }
    response.headers["Cache-Control"] = "private, max-age=60"
    check_etag(request, response, data)
    return data

@router.get("/public/poi/{poi_id}")
def get_poi_detail(
    response: Response,
    request: Request,
    poi_id: uuid.UUID,
    city: str = Query(...),
    device_anon_id: Optional[str] = Query(None),
    session: Session = Depends(get_session)
):
    poi = session.get(Poi, poi_id)
    if not poi or poi.city_slug != city or not poi.published_at:
        raise HTTPException(status_code=404, detail="Not Found")
    
    # Check if this POI belongs to any tour the user has access to, or city-wide access
    # Simpler: check city-wide access only for POI detail if it's not part of a specific tour manifest call
    has_access = check_access(session, city, device_anon_id)
    
    data = poi.model_dump(exclude={'geo'})
    data["sources"] = [s.model_dump() for s in poi.sources]
    data["media"] = [m.model_dump() for m in poi.media]
    data["has_access"] = has_access
    
    if not has_access:
        # Hide full narrations, keep only preview
        data["narrations"] = [] 
    else:
        # Sign narration URLs only for entitled users
        data["narrations"] = [{"id": str(n.id), "url": sign_asset_url(n.url), "locale": n.locale} for n in poi.narrations]

    response.headers["Cache-Control"] = "private, max-age=60"
    check_etag(request, response, data)
    return data

@router.get("/public/nearby")
def get_nearby(response: Response, city: str = Query(...), lat: float = Query(...), lon: float = Query(...), radius_m: int = Query(1000, le=5000), session: Session = Depends(get_session)):
    poi_sql = text("SELECT id, 'poi' as type, title_ru, lat, lon, ST_Distance(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography) as dist FROM poi WHERE city_slug = :city AND published_at IS NOT NULL AND ST_DWithin(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)")
    results = []
    for row in session.exec(poi_sql, params={"city": city, "lat": lat, "lon": lon, "radius": radius_m}).all():
        results.append({"id": row[0], "type": "poi", "title": row[2], "lat": row[3], "lon": row[4], "distance_m": int(row[5])})
    results.sort(key=lambda x: x["distance_m"])
    return results[:50]

@router.get("/public/cities")
def get_cities(response: Response, request: Request, session: Session = Depends(get_session)):
    cities = session.exec(select(City).where(City.is_active == True)).all()
    data = [city.model_dump(exclude={'pois', 'tours'}) for city in cities]
    check_etag(request, response, data)
    return data

@router.get("/public/catalog")
def get_catalog(response: Response, request: Request, city: str = Query(...), session: Session = Depends(get_session)):
    # Discovery only - no narrations or full data here
    tours = session.exec(select(Tour).where(Tour.city_slug == city, Tour.published_at != None)).all()
    data = [t.model_dump(include={'id', 'title_ru', 'city_slug', 'duration_minutes'}) for t in tours]
    check_etag(request, response, data)
    return data

@router.get("/public/map/attribution")
def get_map_attribution(response: Response):
    return {"attribution_text": "© OpenStreetMap contributors", "attribution_url": "https://www.openstreetmap.org/copyright"}

@router.get("/public/helpers")
def get_helpers(response: Response, request: Request, city: str = Query(...), category: Optional[str] = Query(None), session: Session = Depends(get_session)):
    q = select(HelperPlace).where(HelperPlace.city_slug == city)
    if category: q = q.where(HelperPlace.type == category)
    helpers = session.exec(q).all()
    data = [h.model_dump(exclude={'geo'}) for h in helpers]
    check_etag(request, response, data)
    return data
