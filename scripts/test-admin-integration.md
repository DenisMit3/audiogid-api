# Тестирование интеграции Админ-панели

## Подготовка

1. Убедиться, что backend API доступен по адресу `http://82.202.159.64/v1`
2. Запустить админ-панель локально или подключиться к развёрнутой версии
3. Иметь валидные credentials для входа

## Конфигурация

### Переменные окружения

Проверить файл `.env.local` или переменные окружения:

```env
NEXT_PUBLIC_API_URL=http://82.202.159.64/v1
```

### Проверка в коде

Файл `apps/admin/app/api/proxy/[...path]/route.ts`:
- Должен использовать `process.env.NEXT_PUBLIC_API_URL` или `http://82.202.159.64/v1` по умолчанию
- Должен проксировать запросы к backend

Файл `apps/admin/app/api/auth/login/route.ts`:
- Должен использовать тот же API URL
- Должен делать POST к `/auth/login/*` endpoints

## Тест-кейсы

### 1. Аутентификация

**Шаги:**
1. Открыть админ-панель в браузере
2. Перейти на страницу логина (`/login`)
3. Ввести credentials (email/password или dev-admin secret)
4. Нажать "Войти"

**Ожидаемый результат:**
- Успешный логин
- Редирект на `/dashboard` или главную страницу панели
- JWT токен сохранён в cookie `token`
- В консоли браузера нет ошибок

**Проверка в Network tab:**
```
POST /api/auth/login
Status: 200 OK
Response: { "success": true }
Set-Cookie: token=...; Path=/; HttpOnly
```

**Проверка в коде:**
- `apps/admin/app/api/auth/login/route.ts` делает POST к `http://82.202.159.64/v1/auth/login/*`
- Токен сохраняется в cookie

### 2. API Proxy

**Тест:** Проверка проксирования запросов

**Шаги:**
1. После логина открыть любую страницу админки (например, Dashboard)
2. Открыть DevTools → Network
3. Проверить запросы к `/api/proxy/*`

**Ожидаемый результат:**
- Запросы проксируются к backend
- Заголовок `Authorization: Bearer {token}` добавляется автоматически
- Ответы от backend возвращаются клиенту

**Пример запроса:**
```
GET /api/proxy/public/cities
Headers:
  Cookie: token=...
  
Проксируется к:
GET http://82.202.159.64/v1/public/cities
Headers:
  Authorization: Bearer ...
```

**Проверка в коде:**
- `apps/admin/app/api/proxy/[...path]/route.ts` должен:
  - Извлекать токен из cookie
  - Добавлять Authorization header
  - Проксировать к backend

### 3. CRUD операции

#### 3.1 Создание POI

**Шаги:**
1. Открыть Content → POIs
2. Нажать "Создать POI"
3. Заполнить форму:
   - Title (RU)
   - City (kaliningrad_city)
   - Coordinates (lat, lon)
   - Description (опционально)
4. Нажать "Сохранить"

**Ожидаемый результат:**
- POI создаётся в backend
- POI появляется в списке
- Данные сохраняются в БД

**Проверка в Network:**
```
POST /api/proxy/admin/pois
Body: { "title_ru": "...", "city_slug": "...", ... }
Status: 200 OK или 201 Created
```

**Проверка в БД:**
```sql
SELECT * FROM pois WHERE title_ru = '...' ORDER BY created_at DESC LIMIT 1;
```

#### 3.2 Редактирование POI

**Шаги:**
1. Открыть существующий POI
2. Изменить название или описание
3. Сохранить

**Ожидаемый результат:**
- Изменения сохраняются в backend
- UI обновляется
- Данные в БД обновляются

**Проверка в Network:**
```
PATCH /api/proxy/admin/pois/{id}
Body: { "title_ru": "Updated title", ... }
Status: 200 OK
```

#### 3.3 Публикация POI

**Шаги:**
1. Выбрать POI в статусе "Draft"
2. Нажать "Publish"

**Ожидаемый результат:**
- POI публикуется
- Статус меняется на "Published"
- POI доступен через `/public/catalog` endpoint

**Проверка в Network:**
```
POST /api/proxy/admin/pois/{id}/publish
Status: 200 OK
```

**Проверка через public API:**
```bash
curl http://82.202.159.64/v1/public/catalog?city=kaliningrad_city | jq '.pois[] | select(.id == "...")'
```

#### 3.4 Создание тура

**Шаги:**
1. Открыть Content → Tours
2. Нажать "Создать тур"
3. Заполнить форму:
   - Title (RU)
   - City
   - Description
   - Добавить точки маршрута (POI)
4. Сохранить и опубликовать

**Ожидаемый результат:**
- Тур создаётся в backend
- Точки маршрута сохраняются
- Тур доступен через `/public/tours` endpoint

**Проверка в Network:**
```
POST /api/proxy/admin/tours
Body: { "title_ru": "...", "city_slug": "...", ... }
Status: 200 OK

POST /api/proxy/admin/tours/{id}/items
Body: [ { "poi_id": "...", "order_index": 0 }, ... ]
Status: 200 OK

POST /api/proxy/admin/tours/{id}/publish
Status: 200 OK
```

#### 3.5 Управление Entitlements

**Шаги:**
1. Открыть Entitlements
2. Создать entitlement (например, для города)
3. Выдать grant пользователю (по device_anon_id)

**Ожидаемый результат:**
- Entitlement создаётся
- Grant выдаётся
- Grant доступен через `/billing/entitlements` endpoint

**Проверка в Network:**
```
POST /api/proxy/admin/entitlements
Body: { "slug": "...", "scope": "city", "ref": "kaliningrad_city", ... }
Status: 200 OK

POST /api/proxy/admin/entitlements/{id}/grant
Body: { "device_anon_id": "...", ... }
Status: 200 OK
```

### 4. Загрузка файлов (Media)

**Шаги:**
1. Открыть Media или создать POI с изображением
2. Загрузить файл (изображение или аудио)

**Ожидаемый результат:**
- Файл загружается в MinIO/S3
- Presigned URL генерируется
- Файл доступен по публичному URL

**Проверка в Network:**
```
POST /api/proxy/admin/media/presign
Body: { "filename": "...", "content_type": "image/jpeg" }
Response: { "url": "...", "fields": {...} }

POST {presigned_url}
Body: (multipart/form-data with file)
Status: 204 No Content
```

### 5. Analytics

**Шаги:**
1. Открыть Analytics → Overview
2. Проверить отображение статистики

**Ожидаемый результат:**
- Данные загружаются из backend
- Графики отображаются
- Нет ошибок в консоли

**Проверка в Network:**
```
GET /api/proxy/admin/analytics/overview
Status: 200 OK
Response: { "total_pois": ..., "total_tours": ..., ... }
```

### 6. QR коды

**Шаги:**
1. Открыть QR Codes
2. Сгенерировать QR код для POI или тура

**Ожидаемый результат:**
- QR код генерируется
- QR код отображается
- Ссылка работает

**Проверка в Network:**
```
POST /api/proxy/admin/qr
Body: { "entity_type": "poi", "entity_id": "...", ... }
Status: 200 OK
Response: { "code": "...", "url": "..." }
```

## Проверка кнопок и UI элементов

### Dashboard
- [ ] Статистика загружается
- [ ] Графики отображаются
- [ ] Последние логи отображаются

### Content → POIs
- [ ] Список POI загружается
- [ ] Фильтры работают
- [ ] Поиск работает
- [ ] Кнопка "Создать POI" открывает форму
- [ ] Кнопка "Редактировать" открывает форму
- [ ] Кнопка "Publish" публикует POI
- [ ] Кнопка "Unpublish" снимает с публикации
- [ ] Кнопка "Удалить" удаляет POI
- [ ] Bulk actions работают

### Content → Tours
- [ ] Список туров загружается
- [ ] Кнопка "Создать тур" открывает редактор
- [ ] Добавление точек маршрута работает
- [ ] Переупорядочивание точек работает (drag & drop)
- [ ] Кнопка "Publish" публикует тур

### Content → Media
- [ ] Список медиа загружается
- [ ] Загрузка файлов работает
- [ ] Превью изображений работает
- [ ] Удаление медиа работает

### Entitlements
- [ ] Список entitlements загружается
- [ ] Кнопка "Создать entitlement" работает
- [ ] Кнопка "Grant" выдаёт entitlement
- [ ] Кнопка "Revoke" отзывает entitlement

### Analytics
- [ ] Dashboard отображает статистику
- [ ] Heatmap отображает данные
- [ ] Ratings отображают отзывы
- [ ] Графики интерактивны

### Settings
- [ ] Настройки загружаются
- [ ] Сохранение настроек работает
- [ ] Валидация работает

## Проверка ошибок

### Ошибки авторизации
1. Использовать невалидный токен
2. **Ожидаемый результат**: Редирект на `/login` или показ ошибки 401

### Ошибки валидации
1. Создать POI без обязательных полей
2. **Ожидаемый результат**: Показывается сообщение об ошибке валидации

### Ошибки сети
1. Отключить интернет
2. Попытаться загрузить данные
3. **Ожидаемый результат**: Показывается сообщение об ошибке сети

### Ошибки сервера
1. Отправить запрос, который вызывает ошибку на сервере (500)
2. **Ожидаемый результат**: Показывается понятное сообщение об ошибке

## Чек-лист

- [ ] Логин работает
- [ ] API Proxy работает корректно
- [ ] Создание POI работает
- [ ] Редактирование POI работает
- [ ] Публикация POI работает
- [ ] Создание тура работает
- [ ] Управление entitlements работает
- [ ] Загрузка файлов работает
- [ ] Analytics отображаются
- [ ] Все кнопки реагируют на клики
- [ ] Ошибки обрабатываются корректно
- [ ] Данные сохраняются в БД

## Отладка

### Проверка логов в браузере

Открыть DevTools → Console и проверить:
- Нет ошибок JavaScript
- Нет ошибок сети (кроме ожидаемых)
- Логи API запросов (если включены)

### Проверка логов на сервере

```bash
# Логи API
journalctl -u audiogid-api -f

# Логи админки (если развёрнута на сервере)
journalctl -u audiogid-admin -f
```

### Проверка в БД

```sql
-- Проверить созданные POI
SELECT id, title_ru, city_slug, status, created_at 
FROM pois 
ORDER BY created_at DESC 
LIMIT 10;

-- Проверить созданные туры
SELECT id, title_ru, city_slug, status, created_at 
FROM tours 
ORDER BY created_at DESC 
LIMIT 10;

-- Проверить entitlements
SELECT id, entitlement_slug, scope, ref, is_active 
FROM entitlement_grants 
ORDER BY granted_at DESC 
LIMIT 10;
```

