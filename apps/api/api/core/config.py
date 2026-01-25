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
        self.VERCEL_BLOB_READ_WRITE_TOKEN = os.getenv("VERCEL_BLOB_READ_WRITE_TOKEN")
        self.OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
        self.AUDIO_PROVIDER = os.getenv("AUDIO_PROVIDER", "openai")
        self.PUBLIC_APP_BASE_URL = os.getenv("PUBLIC_APP_BASE_URL")
        self.VERCEL_URL = os.getenv("VERCEL_URL")
        self.OVERPASS_API_URL = os.getenv("OVERPASS_API_URL", "https://overpass-api.de/api/interpreter")
        
    def _get_required(self, key: str) -> str:
        value = os.getenv(key)
        if not value:
            raise RuntimeError(f"CRITICAL: Missing environment variable '{key}'. App cannot start.")
        return value

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
    config = DummyConfig()

