import httpx
import logging
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)

# Wikidata User-Agent policy requires a specific User-Agent
USER_AGENT = "AudioGuide2026/1.0 (https://audiogid-api.vercel.app; denis@audiogid.app)"

async def fetch_wikidata_data(wikidata_id: str) -> Optional[Dict[str, Any]]:
    """
    Fetches data from Wikidata for a given ID (e.g., Q182435).
    Extracts: label (ru), description (ru), image (P18), website (P856).
    """
    if not wikidata_id or not wikidata_id.startswith("Q"):
        logger.warning(f"Invalid Wikidata ID: {wikidata_id}")
        return None

    url = f"https://www.wikidata.org/wiki/Special:EntityData/{wikidata_id}.json"
    
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(url, headers={"User-Agent": USER_AGENT}, follow_redirects=True)
            if resp.status_code != 200:
                logger.warning(f"Wikidata fetch failed for {wikidata_id}: {resp.status_code}")
                return None
            
            data = resp.json()
            entity = data.get("entities", {}).get(wikidata_id)
            if not entity:
                return None

            # Extract fields
            result = {
                "wikidata_id": wikidata_id,
                "label_ru": _extract_label(entity, "ru"),
                "description_ru": _extract_description(entity, "ru"),
                "image_filename": _extract_claim_value(entity, "P18"), # Image
                "website": _extract_claim_value(entity, "P856"), # Ticket/Official site
            }
            
            # Resolve image URL if filename exists
            if result["image_filename"]:
                result["image_url"] = await _resolve_commons_image_url(client, result["image_filename"])
            
            return result

    except Exception as e:
        logger.error(f"Error fetching Wikidata {wikidata_id}: {e}")
        return None

def _extract_label(entity: dict, lang: str) -> Optional[str]:
    return entity.get("labels", {}).get(lang, {}).get("value")

def _extract_description(entity: dict, lang: str) -> Optional[str]:
    return entity.get("descriptions", {}).get(lang, {}).get("value")

def _extract_claim_value(entity: dict, prop_id: str) -> Optional[str]:
    """
    Extracts the first 'mainsnak' value for a property.
    """
    claims = entity.get("claims", {}).get(prop_id, [])
    if not claims:
        return None
    
    # Take first claim with 'normal' rank or just first one
    claim = claims[0]
    mainsnak = claim.get("mainsnak", {})
    datavalue = mainsnak.get("datavalue", {})
    
    if datavalue.get("type") == "string":
        return datavalue.get("value")
    
    # For images (P18), the type is string (filename)
    # For others it might be 'wikibase-entityid' or 'monolingualtext'
    # We focus on P18 (string) and P856 (string/url)
    
    return datavalue.get("value")

async def _resolve_commons_image_url(client: httpx.AsyncClient, filename: str) -> Optional[str]:
    """
    Resolves a Commons filename to a direct URL.
    Uses MediaWiki API action=query&titles=File:...&prop=imageinfo&iiprop=url
    """
    # Filename needs to be cleared of "File:" prefix if present, but usually it's just name
    normalized_name = f"File:{filename}" if not filename.startswith("File:") else filename
    
    api_url = "https://commons.wikimedia.org/w/api.php"
    params = {
        "action": "query",
        "titles": normalized_name,
        "prop": "imageinfo",
        "iiprop": "url|extmetadata",
        "format": "json"
    }
    
    try:
        resp = await client.get(api_url, params=params, headers={"User-Agent": USER_AGENT})
        if resp.status_code != 200:
            return None
            
        data = resp.json()
        pages = data.get("query", {}).get("pages", {})
        for _, page in pages.items():
            if "imageinfo" in page:
                info = page["imageinfo"][0]
                url = info.get("url")
                
                # Metadata for license/author could be extracted here too in future
                # meta = info.get("extmetadata", {})
                
                return url
    except Exception:
        return None
    return None
