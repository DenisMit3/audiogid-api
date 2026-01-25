import requests
import os
import sys

# Minimal parser for .env file
def load_env(filepath):
    vars = {}
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
    token = env.get("ADMIN_API_TOKEN")
    if not token:
        print("Error: ADMIN_API_TOKEN not found in .env.prod")
        sys.exit(1)
        
    url = "https://audiogid-api.vercel.app/v1/admin/ingestion/osm/enqueue"
    
    print(f"Triggering ingestion for kaliningrad_city on {url}...")
    
    # We use requests (now installed!)
    resp = requests.post(url, json={"city_slug": "kaliningrad_city"}, headers={"x-admin-token": token})
    
    print(f"Status: {resp.status_code}")
    print(f"Response: {resp.text}")
    
except Exception as e:
    print(f"Failed: {e}")
