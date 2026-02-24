# API Contract & Caching Policy

**Последнее обновление:** 2026-02-24

## Каноническая спецификация
Файл [openapi.yaml](../apps/api/openapi.yaml) является единственным источником истины.

**Текущая версия API:** 1.13.0  
**Production Server:** http://82.202.159.64:8000/v1

## Политика кеширования (Caching Safety)
Для обеспечения производительности и безопасности в Serverless среде применяются следующие правила:

1. **Public Read-Only (Общедоступные данные)**
   - Применяется для: `/public/cities`, `/public/catalog`, `/public/tours`.
   - Заголовки: `Cache-Control: public, max-age=60, s-maxage=3600, stale-while-revalidate=86400`.
   - Механизм: ETag на основе версионных маркеров БД. Поддерживается `304 Not Modified`.

2. **Gated/User-Specific (Защищенный контент)**
   - Применяется для: `/public/poi/{id}` (полные детали), `/manifest`, любая выдача с `signed_asset_url`.
   - Заголовки: `Cache-Control: private, no-store`.
   - Безопасность: Добавляется заголовок `Vary: Authorization` (или аналог), чтобы кеши не смешивали контент разных пользователей.

## Биллинг (Stores)
Реализована серверная верификация чеков (Receipt Server Verify) для iOS и Android.
*   **Apple**: `POST /billing/apple/verify` — проверяет чек через Apple Verify API.
*   **Google**: `POST /billing/google/verify` — проверяет токен через Google Play Developer API.
*   **Entitlements**: `GET /billing/entitlements` — возвращает активные покупки пользователя.
При успешной проверке чека сервер **атомарно** создает запись `EntitlementGrant`.

## Порядок внесения изменений
1. Обновить `openapi.yaml`.
2. Перегенерировать SDK в `packages/api_client`.
3. Закоммитить изменения.
4. CI проверит соответствие через `fail-on-diff`.

## Основные Endpoints

### Public API
| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/public/cities` | GET | Список активных городов |
| `/public/catalog` | GET | Каталог туров для города |
| `/public/poi/{id}` | GET | Детали POI с проверкой доступа |
| `/public/tours` | GET | Туры для города |
| `/public/nearby` | GET | Ближайшие POI (PostGIS KNN) |

### Auth API
| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/auth/login/sms/init` | POST | Инициация SMS авторизации |
| `/auth/login/sms/verify` | POST | Верификация SMS кода |
| `/auth/login/telegram` | POST | Telegram Login Widget |
| `/auth/refresh` | POST | Обновление токенов |
| `/auth/logout` | POST | Выход |

### Billing API
| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/billing/apple/verify` | POST | Верификация Apple Receipt |
| `/billing/google/verify` | POST | Верификация Google Purchase |
| `/billing/entitlements` | GET | Активные права доступа |
| `/billing/restore` | POST | Восстановление покупок |
| `/billing/batch-purchase` | POST | Batch проверка SKU |

### Ops API
| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/ops/health` | GET | Liveness probe |
| `/ops/ready` | GET | Readiness probe |
| `/ops/commit` | GET | Deployed commit info |
