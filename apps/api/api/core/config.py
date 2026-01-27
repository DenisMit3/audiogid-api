import os

class AppConfig:
    def __init__(self):
        # FAIL-FAST: Explicitly verify required vars.
        self.DATABASE_URL = self._get_required("DATABASE_URL")
        
        # Ingestion Env (Strategy A: Readiness-only check, optional at startup)
        self.QSTASH_TOKEN = os.getenv("QSTASH_TOKEN")
        self.QSTASH_CURRENT_SIGNING_KEY = os.getenv("QSTASH_CURRENT_SIGNING_KEY")
        self.QSTASH_NEXT_SIGNING_KEY = os.getenv("QSTASH_NEXT_SIGNING_KEY")
        
        # ADMIN_API_TOKEN is OPTIONAL at startup (fail-closed check at endpoint level)
        self.ADMIN_API_TOKEN = os.getenv("ADMIN_API_TOKEN")
        
        # Optional with default
        self.VERCEL_BLOB_READ_WRITE_TOKEN = (os.getenv("VERCEL_BLOB_READ_WRITE_TOKEN") or "").strip()
        self.OPENAI_API_KEY = (os.getenv("OPENAI_API_KEY") or "").strip()
        self.ALIBABA_API_KEY = (os.getenv("ALIBABA_API_KEY") or "").strip()
        self.AUDIO_PROVIDER = os.getenv("AUDIO_PROVIDER", "qwen").strip()
        self.VERCEL_URL = (os.getenv("VERCEL_URL") or "").strip()
        self.OVERPASS_API_URL = os.getenv("OVERPASS_API_URL")
        
        # Billing (PR-45: Changed to optional at boot, fail-fast at endpoint level)
        # Rationale: Missing billing vars should NOT crash entire app including /ops/*
        self.YOOKASSA_SHOP_ID = os.getenv("YOOKASSA_SHOP_ID")
        self.YOOKASSA_SECRET_KEY = os.getenv("YOOKASSA_SECRET_KEY")
        self.YOOKASSA_WEBHOOK_SECRET = os.getenv("YOOKASSA_WEBHOOK_SECRET")
        self.PAYMENT_WEBHOOK_BASE_PATH = os.getenv("PAYMENT_WEBHOOK_BASE_PATH", "/v1/billing")
        self.PUBLIC_APP_BASE_URL = os.getenv("PUBLIC_APP_BASE_URL")
        
        # Validate billing config only if any billing var is set
        if self.PAYMENT_WEBHOOK_BASE_PATH and not self.PAYMENT_WEBHOOK_BASE_PATH.startswith("/"):
            raise RuntimeError("CRITICAL: PAYMENT_WEBHOOK_BASE_PATH must start with '/'")
        
        # Stores (Apple/Google) - Optional at startup (fail-fast at endpoint)
        self.APPLE_SHARED_SECRET = os.getenv("APPLE_SHARED_SECRET")
        self.GOOGLE_SERVICE_ACCOUNT_JSON = os.getenv("GOOGLE_SERVICE_ACCOUNT_JSON_BASE64")  # Base64 encoded

            
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


