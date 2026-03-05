# План тестирования интеграции: Админка ↔ Backend ↔ Мобильное приложение

## Цель тестирования

Проверить работоспособность взаимодействия между:
- **Админ‑панелью** (Next.js) и backend API
- **Мобильным приложением** (Flutter) и backend API  
- **Backend API** и базой данных PostgreSQL на ckaud.ru (82.202.159.64)

## Конфигурация окружения

### Backend API
- **URL**: `http://82.202.159.64/v1` (через nginx на порту 80)
- **Домен (если настроен)**: `https://ckaud.ru/v1` или `http://ckaud.ru/v1`
- **База данных**: PostgreSQL + PostGIS (локально на сервере)

### Админ‑панель
- **URL**: Зависит от деплоя (может быть на том же сервере или отдельно)
- **API Proxy**: `/api/proxy` → проксирует запросы к `http://82.202.159.64/v1`
- **Аутентификация**: JWT токены через `/api/auth/login`

### Мобильное приложение
- **API Base URL**: `http://82.202.159.64/v1` (по умолчанию)
- **Конфигурация**: `apps/mobile_flutter/lib/core/config/app_config.dart`

---

## Тест‑кейсы

### 1. Проверка доступности Backend API

#### 1.1 Health Check
```bash
# Проверка доступности API
curl -X GET http://82.202.159.64/v1/ops/health

# Ожидаемый результат: 200 OK с JSON {"status": "ok"}
```

#### 1.2 OpenAPI Schema
```bash
# Проверка OpenAPI схемы
curl -X GET http://82.202.159.64/v1/openapi.json

# Ожидаемый результат: 200 OK с полной OpenAPI схемой
```

#### 1.3 Проверка через домен (если настроен)
```bash
# Если ckaud.ru настроен
curl -X GET https://ckaud.ru/v1/ops/health
# или
curl -X GET http://ckaud.ru/v1/ops/health
```

---

### 2. Тестирование Админ‑панели ↔ Backend

#### 2.1 Аутентификация в админке

**Шаги:**
1. Открыть админ‑панель в браузере
2. Перейти на страницу логина
3. Ввести валидные credentials
4. Проверить получение JWT токена

**Ожидаемый результат:**
- Успешный логин
- Редирект на dashboard
- JWT токен сохранён в cookies/session

**Проверка в коде:**
- `apps/admin/app/api/auth/login/route.ts` должен делать POST к `http://82.202.159.64/v1/admin/auth/login`
- Ответ должен содержать `access_token`

#### 2.2 API Proxy в админке

**Тест:** Проверка проксирования запросов через `/api/proxy`

**Примеры запросов:**

```bash
# Получение списка городов (публичный endpoint)
# Замените {ADMIN_URL} на реальный URL админки (например, http://82.202.159.64)
curl -X GET {ADMIN_URL}/api/proxy/public/cities \
  -H "Cookie: admin_token=YOUR_TOKEN"

# Получение списка POI (требует авторизации)
curl -X GET {ADMIN_URL}/api/proxy/admin/pois \
  -H "Cookie: admin_token=YOUR_TOKEN"

# Создание POI
curl -X POST {ADMIN_URL}/api/proxy/admin/pois \
  -H "Cookie: admin_token=YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title_ru": "Test POI", "city_slug": "kaliningrad_city", ...}'
```

**Ожидаемый результат:**
- Запросы проксируются корректно
- Авторизация передаётся через заголовки
- Ответы от backend возвращаются клиенту

**Проверка в коде:**
- `apps/admin/app/api/proxy/[...path]/route.ts` должен:
  - Извлекать токен из cookies
  - Добавлять `Authorization: Bearer {token}` к запросу
  - Проксировать к `http://82.202.159.64/v1/{path}`

#### 2.3 CRUD операции через админку

**Тест‑кейсы:**

1. **Создание POI**
   - Открыть админку → Content → POIs
   - Нажать "Создать POI"
   - Заполнить форму (title, city, coordinates, etc.)
   - Сохранить
   - **Проверка**: POI появился в списке и доступен через API

2. **Редактирование POI**
   - Открыть существующий POI
   - Изменить название/описание
   - Сохранить
   - **Проверка**: Изменения отображаются в админке и доступны через API

3. **Публикация POI**
   - Выбрать POI в статусе "Draft"
   - Нажать "Publish"
   - **Проверка**: POI доступен через `/public/catalog` endpoint

4. **Создание тура**
   - Открыть админку → Content → Tours
   - Создать тур с точками маршрута
   - Опубликовать
   - **Проверка**: Тур доступен через `/public/tours` endpoint

5. **Управление Entitlements**
   - Открыть админку → Entitlements
   - Создать entitlement для города/тура
   - Выдать grant пользователю
   - **Проверка**: Grant доступен через `/billing/entitlements` endpoint

---

### 3. Тестирование Мобильного приложения ↔ Backend

#### 3.1 Инициализация API клиента

**Проверка конфигурации:**
- `apps/mobile_flutter/lib/core/config/app_config.dart`
- Должен использовать `http://82.202.159.64/v1` по умолчанию
- Или переменную окружения `API_BASE_URL` если задана

**Проверка провайдеров:**
- `apps/mobile_flutter/lib/core/api/api_provider.dart`
- Должен создавать `Dio` и `ApiClient` с правильным baseUrl
- Interceptors должны работать (AuthInterceptor, EtagInterceptor, etc.)

#### 3.2 Публичные endpoints (без авторизации)

**Тест‑кейсы:**

1. **Получение списка городов**
   ```dart
   // В мобильном приложении
   final cities = await ref.read(publicApiProvider).getCities();
   ```
   - **Ожидаемый результат**: Список городов (kaliningrad_city, kaliningrad_oblast)
   - **Проверка**: Данные отображаются в CitySelectScreen

2. **Получение каталога POI**
   ```dart
   final catalog = await ref.read(publicApiProvider).getCatalog(city: 'kaliningrad_city');
   ```
   - **Ожидаемый результат**: Список POI для выбранного города
   - **Проверка**: POI отображаются в CatalogScreen

3. **Получение списка туров**
   ```dart
   final tours = await ref.read(tourRepositoryProvider).watchTours('kaliningrad_city');
   ```
   - **Ожидаемый результат**: Список опубликованных туров
   - **Проверка**: Туры отображаются в ToursListScreen

4. **Получение деталей POI**
   ```dart
   final poi = await ref.read(poiRepositoryProvider).watchPoi(poiId);
   ```
   - **Ожидаемый результат**: Полная информация о POI (title, description, media, narrations)
   - **Проверка**: Данные отображаются в PoiDetailScreen

#### 3.3 ETag кэширование

**Тест:**
1. Сделать первый запрос к `/public/catalog`
2. Проверить сохранение ETag в Drift БД
3. Сделать второй запрос с заголовком `If-None-Match`
4. **Ожидаемый результат**: 304 Not Modified, данные из кэша

**Проверка в коде:**
- `apps/mobile_flutter/lib/core/api/interceptors/etag_interceptor.dart`
- Должен сохранять ETag и использовать для последующих запросов

#### 3.4 Offline-first синхронизация

**Тест:**
1. Загрузить данные (города, туры, POI) при наличии интернета
2. Отключить интернет
3. Открыть приложение
4. **Ожидаемый результат**: Данные отображаются из локальной БД (Drift)

**Проверка в коде:**
- Репозитории должны использовать `watchTours()` / `watchPoisForCity()` которые читают из Drift
- `syncTours()` / `syncPoisForCity()` должны вызываться автоматически при watch

#### 3.5 Billing и Entitlements

**Тест‑кейсы:**

1. **Получение entitlements**
   ```dart
   final grants = await ref.read(entitlementRepositoryProvider).watchGrants();
   ```
   - **Ожидаемый результат**: Список активных grants для устройства
   - **Проверка**: Entitlements отображаются в UI (бейджи "Открыто" на турах)

2. **Покупка тура**
   - Выбрать тур в списке
   - Нажать "Купить"
   - Пройти через In-App Purchase flow
   - **Проверка**: После верификации purchase, entitlement появляется в списке grants

3. **Restore purchases**
   - Нажать "Восстановить покупки"
   - **Ожидаемый результат**: Все предыдущие покупки восстановлены, grants обновлены

**Проверка в коде:**
- `apps/mobile_flutter/lib/data/services/purchase_service.dart`
- Должен вызывать `/billing/apple/verify` или `/billing/google/verify`
- После успешной верификации вызывать `entitlementRepository.syncGrants()`

---

### 4. Тестирование работы с базой данных

#### 4.1 Проверка подключения к PostgreSQL

**На сервере:**
```bash
# Подключение к БД
psql -h localhost -U postgres -d audiogid

# Проверка таблиц
\dt

# Проверка данных
SELECT COUNT(*) FROM cities;
SELECT COUNT(*) FROM pois WHERE city_slug = 'kaliningrad_city';
SELECT COUNT(*) FROM tours WHERE city_slug = 'kaliningrad_city';
```

#### 4.2 Проверка PostGIS расширений

```sql
-- Проверка PostGIS
SELECT PostGIS_version();

-- Проверка геопространственных данных
SELECT id, title_ru, ST_AsText(location) FROM pois LIMIT 5;
```

#### 4.3 Проверка миграций

**На сервере:**
```bash
cd /opt/audiogid/apps/api
source venv/bin/activate
alembic current
alembic history
```

**Ожидаемый результат:**
- Все миграции применены
- Версия БД соответствует коду

#### 4.4 Проверка данных из админки

**Тест:**
1. Создать POI через админку
2. Проверить в БД:
   ```sql
   SELECT * FROM pois WHERE title_ru = 'Test POI';
   ```
3. Проверить связанные таблицы (media, narrations, sources)

**Ожидаемый результат:**
- Данные сохранены в БД
- Связи (foreign keys) работают корректно

#### 4.5 Проверка данных в мобильном приложении

**Тест:**
1. Создать/обновить POI через админку
2. В мобильном приложении:
   - Вызвать sync для города
   - Проверить обновление данных в Drift БД
   - Проверить отображение в UI

**Ожидаемый результат:**
- Данные синхронизируются из backend в мобильное приложение
- UI обновляется автоматически

---

### 5. Тестирование UI кнопок и взаимодействий

#### 5.1 Админ‑панель

**Кнопки для проверки:**

1. **Content → POIs**
   - ✅ "Создать POI" → открывает форму
   - ✅ "Редактировать" → открывает форму редактирования
   - ✅ "Publish" → публикует POI
   - ✅ "Unpublish" → снимает с публикации
   - ✅ "Удалить" → удаляет POI
   - ✅ Bulk actions (публикация/удаление нескольких)

2. **Content → Tours**
   - ✅ "Создать тур" → открывает редактор туров
   - ✅ Добавление точек маршрута
   - ✅ Переупорядочивание точек (drag & drop)
   - ✅ "Publish" → публикует тур

3. **Entitlements**
   - ✅ "Создать entitlement" → создаёт новый entitlement
   - ✅ "Grant" → выдаёт entitlement пользователю
   - ✅ "Revoke" → отзывает entitlement

4. **Analytics**
   - ✅ Dashboard отображает статистику
   - ✅ Heatmap отображает данные
   - ✅ Ratings отображают отзывы

#### 5.2 Мобильное приложение

**Кнопки для проверки:**

1. **ToursListScreen**
   - ✅ Фильтры (короткие/пешие/авто) → фильтруют список
   - ✅ Поиск → ищет по названию тура
   - ✅ Карточка тура → открывает TourDetailScreen
   - ✅ Мультивыбор → позволяет выбрать несколько туров
   - ✅ Batch покупка → покупает несколько туров

2. **TourDetailScreen**
   - ✅ "Начать тур" → запускает Tour Mode
   - ✅ "Предпрослушать" → воспроизводит preview аудио
   - ✅ "Купить" → открывает paywall
   - ✅ Tour Timeline → показывает прогресс тура

3. **PoiDetailScreen**
   - ✅ "Слушать" → воспроизводит narration (если есть доступ)
   - ✅ "Превью" → воспроизводит preview аудио
   - ✅ "Скачать" → добавляет в очередь загрузки
   - ✅ "Добавить в маршрут" → добавляет в itinerary

4. **Audio Player**
   - ✅ Play/Pause → управляет воспроизведением
   - ✅ Next/Previous → переключает треки
   - ✅ Progress bar → показывает прогресс
   - ✅ Mini player → переход к full player

5. **Tour Mode**
   - ✅ Карта отображает маршрут
   - ✅ Auto-play → автоматически воспроизводит аудио
   - ✅ Off-route detection → показывает баннер при отклонении
   - ✅ Завершение тура → показывает диалог оценки

---

### 6. Проверка ошибок и edge cases

#### 6.1 Обработка сетевых ошибок

**Тест:**
1. Отключить интернет
2. Попытаться загрузить данные
3. **Ожидаемый результат**: Показывается error state, данные из кэша если доступны

#### 6.2 Обработка ошибок API

**Тест:**
1. Отправить невалидный запрос (например, создать POI без обязательных полей)
2. **Ожидаемый результат**: Показывается понятное сообщение об ошибке

#### 6.3 Обработка истёкших токенов

**Тест:**
1. В админке: использовать истёкший JWT токен
2. **Ожидаемый результат**: Редирект на страницу логина

#### 6.4 Обработка больших объёмов данных

**Тест:**
1. Загрузить каталог с большим количеством POI (1000+)
2. **Ожидаемый результат**: Пагинация работает, UI не зависает

---

## Чек‑лист для ручного тестирования

### Админ‑панель
- [ ] Логин работает корректно
- [ ] Dashboard загружается и показывает статистику
- [ ] Создание POI работает и данные сохраняются в БД
- [ ] Редактирование POI работает
- [ ] Публикация POI делает его доступным через public API
- [ ] Создание тура работает
- [ ] Управление entitlements работает
- [ ] Analytics отображают данные
- [ ] Все кнопки реагируют на клики

### Мобильное приложение
- [ ] Выбор города работает
- [ ] Список туров загружается и отображается
- [ ] Фильтры и поиск работают
- [ ] Детали тура отображаются корректно
- [ ] Детали POI отображаются корректно
- [ ] Аудио плеер работает (play/pause/next/prev)
- [ ] Tour Mode запускается и работает
- [ ] Покупка тура работает (если настроен IAP)
- [ ] Offline режим работает (данные из кэша)
- [ ] Все кнопки реагируют на нажатия

### Backend API
- [ ] Health check возвращает 200 OK
- [ ] OpenAPI schema доступна
- [ ] Публичные endpoints работают без авторизации
- [ ] Admin endpoints требуют авторизации
- [ ] База данных доступна и данные корректны
- [ ] Миграции применены

---

## Автоматизированные тесты

### Скрипт для проверки API (bash)

```bash
#!/bin/bash

API_BASE="http://82.202.159.64/v1"

echo "Testing API endpoints..."

# Health check
echo "1. Health check..."
curl -s "$API_BASE/ops/health" | jq .

# Public endpoints
echo "2. Cities..."
curl -s "$API_BASE/public/cities" | jq '.[0:2]'

echo "3. Catalog (kaliningrad_city)..."
curl -s "$API_BASE/public/catalog?city=kaliningrad_city" | jq '.pois | length'

echo "4. Tours..."
curl -s "$API_BASE/public/tours?city=kaliningrad_city" | jq '.[0:2]'

echo "Tests completed!"
```

### Скрипт для проверки интеграции админки (Node.js)

```javascript
// test-admin-integration.js
const fetch = require('node-fetch');

const API_BASE = 'http://82.202.159.64/v1';
const ADMIN_BASE = 'http://localhost:3000'; // или URL админки

async function testAdminIntegration() {
  // 1. Логин
  const loginRes = await fetch(`${ADMIN_BASE}/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username: 'admin', password: 'password' })
  });
  const { access_token } = await loginRes.json();
  
  // 2. Проверка proxy
  const citiesRes = await fetch(`${ADMIN_BASE}/api/proxy/public/cities`, {
    headers: { 'Cookie': `admin_token=${access_token}` }
  });
  const cities = await citiesRes.json();
  console.log('Cities:', cities.length);
  
  // 3. Проверка admin endpoint
  const poisRes = await fetch(`${ADMIN_BASE}/api/proxy/admin/pois`, {
    headers: { 'Cookie': `admin_token=${access_token}` }
  });
  const pois = await poisRes.json();
  console.log('POIs:', pois.length);
}

testAdminIntegration();
```

---

## Отчёт о тестировании

После выполнения тестов заполнить:

### Результаты тестирования

**Дата:** _______________
**Тестировщик:** _______________

#### Backend API
- Health check: ✅ / ❌
- OpenAPI schema: ✅ / ❌
- Публичные endpoints: ✅ / ❌
- Admin endpoints: ✅ / ❌

#### Админ‑панель
- Логин: ✅ / ❌
- CRUD операции: ✅ / ❌
- API Proxy: ✅ / ❌
- UI кнопки: ✅ / ❌

#### Мобильное приложение
- Загрузка данных: ✅ / ❌
- Offline режим: ✅ / ❌
- Аудио плеер: ✅ / ❌
- Tour Mode: ✅ / ❌
- Покупки: ✅ / ❌
- UI кнопки: ✅ / ❌

#### База данных
- Подключение: ✅ / ❌
- Миграции: ✅ / ❌
- Данные: ✅ / ❌

### Найденные проблемы

1. _______________________________
2. _______________________________
3. _______________________________

### Рекомендации

1. _______________________________
2. _______________________________
3. _______________________________

---

## Примечания

- Если домен `ckaud.ru` настроен, использовать его вместо IP адреса
- Проверить настройки nginx на сервере для проксирования запросов
- Убедиться, что все переменные окружения настроены корректно
- Проверить логи на сервере при возникновении ошибок

