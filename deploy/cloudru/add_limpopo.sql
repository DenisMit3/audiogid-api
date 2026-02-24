-- Add Limpopo tour in Nizhny Novgorod
INSERT INTO tour (id, title_ru, city_slug, description_ru, tour_type, difficulty, duration_minutes, created_at, updated_at, is_deleted, published_at)
VALUES (
    gen_random_uuid(),
    'Лимпопо',
    'nizhny_novgorod',
    'Увлекательный тур по Нижнему Новгороду',
    'walking',
    'easy',
    90,
    NOW(),
    NOW(),
    false,
    NOW()  -- Published immediately
);

-- Verify tours
SELECT id, title_ru, city_slug, published_at FROM tour ORDER BY created_at DESC;
