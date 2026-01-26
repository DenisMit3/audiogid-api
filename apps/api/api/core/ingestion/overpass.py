import requests
import logging
from typing import List, Dict, Any
from ..config import config

logger = logging.getLogger(__name__)

# Configuration for cities (hardcoded for MVP)
CITY_CONFIG = {
    "kaliningrad_city": {
        "area_name": "Калининград",
        "osm_id": 1674442, # Gorodskoy okrug gorod Kaliningrad
    },
    "kaliningrad_oblast": {
        "area_name": "Калининградская область",
        "osm_id": 103906
    }
}

def fetch_params_from_config(city_slug: str):
    return CITY_CONFIG.get(city_slug)

def query_osm(city_slug: str) -> List[Dict[str, Any]]:
    city_conf = fetch_params_from_config(city_slug)
    if not city_conf:
        logger.error(f"No configuration for city: {city_slug}")
        return []
    
    # Query logic:
    # Use Relation ID for area -> map_to_area (much faster than name search)
    osm_id = city_conf.get("osm_id")
    if osm_id:
        area_filter = f"rel({osm_id});map_to_area->.searchArea;"
    else:
        # Fallback to name (inefficient)
        area_filter = f'area["name"="{city_conf["area_name"]}"]->.searchArea;'
    
    # Timeout 45s (must align with Vercel function limits if synchronous, 
    # but here we rely on Overpass responding fast or async worker handling it)
    query = f"""
    [out:json][timeout:25];
    {area_filter}
    (
      node["tourism"~"attraction|museum|viewpoint|artwork|monument"](area.searchArea);
      way["tourism"~"attraction|museum|viewpoint|artwork|monument"](area.searchArea);
      relation["tourism"~"attraction|museum|viewpoint|artwork|monument"](area.searchArea);
      
      node["historic"~"memorial|monument|ruins|castle"](area.searchArea);
      way["historic"~"memorial|monument|ruins|castle"](area.searchArea);
      relation["historic"~"memorial|monument|ruins|castle"](area.searchArea);
    );
    out center;
    """
    
    try:
        # requests timeout should be slightly larger than Overpass timeout
        resp = requests.post(config.OVERPASS_API_URL, data={"data": query}, timeout=30)
        resp.raise_for_status()
        data = resp.json()
        return data.get("elements", [])
    except Exception as e:
        logger.error(f"Overpass query failed: {e}")
        raise e
