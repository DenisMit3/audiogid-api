#!/usr/bin/env python3
"""Apply override_lat/lon migration directly."""
import os
import sys
from pathlib import Path

# Load .env from multiple possible locations
from dotenv import load_dotenv

possible_paths = [
    Path(__file__).parent.parent / '.env',  # scripts/../.env
    Path(__file__).parent.parent.parent / '.env',  # api/../.env
    Path('/opt/audiogid/api/.env'),
    Path('/opt/audiogid/.env'),
    Path.cwd() / '.env',
]

for env_path in possible_paths:
    if env_path.exists():
        print(f'Loading .env from: {env_path}')
        load_dotenv(env_path)
        break
else:
    print(f'No .env found in: {[str(p) for p in possible_paths]}')

db_url = os.environ.get('DATABASE_URL')
if not db_url:
    print('DATABASE_URL not found, skipping migration')
    sys.exit(0)

print(f'DATABASE_URL found, connecting...')

from sqlalchemy import create_engine, text, inspect

engine = create_engine(db_url)
with engine.connect() as conn:
    inspector = inspect(conn)
    columns = [c['name'] for c in inspector.get_columns('tour_items')]
    print(f'Existing columns: {columns}')
    
    added = False
    if 'override_lat' not in columns:
        conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lat FLOAT'))
        print('Added override_lat column')
        added = True
    
    if 'override_lon' not in columns:
        conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lon FLOAT'))
        print('Added override_lon column')
        added = True
    
    if added:
        conn.commit()
        print('Migration complete - columns added')
    else:
        print('Columns already exist, nothing to do')
