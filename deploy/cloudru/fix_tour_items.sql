-- Add missing columns to tour_items table
ALTER TABLE tour_items ADD COLUMN IF NOT EXISTS transition_text_ru VARCHAR;
ALTER TABLE tour_items ADD COLUMN IF NOT EXISTS duration_seconds INTEGER;

-- Verify columns
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'tour_items' ORDER BY ordinal_position;
