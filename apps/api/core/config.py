import os

class AppConfig:
    def __init__(self):
        # FAIL-FAST: Explicitly verify required vars.
        self.DATABASE_URL = self._get_required("DATABASE_URL")
        self.QSTASH_TOKEN = self._get_required("QSTASH_TOKEN")
        self.QSTASH_CURRENT_SIGNING_KEY = self._get_required("QSTASH_CURRENT_SIGNING_KEY")
        self.QSTASH_NEXT_SIGNING_KEY = self._get_required("QSTASH_NEXT_SIGNING_KEY")
        
        # PR-2: Security for Admin Endpoints
        self.ADMIN_API_TOKEN = self._get_required("ADMIN_API_TOKEN")
        
    def _get_required(self, key: str) -> str:
        value = os.getenv(key)
        if not value:
            raise RuntimeError(f"CRITICAL: Missing environment variable '{key}'. App cannot start.")
        return value

try:
    config = AppConfig()
except RuntimeError as e:
    print(f"Startup Config Error: {e}")
    # In Vercel build phase, we might mock this or expect it to fail if we try to run app code.
    # We allow import but execution will fail if config is accessed.
    pass 
