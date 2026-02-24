-- Add missing columns to tour table
ALTER TABLE tour ADD COLUMN IF NOT EXISTS title_en VARCHAR;
ALTER TABLE tour ADD COLUMN IF NOT EXISTS description_en VARCHAR;
ALTER TABLE tour ADD COLUMN IF NOT EXISTS cover_url VARCHAR;
ALTER TABLE tour ADD COLUMN IF NOT EXISTS price_amount FLOAT DEFAULT 0;
ALTER TABLE tour ADD COLUMN IF NOT EXISTS price_currency VARCHAR DEFAULT 'RUB';

-- Add missing columns to poi table
ALTER TABLE poi ADD COLUMN IF NOT EXISTS title_en VARCHAR;
ALTER TABLE poi ADD COLUMN IF NOT EXISTS description_en VARCHAR;
ALTER TABLE poi ADD COLUMN IF NOT EXISTS cover_url VARCHAR;

-- Add missing columns to city table  
ALTER TABLE city ADD COLUMN IF NOT EXISTS title_en VARCHAR;
ALTER TABLE city ADD COLUMN IF NOT EXISTS description_en VARCHAR;

-- Verify
SELECT 'tour columns:' as info;
SELECT column_name FROM information_schema.columns WHERE table_name = 'tour' ORDER BY ordinal_position;

SELECT 'poi columns:' as info;
SELECT column_name FROM information_schema.columns WHERE table_name = 'poi' ORDER BY ordinal_position;
