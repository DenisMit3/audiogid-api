#!/usr/bin/env python3
"""Apply override_lat/lon migration directly."""
import os
import sys
from pathlib import Path

# Load .env - use resolve() to get absolute path
from dotenv import load_dotenv
script_dir = Path(__file__).resolve().parent
env_path = script_dir.parent / '.env'

print(f"Script dir: {script_dir}")
print(f"Looking for .env at: {env_path}")
print(f"Exists: {env_path.exists()}")

if env_path.exists():
    load_dotenv(env_path)
    print("Loaded .env")

from sqlalchemy import create_engine, text, inspect

def main():
    db_url = os.environ.get('DATABASE_URL')
    if not db_url:
        print("ERROR: DATABASE_URL not set")
        sys.exit(1)
    
    print("Connecting to database...")
    engine = create_engine(db_url)
    
    with engine.connect() as conn:
        inspector = inspect(conn)
        
        # Get existing columns in tour_items
        columns = [c['name'] for c in inspector.get_columns('tour_items')]
        print(f"Existing columns in tour_items: {columns}")
        
        # Add override_lat if missing
        if 'override_lat' not in columns:
            print("Adding override_lat column...")
            conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lat FLOAT'))
            conn.commit()
            print("SUCCESS: Added override_lat column")
        else:
            print("Column override_lat already exists")
        
        # Add override_lon if missing
        if 'override_lon' not in columns:
            print("Adding override_lon column...")
            conn.execute(text('ALTER TABLE tour_items ADD COLUMN override_lon FLOAT'))
            conn.commit()
            print("SUCCESS: Added override_lon column")
        else:
            print("Column override_lon already exists")

if __name__ == '__main__':
    main()
