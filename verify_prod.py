import os
import requests
import psycopg2

print("Pulling Prod Env...")
os.system("npx vercel env pull .env.prod --yes --environment=production")

db_url = None
with open('.env.prod') as f:
    for line in f:
        if "DATABASE_URL" in line:
            _, v = line.split('=', 1)
            db_url = v.strip().strip('"')
            break

if not db_url:
    print("No DB URL found")
    exit(1)

print("Connecting to DB...")
try:
    if 'sslmode' not in db_url:
        db_url += "?sslmode=require"
    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    
    tour_id = '22222222-2222-2222-2222-222222222222'
    device = 'test-prod-header'
    city = 'kaliningrad_city'

    print("Seeding...")
    cur.execute("""
        INSERT INTO tour (id, city_slug, title_ru, published_at, created_at, updated_at)
        VALUES (%s, %s, 'Prod Check', NOW(), NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
    """, (tour_id, city))
    
    cur.execute("""
        INSERT INTO entitlements (id, city_slug, tour_id, device_anon_id, granted_at)
        VALUES (gen_random_uuid(), %s, %s, %s, NOW())
    """, (city, tour_id, device))
    conn.commit()
    conn.close()
    print("Seed OK.")
except Exception as e:
    print(f"DB Error: {e}")

print("Verifying...")
url = f"https://audiogid-api.vercel.app/v1/public/tours/{tour_id}/manifest?city={city}&device_anon_id={device}"
r = requests.get(url)
print(f"Status: {r.status_code}")
print(f"Cache-Control: {r.headers.get('Cache-Control')}")
