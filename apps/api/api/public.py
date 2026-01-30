# Check status first
import uuid
import hashlib
from typing import List, Optional
from fastapi import APIRouter, Depends, Response, Query, HTTPException, Request, BackgroundTasks
from sqlmodel import Session, select, text, func
from sqlalchemy.orm import selectinload, joinedload
from slowapi import Limiter
from slowapi.util import get_remote_address

from .core.database import engine

from .core.models import City, Tour, Poi, HelperPlace, Entitlement, EntitlementGrant, ContentEvent, TourItem
from .core.caching import redis_client
import json

def log_analytics_bg(event_data: dict):
    with Session(engine) as session:
        try:
             event = ContentEvent(**event_data)
             session.add(event)
             session.commit()
        except Exception as e:
            print(f"Failed to log event: {e}")

# ...

@router.get("/public/tours/{tour_id}/manifest")
@limiter.limit("20/minute") # Heavy bundle data
def get_tour_manifest(
    response: Response, request: Request, tour_id: uuid.UUID, 
    background_tasks: BackgroundTasks, # Injected
    city: str = Query(...), 
    device_anon_id: str = Query(...), session: Session = Depends(get_session)
):
    """Gated Manifest: private, no-store."""
    if not check_access(session, city, device_anon_id, tour_id):
        raise HTTPException(status_code=403, detail="Payment Required", headers={"Cache-Control": "private, no-store"})
    
    # Optimized loading
    query = select(Tour).where(Tour.id == tour_id).options(
        selectinload(Tour.media),
        selectinload(Tour.items).joinedload(TourItem.poi).options(
            selectinload(Poi.narrations),
            selectinload(Poi.media)
        )
    )
    tour = session.exec(query).first()
    if not tour or tour.city_slug != city or not tour.published_at:
        raise HTTPException(status_code=404, detail="Tour not found", headers={"Cache-Control": "private, no-store"})
    
    # Analytics: TOUR_STARTED (Background)
    background_tasks.add_task(log_analytics_bg, {
        "event_type": "tour_started",
        "anon_id": device_anon_id,
        "entity_type": "tour",
        "entity_id": tour_id
    })

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

# ...

@router.get("/public/poi/{poi_id}")
@limiter.limit("100/minute")
def get_poi_detail(response: Response, request: Request, poi_id: uuid.UUID, 
                   background_tasks: BackgroundTasks,
                   city: str = Query(...), device_anon_id: Optional[str] = Query(None), session: Session = Depends(get_session)):
    # Try Cache
    poi_data_raw = None
    cache_key = f"poi:{poi_id}:raw"
    if redis_client:
        try:
            cached = redis_client.get(cache_key)
            if cached: poi_data_raw = json.loads(cached)
        except Exception: pass
    
    if not poi_data_raw:
        # Optimized Query
        query = select(Poi).where(Poi.id == poi_id).options(
            selectinload(Poi.sources),
            selectinload(Poi.media),
            selectinload(Poi.narrations)
        )
        poi = session.exec(query).first()
        if not poi or poi.city_slug != city or not poi.published_at: raise HTTPException(status_code=404, detail="Not Found")
        
        # Serialize
        poi_data_raw = poi.model_dump(exclude={'geo'})
        poi_data_raw["sources"] = [s.model_dump() for s in poi.sources]
        poi_data_raw["media"] = [m.model_dump() for m in poi.media]
        poi_data_raw["narrations_raw"] = [n.model_dump() for n in poi.narrations]
        poi_data_raw["updated_at_iso"] = poi.updated_at.isoformat() if poi.updated_at else ""
        
        if redis_client:
            redis_client.setex(cache_key, 300, json.dumps(poi_data_raw))
    
    has_access = check_access(session, city, device_anon_id)
    # Individual POI might change, but updated_at is the master marker
    etag = f"{SCHEMA_VERSION}|{poi_id}|{poi_data_raw.get('updated_at_iso')}|{has_access}"
    check_etag_versioned(request, response, f'W/"{hashlib.md5(etag.encode()).hexdigest()}"', is_public=not has_access)
    
    # Cache Control for Public access
    if not has_access:
        # Public data changes rarely, cache for 1 minute at CDN/Edge
        response.headers["Cache-Control"] = "public, max-age=60, s-maxage=60"
    else:
        # Private data (signed URLs) shouldn't be cached widely or for long
        response.headers["Cache-Control"] = "private, max-age=0, must-revalidate"

    # Analytics: POI_VIEWED (Background)
    if device_anon_id:
        background_tasks.add_task(log_analytics_bg, {
            "event_type": "poi_viewed",
            "anon_id": device_anon_id,
            "entity_type": "poi",
            "entity_id": poi_id
        })

    data = poi_data_raw.copy()
    data["has_access"] = has_access
    data["category"] = "Cultural Heritage" # Simplified for now
    
    if "narrations_raw" in data:
        raw_narrations = data.pop("narrations_raw")
        if not has_access:
            data["narrations"] = [] 
        else:
            data["narrations"] = [
                {
                    "id": str(n["id"]), 
                    "url": sign_asset_url(n["url"]), 
                    "locale": n["locale"], 
                    "duration_seconds": n["duration_seconds"],
                    "transcript": n.get("transcript")
                } for n in raw_narrations
            ]
    return data



@router.get("/public/nearby")
@limiter.limit("50/minute") # Geo-postgis is somewhat expensive
def get_nearby(response: Response, city: str = Query(...), lat: float = Query(...), lon: float = Query(...), radius_m: int = Query(1000, le=5000), session: Session = Depends(get_session)):
    # KNN Optimization: Use <-> operator for nearest neighbor search, then filter by radius.
    # This is much faster than checking ST_DWithin on entire table first if index exists.
    # Logic: Get nearest 50 points, then verify they are within radius.
    # Actually, standard pattern: ORDER BY geo <-> point LIMIT N.
    # But we also have `city_slug` constraint and `radius` constraint.
    # Index on (city_slug, geo) allows efficient filtering.
    
    # Using parameterized query for safety
    poi_sql = text("""
        SELECT 
            id, 'poi' as type, title_ru, lat, lon, 
            ST_Distance(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography) as dist 
        FROM poi 
        WHERE 
            city_slug = :city 
            AND published_at IS NOT NULL 
            -- AND ST_DWithin(geo, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)
        ORDER BY 
            geo <-> ST_SetSRID(ST_MakePoint(:lon, :lat), 4326) 
        LIMIT 50
    """)
    
    results = []
    for row in session.exec(poi_sql, params={"city": city, "lat": lat, "lon": lon, "radius": radius_m}).all():
        results.append({"id": row[0], "type": "poi", "title": row[2], "lat": row[3], "lon": row[4], "distance_m": int(row[5])})
    
    # Results are already sorted by Distance due to KNN operator
    response.headers["Cache-Control"] = "public, max-age=10" # Nearby is very reactive
    return results

@router.get("/public/cities")
def get_cities(response: Response, request: Request, session: Session = Depends(get_session)):
    etag = generate_version_marker(session, City)
    check_etag_versioned(request, response, etag)
    cities = session.exec(select(City).where(City.is_active == True)).all()
    return [city.model_dump(exclude={'pois', 'tours', 'osm_relation_id'}) for city in cities]

@router.get("/public/catalog")
def get_catalog(
    response: Response, 
    request: Request, 
    city: str = Query(...), 
    limit: int = Query(50, le=100),
    offset: int = Query(0),
    session: Session = Depends(get_session)
):
    etag = generate_version_marker(session, Tour, city)
    check_etag_versioned(request, response, etag)
    
    query = select(Tour).where(Tour.city_slug == city, Tour.published_at != None)
    
    # Count total (optional, skipping for performance unless needed by UI)
    # total = session.exec(select(func.count()).select_from(query.subquery())).one()
    
    tours = session.exec(query.offset(offset).limit(limit)).all()
    
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

# --- Phase 5: Mobile Sync Expanded ---

@router.get("/public/cities/{slug}")
def get_city_detail(response: Response, request: Request, slug: str, session: Session = Depends(get_session)):
    city = session.exec(select(City).where(City.slug == slug)).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
        
    etag = f"city|{slug}|{city.updated_at}" # Simple etag
    check_etag_versioned(request, response, f'W/"{hashlib.md5(etag.encode()).hexdigest()}"')
    
    return city.model_dump(exclude={'pois', 'tours', 'osm_relation_id'})

@router.get("/public/cities/{slug}/pois")
@limiter.limit("50/minute")
def get_city_pois(response: Response, request: Request, slug: str, page: int = 1, per_page: int = 50, session: Session = Depends(get_session)):
    # List POIs for "Map Mode" or "Catalog"
    offset = (page - 1) * per_page
    query = select(Poi).where(Poi.city_slug == slug, Poi.published_at != None)
    
    # ETag based on latest POI update in city? Expensive. 
    # For list, we might just cache short term or rely on client to not spam.
    # Let's use generic list caching.
    response.headers["Cache-Control"] = "public, max-age=60"
    
    total = session.exec(select(func.count()).select_from(query.subquery())).one()
    pois = session.exec(query.offset(offset).limit(per_page)).all()
    
    return {
        "items": [p.model_dump(include={'id', 'title_ru', 'category', 'lat', 'lon', 'cover_image'}) for p in pois],
        "total": total,
        "page": page,
        "per_page": per_page
    }

@router.get("/public/cities/{slug}/tours")
def get_city_tours(response: Response, request: Request, slug: str, session: Session = Depends(get_session)):
    tours = session.exec(select(Tour).where(Tour.city_slug == slug, Tour.published_at != None)).all()
    return [t.model_dump(include={'id', 'title_ru', 'description_ru', 'cover_image', 'duration_minutes', 'tour_type'}) for t in tours]

