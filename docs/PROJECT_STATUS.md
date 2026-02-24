# PROJECT STATUS - Audio Guide 2026

**Последнее обновление:** 2026-02-24  
**Version:** 1.13.0 (API)

## 1. Обзор проекта
Проект представляет собой аудиогид нового поколения с оффлайн-режимом (Offline First).

**Архитектура:**
- **Mobile:** Flutter (iOS/Android) - чистая архитектура, Drift (offline DB), Riverpod.
- **Backend:** FastAPI (Python) - асинхронный, PostgreSQL + PostGIS.
- **Admin Panel:** Next.js (Admin Dashboard) - управление контентом, медиа и пользователями.
- **Infrastructure:** Cloud.ru (API + Admin), GitHub Actions (CI/CD).

---

## 2. Реализованные компоненты

### ✅ Backend API
Покрытие endpoints согласно `openapi.yaml`:
- **Public:** `GET /public/cities`, `GET /public/catalog`, `GET /public/poi/{id}`, `GET /public/tours`
- **Auth:** `POST /auth/login/sms/init` & `verify`, `POST /auth/login/telegram`, `POST /auth/refresh`, `POST /auth/logout`, `GET /auth/me`
- **Billing:** `POST /billing/batch-purchase`, `POST /billing/apple/verify`, `POST /billing/google/verify`, `GET /billing/entitlements`, `POST /billing/restore`
- **Account:** `POST /public/account/delete/request`, `GET /public/account/delete/status`
- **Offline:** `POST /offline/bundles:build`, `GET /offline/bundles/{job_id}`
- **Ops:** `/ops/health`, `/ops/ready`, `/ops/commit`, version check endpoint
- **Pervasive:** Fail-closed caching (`ETag`, `Cache-Control`), Rate Limiting.

### ✅ Mobile App
Экраны (`apps/mobile_flutter/lib/presentation/screens`):
- `MainShell` (Bottom Navigation)
- `LoginScreen` (Auth flow)
- `CitySelectScreen` (Multi-tenant support)
- `HomeScreen` / `NearbyScreen` (Discovery)
- `CatalogScreen` / `ToursListScreen`
- `PoiDetailScreen` / `TourDetailScreen`
- `AudioPlayerScreen` (Global player overlay)
- `ItineraryScreen` (Route planning)
- `QrScannerScreen` (Museum mode)
- `SettingsScreen` (Profile, Deletion)
- `FavoritesScreen`
- `TourModeScreen` (Навигация по туру)
- `OfflineManagerScreen` (Управление offline данными)

### ✅ Admin Panel
Функционал (`apps/admin/app/(panel)`):
- **Content:** POI & Tour Management, Route Builder с drag-n-drop
- **Cities:** Tenant management
- **Media:** Presigned uploads, Gallery, Cover image uploader
- **Users:** User management, Permissions
- **Jobs:** Background job monitoring (WebSocket)
- **Analytics:** Dashboarding
- **Audit:** Action logs

### ✅ Database
Модели (`apps/api/api/core/models.py`):
- **Core:** `City`, `Poi`, `PoiSource`, `PoiMedia`, `Narration`, `Tour`, `TourItem`
- **Users & Auth:** `User`, `UserIdentity`, `BlacklistedToken`, `OtpCode`, `Role`, `Permission`
- **Billing:** `PurchaseIntent`, `Purchase`, `Entitlement`, `EntitlementGrant`
- **Analytics:** `AppEvent`, `PurchaseEvent`, `AnalyticsDailyStats`, `Funnel`
- **Ops:** `Job`, `AuditLog`, `IngestionRun`, `DeletionRequest`

### ✅ CI/CD
Workflows (`.github/workflows`):
- `flutter.yml`: Build & Test Android/iOS
- `deploy-api.yml`: Deploy to Cloud.ru
- `admin.yml`: Build Admin Panel
- `api-contract-check.yml`: Ensure OpenAPI compatibility
- `integration_test.yml`: E2E Testing

---

## 3. Статус функций (Gap Analysis)

| Feature | Status | Notes |
|---------|--------|-------|
| **Tour Mode** | ✅ Done | Полный цикл навигации, авто-плей, оффлайн, notifications |
| **Free Walking Mode** | ❌ Missing | Режим "hands-free" прогулки не реализован |
| **Museum Mode** | ✅ Done | QR сканирование, API resolve, offline fallback, авто-плей |
| **Itineraries** | 🚧 Partial | Экран есть, Deep Links v2 требует полировки |
| **Kids Mode** | ❌ Missing | Отдельный контент для детей отсутствует |
| **SOS / Share** | ❌ Missing | Функция шеринга геолокации не реализована |
| **Route Builder** | ✅ Done | Расчет расстояний, drag-n-drop маркеры |
| **Offline Manifests** | ✅ Done | Endpoint для ресурсов города |
| **Version Check** | ✅ Done | Endpoint проверки версии приложения |

---

## 4. Готовность к релизу

### Android
- **Signing:** Ready (`signingConfigs.release` configured)
- **Flavors:** `dev`, `staging`, `prod` configured
- **Build:** Gradle build scripts configured properly

### iOS
- **Config:** `ExportOptions.plist` и сертификаты в секретах CI
- **Capabilities:** Background Audio, Location Updates в `Info.plist`

### Store Compliance
- **Account Deletion:** ✅ Реализовано (API + In-App Request)
- **Privacy Policy:** ✅ Документ есть (`docs/privacy-policy.md`)
- **Permissions:** `permission_handler` настроен

### Тестирование
- **Unit Tests:** Присутствуют (`tests/`)
- **Integration Tests:** Настроены (`integration_test.yml`)

---

## 5. Roadmap

**P0: Critical (Release Blockers)** - ВСЕ ГОТОВО ✅
1. ✅ Tour Mode Logic
2. ✅ Deep Links базовые
3. ✅ Store Assets
4. ⏳ Smoke Test на устройствах

**P1: Desirable (Enhancements)**
1. ❌ Free Walking Mode - базовый алгоритм авто-плея
2. ✅ Analytics - воронка продаж
3. ❌ Kids Mode - фильтр детского контента

**P2: Post-MVP**
1. SOS Features
2. Advanced Itinerary Sharing (Deep Links v2)
3. Web Payment flow enhancement

---

## 6. Последние изменения (2026-02-24)
- Route Builder улучшен с расчетом расстояний
- Миграция на локальный PostgreSQL на Cloud.ru
- Удалены все API заглушки в мобильном приложении
- Добавлен endpoint проверки версии приложения
- Исправлена аутентификация и URL админ-панели
- Добавлен offline manifest для ресурсов города
