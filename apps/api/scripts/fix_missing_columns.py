#!/usr/bin/env python3
"""Fix missing database columns that migrations failed to add."""
import os
import sys
from pathlib import Path

# Load .env
from dotenv import load_dotenv
env_path = Path(__file__).parent.parent / '.env'
if env_path.exists():
    load_dotenv(env_path)

from sqlalchemy import create_engine, text, inspect

def main():
    db_url = os.environ.get('DATABASE_URL')
    if not db_url:
        print("ERROR: DATABASE_URL not set")
        sys.exit(1)
    
    engine = create_engine(db_url)
    
    with engine.connect() as conn:
        inspector = inspect(conn)
        
        # Get existing columns in tour_items
        columns = [c['name'] for c in inspector.get_columns('tour_items')]
        print(f"Existing columns in tour_items: {columns}")
        
        # Add transition_audio_url if missing
        if 'transition_audio_url' not in columns:
            print("Adding transition_audio_url column...")
            conn.execute(text('ALTER TABLE tour_items ADD COLUMN transition_audio_url VARCHAR'))
            conn.commit()
            print("SUCCESS: Added transition_audio_url column")
        else:
            print("Column transition_audio_url already exists")
        
        # Add duration_seconds if missing
        if 'duration_seconds' not in columns:
            print("Adding duration_seconds column...")
            conn.execute(text('ALTER TABLE tour_items ADD COLUMN duration_seconds INTEGER'))
            conn.commit()
            print("SUCCESS: Added duration_seconds column")
        else:
            print("Column duration_seconds already exists")

if __name__ == '__main__':
    main()
