#!/usr/bin/env python3
"""Apply override_lat/lon migration directly."""
import os
import sys
from pathlib import Path

# Load .env
from dotenv import load_dotenv
env_path = Path(__file__).parent.parent / '.env'
if env_path.exists():
    load_dotenv(env_path)

db_url = os.environ.get('DATABASE_URL')
if not db_url:
    print('DATABASE_URL not found, skipping migration')
    sys.exit(0)

from sqlalchemy import create_engine, text, inspect

engine = create_engine(db_url)
with engine.connect() as conn:
    inspector = inspect(conn)
    columns = [c['name'] for c in inspector.get_columns('tour_items')]
    
    if 'override_lat' not in columns:
        conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lat FLOAT'))
        print('Added override_lat column')
    
    if 'override_lon' not in columns:
        conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lon FLOAT'))
        print('Added override_lon column')
    
    conn.commit()
    print('Migration complete')
