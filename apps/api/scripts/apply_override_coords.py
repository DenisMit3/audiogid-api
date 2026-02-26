#!/usr/bin/env python3
"""Apply override_lat/lon migration directly."""
import os
import sys

print('=== Migration script started ===')
print(f'Python: {sys.version}')
print(f'CWD: {os.getcwd()}')
print(f'__file__: {__file__}')

# Try to load .env
try:
    from pathlib import Path
    from dotenv import load_dotenv
    
    env_path = Path(__file__).resolve().parent.parent / '.env'
    print(f'Looking for .env at: {env_path}')
    print(f'Exists: {env_path.exists()}')
    
    if env_path.exists():
        load_dotenv(env_path)
        print('Loaded .env')
    else:
        # Try alternative path
        env_path2 = Path('/opt/audiogid/api/.env')
        print(f'Trying: {env_path2}, exists: {env_path2.exists()}')
        if env_path2.exists():
            load_dotenv(env_path2)
            print('Loaded .env from /opt/audiogid/api/')
except Exception as e:
    print(f'Error loading .env: {e}')

db_url = os.environ.get('DATABASE_URL', '')
print(f'DATABASE_URL found: {bool(db_url)}')

if not db_url:
    print('No DATABASE_URL, exiting')
    sys.exit(0)

try:
    from sqlalchemy import create_engine, text, inspect
    
    print('Connecting to database...')
    engine = create_engine(db_url)
    
    with engine.connect() as conn:
        inspector = inspect(conn)
        columns = [c['name'] for c in inspector.get_columns('tour_items')]
        print(f'Existing columns in tour_items: {columns}')
        
        added = False
        if 'override_lat' not in columns:
            conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lat FLOAT'))
            print('Added override_lat')
            added = True
        
        if 'override_lon' not in columns:
            conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lon FLOAT'))
            print('Added override_lon')
            added = True
        
        if added:
            conn.commit()
            print('=== Migration complete ===')
        else:
            print('=== Columns already exist ===')
            
except Exception as e:
    print(f'Database error: {e}')
    sys.exit(1)
