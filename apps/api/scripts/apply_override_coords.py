#!/usr/bin/env python3
"""Apply override_lat/lon migration directly."""
import os
from dotenv import load_dotenv

load_dotenv()

db_url = os.getenv('DATABASE_URL', '')
if not db_url:
    print('DATABASE_URL not found, skipping migration')
    exit(0)

from sqlalchemy import create_engine, text

engine = create_engine(db_url)
with engine.connect() as conn:
    conn.execute(text('ALTER TABLE tour_items ADD COLUMN IF NOT EXISTS override_lat FLOAT'))
    conn.execute(text('ALTER TABLE tour_items ADD COLUMN IF NOT EXISTS override_lon FLOAT'))
    conn.commit()
    print('Migration applied: override_lat/lon columns added')
