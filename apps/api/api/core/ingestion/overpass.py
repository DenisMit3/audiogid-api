import requests
import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

OVERPASS_URL = "http://overpass-api.de/api/interpreter"

# Configuration for cities (hardcoded for MVP)
CITY_CONFIG = {
    "kaliningrad_city": {
        "area_name": "Калининград",
        "osm_id": 1674442, # Valid Relation ID for Kaliningrad City? (Need to verify or use name)
        # Using name is safer if ID changes, but slower. Relation ID is robust.
        # Relation 1674442 is "Gorodskoy okrug gorod Kaliningrad"
    },
    "kaliningrad_oblast": {
        "area_name": "Калининградская область",
        "osm_id": 103906
    }
}

def fetch_params_from_config(city_slug: str):
    return CITY_CONFIG.get(city_slug)

def query_osm(city_slug: str) -> List[Dict[str, Any]]:
    config = fetch_params_from_config(city_slug)
    if not config:
        logger.error(f"No configuration for city: {city_slug}")
        return []
    
    # Query logic:
    # 1. Get Area by name (or id)
    # 2. Search POIs (tourism, historic, etc)
    
    area_filter = f'area["name"="{config["area_name"]}"]->.searchArea;'
    
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
        resp = requests.post(OVERPASS_URL, data={"data": query}, timeout=30)
        resp.raise_for_status()
        data = resp.json()
        return data.get("elements", [])
    except Exception as e:
        logger.error(f"Overpass query failed: {e}")
        raise e
