import requests
import os
import sys

# Minimal parser for .env file
def load_env(filepath):
    vars = {}
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'): continue
                if '=' in line:
                    k, v = line.split('=', 1)
                    vars[k.strip()] = v.strip().strip('"').strip("'")
    return vars

try:
    env = load_env('.env.prod')
    token = os.getenv("ADMIN_API_TOKEN") or env.get("ADMIN_API_TOKEN")
    
    if not token:
        print("Error: ADMIN_API_TOKEN not found in environment or .env.prod")
        sys.exit(1)
        
    url = "http://82.202.159.64:8000/v1/admin/ingestion/osm/enqueue"
    
    print(f"Triggering ingestion for kaliningrad_city on {url}...")
    
    # Payload for the OSM ingestion
    # Note: ingestion.py OsmImportRequest expects city_slug
    payload = {"city_slug": "kaliningrad_city"}
    
    resp = requests.post(
        url, 
        json=payload, 
        headers={"x-admin-token": token}
    )
    
    print(f"Status Code: {resp.status_code}")
    print(f"Response Body: {resp.text}")
    
except Exception as e:
    print(f"Failed to trigger ingestion: {e}")
