import os
import psycopg2

def load_env(filepath):
    vars = {}
    if not os.path.exists(filepath): return vars
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'): continue
            if '=' in line:
                k, v = line.split('=', 1)
                vars[k.strip()] = v.strip().strip('"').strip("'")
    return vars

env = load_env('.env.prod')
db_url = env.get("DATABASE_URL")

if not db_url:
    print("DATABASE_URL not found in .env.prod")
    exit(1)

try:
    if 'sslmode' not in db_url:
        db_url += "?sslmode=require"
    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    
    cur.execute("SELECT COUNT(*) FROM poi")
    count = cur.fetchone()[0]
    print(f"Total POIs in DB: {count}")
    
    if count > 0:
        cur.execute("SELECT title_ru, city_slug FROM poi LIMIT 5")
        for row in cur.fetchall():
            print(f" - {row[0]} ({row[1]})")
            
    conn.close()
except Exception as e:
    print(f"Error: {e}")
