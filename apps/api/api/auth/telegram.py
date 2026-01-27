import hashlib
import hmac
import time
from typing import Dict
from ..core.config import config

def verify_telegram_data(data: Dict[str, str]) -> bool:
    """
    Verifies the data received from Telegram Login Widget.
    Ref: https://core.telegram.org/widgets/login#checking-authorization
    """
    if not config.TELEGRAM_BOT_TOKEN:
        return False
        
    received_hash = data.get("hash")
    if not received_hash:
        return False
        
    auth_date = data.get("auth_date")
    if not auth_date:
        return False
        
    # TTL Check (e.g. 1 hour = 3600s)
    current_time = time.time()
    try:
        auth_ts = int(auth_date)
        if current_time - auth_ts > 3600:
            return False # Expired
        if current_time - auth_ts < -60:
             # Clock skew future check
            return False
    except ValueError:
        return False
        
    # Construct Check String
    check_str_parts = []
    for k in sorted(data.keys()):
        if k != "hash":
            check_str_parts.append(f"{k}={data[k]}")
    
    check_str = "\n".join(check_str_parts)
    
    # Calculate Secret (SHA256 of Token)
    # The secret key implies "SHA256(BotToken)"
    secret_key = hashlib.sha256(config.TELEGRAM_BOT_TOKEN.encode()).digest()
    
    # Calculate HMAC-SHA256
    calc_hash = hmac.new(secret_key, check_str.encode(), hashlib.sha256).hexdigest()
    
    return calc_hash == received_hash
