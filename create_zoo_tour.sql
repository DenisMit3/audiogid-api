-- Скрипт создания тура "Зоопарк Лимпопо" в Нижнем Новгороде
-- Выполнить на сервере: psql $DATABASE_URL -f create_zoo_tour.sql

-- 1. Создание города Нижний Новгород
INSERT INTO city (id, slug, name_ru, name_en, description_ru, description_en, bounds_lat_min, bounds_lat_max, bounds_lon_min, bounds_lon_max, default_zoom, timezone, is_active, updated_at)
VALUES (
    gen_random_uuid(),
    'nizhny_novgorod',
    'Нижний Новгород',
    'Nizhny Novgorod',
    'Нижний Новгород - пятый по численности населения город России, расположенный на слиянии рек Оки и Волги.',
    'Nizhny Novgorod is the fifth largest city in Russia, located at the confluence of the Oka and Volga rivers.',
    56.20, 56.40, 43.80, 44.10,
    12.0,
    'Europe/Moscow',
    true,
    NOW()
) ON CONFLICT (slug) DO NOTHING;

-- 2. Создание POI (точек интереса)
-- POI 1: Главный вход
INSERT INTO poi (id, city_slug, title_ru, title_en, description_ru, description_en, category, lat, lon, address, published_at, updated_at)
VALUES (
    'a1000001-0000-0000-0000-000000000001'::uuid,
    'nizhny_novgorod',
    'Зоопарк Лимпопо - Главный вход',
    'Limpopo Zoo - Main Entrance',
    'Главный вход в зоопарк Лимпопо. Здесь расположены кассы и информационный центр. Зоопарк работает со вторника по воскресенье с 9:00 до 17:00. Стоимость билетов: взрослый - 1100 руб., льготный - 700 руб.',
    'Main entrance to Limpopo Zoo. Ticket office and information center are located here.',
    'attraction',
    56.2847, 43.9892,
    'ул. Ярошенко, д. 7Б, Нижний Новгород',
    NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- POI 2: Вольер тигров
INSERT INTO poi (id, city_slug, title_ru, title_en, description_ru, description_en, category, lat, lon, address, published_at, updated_at)
VALUES (
    'a1000001-0000-0000-0000-000000000002'::uuid,
    'nizhny_novgorod',
    'Вольер бенгальских тигров',
    'Bengal Tigers Enclosure',
    'Один из главных аттракционов зоопарка - вольер с бенгальскими тиграми. Эти величественные хищники являются одними из самых крупных представителей семейства кошачьих.',
    'One of the main attractions - the Bengal tigers enclosure.',
    'attraction',
    56.2852, 43.9898,
    'Зоопарк Лимпопо, территория',
    NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- POI 3: Контактная площадка
INSERT INTO poi (id, city_slug, title_ru, title_en, description_ru, description_en, category, lat, lon, address, published_at, updated_at)
VALUES (
    'a1000001-0000-0000-0000-000000000003'::uuid,
    'nizhny_novgorod',
    'Контактная площадка',
    'Petting Zoo Area',
    'Контактная площадка - любимое место детей и взрослых! Здесь можно погладить и покормить домашних животных: кроликов, козочек, овечек, морских свинок.',
    'Petting zoo area where visitors can interact with domestic animals.',
    'attraction',
    56.2855, 43.9885,
    'Зоопарк Лимпопо, контактная зона',
    NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- POI 4: Амазония
INSERT INTO poi (id, city_slug, title_ru, title_en, description_ru, description_en, category, lat, lon, address, published_at, updated_at)
VALUES (
    'a1000001-0000-0000-0000-000000000004'::uuid,
    'nizhny_novgorod',
    'Ботанический сад Амазония',
    'Amazonia Botanical Garden',
    'Уникальный крытый комплекс Амазония включает ботанический сад с тропическими растениями и экспозицию Ночной мир с ночными животными.',
    'Unique indoor complex with tropical plants and nocturnal animals exhibition.',
    'attraction',
    56.2849, 43.9880,
    'Зоопарк Лимпопо, комплекс Амазония',
    NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- POI 5: Жирафы
INSERT INTO poi (id, city_slug, title_ru, title_en, description_ru, description_en, category, lat, lon, address, published_at, updated_at)
VALUES (
    'a1000001-0000-0000-0000-000000000005'::uuid,
    'nizhny_novgorod',
    'Вольер с жирафами',
    'Giraffes Enclosure',
    'Жирафы - самые высокие животные на планете. В зоопарке Лимпопо можно увидеть этих грациозных животных.',
    'Giraffes enclosure - see the tallest animals on the planet.',
    'attraction',
    56.2858, 43.9895,
    'Зоопарк Лимпопо, африканская зона',
    NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- POI 6: Обезьянник
INSERT INTO poi (id, city_slug, title_ru, title_en, description_ru, description_en, category, lat, lon, address, published_at, updated_at)
VALUES (
    'a1000001-0000-0000-0000-000000000006'::uuid,
    'nizhny_novgorod',
    'Обезьянник - Приматы',
    'Primates House',
    'В обезьяннике зоопарка обитают различные виды приматов: суматранские орангутаны, капуцины, лемуры вари и другие.',
    'Primates house with orangutans, capuchins, lemurs and other species.',
    'attraction',
    56.2845, 43.9890,
    'Зоопарк Лимпопо, дом приматов',
    NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- 3. Создание тура
INSERT INTO tour (id, city_slug, title_ru, title_en, description_ru, description_en, duration_minutes, tour_type, difficulty, published_at, created_at, updated_at)
VALUES (
    'b2000001-0000-0000-0000-000000000001'::uuid,
    'nizhny_novgorod',
    'Зоопарк Лимпопо - семейная прогулка',
    'Limpopo Zoo - Family Walk',
    'Увлекательная прогулка по зоопарку Лимпопо в Нижнем Новгороде. Вы увидите бенгальских тигров, жирафов, обезьян и многих других животных. Особенно понравится детям контактная площадка.',
    'An exciting walk through Limpopo Zoo in Nizhny Novgorod.',
    120,
    'walking',
    'easy',
    NOW(), NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- 4. Добавление точек в маршрут тура
INSERT INTO tour_items (id, tour_id, poi_id, order_index, transition_text_ru, duration_seconds)
VALUES 
    (gen_random_uuid(), 'b2000001-0000-0000-0000-000000000001'::uuid, 'a1000001-0000-0000-0000-000000000001'::uuid, 0, 'Начните прогулку от главного входа. Пройдите через турникеты и следуйте по главной аллее.', 600),
    (gen_random_uuid(), 'b2000001-0000-0000-0000-000000000001'::uuid, 'a1000001-0000-0000-0000-000000000002'::uuid, 1, 'От входа идите прямо около 100 метров до вольера с тиграми. Он будет справа от вас.', 600),
    (gen_random_uuid(), 'b2000001-0000-0000-0000-000000000001'::uuid, 'a1000001-0000-0000-0000-000000000003'::uuid, 2, 'После тигров поверните налево и пройдите к контактной площадке - любимому месту детей!', 900),
    (gen_random_uuid(), 'b2000001-0000-0000-0000-000000000001'::uuid, 'a1000001-0000-0000-0000-000000000004'::uuid, 3, 'От контактной площадки пройдите к крытому комплексу Амазония - он находится в 50 метрах.', 600),
    (gen_random_uuid(), 'b2000001-0000-0000-0000-000000000001'::uuid, 'a1000001-0000-0000-0000-000000000005'::uuid, 4, 'Выйдя из Амазонии, направляйтесь к вольеру с жирафами в африканской зоне.', 600),
    (gen_random_uuid(), 'b2000001-0000-0000-0000-000000000001'::uuid, 'a1000001-0000-0000-0000-000000000006'::uuid, 5, 'Завершите прогулку посещением обезьянника - он находится недалеко от выхода.', 600)
ON CONFLICT DO NOTHING;

-- Готово!
SELECT 'Тур создан успешно!' as result;
SELECT id, title_ru FROM tour WHERE city_slug = 'nizhny_novgorod';
