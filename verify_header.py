import os
import psycopg2
import requests

print("Pulling env vars...")
os.system("npx vercel env pull .env.preview --yes --environment=preview")

vars = {}
try:
    with open('.env.preview', encoding='utf-8') as f:
        for line in f:
            if '=' in line:
                k,v = line.strip().split('=', 1)
                vars[k] = v.strip('"')
except FileNotFoundError:
    print("Env file not found")
    exit(1)

db_url = vars.get("DATABASE_URL")
if not db_url:
    print("DB_URL not found in .env.preview")
    exit(1)

print("Connecting to DB...")
try:
    # sslmode=require is usually needed for Neon
    if 'sslmode' not in db_url:
        db_url += "?sslmode=require"
        
    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    
    tour_id = '11111111-1111-1111-1111-111111111111'
    device_id = 'test-device-header-check'
    city = 'kaliningrad_city' 
    
    print(f"Seeding Tour {tour_id}...")
    cur.execute("""
        INSERT INTO tour (id, city_slug, title_ru, published_at, created_at, updated_at)
        VALUES (%s, %s, 'Header Check Tour', NOW(), NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
    """, (tour_id, city))
    
    print(f"Seeding Entitlement for {device_id}...")
    cur.execute("""
        INSERT INTO entitlements (id, city_slug, tour_id, device_anon_id, granted_at)
        VALUES (gen_random_uuid(), %s, %s, %s, NOW())
    """, (city, tour_id, device_id))
    
    conn.commit()
    conn.close()
    print("Seed complete.")
except Exception as e:
    print(f"DB Error: {e}")

# Verify
base = "http://82.202.159.64:8000"

print("--- 403 CASE ---")
url_403 = f"{base}/v1/public/tours/{tour_id}/manifest?city={city}&device_anon_id=unauthorized_guy"
try:
    r = requests.get(url_403)
    print(f"Status: {r.status_code}")
    print(f"Cache-Control: {r.headers.get('Cache-Control')}")
except Exception as e:
    print(e)
    
print("--- 200 CASE ---")
url_200 = f"{base}/v1/public/tours/{tour_id}/manifest?city={city}&device_anon_id={device_id}"
try:
    r = requests.get(url_200)
    print(f"Status: {r.status_code}")
    print(f"Cache-Control: {r.headers.get('Cache-Control')}")
except Exception as e:
    print(e)
