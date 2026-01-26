import logging
import base64
import json
import httpx
from datetime import datetime
from typing import Optional, Dict

# Google API Client (using REST or library)
# To keep deployment light, we can use simple REST if we handle auth tokens manually, 
# but using `google-api-python-client` is standard if auth is complex.
# However, "service account key" allows simple JWT generation. 
# For MVP/Serverless, let's use `google.oauth2` + `googleapiclient` if installed, 
# OR reuse a simple requests approach if we want to avoid 50MB deps.
# We installed google-api-python-client so let's use it.

from google.oauth2 import service_account
from googleapiclient.discovery import build

from ..core.config import config

logger = logging.getLogger(__name__)

SCOPES = ['https://www.googleapis.com/auth/androidpublisher']

async def verify_google_purchase(package_name: str, product_id: str, token: str) -> Dict:
    """
    Verifies purchase via Google Play Developer API.
    """
    if not config.GOOGLE_SERVICE_ACCOUNT_JSON:
        logger.error("Missing GOOGLE_SERVICE_ACCOUNT_JSON")
        raise RuntimeError("Server misconfigured: missing Google Service Account")

    try:
        # Decode base64 JSON key
        key_json = base64.b64decode(config.GOOGLE_SERVICE_ACCOUNT_JSON).decode("utf-8")
        key_info = json.loads(key_json)
        
        creds = service_account.Credentials.from_service_account_info(key_info, scopes=SCOPES)
        
        # Build service (this is synchronous usually, but fast enough for MVP validation step?)
        # Google lib is sync. Ideally run in executor.
        with build('androidpublisher', 'v3', credentials=creds, cache_discovery=False) as service:
            product = service.purchases().products().get(
                packageName=package_name,
                productId=product_id,
                token=token
            ).execute()
            
            # Check purchaseState (0=purchased, 1=canceled, 2=pending)
            state = product.get("purchaseState")
            if state != 0:
                 return {"verified": False, "error": f"Purchase State {state} (not purchased)"}
                 
            order_id = product.get("orderId")
            return {
                "verified": True,
                "transaction_id": order_id,
                "environment": "Production" # Play API is always prod/alpha/beta
            }
            
    except Exception as e:
        logger.error(f"Google verify error: {e}")
        # Identify specific google errors (400/404) vs network
        return {"verified": False, "error": str(e)}
