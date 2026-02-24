-- Add Nizhny Novgorod city
INSERT INTO city (id, slug, name_ru, name_en, is_active, updated_at)
VALUES (
    gen_random_uuid(),
    'nizhny_novgorod',
    'Нижний Новгород',
    'Nizhny Novgorod',
    true,
    NOW()
) ON CONFLICT (slug) DO NOTHING;

-- Verify cities
SELECT slug, name_ru, is_active FROM city ORDER BY name_ru;
