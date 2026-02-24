-- Add ALL missing columns to tour table based on TourBase model
ALTER TABLE tour ADD COLUMN IF NOT EXISTS cover_image VARCHAR;
ALTER TABLE tour ADD COLUMN IF NOT EXISTS tour_type VARCHAR DEFAULT 'walking';
ALTER TABLE tour ADD COLUMN IF NOT EXISTS difficulty VARCHAR DEFAULT 'easy';
ALTER TABLE tour ADD COLUMN IF NOT EXISTS distance_km FLOAT;

-- Add missing columns to city table based on CityBase model
ALTER TABLE city ADD COLUMN IF NOT EXISTS cover_image VARCHAR;
ALTER TABLE city ADD COLUMN IF NOT EXISTS bounds_lat_min FLOAT;
ALTER TABLE city ADD COLUMN IF NOT EXISTS bounds_lat_max FLOAT;
ALTER TABLE city ADD COLUMN IF NOT EXISTS bounds_lon_min FLOAT;
ALTER TABLE city ADD COLUMN IF NOT EXISTS bounds_lon_max FLOAT;
ALTER TABLE city ADD COLUMN IF NOT EXISTS default_zoom FLOAT;
ALTER TABLE city ADD COLUMN IF NOT EXISTS timezone VARCHAR;
ALTER TABLE city ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE city ADD COLUMN IF NOT EXISTS osm_relation_id INTEGER;
ALTER TABLE city ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Verify tour columns
SELECT 'TOUR COLUMNS:' as info;
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'tour' ORDER BY ordinal_position;

-- Verify city columns
SELECT 'CITY COLUMNS:' as info;
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'city' ORDER BY ordinal_position;
