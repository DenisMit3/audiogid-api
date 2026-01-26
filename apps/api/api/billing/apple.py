import logging
import httpx
from datetime import datetime
from typing import Optional, Dict

from ..core.config import config

logger = logging.getLogger(__name__)

# Sandbox/Prod URLs for Apple (Classic Receipt Verify)
APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
APPLE_PROD_URL = "https://buy.itunes.apple.com/verifyReceipt"

async def verify_apple_receipt(receipt_data: str, product_id: str) -> Dict:
    """
    Verifies receipt with Apple. 
    Returns standardized dict: {verified: bool, transaction_id: str, original_transaction_id: str, environment: str}
    """
    if not config.APPLE_SHARED_SECRET:
        logger.error("Missing APPLE_SHARED_SECRET")
        raise RuntimeError("Server misconfigured: missing Apple Secret")

    payload = {
        "receipt-data": receipt_data,
        "password": config.APPLE_SHARED_SECRET,
        "exclude-old-transactions": True
    }
    
    # Strategy: Try Prod first. If error 21007, try Sandbox.
    # This handles App Store Review which might use Sandbox receipts in Prod env.
    
    env = "Production"
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            resp = await client.post(APPLE_PROD_URL, json=payload)
            resp.raise_for_status()
            data = resp.json()
            
            if data.get("status") == 21007: # Sandbox receipt sent to Prod
                logger.info("Apple: Switching to Sandbox verification (21007)")
                env = "Sandbox"
                resp = await client.post(APPLE_SANDBOX_URL, json=payload)
                resp.raise_for_status()
                data = resp.json()
                
            if data.get("status") != 0:
                logger.warning(f"Apple Verify Failed. Status: {data.get('status')}")
                return {"verified": False, "error": f"Apple Status {data.get('status')}"}
            
            # extract receipt info
            receipt_info = data.get("receipt", {})
            in_app = receipt_info.get("in_app", [])
            
            # Find matching product_id
            target_tx = None
            for tx in in_app:
                if tx.get("product_id") == product_id:
                    target_tx = tx
                    break
            
            if not target_tx:
                # Fallback: maybe the main receipt info has the fields (rare for auto-renewable, common for consumable)
                # But here we assume standard structure.
                return {"verified": False, "error": "Product ID not found in receipt"}
                
            return {
                "verified": True,
                "transaction_id": target_tx.get("transaction_id"),
                "original_transaction_id": target_tx.get("original_transaction_id"),
                "environment": env
            }
            
        except Exception as e:
            logger.error(f"Apple verification network error: {e}")
            raise e
