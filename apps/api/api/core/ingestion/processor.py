import logging
import json
from sqlmodel import Session, select
from ..models import Poi, PoiStaging, City, PoiMedia
from .overpass import query_osm
from .wikidata import fetch_wikidata_data

logger = logging.getLogger(__name__)

async def run_ingestion(session: Session, city_slug: str):
    logger.info(f"Starting ingestion for {city_slug}")
    
    # Check city exists
    city = session.exec(select(City).where(City.slug == city_slug)).first()
    if not city:
        logger.error(f"City not found: {city_slug}")
        return {"error": "City not found"}

    try:
        # Sync call is fine here for now
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
        
        # 2. POI Upsert
        if not name_ru:
            continue 
            
        # Try finding POI by osm_id
        poi = session.exec(select(Poi).where(Poi.osm_id == osm_uniq_id)).first()
        
        lat = el.get("lat", el.get("center", {}).get("lat"))
        lon = el.get("lon", el.get("center", {}).get("lon"))
        
        is_new = False
        if not poi:
            poi = Poi(
                city_slug=city_slug,
                title_ru=name_ru,
                osm_id=osm_uniq_id,
                description_ru=tags.get("description:ru", tags.get("description")),
                lat=lat,
                lon=lon
            )
            is_new = True
        else:
            poi.title_ru = name_ru
            poi.lat = lat
            poi.lon = lon
            desc = tags.get("description:ru", tags.get("description"))
            if desc:
                poi.description_ru = desc
        
        # 3. Wikidata Enrichment
        wd_id = tags.get("wikidata") or tags.get("brand:wikidata")
        if wd_id:
            try:
                wd_data = await fetch_wikidata_data(wd_id)
                if wd_data:
                    poi.wikidata_id = wd_id
                    poi.confidence_score = 1.0
                    
                    # Update description if missing in OSM
                    if not poi.description_ru and wd_data.get("description_ru"):
                         poi.description_ru = wd_data.get("description_ru")
                    
                    # Add Image from Commons
                    img_url = wd_data.get("image_url")
                    if img_url:
                        # Check exist media to avoid dupes (naive check)
                        # We need to save the poi first to get ID for relation? 
                        # Only if it's new. But SQLModel object might not have ID if not flushed.
                        # We will handle media AFTER flush.
                        pass
            except Exception as e:
                 logger.error(f"Enrichment failed for {osm_uniq_id}: {e}")

        session.add(poi)
        
        # Should flush to get ID for media relation
        # But flush in loop is slow. For MVP okay.
        session.flush() # Ensure poi.id is available
        session.refresh(poi)

        if wd_id and 'wd_data' in locals() and wd_data and wd_data.get("image_url"):
             img_url = wd_data.get("image_url")
             # Check if this URL already exists
             exists_media = session.exec(select(PoiMedia).where(PoiMedia.poi_id == poi.id, PoiMedia.url == img_url)).first()
             if not exists_media:
                 media = PoiMedia(
                     poi_id=poi.id,
                     url=img_url,
                     media_type="image",
                     license_type=wd_data.get("image_license", "Unknown"),
                     author=wd_data.get("image_author", "WikiCommons"),
                     source_page_url=wd_data.get("source_page_url", f"https://commons.wikimedia.org/wiki/File:{wd_data['image_filename']}")
                 )
                 session.add(media)
             elif exists_media.license_type == "Commons":
                 exists_media.license_type = wd_data.get("image_license", "Unknown")
                 exists_media.author = wd_data.get("image_author", "WikiCommons")
                 exists_media.source_page_url = wd_data.get("source_page_url", exists_media.source_page_url)
                 session.add(exists_media)
        
        if is_new:
            count_poi += 1
            
    session.commit()
    logger.info(f"Ingestion finished. Staged: {count_staged}, POIs created: {count_poi}")
    return {"staged": count_staged, "pois_created": count_poi}
