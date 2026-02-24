-- Find Nizhny Novgorod city
SELECT * FROM city WHERE slug ILIKE '%nizhny%' OR name_ru ILIKE '%нижн%' OR name_ru ILIKE '%новгород%';

-- Find all cities
SELECT slug, name_ru FROM city;

-- Find tours with Nizhny Novgorod
SELECT id, title_ru, city_slug FROM tour WHERE city_slug ILIKE '%nizhny%' OR title_ru ILIKE '%лимпопо%';

-- Find all tours
SELECT id, title_ru, city_slug, published_at FROM tour;
