-- Migration: Add override coordinates to tour_items table
-- Run this manually on the production database

-- Add override_lat column if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tour_items' AND column_name = 'override_lat'
    ) THEN
        ALTER TABLE tour_items ADD COLUMN override_lat FLOAT;
    END IF;
END $$;

-- Add override_lon column if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tour_items' AND column_name = 'override_lon'
    ) THEN
        ALTER TABLE tour_items ADD COLUMN override_lon FLOAT;
    END IF;
END $$;

-- Verify columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tour_items' 
AND column_name IN ('override_lat', 'override_lon');
