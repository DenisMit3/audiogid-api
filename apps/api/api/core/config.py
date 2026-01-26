import os

class AppConfig:
    def __init__(self):
        # FAIL-FAST: Explicitly verify required vars.
        self.DATABASE_URL = self._get_required("DATABASE_URL")
        
        # Ingestion Env (Strategy A: Readiness-only check, optional at startup)
        self.QSTASH_TOKEN = os.getenv("QSTASH_TOKEN")
        self.QSTASH_CURRENT_SIGNING_KEY = os.getenv("QSTASH_CURRENT_SIGNING_KEY")
        self.QSTASH_NEXT_SIGNING_KEY = os.getenv("QSTASH_NEXT_SIGNING_KEY")
        
        # ADMIN_API_TOKEN is OPTIONAL at startup (fail-closed level at endpoint)
        self.ADMIN_API_TOKEN = os.getenv("ADMIN_API_TOKEN")
        
        # Optional with default
        self.VERCEL_BLOB_READ_WRITE_TOKEN = (os.getenv("VERCEL_BLOB_READ_WRITE_TOKEN") or "").strip()
        self.OPENAI_API_KEY = (os.getenv("OPENAI_API_KEY") or "").strip()
        self.AUDIO_PROVIDER = os.getenv("AUDIO_PROVIDER", "openai").strip()
        self.VERCEL_URL = (os.getenv("VERCEL_URL") or "").strip()
        self.OVERPASS_API_URL = os.getenv("OVERPASS_API_URL")
        
        # Billing (P0 Required per POLICY)
        self.YOOKASSA_SHOP_ID = self._get_required("YOOKASSA_SHOP_ID")
        self.YOOKASSA_SECRET_KEY = self._get_required("YOOKASSA_SECRET_KEY")
        self.YOOKASSA_WEBHOOK_SECRET = self._get_required("YOOKASSA_WEBHOOK_SECRET")
        self.PUBLIC_APP_BASE_URL = self._get_required("PUBLIC_APP_BASE_URL")
        self.PAYMENT_WEBHOOK_BASE_PATH = self._get_required("PAYMENT_WEBHOOK_BASE_PATH")
        
        if not self.PAYMENT_WEBHOOK_BASE_PATH.startswith("/"):
            raise RuntimeError("CRITICAL: PAYMENT_WEBHOOK_BASE_PATH must start with '/'")

            
    def _get_required(self, key: str) -> str:
        value = os.getenv(key)
        if not value:
            raise RuntimeError(f"CRITICAL: Missing environment variable '{key}'. App cannot start.")
        return value.strip()

try:
    config = AppConfig()
except RuntimeError as e:
    # Fail fast means we crash if REQUIRED vars are missing.
    # But for local dev sometimes people want partial start?
    # POLICY says NO LOCAL. So we just crash print.
    print(f"Startup Config Error: {e}")
    raise e


