import requests
import logging
from typing import List, Dict, Any
from ..config import config

logger = logging.getLogger(__name__)

def query_osm(osm_id: int = None, area_name: str = None) -> List[Dict[str, Any]]:
    if not osm_id and not area_name:
        logger.error("No osm_id or area_name provided for OSM query")
        return []
    
    # Query logic:
    # Use Relation ID for area -> map_to_area (much faster than name search)
    if osm_id:
        area_filter = f"rel({osm_id});map_to_area->.searchArea;"
    else:
        # Fallback to name (inefficient)
        area_filter = f'area["name"="{area_name}"]->.searchArea;'
    
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
