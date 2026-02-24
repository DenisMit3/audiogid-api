-- Create test tour
INSERT INTO tour (id, title_ru, city_slug, description_ru, tour_type, difficulty, duration_minutes, created_at, updated_at, is_deleted) 
VALUES (gen_random_uuid(), 'Тестовый тур по Калининграду', 'kaliningrad_city', 'Описание тестового тура для проверки работы админки', 'walking', 'easy', 60, NOW(), NOW(), false);

-- Verify
SELECT id, title_ru, city_slug, published_at, is_deleted FROM tour;
