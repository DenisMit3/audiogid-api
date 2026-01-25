import os
import requests
import psycopg2

base = "https://audiogid-2nljrobzs-denis-projects-a19daef6.vercel.app"

print(f"Checking {base}/v1/ops/ready ...")
try:
    r = requests.get(f"{base}/v1/ops/ready", timeout=5)
    print(f"Ready Status: {r.status_code}")
except Exception as e:
    print(f"Ready Check Failed: {e}")

print("Pulling PROD env to get DB_URL...")
# Pull Prod because we know it has the DB_URL (we rotated it)
os.system("npx vercel env pull .env.prod --yes --environment=production")

db_url = None
try:
    with open('.env.prod') as f:
        for line in f:
            if line.startswith("DATABASE_URL="):
                db_url = line.strip().split('=', 1)[1].strip('"')
                break
except FileNotFoundError:
    print("Prod env file not found")

if not db_url:
    print("DB_URL not found in Prod")
    exit(1)

print("Connecting to DB (using Prod URL)...")
# We assume Neon DB is shared or accessible.
try:
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

print("\n--- Verifying Headers ---")
print("403 CASE:")
url_403 = f"{base}/v1/public/tours/{tour_id}/manifest?city={city}&device_anon_id=unauthorized"
try:
    r = requests.get(url_403)
    print(f"Status: {r.status_code}")
    print(f"Cache-Control: {r.headers.get('Cache-Control')}")
except Exception as e:
    print(e)

print("200 CASE:")
url_200 = f"{base}/v1/public/tours/{tour_id}/manifest?city={city}&device_anon_id={device_id}"
try:
    r = requests.get(url_200)
    print(f"Status: {r.status_code}")
    print(f"Cache-Control: {r.headers.get('Cache-Control')}")
except Exception as e:
    print(e)
