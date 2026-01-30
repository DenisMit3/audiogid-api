import httpx
import random
import logging
from fastapi import HTTPException
from ..core.config import config

logger = logging.getLogger(__name__)

def generate_otp() -> str:
    return str(random.randint(100000, 999999))

async def send_sms_otp(phone: str, code: str) -> bool:
    if not config.SMS_RU_API_KEY:
        logger.warning("SMS_RU_API_KEY not configured. Skipping SMS send.")
        return False
        
    msg = f"AudioGuide Code: {code}"
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get("https://sms.ru/sms/send", params={
                "api_id": config.SMS_RU_API_KEY,
                "to": phone,
                "msg": msg,
                "json": 1
            }, timeout=10.0)
            
            if resp.status_code != 200:
                logger.error(f"SMS.RU returned {resp.status_code}: {resp.text}")
                raise HTTPException(status_code=502, detail="SMS Provider Error")
                
            data = resp.json()
            # SMS.RU returns status: "OK" on success
            if data.get("status") == "OK":
                return True
            
            logger.error(f"SMS.RU Error: {data}")
            raise HTTPException(status_code=502, detail=f"SMS Send Failed: {data.get('status_text', 'Unknown Error')}")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to send SMS to {phone}: {e}")
        # Propagate as 500
        raise HTTPException(status_code=500, detail="SMS Service Unavailable")
