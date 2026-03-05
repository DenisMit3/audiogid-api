# Отчёт о тестировании облачной конфигурации

**Дата:** 2026-01-28  
**Цель:** Проверка работоспособности приложения с облачным API (ckaud.ru / 82.202.159.64)  
**Статус:** ✅ Завершено

## Выполненные изменения

### 1. Удаление локальных конфигураций

#### Backend (apps/api)
- ✅ Удалены локальные CORS origins (`localhost:3000`, `localhost:3080`) из `apps/api/index.py`
- ✅ Оставлены только облачные URLs:
  - `http://82.202.159.64:8000` (Cloud.ru API)
  - `https://audiogid.app`
  - `https://admin.audiogid.app`

#### Admin Panel (apps/admin)
- ✅ Отключён debug logger с подключением к `localhost:8765` в `apps/admin/lib/debug-logger.ts`
- ✅ Удалены debug fetch запросы к `localhost:7766` из `apps/admin/app/api/proxy/[...path]/route.ts`
- ✅ API URL по умолчанию: `http://82.202.159.64/v1` (через nginx на порту 80)

#### Mobile Flutter App
- ✅ Конфигурация уже использует облачный URL по умолчанию: `http://82.202.159.64/v1`
- ✅ Все flavors (dev, staging, prod) используют облачный URL если не указан `API_BASE_URL`

### 2. Тестирование API

#### Health Check
```bash
curl http://82.202.159.64/v1/ops/health
```
**Результат:** ✅ `{"status":"ok","checks":["config_import"],"error":null}`

#### Public Endpoints

**Cities:**
```bash
curl http://82.202.159.64/v1/public/cities
```
**Результат:** ✅ Возвращает список городов:
- Калининград (Город) - `kaliningrad_city`
- Калининградская область - `kaliningrad_oblast`
- Нижний Новгород - `nizhny_novgorod`

**Catalog:**
```bash
curl "http://82.202.159.64/v1/public/catalog?city=kaliningrad_city"
```
**Результат:** ✅ Возвращает массив (пустой, если нет данных в базе) - endpoint работает корректно

#### OpenAPI Schema
```bash
curl http://82.202.159.64/openapi.json
```
**Результат:** ✅ Доступен
- Title: Audio Guide 2026 API
- Version: 1.15.6
- Swagger UI: http://82.202.159.64/docs

#### ETag Кэширование
```bash
curl -H "If-None-Match: W/\"9db36e2da3b2087c\"" http://82.202.159.64/v1/public/cities
```
**Результат:** ✅ Работает корректно (возвращает 304 Not Modified)

## Конфигурация мобильного приложения

### AppConfig (apps/mobile_flutter/lib/core/config/app_config.dart)

Все flavors используют облачный URL по умолчанию:
```dart
const cloudUrl = 'http://82.202.159.64/v1';
```

Переопределение через переменную окружения:
```bash
flutter run --dart-define=API_BASE_URL=http://82.202.159.64/v1
```

## Конфигурация админки

### API Proxy (apps/admin/app/api/proxy/[...path]/route.ts)

```typescript
const ENV_API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64/v1';
const BACKEND_URL = ENV_API_URL.endsWith('/v1') ? ENV_API_URL : `${ENV_API_URL}/v1`;
```

### Environment Variables

Для админки требуется установить:
```bash
NEXT_PUBLIC_API_URL=http://82.202.159.64/v1
BACKEND_URL=http://82.202.159.64/v1
```

## Результаты тестирования

### Автоматизированные тесты

Запущен скрипт `scripts/test-cloud-api-final.ps1`:

```
==========================================
Cloud API Testing
API Base URL: http://82.202.159.64/v1
==========================================

1. Health Check...
   ✅ OK - Status: 200
   Response: {"status":"ok","checks":["config_import"],"error":null}

2. Get Cities List...
   ✅ OK - Status: 200, Cities found: 3
   First city: Калининград (Город) (kaliningrad_city)

3. Get Catalog (kaliningrad_city)...
   ✅ OK - Status: 200
   Data type: Object[]
   Items count: 0

4. Check OpenAPI Schema...
   ✅ OK - Status: 200
   Title: Audio Guide 2026 API
   Version: 1.15.6

5. Check ETag Caching...
   ✅ OK - ETag caching works (Status: 304)

==========================================
Test Results:
Passed: 5
Failed: 0
==========================================

All tests passed!
```

### Выполненные проверки

1. ✅ Удалены все локальные конфигурации
2. ✅ Проверен Health Check API - работает
3. ✅ Проверен список городов - возвращает 3 города
4. ✅ Проверен Catalog endpoint - работает (возвращает пустой массив, если нет данных)
5. ✅ Проверен OpenAPI Schema - доступен и корректный
6. ✅ Проверено ETag кэширование - работает корректно

### Конфигурация мобильного приложения

Мобильное приложение уже настроено на использование облачного API:
- Все flavors (dev, staging, prod) используют `http://82.202.159.64/v1` по умолчанию
- Конфигурация находится в `apps/mobile_flutter/lib/core/config/app_config.dart`
- Можно переопределить через `--dart-define=API_BASE_URL=...`

### Конфигурация админки

Админка настроена на использование облачного API:
- API Proxy использует `http://82.202.159.64/v1` по умолчанию
- Конфигурация находится в `apps/admin/app/api/proxy/[...path]/route.ts`
- Требуется установить переменные окружения при деплое:
  - `NEXT_PUBLIC_API_URL=http://82.202.159.64/v1`
  - `BACKEND_URL=http://82.202.159.64/v1`

## Скрипты для тестирования

Созданы PowerShell скрипты для автоматизированного тестирования:
- `scripts/test-cloud-api-final.ps1` - полный набор тестов (рекомендуется)
- `scripts/test-cloud-simple.ps1` - упрощённый вариант

Запуск:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\test-cloud-api-final.ps1
```

## Выводы

✅ **Все основные endpoints работают корректно**
✅ **ETag кэширование функционирует**
✅ **OpenAPI документация доступна**
✅ **Локальные конфигурации полностью удалены**
✅ **Приложение готово к работе только с облачным API**

### Примечания

- Catalog возвращает пустой массив - это нормально, если в базе данных нет туров для указанного города
- Для добавления данных требуется использовать админку или прямые запросы к admin API
- Все компоненты системы (мобильное приложение, админка, backend) настроены на работу с облачным API

## Примечания

- Все локальные серверы удалены из конфигурации
- Приложение настроено только на облачную работу
- Для локальной разработки можно использовать переменные окружения для переопределения URL

