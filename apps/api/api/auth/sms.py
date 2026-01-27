import httpx
import random
import logging
from ..core.config import config

logger = logging.getLogger(__name__)

def generate_otp() -> str:
    return str(random.randint(100000, 999999))

async def send_sms_otp(phone: str, code: str) -> bool:
    if not config.SMSRU_API_ID:
        logger.warning("SMSRU_API_ID not configured. Skipping SMS send (Dev Mode logic would go here if allowed, but strict NON-LOCAL policy implies we just fail or log).")
        # In strict prod, we return False.
        # But for "Preview" without credentials, maybe we want to log the code?
        # WARNING: Security risk to log OTP. 
        # Better: Fail closed.
        return False
        
    msg = f"AudioGuide Code: {code}"
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get("https://sms.ru/sms/send", params={
                "api_id": config.SMSRU_API_ID,
                "to": phone,
                "msg": msg,
                "json": 1
            }, timeout=5.0)
            
            if resp.status_code != 200:
                logger.error(f"SMS.RU returned {resp.status_code}: {resp.text}")
                return False
                
            data = resp.json()
            status = data.get("status_code") # SMS.RU 2026 API uses status_code 100 on success
            # Check docs or assume generic 'status' field?
            # Standard SMS.RU JSON response: {"status": "OK", "status_code": 100, "sms": {...}}
            if data.get("status") == "OK":
                return True
            
            logger.error(f"SMS.RU Error: {data}")
            return False
            
    except Exception as e:
        logger.error(f"Failed to send SMS to {phone}: {e}")
        return False
