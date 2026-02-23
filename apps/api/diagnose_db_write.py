
import os
import sys
import uuid
import json
from datetime import datetime
from sqlmodel import SQLModel, create_engine, text, Session
from sqlalchemy import inspect

# Load env from .env.prod (Assuming running from root)
try:
    with open(".env.prod", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#") and "=" in line:
                key, val = line.strip().split("=", 1)
                os.environ[key] = val.strip('"').strip("'")
except FileNotFoundError:
    print(".env.prod not found in CWD")

db_url = os.getenv("DATABASE_URL")
if not db_url:
    print("DATABASE_URL not found")
    sys.exit(1)

if "sslmode=require" not in db_url and "neon.tech" in db_url:
    # Для Neon требуется SSL, для локального PostgreSQL - нет
    db_url += "?sslmode=require"

engine = create_engine(db_url)

# Import models
from api.core.models import *

print("Diagnosing DB Writes...")

with Session(engine) as session:
    try:
        # 1. Inspect PoiVersion columns
        insp = inspect(engine)
        cols = [c['name'] for c in insp.get_columns('poi_versions')]
        print("PoiVersion Columns:", cols)
        
        # 2. Try Create POI
        poi_id = uuid.uuid4()
        print(f"Attempting to create POI {poi_id}...")
        
        # Fake a user ID
        user_id = uuid.uuid4()
        
        p = Poi(
            id=poi_id,
            title_ru="Test POI",
            description_ru="Test Desc",
            city_slug="kaliningrad_city", # Must exist
            lat=54.0,
            lon=20.0,
            # Schema fields that were problematic
            title_en="Test EN",
            description_en="Desc EN",
            address="Addr",
            cover_image="http://img",
            preview_audio_url="http://aud",
            preview_bullets=["b1"],
            opening_hours={"open": "10:00"},
            external_links=["http://link"]
        )
        session.add(p)
        session.flush() # This triggers SQL
        print("POI Creation SUCCESS")
        
        # 3. Try Create Version
        print("Attempting to create PoiVersion...")
        v = PoiVersion(
             poi_id=poi_id,
             changed_by=user_id,
             title_ru="Test POI",
             description_ru="Test Desc",
             lat=54.0,
             lon=20.0,
             full_snapshot_json=p.json()
        )
        session.add(v)
        session.flush()
        print("PoiVersion Creation SUCCESS")
        
        # 4. Try Create AppEvent
        print("Attempting to create AppEvent...")
        ae = AppEvent(
            event_type="poi_created", 
            user_id=user_id, 
            payload_json=json.dumps({"id": str(poi_id)})
        )
        session.add(ae)
        session.flush()
        print("AppEvent Creation SUCCESS")
        
        # 5. Check Audit Log (just in case delete uses it)
        print("Attempting to create AuditLog...")
        al = AuditLog(
            action="TEST", 
            target_id=poi_id, 
            actor_type="test", 
            actor_fingerprint="test"
        )
        session.add(al)
        session.flush()
        print("AuditLog Creation SUCCESS")
        
        print("ALL CHECKS PASSED. Rolling back.")
        session.rollback()
        
    except Exception as e:
        print("\n!!! ERROR ENCOUNTERED !!!")
        print(str(e))
        import traceback
        traceback.print_exc()
        session.rollback()
