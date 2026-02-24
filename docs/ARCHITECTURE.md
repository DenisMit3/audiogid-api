# Аудиогид 2026 - Полная техническая документация

## 1. Обзор проекта

**Audio Guide 2026** - мобильное приложение-аудиогид нового поколения с поддержкой offline-режима (Offline First).

### 1.1 Ключевые характеристики

| Параметр | Значение |
|----------|----------|
| Название | Audio Guide 2026 / Аудиогид |
| Версия API | 1.13.0 |
| Архитектура | Monorepo (pnpm workspaces + Turborepo) |
| Package Manager | pnpm 8.15.4 |
| Деплой | Cloud.ru (API + Admin), App Stores (Mobile) |
| База данных | PostgreSQL + PostGIS (локально на Cloud.ru) |
| Статус | Release Candidate (RC1) |
| Последнее обновление | 2026-02-24 |

### 1.2 Технологический стек

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND                                  │
├─────────────────────────────────────────────────────────────────┤
│  Mobile App (Flutter 3.16+)                                     │
│  - Riverpod (State Management)                                  │
│  - GoRouter (Navigation)                                        │
│  - Drift (SQLite, Offline DB)                                   │
│  - just_audio + audio_service (Audio Playback)                  │
│  - in_app_purchase (Billing)                                    │
│  - flutter_map + geolocator (Maps & Location)                   │
├─────────────────────────────────────────────────────────────────┤
│  Admin Panel (Next.js 14.1)                                     │
│  - React 18 + TypeScript                                        │
│  - TailwindCSS + Radix UI                                       │
│  - TanStack Query (Data Fetching)                               │
│  - Recharts (Analytics)                                         │
│  - Leaflet (Maps)                                               │
├─────────────────────────────────────────────────────────────────┤
│                        BACKEND                                   │
├─────────────────────────────────────────────────────────────────┤
│  API (FastAPI + Python 3.11+)                                   │
│  - SQLModel + SQLAlchemy 2.0                                    │
│  - Alembic (Migrations)                                         │
│  - GeoAlchemy2 (PostGIS)                                        │
│  - QStash (Background Jobs)                                     │
│  - Sentry (Monitoring)                                          │
├─────────────────────────────────────────────────────────────────┤
│                     INFRASTRUCTURE                               │
├─────────────────────────────────────────────────────────────────┤
│  - Cloud.ru (Hosting: API + Admin)                              │
│  - PostgreSQL + PostGIS (локально на сервере)                   │
│  - MinIO (Media Storage)                                        │
│  - Upstash QStash (Job Queue)                                   │
│  - GitHub Actions (CI/CD)                                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Структура проекта

```
1Audiogid/
├── apps/
│   ├── api/                    # FastAPI Backend
│   │   ├── api/                # Исходный код API
│   │   │   ├── admin/          # Admin endpoints
│   │   │   ├── analytics/      # Analytics endpoints
│   │   │   ├── auth/           # Authentication
│   │   │   ├── billing/        # Payments (Apple/Google/YooKassa)
│   │   │   ├── core/           # Core: config, models, database
│   │   │   ├── offline/        # Offline bundles
│   │   │   └── push/           # Push notifications
│   │   ├── migrations/         # Alembic migrations
│   │   ├── tests/              # Pytest tests
│   │   ├── index.py            # Entry point (Vercel)
│   │   ├── openapi.yaml        # API Contract (Source of Truth)
│   │   └── requirements.txt    # Python dependencies
│   │
│   ├── admin/                  # Next.js Admin Panel
│   │   ├── app/                # App Router pages
│   │   │   ├── (panel)/        # Protected admin routes
│   │   │   ├── (public)/       # Public pages (privacy, terms)
│   │   │   ├── api/            # API routes (proxy, auth)
│   │   │   └── login/          # Login page
│   │   ├── components/         # React components
│   │   ├── hooks/              # Custom hooks
│   │   └── lib/                # Utilities
│   │
│   ├── mobile_flutter/         # Flutter Mobile App
│   │   ├── lib/
│   │   │   ├── core/           # Core services
│   │   │   │   ├── api/        # API client, interceptors
│   │   │   │   ├── audio/      # Audio playback
│   │   │   │   ├── location/   # GPS services
│   │   │   │   ├── router/     # GoRouter config
│   │   │   │   └── theme/      # App theme
│   │   │   ├── data/           # Data layer
│   │   │   │   ├── local/      # Drift database, DAOs
│   │   │   │   ├── repositories/
│   │   │   │   └── services/   # Business services
│   │   │   ├── domain/         # Domain entities
│   │   │   ├── l10n/           # Localization (ru, en)
│   │   │   └── presentation/   # UI layer
│   │   │       ├── screens/    # App screens
│   │   │       ├── widgets/    # Reusable widgets
│   │   │       └── providers/  # Riverpod providers
│   │   ├── android/            # Android config
│   │   ├── ios/                # iOS config
│   │   └── pubspec.yaml        # Flutter dependencies
│   │
│   └── mobile/                 # Legacy web mobile (Vite)
│
├── packages/
│   ├── api_client/             # Generated Dart API client
│   └── contract/               # Shared contracts
│
├── docs/                       # Documentation
├── scripts/                    # Utility scripts
├── deploy/                     # Deployment configs
├── .github/workflows/          # CI/CD pipelines
│
├── package.json                # Root package.json
├── pnpm-workspace.yaml         # Workspace config
├── turbo.json                  # Turborepo config
└── AG_CONTEXT.md               # Project context & policies
```

---

## 3. Backend API (FastAPI)

### 3.1 Архитектура

```
┌─────────────────────────────────────────────────────────────────┐
│                         index.py                                 │
│                    (FastAPI Application)                         │
├─────────────────────────────────────────────────────────────────┤
│  Middleware Stack:                                               │
│  1. CORSMiddleware                                               │
│  2. SecurityMiddleware                                           │
│  3. RateLimitMiddleware                                          │
│  4. TimeoutMiddleware                                            │
│  5. AuditMiddleware                                              │
│  6. GZipMiddleware                                               │
├─────────────────────────────────────────────────────────────────┤
│  Routers:                                                        │
│  /v1/ops/*          - Health, Config, Migrations                 │
│  /v1/public/*       - Public API (cities, tours, POIs)           │
│  /v1/auth/*         - Authentication (SMS, Telegram, Email)      │
│  /v1/billing/*      - Payments & Entitlements                    │
│  /v1/admin/*        - Admin operations                           │
│  /v1/offline/*      - Offline bundles                            │
│  /v1/analytics/*    - Analytics events                           │
│  /.well-known/*     - Deep links (Apple/Android)                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Модели данных (SQLModel)

#### Core Models

| Модель | Описание | Ключевые поля |
|--------|----------|---------------|
| `City` | Город/регион | slug, name_ru, bounds, timezone |
| `Poi` | Point of Interest | title_ru, lat/lon, geo (PostGIS), category |
| `Tour` | Экскурсия | title_ru, city_slug, duration_minutes, tour_type |
| `TourItem` | Точка в туре | tour_id, poi_id, order_index |
| `Narration` | Аудио-нарратив | poi_id, url, locale, duration_seconds, transcript |
| `PoiMedia` | Медиа POI | poi_id, url, media_type, license_type |
| `PoiSource` | Источник данных | poi_id, name, url |

#### Auth Models

| Модель | Описание |
|--------|----------|
| `User` | Пользователь (role, email, is_active) |
| `UserIdentity` | Провайдер авторизации (phone, telegram, email) |
| `OtpCode` | SMS OTP коды |
| `BlacklistedToken` | Отозванные JWT токены |
| `Role` / `Permission` | RBAC система |

#### Billing Models

| Модель | Описание |
|--------|----------|
| `Entitlement` | Продукт/SKU (slug, scope, ref, price) |
| `EntitlementGrant` | Выданный доступ (device_anon_id, user_id) |
| `PurchaseIntent` | Намерение покупки |
| `Purchase` | Завершенная покупка |

#### Analytics Models

| Модель | Описание |
|--------|----------|
| `AppEvent` | События приложения |
| `ContentEvent` | События контента (poi_viewed, tour_started) |
| `PurchaseEvent` | События покупок |
| `AnalyticsDailyStats` | Агрегированная статистика |
| `Funnel` / `FunnelStep` | Воронки конверсии |

#### Operations Models

| Модель | Описание |
|--------|----------|
| `Job` | Фоновые задачи (QStash) |
| `AuditLog` | Аудит действий |
| `IngestionRun` | Запуски импорта данных |
| `DeletionRequest` | Запросы на удаление данных |

### 3.3 API Endpoints

#### Public API (`/v1/public/*`)

```
GET  /public/cities              - Список активных городов
GET  /public/cities/{slug}       - Детали города
GET  /public/cities/{slug}/pois  - POI города (пагинация)
GET  /public/cities/{slug}/tours - Туры города
GET  /public/catalog             - Каталог туров
GET  /public/poi/{poi_id}        - Детали POI (с проверкой доступа)
GET  /public/tours/{tour_id}/manifest - Манифест тура (gated)
GET  /public/nearby              - Ближайшие POI (PostGIS KNN)
GET  /public/helpers             - Вспомогательные точки (туалеты, кафе)

POST /public/itineraries         - Создать маршрут
GET  /public/itineraries/{id}    - Получить маршрут
PUT  /public/itineraries/{id}    - Обновить маршрут
GET  /public/itineraries/{id}/manifest - Манифест маршрута

POST /public/share/trip          - Создать ссылку на геолокацию
GET  /public/share/trip/{id}     - Просмотр геолокации (HTML)
```

#### Auth API (`/v1/auth/*`)

```
POST /auth/login/sms/init        - Инициация SMS авторизации
POST /auth/login/sms/verify      - Верификация SMS кода
POST /auth/login/telegram        - Telegram Login Widget
POST /auth/login/email           - Email + Password
POST /auth/login/dev-admin       - Dev admin login (ADMIN_API_TOKEN)
POST /auth/refresh               - Обновление токенов
POST /auth/logout                - Выход (blacklist tokens)
GET  /auth/me                    - Текущий пользователь
```

#### Billing API (`/v1/billing/*`)

```
POST /billing/apple/verify       - Верификация Apple Receipt
POST /billing/google/verify      - Верификация Google Purchase
GET  /billing/entitlements       - Активные права доступа
POST /billing/restore            - Восстановление покупок (async)
GET  /billing/restore/{job_id}   - Статус восстановления
POST /billing/batch-purchase     - Batch проверка SKU
```

#### Admin API (`/v1/admin/*`)

```
# POI Management
GET    /admin/pois               - Список POI
POST   /admin/pois               - Создать POI
GET    /admin/pois/{id}          - Детали POI
PUT    /admin/pois/{id}          - Обновить POI
DELETE /admin/pois/{id}          - Удалить POI (soft delete)

# Tour Management
GET    /admin/tours              - Список туров
POST   /admin/tours              - Создать тур
PUT    /admin/tours/{id}         - Обновить тур
DELETE /admin/tours/{id}         - Удалить тур

# Media
POST   /admin/media/presign      - Presigned URL для загрузки

# Ingestion
POST   /admin/ingestion/osm/enqueue     - Запуск OSM импорта
POST   /admin/ingestion/helpers/enqueue - Импорт вспомогательных точек
GET    /admin/ingestion/runs            - История импортов

# Users & Analytics
GET    /admin/users              - Список пользователей
GET    /admin/analytics/*        - Аналитика
GET    /admin/audit              - Аудит логи
```

#### Offline API (`/v1/offline/*`)

```
POST /offline/bundles:build      - Создать offline bundle
GET  /offline/bundles/{job_id}   - Статус bundle job
```

#### Ops API (`/v1/ops/*`)

```
GET  /ops/health                 - Liveness probe
GET  /ops/ready                  - Readiness probe (DB check)
GET  /ops/commit                 - Deployed commit info
GET  /ops/config-check           - Config status (boolean flags)
POST /ops/migrate                - Run migrations (protected)
POST /ops/init-skus              - Initialize default SKUs
GET  /ops/cron/cleanup-tokens    - Cleanup expired tokens
```

### 3.4 Конфигурация (Environment Variables)

```python
# Database
DATABASE_URL                     # PostgreSQL connection string (localhost)

# Auth
JWT_SECRET                       # JWT signing key (>=32 chars)
JWT_ALGORITHM                    # HS256 (default)
OTP_TTL_SECONDS                  # SMS OTP lifetime (300)
SMS_RU_API_KEY                   # SMS.RU API key
TELEGRAM_BOT_TOKEN               # Telegram bot token

# Admin
ADMIN_API_TOKEN                  # Admin API protection

# Storage
VERCEL_BLOB_READ_WRITE_TOKEN     # Vercel Blob storage

# AI & Content
OPENAI_API_KEY                   # OpenAI for narration generation
AUDIO_PROVIDER                   # Audio provider (openai)
OVERPASS_API_URL                 # OSM Overpass API

# Jobs
QSTASH_TOKEN                     # Upstash QStash
QSTASH_CURRENT_SIGNING_KEY       # Webhook verification
QSTASH_NEXT_SIGNING_KEY          # Key rotation

# Billing - YooKassa
YOOKASSA_SHOP_ID                 # YooKassa shop ID
YOOKASSA_SECRET_KEY              # YooKassa secret
YOOKASSA_WEBHOOK_SECRET          # Webhook verification
PAYMENT_WEBHOOK_BASE_PATH        # Webhook path (/v1/billing)
PUBLIC_APP_BASE_URL              # App base URL

# Billing - Stores
APPLE_SHARED_SECRET              # Apple App Store
GOOGLE_SERVICE_ACCOUNT_JSON_BASE64  # Google Play (base64)

# Monitoring
SENTRY_DSN                       # Sentry error tracking
REDIS_URL                        # Redis (optional, rate limiting)
```

### 3.5 Безопасность

1. **Fail-Fast Config** - приложение не запустится без критических переменных
2. **JWT Authentication** - access + refresh tokens с blacklist
3. **HMAC Asset Signing** - подписанные URL для медиа с TTL
4. **Rate Limiting** - slowapi + Redis
5. **CORS** - whitelist origins + regex для preview deployments
6. **Audit Logging** - все admin действия логируются
7. **Idempotency Keys** - защита от дублирования операций

---

## 4. Mobile App (Flutter)

### 4.1 Архитектура

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   Screens   │  │   Widgets   │  │  Providers  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│                        Domain Layer                              │
│  ┌─────────────┐  ┌─────────────┐                               │
│  │  Entities   │  │ Repositories│ (interfaces)                  │
│  └─────────────┘  └─────────────┘                               │
├─────────────────────────────────────────────────────────────────┤
│                         Data Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │Repositories │  │  Services   │  │    DAOs     │              │
│  │   (impl)    │  │             │  │   (Drift)   │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│                         Core Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │     API     │  │    Audio    │  │  Location   │              │
│  │  (Dio +     │  │  (just_audio│  │ (geolocator)│              │
│  │ api_client) │  │   + service)│  │             │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Экраны приложения

| Экран | Путь | Описание |
|-------|------|----------|
| CitySelectScreen | `/select-city` | Выбор города |
| ToursListScreen | `/` | Главная - список туров |
| NearbyScreen | `/nearby` | Ближайшие POI на карте |
| CatalogScreen | `/catalog` | Каталог POI |
| FavoritesScreen | `/favorites` | Избранное |
| TourDetailScreen | `/tour/:id` | Детали тура |
| PoiDetailScreen | `/poi/:id` | Детали POI |
| AudioPlayerScreen | `/player` | Полноэкранный плеер |
| TourModeScreen | `/tour_mode` | Режим экскурсии |
| QrScannerScreen | `/qr_scanner` | Сканер QR (Museum Mode) |
| OfflineManagerScreen | `/offline-manager` | Управление offline данными |
| LoginScreen | `/login` | Авторизация |
| SettingsScreen | (в shell) | Настройки |
| ItineraryScreen | `/itinerary` | Мои маршруты |
| ItineraryCreateScreen | `/itinerary/create` | Создание маршрута |
| FreeWalkingModeScreen | `/free_walking` | Свободная прогулка |
| SosScreen | `/sos` | SOS функции |
| SharedLocationScreen | `/share_trip` | Просмотр shared location |

### 4.3 Ключевые сервисы

#### AudioPlayerService
- Воспроизведение аудио через `just_audio`
- Background playback через `audio_service`
- Playlist management для туров
- Lock screen controls

#### TourModeService
- GPS tracking с geofencing (30m radius)
- Auto-play при приближении к POI
- Off-route detection (100m threshold)
- ETA calculation с учетом скорости
- Progress persistence

#### PurchaseService
- In-App Purchase (Apple/Google)
- Server-side verification
- Restore purchases (async polling)
- Batch purchase support

#### DownloadService
- Offline bundle download
- Progress tracking
- ZIP extraction
- Local storage management

#### SyncService
- ETag-based caching
- Incremental sync
- Conflict resolution

### 4.4 Локальная база данных (Drift)

```dart
Tables:
- Cities           // Кэш городов
- Tours            // Кэш туров
- TourItems        // Точки туров
- Pois             // Кэш POI
- Narrations       // Аудио метаданные + localPath
- Media            // Медиа метаданные + localPath
- PoiSources       // Источники POI
- EntitlementGrants // Права доступа
- Etags            // ETag кэш
- QrMappingsCache  // QR код маппинги
- AnalyticsPendingEvents // Offline analytics queue

Schema Version: 13
```

### 4.5 Deep Links

```
audiogid://                      # App scheme
├── /dl/tour/{id}               # Открыть тур
├── /dl/poi/{id}                # Открыть POI
├── /dl/city/{slug}             # Открыть город
├── /dl/itinerary/{id}          # Открыть маршрут
└── /share_trip?lat=&lon=&time= # Shared location
```

### 4.6 Flavors & Build

```
Flavors: dev, staging, prod

Android:
- compileSdk: 36
- targetSdk: 36
- AGP: 8.9.1
- Kotlin: 2.1.0
- Gradle: 8.11.1

iOS:
- Deployment Target: 12.0
- Swift 5.0
```

---

## 5. Admin Panel (Next.js)

### 5.1 Структура страниц

```
/login                          # Авторизация
/(panel)/
├── dashboard/                  # Главная панель
├── content/
│   ├── pois/                   # Управление POI
│   │   ├── new/                # Создание POI
│   │   └── [id]/               # Редактирование POI
│   ├── tours/                  # Управление турами
│   │   ├── new/
│   │   └── [id]/
│   ├── media/                  # Медиа галерея
│   └── validation/             # Валидация контента
├── cities/                     # Управление городами
│   ├── new/
│   └── [id]/
├── analytics/
│   ├── overview/               # Обзор метрик
│   ├── cohorts/                # Когортный анализ
│   ├── funnels/                # Воронки
│   └── heatmap/                # Тепловые карты
├── users/                      # Пользователи
├── jobs/                       # Фоновые задачи
├── audit/                      # Аудит логи
├── qr-codes/                   # QR коды
├── media/                      # Медиа менеджер
└── settings/
    ├── general/                # Общие настройки
    ├── billing/                # Биллинг
    ├── ai/                     # AI настройки
    ├── integrations/           # Интеграции
    ├── notifications/          # Уведомления
    └── backup/                 # Бэкапы
/(public)/
├── privacy/                    # Privacy Policy
└── terms/                      # Terms of Service
```

### 5.2 Авторизация

- JWT-based authentication
- Role-based access control (RBAC)
- Roles: `admin`, `editor`, `viewer`
- Cookie-based session

### 5.3 Компоненты

- Radix UI primitives
- TailwindCSS styling
- react-hook-form + zod validation
- TanStack Query for data fetching
- Recharts for analytics
- Leaflet for maps
- react-dropzone for uploads
- dnd-kit for drag & drop

---

## 6. CI/CD Pipeline

### 6.1 GitHub Actions Workflows

| Workflow | Триггер | Действия |
|----------|---------|----------|
| `flutter.yml` | Push to apps/mobile_flutter | Test, Build APK/IPA |
| `deploy-api.yml` | Push to apps/api | Migrate DB, Deploy to Vercel |
| `admin.yml` | Push to apps/admin | Build Admin Panel |
| `api-contract-check.yml` | PR | Validate OpenAPI contract |
| `openapi-sync.yml` | Push to openapi.yaml | Regenerate api_client |
| `integration_test.yml` | PR | E2E tests |

### 6.2 Secrets Required

```
# Database
DATABASE_URL

# Vercel
VERCEL_TOKEN
VERCEL_ORG_ID
VERCEL_PROJECT_ID

# Android Signing
KEYSTORE_BASE64
KEYSTORE_PASSWORD
KEY_PASSWORD

# iOS Signing
IOS_CERTIFICATE_BASE64
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64

# Optional
GOOGLE_SERVICE_INFO_PLIST
GOOGLE_SERVICES_JSON
```

---

## 7. Интеграции

### 7.1 Платежные системы

| Провайдер | Статус | Использование |
|-----------|--------|---------------|
| YooKassa | ✅ Готово | Web payments (RU) |
| Apple App Store | ✅ Готово | iOS In-App Purchase |
| Google Play | ✅ Готово | Android In-App Purchase |

### 7.2 Внешние сервисы

| Сервис | Назначение |
|--------|------------|
| SMS.RU | SMS OTP авторизация |
| Telegram | Telegram Login Widget |
| OpenAI | Генерация нарративов (TTS) |
| Overpass API | OSM данные для импорта |
| Sentry | Error tracking |
| Upstash QStash | Background jobs |
| MinIO | Media storage |
| PostgreSQL + PostGIS | Database (локально) |

---

## 8. Известные проблемы и TODO

### 8.1 Что работает ✅

- [x] API: все endpoints, billing, auth, offline bundles
- [x] Mobile: все экраны, tour mode, offline, purchases
- [x] Admin: CRUD, media upload, analytics
- [x] CI/CD: автоматический деплой
- [x] Store compliance: deletion, privacy policy

### 8.2 Что требует внимания ⚠️

- [ ] Free Walking Mode - базовый алгоритм не реализован
- [ ] Kids Mode - отдельный контент для детей
- [ ] Deep Links v2 - улучшенный шеринг маршрутов
- [ ] Web Payment flow - улучшение UX

### 8.3 Известные ограничения

1. **Без платных AI API** - проект использует только оплаченные сервисы
2. **Self-hosted** - все должно работать на своем сервере
3. **Чат-бот** - только rule-based, без LLM

---

## 9. Запуск проекта

### 9.1 Backend (API)

```bash
cd apps/api
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
# Настроить .env (см. .env.example)
uvicorn index:app --reload
```

### 9.2 Admin Panel

```bash
cd apps/admin
pnpm install
pnpm dev
```

### 9.3 Mobile App

```bash
cd apps/mobile_flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### 9.4 Генерация API клиента

```bash
cd packages/api_client
# Генерируется автоматически из openapi.yaml
# См. scripts/generate-client.sh
```

---

## 10. Контакты и ресурсы

- **API Docs**: https://audiogid-api.vercel.app/docs
- **OpenAPI Spec**: `apps/api/openapi.yaml`
- **Project Context**: `AG_CONTEXT.md`
- **Current TODO**: `AG_TODO_NOW.md`

---

---

## 11. Последние изменения (Changelog)

### 2026-02-24
- Улучшен Route Builder с расчетом расстояний и перетаскиваемыми маркерами
- Исправлены зависимости react-leaflet (downgrade до 4.2.1)
- Добавлено расширенное логирование для туров и маршрутов
- Обновлена схема хеширования паролей
- Исправлен API endpoint для аутентификации
- Исправлен URL админ-панели (порт 80 вместо 8000)

### 2026-02-23
- Добавлен endpoint проверки версии приложения
- Обновлена модель Tour с новыми полями
- Полная миграция с Neon на локальный PostgreSQL на Cloud.ru
- Удалены все заглушки API в мобильном приложении
- Добавлен загрузчик обложек туров
- Добавлен offline manifest endpoint для ресурсов города

---

*Документация обновлена: 2026-02-24*
