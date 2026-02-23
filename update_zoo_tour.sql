-- Обновление тура "Зоопарк Лимпопо"
-- Координаты зоопарка: 56.3097, 43.9364 (ул. Ярошенко, 7Б)

-- 1. Обновляем данные тура
UPDATE tour SET
    description_ru = 'Добро пожаловать в зоопарк "Лимпопо" - первый частный зоопарк России! На территории более 7 гектаров обитает свыше 1500 животных 270 видов. Вы увидите белых медведей в уникальном вольере с подводными окнами, жирафов, тигров, орангутанов и многих других. Маршрут проведет вас по всем основным зонам зоопарка.',
    description_en = 'Welcome to Limpopo Zoo - the first private zoo in Russia! Over 1500 animals of 270 species live on more than 7 hectares. You will see polar bears in a unique enclosure with underwater windows, giraffes, tigers, orangutans and many others.',
    cover_image = 'https://nnzoo.ru/images/zoo-main.jpg',
    distance_km = 2.5,
    duration_minutes = 120,
    tour_type = 'walking',
    updated_at = NOW()
WHERE id = 'b2000001-0000-0000-0000-000000000001';

-- 2. Создаем POI для зоопарка (если не существуют)
-- Главный вход
INSERT INTO poi (id, title_ru, title_en, city_slug, description_ru, lat, lon, category, address, published_at, updated_at)
VALUES (
    'p0000001-0000-0000-0000-000000000001',
    'Главный вход в зоопарк Лимпопо',
    'Limpopo Zoo Main Entrance',
    'nizhny_novgorod',
    'Главный вход в зоопарк. Здесь расположены кассы, информационный центр и зоомагазин. Режим работы: вт-вс 9:00-17:00.',
    56.3097,
    43.9364,
    'landmark',
    'ул. Ярошенко, 7Б',
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title_ru = EXCLUDED.title_ru,
    description_ru = EXCLUDED.description_ru,
    updated_at = NOW();

-- Вольер белых медведей
INSERT INTO poi (id, title_ru, title_en, city_slug, description_ru, lat, lon, category, address, published_at, updated_at)
VALUES (
    'p0000002-0000-0000-0000-000000000002',
    'Вольер белых медведей',
    'Polar Bear Enclosure',
    'nizhny_novgorod',
    'Уникальный вольерный комплекс площадью более 1200 м² с бассейном 220 м² и подводными окнами для наблюдения. Здесь живут белые медведи - символ зоопарка.',
    56.3102,
    43.9370,
    'landmark',
    'Зоопарк Лимпопо',
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title_ru = EXCLUDED.title_ru,
    description_ru = EXCLUDED.description_ru,
    updated_at = NOW();

-- Жирафы и копытные
INSERT INTO poi (id, title_ru, title_en, city_slug, description_ru, lat, lon, category, address, published_at, updated_at)
VALUES (
    'p0000003-0000-0000-0000-000000000003',
    'Павильон жирафов и копытных',
    'Giraffe and Hoofed Animals Pavilion',
    'nizhny_novgorod',
    'Просторный павильон с жирафами, зебрами и другими копытными животными Африки. Можно покормить жирафов специальным кормом.',
    56.3095,
    43.9380,
    'landmark',
    'Зоопарк Лимпопо',
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title_ru = EXCLUDED.title_ru,
    description_ru = EXCLUDED.description_ru,
    updated_at = NOW();

-- Хищники
INSERT INTO poi (id, title_ru, title_en, city_slug, description_ru, lat, lon, category, address, published_at, updated_at)
VALUES (
    'p0000004-0000-0000-0000-000000000004',
    'Зона хищников',
    'Predators Zone',
    'nizhny_novgorod',
    'Здесь обитают тигры, львы, леопарды и другие крупные кошки. Вольеры оборудованы смотровыми площадками для безопасного наблюдения.',
    56.3090,
    43.9375,
    'landmark',
    'Зоопарк Лимпопо',
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title_ru = EXCLUDED.title_ru,
    description_ru = EXCLUDED.description_ru,
    updated_at = NOW();

-- Приматы
INSERT INTO poi (id, title_ru, title_en, city_slug, description_ru, lat, lon, category, address, published_at, updated_at)
VALUES (
    'p0000005-0000-0000-0000-000000000005',
    'Дом приматов',
    'Primate House',
    'nizhny_novgorod',
    'Теплый павильон с орангутанами, шимпанзе, гориллами и различными видами обезьян. Интерактивные информационные стенды расскажут о жизни приматов.',
    56.3088,
    43.9368,
    'landmark',
    'Зоопарк Лимпопо',
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title_ru = EXCLUDED.title_ru,
    description_ru = EXCLUDED.description_ru,
    updated_at = NOW();

-- Контактный зоопарк
INSERT INTO poi (id, title_ru, title_en, city_slug, description_ru, lat, lon, category, address, published_at, updated_at)
VALUES (
    'p0000006-0000-0000-0000-000000000006',
    'Русская деревня - контактный зоопарк',
    'Russian Village - Petting Zoo',
    'nizhny_novgorod',
    'Площадка для близкого общения с домашними животными: козами, овцами, кроликами, курами. Отличное место для детей!',
    56.3100,
    43.9355,
    'landmark',
    'Зоопарк Лимпопо',
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title_ru = EXCLUDED.title_ru,
    description_ru = EXCLUDED.description_ru,
    updated_at = NOW();

-- 3. Удаляем старые связи тура с POI
DELETE FROM tour_items WHERE tour_id = 'b2000001-0000-0000-0000-000000000001';

-- 4. Создаем связи тура с POI (маршрут)
INSERT INTO tour_items (id, tour_id, poi_id, order_index, transition_text_ru, duration_seconds)
VALUES
    ('ti000001-0000-0000-0000-000000000001', 'b2000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 0, 'Начните маршрут у главного входа. Купите билеты и возьмите карту зоопарка.', 600),
    ('ti000002-0000-0000-0000-000000000002', 'b2000001-0000-0000-0000-000000000001', 'p0000002-0000-0000-0000-000000000002', 1, 'Пройдите прямо по главной аллее к вольеру белых медведей.', 900),
    ('ti000003-0000-0000-0000-000000000003', 'b2000001-0000-0000-0000-000000000001', 'p0000003-0000-0000-0000-000000000003', 2, 'Поверните направо к павильону жирафов.', 900),
    ('ti000004-0000-0000-0000-000000000004', 'b2000001-0000-0000-0000-000000000001', 'p0000004-0000-0000-0000-000000000004', 3, 'Продолжайте движение к зоне хищников.', 900),
    ('ti000005-0000-0000-0000-000000000005', 'b2000001-0000-0000-0000-000000000001', 'p0000005-0000-0000-0000-000000000005', 4, 'Пройдите к дому приматов.', 900),
    ('ti000006-0000-0000-0000-000000000006', 'b2000001-0000-0000-0000-000000000001', 'p0000006-0000-0000-0000-000000000006', 5, 'Завершите маршрут в контактном зоопарке "Русская деревня".', 1200);

-- 5. Проверяем результат
SELECT t.id, t.title_ru, t.description_ru, t.cover_image, t.distance_km, t.tour_type,
       (SELECT COUNT(*) FROM tour_items ti WHERE ti.tour_id = t.id) as poi_count
FROM tour t
WHERE t.id = 'b2000001-0000-0000-0000-000000000001';

-- 6. Проверяем POI
SELECT p.id, p.title_ru, p.lat, p.lon
FROM poi p
WHERE p.city_slug = 'nizhny_novgorod'
ORDER BY p.title_ru;
