import uuid
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import List, Optional
from fastapi import APIRouter, Depends, Response, Query, HTTPException, Request, BackgroundTasks
from sqlmodel import Session, select, text, func, SQLModel
from sqlalchemy.orm import selectinload, joinedload
from slowapi import Limiter
from slowapi.util import get_remote_address

from .core.database import engine

from .core.models import City, Tour, Poi, HelperPlace, Entitlement, EntitlementGrant, ContentEvent, TourItem, Itinerary, ItineraryItem
from .core.caching import redis_client
from .core.security import sign_asset_url
from .core.caching import SCHEMA_VERSION, generate_version_marker, check_etag_versioned

router = APIRouter()
limiter = Limiter(key_func=get_remote_address)

def get_session():
    with Session(engine) as session:
        yield session

def check_access(session: Session, city: str, device_anon_id: Optional[str], tour_id: Optional[uuid.UUID] = None) -> bool:
    """
    Checks if a device has an active entitlement for a city or a specific tour.
    Admin bypass is handled at middleware or auth level if needed, 
    but for public manifest endpoints we check device_anon_id.
    """
    # 0. Check if tour has a FREE entitlement (price_amount = 0)
    if tour_id:
        free_entitlement = session.exec(
            select(Entitlement).where(
                Entitlement.scope == "tour",
                Entitlement.ref == str(tour_id),
                Entitlement.price_amount == 0,
                Entitlement.is_active == True
            )
        ).first()
        if free_entitlement:
            return True
    
    if not device_anon_id:
        return False
        
    # 1. Check City-wide access
    query = select(EntitlementGrant).where(
        EntitlementGrant.device_anon_id == device_anon_id,
        EntitlementGrant.revoked_at == None
    ).join(Entitlement).where(
        Entitlement.scope == "city",
        Entitlement.ref == city
    )
    if session.exec(query).first():
        return True
        
    # 2. Check Specific Tour access if tour_id is provided
    if tour_id:
        query = select(EntitlementGrant).where(
            EntitlementGrant.device_anon_id == device_anon_id,
            EntitlementGrant.revoked_at == None
        ).join(Entitlement).where(
            Entitlement.scope == "tour",
            Entitlement.ref == str(tour_id)
        )
        if session.exec(query).first():
            return True
            
    return False

def log_analytics_bg(event_data: dict):
    with Session(engine) as session:
        try:
             event = ContentEvent(**event_data)
             session.add(event)
             session.commit()
        except Exception as e:
            print(f"Failed to log event: {e}")

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
            # Include override coordinates and effective coordinates
            poi_lat = item.poi.lat
            poi_lon = item.poi.lon
            effective_lat = item.override_lat if item.override_lat is not None else poi_lat
            effective_lon = item.override_lon if item.override_lon is not None else poi_lon
            pois_data.append({
                "order_index": item.order_index, 
                **p,
                "override_lat": item.override_lat,
                "override_lon": item.override_lon,
                "effective_lat": effective_lat,
                "effective_lon": effective_lon
            })
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
                    "kids_url": sign_asset_url(n["kids_url"]) if n.get("kids_url") else None,
                    "locale": n["locale"], 
                    "duration_seconds": n["duration_seconds"],
                    "transcript": n.get("transcript")
                } for n in raw_narrations
            ]
    return data



@router.get("/public/nearby")
@limiter.limit("50/minute") # Geo-postgis is somewhat expensive
def get_nearby(response: Response, request: Request, city: str = Query(...), lat: float = Query(...), lon: float = Query(...), radius_m: int = Query(1000, le=5000), session: Session = Depends(get_session)):
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
    
    return [t.model_dump(include={'id', 'title_ru', 'city_slug', 'duration_minutes', 'cover_image', 'distance_km', 'tour_type', 'description_ru'}) for t in tours]

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
    return [t.model_dump(include={'id', 'title_ru', 'description_ru', 'cover_image', 'duration_minutes', 'tour_type', 'difficulty', 'distance_km'}) for t in tours]

@router.get("/public/cities/{slug}/offline-manifest")
def get_city_offline_manifest(
    response: Response, 
    request: Request, 
    slug: str, 
    session: Session = Depends(get_session)
):
    """
    Синхронный эндпоинт для получения оффлайн манифеста города.
    Возвращает список всех ресурсов (аудио, изображения) для загрузки.
    Не требует QStash - клиент сам скачивает файлы по URL.
    """
    city = session.exec(select(City).where(City.slug == slug)).first()
    if not city:
        raise HTTPException(status_code=404, detail="City not found")
    
    # Загружаем все опубликованные POI с их медиа и нарациями
    pois = session.exec(
        select(Poi)
        .where(Poi.city_slug == slug, Poi.published_at != None)
        .options(selectinload(Poi.narrations), selectinload(Poi.media))
    ).all()
    
    # Загружаем все опубликованные туры
    tours = session.exec(
        select(Tour)
        .where(Tour.city_slug == slug, Tour.published_at != None)
        .options(selectinload(Tour.items), selectinload(Tour.media))
    ).all()
    
    # Формируем список ресурсов для загрузки
    assets = []
    pois_data = []
    tours_data = []
    
    for poi in pois:
        poi_dict = poi.model_dump(include={'id', 'title_ru', 'description_ru', 'lat', 'lon', 'category', 'cover_image'})
        pois_data.append(poi_dict)
        
        # Аудио нарации
        for n in poi.narrations:
            if n.url:
                assets.append({
                    "id": str(n.id),
                    "url": sign_asset_url(n.url),
                    "type": "audio",
                    "owner_type": "poi",
                    "owner_id": str(poi.id),
                    "locale": n.locale,
                    "duration": n.duration_seconds
                })
        
        # Медиа (изображения)
        for m in poi.media:
            if m.url:
                assets.append({
                    "id": str(m.id),
                    "url": sign_asset_url(m.url),
                    "type": m.media_type or "image",
                    "owner_type": "poi",
                    "owner_id": str(poi.id)
                })
    
    for tour in tours:
        tour_dict = tour.model_dump(include={'id', 'title_ru', 'description_ru', 'duration_minutes', 'tour_type', 'cover_image', 'distance_km'})
        tour_dict['item_ids'] = [str(item.poi_id) for item in sorted(tour.items, key=lambda i: i.order_index) if item.poi_id]
        tours_data.append(tour_dict)
        
        # Медиа тура
        for m in tour.media:
            if m.url:
                assets.append({
                    "id": str(m.id),
                    "url": sign_asset_url(m.url),
                    "type": m.media_type or "image",
                    "owner_type": "tour",
                    "owner_id": str(tour.id)
                })
    
    # Кэшируем на 5 минут
    response.headers["Cache-Control"] = "public, max-age=300"
    
    return {
        "city": city.model_dump(include={'id', 'slug', 'name_ru', 'name_en'}),
        "pois": pois_data,
        "tours": tours_data,
        "assets": assets,
        "total_assets": len(assets)
    }


# --- Itineraries ---

class ItineraryCreate(SQLModel):
    title: str
    city_slug: str
    poi_ids: List[uuid.UUID]
    device_anon_id: str 

@router.post("/public/itineraries")
def create_itinerary(
    request: Request, 
    payload: ItineraryCreate, 
    session: Session = Depends(get_session)
):
    # limit creations per IP?
    itinerary = Itinerary(
        title=payload.title,
        city_slug=payload.city_slug,
        device_anon_id=payload.device_anon_id
        # user_id handling if we have auth later
    )
    session.add(itinerary)
    session.commit()
    session.refresh(itinerary)
    
    for index, poi_id in enumerate(payload.poi_ids):
        item = ItineraryItem(
            itinerary_id=itinerary.id,
            poi_id=poi_id,
            order_index=index
        )
        session.add(item)
    
    session.commit()
    return {"id": itinerary.id, "share_token": itinerary.id} # Use ID as token for now

@router.get("/public/itineraries/{itinerary_id}")
def get_itinerary(itinerary_id: uuid.UUID, session: Session = Depends(get_session)):
    itinerary = session.exec(
        select(Itinerary)
        .where(Itinerary.id == itinerary_id)
        .options(selectinload(Itinerary.items).joinedload(ItineraryItem.poi))
    ).first()
    
    if not itinerary:
        raise HTTPException(status_code=404, detail="Itinerary not found")
        
    items_sorted = sorted(itinerary.items, key=lambda x: x.order_index)
    
    return {
        "id": itinerary.id,
        "title": itinerary.title,
        "city_slug": itinerary.city_slug,
        "items": [
            {
                "poi": item.poi.model_dump(include={'id', 'title_ru', 'cover_image', 'category', 'lat', 'lon'}) if item.poi else None,
                "order_index": item.order_index
            }
            for item in items_sorted if item.poi
        ]
    }

@router.get("/public/itineraries/{itinerary_id}/manifest")
def get_itinerary_manifest(
    response: Response, 
    request: Request, 
    itinerary_id: uuid.UUID, 
    session: Session = Depends(get_session)
):
    # Returns format compatible with Tour Manifest
    itinerary = session.exec(
        select(Itinerary)
        .where(Itinerary.id == itinerary_id)
        .options(
            selectinload(Itinerary.items).joinedload(ItineraryItem.poi).options(
                selectinload(Poi.narrations),
                selectinload(Poi.media)
            )
        )
    ).first()
    
    if not itinerary:
        raise HTTPException(status_code=404, detail="Itinerary not found")
        
    # Duck-typing into Tour format
    data = {
        "id": itinerary.id,
        "city_slug": itinerary.city_slug,
        "title_ru": itinerary.title,
        "description_ru": "Custom Itinerary",
        "duration_minutes": 0, # Calculate?
        "published_at": itinerary.created_at # Mock
    }
    
    pois_data = []
    assets = []
    
    for item in sorted(itinerary.items, key=lambda i: i.order_index):
        if item.poi:
            p = item.poi.model_dump(include={'id', 'title_ru', 'description_ru', 'lat', 'lon'})
            pois_data.append({"order_index": item.order_index, **p})
            for n in item.poi.narrations:
                assets.append({"url": sign_asset_url(n.url), "type": "audio", "owner_id": str(item.poi.id), "locale": n.locale, "duration": n.duration_seconds})
            for m in item.poi.media:
                assets.append({"url": sign_asset_url(m.url), "type": m.media_type, "owner_id": str(item.poi.id)})
                
    response.headers["Cache-Control"] = "private, no-store"
    return {"tour": data, "pois": pois_data, "assets": assets}

@router.put("/public/itineraries/{itinerary_id}")
def update_itinerary(
    itinerary_id: uuid.UUID,
    payload: ItineraryCreate, # Reuse create schema for full update
    session: Session = Depends(get_session)
):
    itinerary = session.exec(
        select(Itinerary).where(Itinerary.id == itinerary_id)
    ).first()
    
    if not itinerary:
        raise HTTPException(status_code=404, detail="Itinerary not found")
        
    # Check ownership using device_anon_id? 
    if itinerary.device_anon_id != payload.device_anon_id:
         raise HTTPException(status_code=403, detail="Not authorized to edit this itinerary")
         
    itinerary.title = payload.title
    session.add(itinerary)
    
    # Replace items
    session.exec(select(ItineraryItem).where(ItineraryItem.itinerary_id == itinerary_id)).all() 
    # Actually better to delete all and recreate
    # session.exec(delete(ItineraryItem).where(...)) -> SQLModel support for delete?
    # Idiomatic:
    item_rows = session.exec(select(ItineraryItem).where(ItineraryItem.itinerary_id == itinerary_id)).all()
    for row in item_rows:
        session.delete(row)
        
    for index, poi_id in enumerate(payload.poi_ids):
        item = ItineraryItem(
            itinerary_id=itinerary.id,
            poi_id=poi_id,
            order_index=index
        )
        session.add(item)
        
    session.commit()
    return {"status": "ok"}


# --- Share Trip / SOS ---

class TripShareRequest(SQLModel):
    lat: float
    lon: float
    ttl_seconds: int = 3600 # Default 1 hour
    device_anon_id: Optional[str] = None
    
@router.post("/public/share/trip")
def create_trip_share(
    payload: TripShareRequest,
    request: Request
):
    # limit?
    share_id = secrets.token_urlsafe(6)
    data = {
        "lat": payload.lat, 
        "lon": payload.lon, 
        "created_at": datetime.utcnow().isoformat(),
        "device_anon_id": payload.device_anon_id
    }
    
    if redis_client:
        redis_client.setex(f"share:{share_id}", payload.ttl_seconds, json.dumps(data))
    else:
        # Fallback for dev without redis? Or just error.
        # Ideally we need redis for TTL.
        pass

    # Construct web URL.
    # We assume the API domain is the share domain for simplicity.
    base_url = str(request.base_url).rstrip('/')
    share_url = f"{base_url}/public/share/trip/{share_id}"
    
    return {
        "share_id": share_id, 
        "share_url": share_url,
        "expires_at": (datetime.utcnow() + timedelta(seconds=payload.ttl_seconds)).isoformat()
    }

from fastapi.responses import HTMLResponse

@router.get("/public/share/trip/{share_id}", response_class=HTMLResponse)
def view_trip_share(share_id: str):
    data_raw = None
    if redis_client:
        data_raw = redis_client.get(f"share:{share_id}")
    
    if not data_raw:
        return HTMLResponse(content="<h1>Link Expired</h1><p>This location share link has expired.</p>", status_code=404)
        
    data = json.loads(data_raw)
    lat = data['lat']
    lon = data['lon']
    date_str = data['created_at']
    
    # Deep Link to app
    app_scheme = f"audiogid://share_trip?id={share_id}&lat={lat}&lon={lon}&time={date_str}"
    maps_link = f"https://www.google.com/maps/search/?api=1&query={lat},{lon}"
    
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Location Shared</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta property="og:title" content="Location Shared" />
        <meta property="og:description" content="Click to view shared location." />
        <script>
            window.onload = function() {{
                // Try to open app
                window.location.href = "{app_scheme}";
                // Fallback after timeout? Browser might handle "Unknown scheme" error poorly.
            }};
        </script>
        <style>
            body {{ font-family: sans-serif; text-align: center; padding: 20px; }}
            .btn {{ display: inline-block; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; margin: 10px; }}
            .btn-map {{ background: #28a745; }}
        </style>
    </head>
    <body>
        <h2>Location Shared</h2>
        <p>Time: {date_str}</p>
        <p>
            <a href="{app_scheme}" class="btn">Open in App</a>
        </p>
        <p>
            <a href="{maps_link}" class="btn btn-map">View on Google Maps</a>
        </p>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content)
