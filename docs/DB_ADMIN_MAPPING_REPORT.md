# Отчёт о взаимосвязи таблиц БД и админки

**Дата:** 2026-01-28  
**Цель:** Проверка соответствия структуры базы данных и форм админки

## Резюме

✅ **Все основные таблицы имеют соответствующие формы в админке**  
✅ **Foreign keys и relationships корректно настроены**  
✅ **API endpoints соответствуют CRUD операциям**  
✅ **Поля в формах соответствуют полям в БД**

---

## 1. Структура базы данных

### Основные таблицы и их связи

#### City (Города)
**Таблица**: `city`  
**Primary Key**: `id` (UUID)  
**Unique Index**: `slug`

**Связи**:
- `tours` → `Tour.city` (one-to-many)
- `pois` → `Poi.city` (one-to-many)

**Поля**:
- `slug` (str, unique, index) - используется как foreign key в Poi и Tour
- `name_ru`, `name_en`
- `description_ru`, `description_en`
- `cover_image`
- `bounds_lat_min/max`, `bounds_lon_min/max`
- `default_zoom`, `timezone`
- `is_active`
- `osm_relation_id`
- `updated_at`

#### Poi (Точки интереса)
**Таблица**: `poi`  
**Primary Key**: `id` (UUID)  
**Foreign Keys**:
- `city_slug` → `city.slug`

**Связи**:
- `city` ← `City.pois` (many-to-one)
- `tour_items` → `TourItem.poi` (one-to-many)
- `sources` → `PoiSource.poi` (one-to-many)
- `media` → `PoiMedia.poi` (one-to-many)
- `narrations` → `Narration.poi` (one-to-many)

**Поля**:
- `title_ru`, `title_en`
- `description_ru`, `description_en`
- `city_slug` (FK → city.slug)
- `category` (index)
- `address`
- `cover_image`
- `lat`, `lon`
- `geo` (PostGIS Geography POINT)
- `osm_id`, `wikidata_id` (index)
- `preview_audio_url`
- `preview_bullets` (JSON)
- `opening_hours` (JSON)
- `external_links` (JSON array)
- `published_at` (index)
- `confidence_score`
- `is_deleted`, `deleted_at` (soft delete)
- `updated_at` (index)

#### Tour (Туры)
**Таблица**: `tour`  
**Primary Key**: `id` (UUID)  
**Foreign Keys**:
- `city_slug` → `city.slug`

**Связи**:
- `city` ← `City.tours` (many-to-one)
- `items` → `TourItem.tour` (one-to-many)
- `sources` → `TourSource.tour` (one-to-many)
- `media` → `TourMedia.tour` (one-to-many)

**Поля**:
- `title_ru`, `title_en`
- `description_ru`, `description_en`
- `city_slug` (FK → city.slug)
- `cover_image`
- `tour_type` (walking, driving, cycling, boat)
- `difficulty` (easy, moderate, hard)
- `distance_km`
- `duration_minutes`
- `published_at` (index)
- `created_at`, `updated_at`
- `is_deleted`, `deleted_at` (soft delete)

#### TourItem (Элементы тура)
**Таблица**: `tour_items`  
**Primary Key**: `id` (UUID)  
**Foreign Keys**:
- `tour_id` → `tour.id`
- `poi_id` → `poi.id` (optional)

**Связи**:
- `tour` ← `Tour.items` (many-to-one)
- `poi` ← `Poi.tour_items` (many-to-one, optional)

**Поля**:
- `tour_id` (FK → tour.id)
- `poi_id` (FK → poi.id, optional)
- `order_index`
- `transition_text_ru`, `transition_text_en`
- `transition_audio_url`
- `duration_seconds`
- `override_lat`, `override_lon`

#### Связанные таблицы

**PoiSource** (`poi_sources`):
- `poi_id` → `poi.id`
- `name`, `url`

**PoiMedia** (`poi_media`):
- `poi_id` → `poi.id`
- `url`, `media_type`, `license_type`, `author`, `source_page_url`

**Narration** (`narrations`):
- `poi_id` → `poi.id`
- `locale`, `url`, `kids_url`, `duration_seconds`, `transcript`, `voice_id`, `filesize_bytes`

**TourSource** (`tour_sources`):
- `tour_id` → `tour.id`
- `name`, `url`, `retrieved_at`

**TourMedia** (`tour_media`):
- `tour_id` → `tour.id`
- `url`, `media_type`, `license_type`, `author`, `source_page_url`

---

## 2. Соответствие форм админки и таблиц БД

### City Form ↔ City Table

**Файл формы**: `apps/admin/components/cities/city-form.tsx`  
**API endpoint**: `/admin/cities` (POST, PATCH)

| Поле формы | Поле БД | Тип | Обязательное | Статус |
|------------|---------|-----|--------------|--------|
| `slug` | `slug` | string | ✅ Да | ✅ Соответствует |
| `name_ru` | `name_ru` | string | ✅ Да | ✅ Соответствует |
| `name_en` | `name_en` | string | ❌ Нет | ✅ Соответствует |
| `description_ru` | `description_ru` | string | ❌ Нет | ✅ Соответствует |
| `description_en` | `description_en` | string | ❌ Нет | ✅ Соответствует |
| `cover_image` | `cover_image` | string | ❌ Нет | ✅ Соответствует |
| `timezone` | `timezone` | string | ❌ Нет | ✅ Соответствует |
| `is_active` | `is_active` | boolean | ❌ Нет (default: true) | ✅ Соответствует |
| `bounds_lat_min` | `bounds_lat_min` | float | ❌ Нет | ✅ Соответствует |
| `bounds_lat_max` | `bounds_lat_max` | float | ❌ Нет | ✅ Соответствует |
| `bounds_lon_min` | `bounds_lon_min` | float | ❌ Нет | ✅ Соответствует |
| `bounds_lon_max` | `bounds_lon_max` | float | ❌ Нет | ✅ Соответствует |
| `default_zoom` | `default_zoom` | float | ❌ Нет | ✅ Соответствует |

**Поля БД не в форме** (автоматические):
- `id` (генерируется)
- `updated_at` (автоматически)
- `osm_relation_id` (не редактируется через форму)

### Poi Form ↔ Poi Table

**Файл формы**: `apps/admin/components/PoiForm.tsx`  
**API endpoint**: `/admin/pois` (POST, PATCH)

| Поле формы | Поле БД | Тип | Обязательное | Статус |
|------------|---------|-----|--------------|--------|
| `title_ru` | `title_ru` | string | ✅ Да | ✅ Соответствует |
| `title_en` | `title_en` | string | ❌ Нет | ✅ Соответствует |
| `city_slug` | `city_slug` | string (FK) | ✅ Да | ✅ Соответствует |
| `description_ru` | `description_ru` | string | ❌ Нет | ✅ Соответствует |
| `description_en` | `description_en` | string | ❌ Нет | ✅ Соответствует |
| `category` | `category` | string | ❌ Нет | ✅ Соответствует |
| `address` | `address` | string | ❌ Нет | ✅ Соответствует |
| `cover_image` | `cover_image` | string | ❌ Нет | ✅ Соответствует |
| `lat` | `lat` | float | ❌ Нет | ✅ Соответствует |
| `lon` | `lon` | float | ❌ Нет | ✅ Соответствует |
| `opening_hours` | `opening_hours` | JSON | ❌ Нет | ✅ Соответствует |
| `external_links` | `external_links` | JSON array | ❌ Нет | ✅ Соответствует |
| `preview_audio_url` | `preview_audio_url` | string | ❌ Нет | ✅ Соответствует |
| `preview_bullets` | `preview_bullets` | JSON array | ❌ Нет | ✅ Соответствует |

**Связанные данные** (отдельные вкладки):
- `sources` → `PoiSource` (CRUD через `/admin/pois/{id}/sources`)
- `media` → `PoiMedia` (CRUD через `/admin/pois/{id}/media`)
- `narrations` → `Narration` (CRUD через `/admin/pois/{id}/narrations`)

**Поля БД не в форме** (автоматические):
- `id` (генерируется)
- `geo` (вычисляется из lat/lon)
- `osm_id`, `wikidata_id` (из ingestion)
- `confidence_score` (вычисляется)
- `published_at` (устанавливается через publish action)
- `is_deleted`, `deleted_at` (soft delete)
- `updated_at` (автоматически)

### Tour Form ↔ Tour Table

**Файл формы**: `apps/admin/components/tour-editor.tsx`  
**API endpoint**: `/admin/tours` (POST, PATCH)

| Поле формы | Поле БД | Тип | Обязательное | Статус |
|------------|---------|-----|--------------|--------|
| `title_ru` | `title_ru` | string | ✅ Да | ✅ Соответствует |
| `title_en` | `title_en` | string | ❌ Нет | ✅ Соответствует |
| `city_slug` | `city_slug` | string (FK) | ✅ Да | ✅ Соответствует |
| `description_ru` | `description_ru` | string | ❌ Нет | ✅ Соответствует |
| `description_en` | `description_en` | string | ❌ Нет | ✅ Соответствует |
| `duration_minutes` | `duration_minutes` | int | ❌ Нет | ✅ Соответствует |
| `distance_km` | `distance_km` | float | ❌ Нет | ✅ Соответствует |
| `tour_type` | `tour_type` | string | ❌ Нет (default: walking) | ✅ Соответствует |
| `difficulty` | `difficulty` | string | ❌ Нет (default: easy) | ✅ Соответствует |
| `cover_image` | `cover_image` | string | ❌ Нет | ✅ Соответствует |

**Связанные данные** (отдельные вкладки):
- `items` → `TourItem` (CRUD через `/admin/tours/{id}/items`)
- `sources` → `TourSource` (CRUD через `/admin/tours/{id}/sources`)
- `media` → `TourMedia` (CRUD через `/admin/tours/{id}/media`)

**Поля БД не в форме** (автоматические):
- `id` (генерируется)
- `published_at` (устанавливается через publish action)
- `created_at`, `updated_at` (автоматически)
- `is_deleted`, `deleted_at` (soft delete)

---

## 3. API Endpoints и CRUD операции

### Cities API

**Base URL**: `/admin/cities`

| Метод | Endpoint | Операция | Таблица | Статус |
|-------|----------|----------|---------|--------|
| GET | `/admin/cities` | Список городов | `city` | ✅ |
| GET | `/admin/cities/{id}` | Детали города | `city` | ✅ |
| POST | `/admin/cities` | Создать город | `city` | ✅ |
| PATCH | `/admin/cities/{id}` | Обновить город | `city` | ✅ |
| DELETE | `/admin/cities/{id}` | Удалить город | `city` | ✅ |

### POIs API

**Base URL**: `/admin/pois`

| Метод | Endpoint | Операция | Таблица | Статус |
|-------|----------|----------|---------|--------|
| GET | `/admin/pois` | Список POI | `poi` | ✅ |
| GET | `/admin/pois/{id}` | Детали POI | `poi` + связанные | ✅ |
| POST | `/admin/pois` | Создать POI | `poi` | ✅ |
| PATCH | `/admin/pois/{id}` | Обновить POI | `poi` | ✅ |
| DELETE | `/admin/pois/{id}` | Удалить POI (soft) | `poi` | ✅ |
| POST | `/admin/pois/{id}/publish` | Опубликовать | `poi` | ✅ |
| POST | `/admin/pois/{id}/unpublish` | Снять с публикации | `poi` | ✅ |

**Связанные endpoints**:
- `GET/POST/DELETE /admin/pois/{id}/sources` → `poi_sources`
- `GET/POST/DELETE /admin/pois/{id}/media` → `poi_media`
- `GET/POST/DELETE /admin/pois/{id}/narrations` → `narrations`

### Tours API

**Base URL**: `/admin/tours`

| Метод | Endpoint | Операция | Таблица | Статус |
|-------|----------|----------|---------|--------|
| GET | `/admin/tours` | Список туров | `tour` | ✅ |
| GET | `/admin/tours/{id}` | Детали тура | `tour` + связанные | ✅ |
| POST | `/admin/tours` | Создать тур | `tour` | ✅ |
| PATCH | `/admin/tours/{id}` | Обновить тур | `tour` | ✅ |
| DELETE | `/admin/tours/{id}` | Удалить тур (soft) | `tour` | ✅ |
| POST | `/admin/tours/{id}/publish` | Опубликовать | `tour` | ✅ |
| POST | `/admin/tours/{id}/unpublish` | Снять с публикации | `tour` | ✅ |

**Связанные endpoints**:
- `GET/POST/PATCH/DELETE /admin/tours/{id}/items` → `tour_items`
- `GET/POST/DELETE /admin/tours/{id}/sources` → `tour_sources`
- `GET/POST/DELETE /admin/tours/{id}/media` → `tour_media`

---

## 4. Проверка целостности связей

### Foreign Keys

✅ **City → Poi/Tour**: `city_slug` в Poi и Tour ссылается на `city.slug`  
✅ **Poi → PoiSource**: `poi_id` в PoiSource ссылается на `poi.id`  
✅ **Poi → PoiMedia**: `poi_id` в PoiMedia ссылается на `poi.id`  
✅ **Poi → Narration**: `poi_id` в Narration ссылается на `poi.id`  
✅ **Tour → TourItem**: `tour_id` в TourItem ссылается на `tour.id`  
✅ **TourItem → Poi**: `poi_id` в TourItem ссылается на `poi.id` (optional)  
✅ **Tour → TourSource**: `tour_id` в TourSource ссылается на `tour.id`  
✅ **Tour → TourMedia**: `tour_id` в TourMedia ссылается на `tour.id`

### Relationships (SQLModel)

✅ **City.tours** ↔ **Tour.city** (back_populates)  
✅ **City.pois** ↔ **Poi.city** (back_populates)  
✅ **Poi.tour_items** ↔ **TourItem.poi** (back_populates)  
✅ **Poi.sources** ↔ **PoiSource.poi** (back_populates)  
✅ **Poi.media** ↔ **PoiMedia.poi** (back_populates)  
✅ **Poi.narrations** ↔ **Narration.poi** (back_populates)  
✅ **Tour.items** ↔ **TourItem.tour** (back_populates)  
✅ **Tour.sources** ↔ **TourSource.tour** (back_populates)  
✅ **Tour.media** ↔ **TourMedia.tour** (back_populates)

---

## 5. Проверка валидации

### City Form Validation

✅ Slug: минимум 2 символа, только `[a-z0-9-_]`  
✅ Name RU: минимум 2 символа  
✅ Cover Image: валидация URL  
✅ Bounds: валидация диапазонов (-90..90 для lat, -180..180 для lon)  
✅ Zoom: валидация диапазона (0..22)

### Poi Form Validation

✅ Title RU: минимум 3 символа  
✅ City Slug: обязательное поле  
✅ Lat/Lon: валидация диапазонов  
✅ External Links: валидация URL для каждого элемента массива

### Tour Form Validation

✅ Title RU: минимум 3 символа  
✅ City Slug: обязательное поле  
✅ Duration/Distance: валидация неотрицательных чисел  
✅ Tour Type: выбор из предопределённых значений  
✅ Difficulty: выбор из предопределённых значений

---

## 6. Выявленные проблемы и рекомендации

### ✅ Что работает отлично:

1. Все основные таблицы имеют соответствующие формы
2. Foreign keys корректно настроены
3. Relationships настроены с back_populates
4. API endpoints покрывают все CRUD операции
5. Валидация форм соответствует ограничениям БД
6. Soft delete реализован для Poi и Tour

### ✅ Дополнительные функции:

1. **Версионирование**: ✅ Реализовано - при создании/обновлении POI/Tour создаётся запись в `poi_versions`/`tour_versions`
2. **Audit Log**: ✅ Реализовано - все изменения логируются в `audit_logs` через `AppEvent`
3. **Publish Check**: ✅ Реализовано - проверка возможности публикации перед publish
4. **Soft Delete**: ✅ Реализовано - используется `is_deleted` флаг вместо физического удаления
5. **Geo Fields**: ✅ Реализовано - автоматическое обновление PostGIS `geo` поля при изменении lat/lon

### ⚠️ Рекомендации:

1. **Проверить каскадное удаление**: При удалении City должны удаляться связанные Poi и Tour (или помечаться как deleted) - сейчас используется soft delete
2. **Проверить уникальность**: Убедиться что `city.slug` действительно unique на уровне БД - ✅ настроено в модели
3. **Индексы**: ✅ Все необходимые индексы настроены в моделях (city_slug, published_at, is_deleted, osm_id, wikidata_id)
4. **Валидация publish**: ✅ Реализована проверка перед публикацией (title, description, coordinates, city)

---

## 7. Схема связей

### Иерархическая структура

```
City (1)
  ├──< (many) Poi
  │     ├──< (many) PoiSource
  │     ├──< (many) PoiMedia
  │     ├──< (many) Narration
  │     └──< (many) TourItem (optional link)
  │
  └──< (many) Tour
        ├──< (many) TourItem
        │     └──> (1) Poi (optional)
        ├──< (many) TourSource
        └──< (many) TourMedia
```

### Foreign Key Mapping

| Таблица | Foreign Key | Ссылается на | Тип связи | Каскад |
|---------|-------------|--------------|-----------|--------|
| `poi` | `city_slug` | `city.slug` | Many-to-One | ❌ Нет (защита при удалении) |
| `tour` | `city_slug` | `city.slug` | Many-to-One | ❌ Нет (защита при удалении) |
| `poi_sources` | `poi_id` | `poi.id` | Many-to-One | ✅ Удаление при удалении POI |
| `poi_media` | `poi_id` | `poi.id` | Many-to-One | ✅ Удаление при удалении POI |
| `narrations` | `poi_id` | `poi.id` | Many-to-One | ✅ Удаление при удалении POI |
| `tour_items` | `tour_id` | `tour.id` | Many-to-One | ✅ Удаление при удалении Tour |
| `tour_items` | `poi_id` | `poi.id` | Many-to-One (optional) | ❌ Нет (optional) |
| `tour_sources` | `tour_id` | `tour.id` | Many-to-One | ✅ Удаление при удалении Tour |
| `tour_media` | `tour_id` | `tour.id` | Many-to-One | ✅ Удаление при удалении Tour |

### Admin Panel → API → Database Flow

```
Admin Form (PoiForm.tsx)
    ↓ POST/PATCH /api/proxy/admin/pois/{id}
Admin Proxy (route.ts)
    ↓ Forward to backend
Backend API (poi.py)
    ↓ Validate & Process
Database (PostgreSQL)
    ↓ SQLModel ORM
Table: poi
    ↓ Relationships
Related Tables: poi_sources, poi_media, narrations
```

### CRUD Operations Mapping

#### Create Operation
1. **Admin Form** → заполнение полей
2. **POST /admin/pois** → валидация через Pydantic
3. **SQLModel** → создание записи в БД
4. **Relationships** → автоматическая загрузка связанных данных
5. **Versioning** → создание записи в `poi_versions`
6. **Audit** → запись в `audit_logs` и `app_events`

#### Update Operation
1. **Admin Form** → изменение полей
2. **PATCH /admin/pois/{id}** → частичное обновление
3. **SQLModel** → обновление записи в БД
4. **Geo Update** → автоматическое обновление PostGIS `geo` поля
5. **Versioning** → создание новой версии
6. **Audit** → запись изменений

#### Delete Operation
1. **Admin UI** → кнопка удаления
2. **DELETE /admin/pois/{id}** → soft delete
3. **SQLModel** → установка `is_deleted = True`
4. **Unpublish** → снятие с публикации (`published_at = None`)
5. **Audit** → запись удаления

#### Read Operation
1. **Admin UI** → загрузка списка/деталей
2. **GET /admin/pois** или **GET /admin/pois/{id}**
3. **SQLModel** → запрос с фильтрацией (is_deleted, published_at)
4. **Relationships** → загрузка связанных данных (sources, media, narrations)
5. **Enrichment** → добавление `can_publish`, `publish_issues`

---

## 8. Детальная проверка целостности

### Проверка каскадных операций

#### City Delete Protection
✅ **Реализовано**: При попытке удалить City проверяется наличие связанных POI и Tours
```python
# apps/api/api/admin/cities.py:189-193
if city.pois and len(city.pois) > 0:
    raise HTTPException(400, f"Cannot delete city with {len(city.pois)} POIs...")
if city.tours and len(city.tours) > 0:
    raise HTTPException(400, f"Cannot delete city with {len(city.tours)} Tours...")
```

#### Soft Delete для Poi и Tour
✅ **Реализовано**: Используется `is_deleted` флаг вместо физического удаления
- Poi: `is_deleted = True`, `deleted_at = datetime.utcnow()`, `published_at = None`
- Tour: аналогично

#### Версионирование
✅ **Реализовано**: При каждом изменении создаётся запись в `poi_versions`/`tour_versions`
- Сохраняется snapshot важных полей
- Записывается `changed_by` (user_id)
- Сохраняется `full_snapshot_json` для полного восстановления

#### Audit Logging
✅ **Реализовано**: Все операции логируются в `audit_logs` и `app_events`
- CREATE, UPDATE, DELETE операции
- Publish/Unpublish действия
- Записывается `actor_fingerprint` (user_id)
- Записывается `action` (CREATE_POI, UPDATE_TOUR, etc.)

### Проверка Foreign Key Constraints

#### City → Poi/Tour
✅ **Проверка**: `city_slug` в Poi и Tour должен существовать в `city.slug`
- При создании POI/Tour: проверяется существование City
- При обновлении: если меняется `city_slug`, проверяется новый City
- При удалении City: проверяется отсутствие зависимостей

#### Poi → Related Tables
✅ **Проверка**: Все связанные таблицы имеют правильные foreign keys
- `PoiSource.poi_id` → `poi.id` ✅
- `PoiMedia.poi_id` → `poi.id` ✅
- `Narration.poi_id` → `poi.id` ✅
- `TourItem.poi_id` → `poi.id` (optional) ✅

#### Tour → Related Tables
✅ **Проверка**: Все связанные таблицы имеют правильные foreign keys
- `TourItem.tour_id` → `tour.id` ✅
- `TourSource.tour_id` → `tour.id` ✅
- `TourMedia.tour_id` → `tour.id` ✅

### Проверка данных в формах админки

#### PoiForm → Poi Table
✅ **Все поля соответствуют**:
- Основные поля: ✅
- Геолокация: ✅ (lat/lon → geo автоматически)
- Связанные данные: ✅ (sources, media, narrations через отдельные endpoints)

#### TourEditor → Tour Table
✅ **Все поля соответствуют**:
- Основные поля: ✅
- Tour Items: ✅ (управление через `/admin/tours/{id}/items`)
- Связанные данные: ✅ (sources, media через отдельные endpoints)

#### CityForm → City Table
✅ **Все поля соответствуют**:
- Основные поля: ✅
- Map bounds: ✅
- Счётчики POI/Tours: ✅ (вычисляются автоматически, не редактируются)

---

## Выводы

✅ **Взаимосвязь таблиц БД и админки настроена корректно**  
✅ **Все основные CRUD операции реализованы**  
✅ **Foreign keys и relationships работают правильно**  
✅ **Формы соответствуют структуре таблиц**  
✅ **Защита от каскадного удаления реализована**  
✅ **Версионирование и аудит работают**  
✅ **Валидация publish реализована**

### Итоговая оценка

| Компонент | Статус | Примечания |
|-----------|--------|------------|
| Структура БД | ✅ Отлично | Все таблицы правильно спроектированы |
| Foreign Keys | ✅ Отлично | Все связи настроены корректно |
| Relationships | ✅ Отлично | SQLModel relationships работают |
| API Endpoints | ✅ Отлично | Все CRUD операции реализованы |
| Формы админки | ✅ Отлично | Соответствуют структуре БД |
| Валидация | ✅ Отлично | Проверки на уровне API и форм |
| Защита данных | ✅ Отлично | Soft delete, версионирование, аудит |

**Система готова к использованию. Все связи между таблицами и админкой работают корректно и надёжно.**

