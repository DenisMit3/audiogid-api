#!/usr/bin/env python3
import sys
sys.path.insert(0, '/opt/audiogid/api')

from dotenv import load_dotenv
load_dotenv('/opt/audiogid/api/.env')

try:
    from api.admin.cities import router
    print(f"SUCCESS: router = {router}")
    print(f"Routes: {[r.path for r in router.routes]}")
except Exception as e:
    print(f"FAILED: {e}")
    import traceback
    traceback.print_exc()
