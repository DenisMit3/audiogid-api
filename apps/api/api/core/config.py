import os

class AppConfig:
    def __init__(self):
        # FAIL-FAST: Explicitly verify required vars.
        self.DATABASE_URL = self._get_required("DATABASE_URL")
        self.QSTASH_TOKEN = self._get_required("QSTASH_TOKEN")
        self.QSTASH_CURRENT_SIGNING_KEY = self._get_required("QSTASH_CURRENT_SIGNING_KEY")
        self.QSTASH_NEXT_SIGNING_KEY = self._get_required("QSTASH_NEXT_SIGNING_KEY")
        self.ADMIN_API_TOKEN = self._get_required("ADMIN_API_TOKEN")
        
        # Optional with default
        self.VERCEL_BLOB_READ_WRITE_TOKEN = (os.getenv("VERCEL_BLOB_READ_WRITE_TOKEN") or "").strip()
        self.OPENAI_API_KEY = (os.getenv("OPENAI_API_KEY") or "").strip()
        self.AUDIO_PROVIDER = os.getenv("AUDIO_PROVIDER", "openai").strip()
        self.PUBLIC_APP_BASE_URL = (os.getenv("PUBLIC_APP_BASE_URL") or "").strip()
        self.VERCEL_URL = (os.getenv("VERCEL_URL") or "").strip()
        self.OVERPASS_API_URL = os.getenv("OVERPASS_API_URL", "https://overpass-api.de/api/interpreter").strip()
        
        # Billing & Platform (P0 Required)
        self.YOOKASSA_SHOP_ID = self._get_required("YOOKASSA_SHOP_ID")
        self.YOOKASSA_SECRET_KEY = self._get_required("YOOKASSA_SECRET_KEY")
        self.YOOKASSA_WEBHOOK_SECRET = self._get_required("YOOKASSA_WEBHOOK_SECRET")
        self.PUBLIC_APP_BASE_URL = self._get_required("PUBLIC_APP_BASE_URL")
        self.PAYMENT_WEBHOOK_BASE_PATH = os.getenv("PAYMENT_WEBHOOK_BASE_PATH", "/v1/billing/yookassa/webhook").strip()
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
    print(f"Startup Config Error: {e}")
    # Create a dummy config to allow app to at least start
    class DummyConfig:
        DATABASE_URL = None
        QSTASH_TOKEN = None
        QSTASH_CURRENT_SIGNING_KEY = "dummy"
        QSTASH_NEXT_SIGNING_KEY = "dummy"
        ADMIN_API_TOKEN = None
        OVERPASS_API_URL = "https://overpass-api.de/api/interpreter"
        YOOKASSA_SHOP_ID = None
        YOOKASSA_SECRET_KEY = None
        YOOKASSA_WEBHOOK_SECRET = None
        PAYMENT_WEBHOOK_BASE_PATH = "/v1/billing/yookassa/webhook"
        PUBLIC_APP_BASE_URL = "http://localhost:3000"
    config = DummyConfig()

