-- Check tour data for Limpopo Zoo
SELECT id, name_ru, description, transport_type, cover_url, distance_km, duration_min, city_slug, is_published 
FROM tour 
WHERE city_slug = 'nizhny_novgorod';

-- Check POIs for Nizhny Novgorod
SELECT id, name_ru, lat, lon, description, audio_url, image_url 
FROM poi 
WHERE city_slug = 'nizhny_novgorod';

-- Check tour_poi relationships
SELECT tp.tour_id, tp.poi_id, tp.order_index, p.name_ru as poi_name
FROM tour_poi tp
JOIN poi p ON tp.poi_id = p.id
JOIN tour t ON tp.tour_id = t.id
WHERE t.city_slug = 'nizhny_novgorod'
ORDER BY tp.order_index;

-- Check table structure
\d tour
\d poi
\d tour_poi
