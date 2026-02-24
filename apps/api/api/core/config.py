import os

class AppConfig:
    def __init__(self):
        # FAIL-FAST: Explicitly verify required vars.
        # PostgreSQL connection (local on Cloud.ru or any PostgreSQL instance)
        self.DATABASE_URL = self._get_required("DATABASE_URL")
        
        # Deploy environment: "production", "staging", "development"
        # Replaces VERCEL_ENV - works on any hosting (Cloud.ru, VPS, etc.)
        self.DEPLOY_ENV = os.getenv("DEPLOY_ENV", "development").strip()
        self.is_production = self.DEPLOY_ENV == "production"
        
        # Ingestion Env (Strategy A: Readiness-only check, optional at startup)
        self.QSTASH_TOKEN = (os.getenv("QSTASH_TOKEN") or "").strip()
        self.QSTASH_CURRENT_SIGNING_KEY = (os.getenv("QSTASH_CURRENT_SIGNING_KEY") or "").strip()
        self.QSTASH_NEXT_SIGNING_KEY = (os.getenv("QSTASH_NEXT_SIGNING_KEY") or "").strip()
        # Default to US-East-1 (common region) if not specified
        self.QSTASH_URL = (os.getenv("QSTASH_URL") or "https://qstash-us-east-1.upstash.io").strip()
        
        # ADMIN_API_TOKEN is OPTIONAL at startup (fail-closed check at endpoint level)
        self.ADMIN_API_TOKEN = os.getenv("ADMIN_API_TOKEN")
        if not self.ADMIN_API_TOKEN and self.is_production:
             raise RuntimeError("CRITICAL: ADMIN_API_TOKEN is required in production.")
        
        # S3-compatible storage (MinIO, Yandex Object Storage, etc.)
        # Replaces Vercel Blob
        self.S3_ENDPOINT_URL = os.getenv("S3_ENDPOINT_URL", "").strip()  # e.g., http://localhost:9000
        self.S3_ACCESS_KEY = os.getenv("S3_ACCESS_KEY", "").strip()
        self.S3_SECRET_KEY = os.getenv("S3_SECRET_KEY", "").strip()
        self.S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME", "audiogid").strip()
        self.S3_PUBLIC_URL = os.getenv("S3_PUBLIC_URL", "").strip()  # Public URL for accessing files
        
        # Legacy: keep for backward compatibility during migration
        self.VERCEL_BLOB_READ_WRITE_TOKEN = (os.getenv("BLOB_READ_WRITE_TOKEN") or os.getenv("VERCEL_BLOB_READ_WRITE_TOKEN") or "").strip()
        
        self.OPENAI_API_KEY = (os.getenv("OPENAI_API_KEY") or "").strip()
        self.AUDIO_PROVIDER = os.getenv("AUDIO_PROVIDER", "openai").strip()
        self.PUBLIC_URL = os.getenv("PUBLIC_URL", "").strip()  # Replaces VERCEL_URL
        self.OVERPASS_API_URL = os.getenv("OVERPASS_API_URL")
        
        # Billing (PR-50 Hotfix: Force Optional Config for YooKassa to prevent crash)
        # Previously caused crash if YOOKASSA_SHOP_ID missing.
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

        # Auth (PR-58)
        self.SMS_RU_API_KEY = os.getenv("SMS_RU_API_KEY")
        self.TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
        self.JWT_SECRET = (os.getenv("JWT_SECRET") or "").strip()
        if self.JWT_SECRET and len(self.JWT_SECRET) < 32:
            raise RuntimeError("CRITICAL: JWT_SECRET must be at least 32 characters long.")
        if not self.JWT_SECRET and self.is_production:
            raise RuntimeError("CRITICAL: JWT_SECRET is required in production.") 
        self.JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256").strip()
        self.OTP_TTL_SECONDS = int(os.getenv("OTP_TTL_SECONDS", "300"))
        
        # Monitoring
        self.SENTRY_DSN = os.getenv("SENTRY_DSN")
        
        # Redis (Optional, used for shared rate limiting)
        self.REDIS_URL = os.getenv("REDIS_URL")


            
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
