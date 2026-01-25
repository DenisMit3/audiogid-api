import logging
import json
from sqlmodel import Session, select
from ..models import Poi, PoiStaging, City
from .overpass import query_osm

logger = logging.getLogger(__name__)

def run_ingestion(session: Session, city_slug: str):
    logger.info(f"Starting ingestion for {city_slug}")
    
    # Check city exists
    city = session.exec(select(City).where(City.slug == city_slug)).first()
    if not city:
        logger.error(f"City not found: {city_slug}")
        return {"error": "City not found"}

    try:
        elements = query_osm(city_slug)
    except Exception as e:
        return {"error": str(e)}
        
    count_staged = 0
    count_poi = 0
    
    for el in elements:
        osm_type = el.get("type")
        osm_id_raw = el.get("id")
        if not osm_type or not osm_id_raw:
            continue
            
        osm_uniq_id = f"{osm_type}/{osm_id_raw}"
        
        # 1. Staging Upsert
        staging = session.exec(select(PoiStaging).where(
            PoiStaging.city_slug == city_slug,
            PoiStaging.osm_id == osm_uniq_id
        )).first()
        
        payload_str = json.dumps(el, ensure_ascii=False)
        tags = el.get("tags", {})
        name_ru = tags.get("name:ru", tags.get("name", tags.get("int_name")))
        
        if not staging:
            staging = PoiStaging(
                city_slug=city_slug,
                osm_id=osm_uniq_id,
                raw_payload=payload_str,
                name_ru=name_ru
            )
            session.add(staging)
        else:
            staging.raw_payload = payload_str
            staging.name_ru = name_ru
            session.add(staging)
            
        count_staged += 1
        
        # 2. POI Upsert (Simple MVP Logic)
        if not name_ru:
            continue # Skip unnamed POIs for main table
            
        # Try finding POI by osm_id
        poi = session.exec(select(Poi).where(Poi.osm_id == osm_uniq_id)).first()
        
        lat = el.get("lat", el.get("center", {}).get("lat"))
        lon = el.get("lon", el.get("center", {}).get("lon"))
        
        if not poi:
            # Create new
            poi = Poi(
                city_slug=city_slug,
                title_ru=name_ru,
                osm_id=osm_uniq_id,
                description_ru=tags.get("description:ru", tags.get("description")),
                lat=lat,
                lon=lon
            )
            session.add(poi)
            count_poi += 1
        else:
            # Update existing
            # Respect editor lock (TODO: add check if field exists, for now just overwrite title/desc)
            poi.title_ru = name_ru
            poi.lat = lat
            poi.lon = lon
            desc = tags.get("description:ru", tags.get("description"))
            if desc:
                poi.description_ru = desc
            session.add(poi)
            # count_poi += 0 (updated)
            
    session.commit()
    logger.info(f"Ingestion finished. Staged: {count_staged}, POIs created: {count_poi}")
    return {"staged": count_staged, "pois_created": count_poi}
