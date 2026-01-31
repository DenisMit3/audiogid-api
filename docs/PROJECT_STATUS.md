I have the following user query that I want you to help me with. Please implement the requested functionality following best practices.

Добавить Museum Mode для музейных экспонатов:

- Доработать `c:\Users\Denis\Desktop\vse boty\Audiogid\apps\mobile_flutter\lib\presentation\screens\qr_scanner_screen.dart`
- Интеграция с `mobile_scanner` (уже в dependencies)
- Реализовать resolve QR кода в POI через API endpoint `/public/qr/resolve`
- Добавить автоматическое воспроизведение narration после сканирования
- Поддержка offline режима (если POI скачан в offline bundle)
- Обработка ошибок: неизвестный QR, нет доступа к POI, нет интернета
- UI для сканирования с подсказками и feedback# PROJECT STATUS — Audio Guide 2026

**Date:** 2026-01-30  
**Version:** 1.13.0 (API)

## 1. Обзор проекта
Проект представляет собой аудиогид нового поколения с оффлайн-режимом (Offline First).

**Архитектура:**
- **Mobile:** Flutter (iOS/Android) — чистая архитектура, Drift (offline DB), Provider/BloC.
- **Backend:** FastAPI (Python) — асинхронный, PostgreSQL + PostGIS, Redis.
- **Admin Panel:** Next.js (Admin Dashboard) — управление контентом, медиа и пользователями.
- **Infrastructure:** Vercel (Web/API), GitHub Actions (CI/CD).

---

## 2. Реализованные компоненты

### ✅ Backend API
Покрытие endpoints согласно `openapi.yaml`:
- **Public:** `GET /public/cities`, `GET /public/catalog`, `GET /public/poi/{id}`, `GET /public/tours`
- **Auth:** `POST /auth/login/sms/init` & `verify`, `POST /auth/login/telegram`, `POST /auth/refresh`, `POST /auth/logout`, `GET /auth/me`
- **Billing:** `POST /billing/batch-purchase` (new), `POST /billing/apple/verify`, `POST /billing/google/verify`, `GET /billing/entitlements`, `POST /billing/restore`
- **Account:** `POST /public/account/delete/request`, `GET /public/account/delete/status`
- **Offline:** `POST /offline/bundles:build`, `GET /offline/bundles/{job_id}`
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

### ✅ Admin Panel
Функционал (`apps/admin/app/(panel)`):
- **Content:** POI & Tour Management
- **Cities:** Tenant management
- **Media:** Presigned uploads, Gallery
- **Users:** User management, Permissions
- **Jobs:** Background job monitoring
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
- `deploy-api.yml`: Deploy to Vercel
- `admin.yml`: Build Admin Panel
- `api-contract-check.yml`: Ensure OpenAPI compatibility
- `integration_test.yml`: E2E Testing

---

## 3. Недостающие функции (Gap Analysis)
Согласно `docs/prompt/PRODUCT.md`:

| Feature | Status | Notes |
|---------|--------|-------|
| **Tour Mode** | ✅ Done | Реализован полный цикл навигации, авто-плей, оффлайн prompt и notifications. |
| **Free Walking Mode** | ❌ Missing | Режим "hands-free" прогулки с авто-воспроизведением не реализован. |
| **Museum Mode** | ✅ Done | QR код сканирование, API resolve, offline fallback, авто-плей реализованы. |
| **Itineraries** | 🚧 Partial | Экран есть, но создание маршрутов и шеринг (Deep Links) требуют полировки (Deep Links v2). |
| **Kids Mode** | ❌ Missing | Отдельный режим/контент для детей отсутствует. |
| **SOS / Share** | ❌ Missing | Функция шеринга геолокации не найдена. |

---

## 4. Готовность к релизу

### Android
- **Signing:** Ready (`signingConfigs.release` configured with keystore & env vars).
- **Flavors:** `dev`, `staging`, `prod` configured.
- **Build:** Gradle build scripts configured properly.

### iOS
- **Config:** Требуется проверка наличия `ExportOptions.plist` и сертификатов в секретах CI.
- **Capabilities:** Background Audio, Location Updates должны быть включены в `Info.plist`.

### Store Compliance
- **Account Deletion:** ✅ Реализовано (API + In-App Request).
- **Privacy Policy:** ✅ Документ есть (`docs/privacy-policy.md`), ссылка в приложении нужна.
- **Permissions:** Проверить `permission_handler` и строки объяснений в `Info.plist` / `AndroidManifest.xml`.

### Тестирование
- **Unit Tests:** Присутствуют (`tests/`).
- **Integration Tests:** Настроены (`integration_test.yml`).

---

## 5. Roadmap (MVP Completion)

**P0: Critical (Release Blockers)**
1. **Tour Mode Logic:** ✅ Готово.
2. **Deep Links:** Убедиться, что `dl/city/{slug}` и `dl/tour/{id}` открывают нужные экраны.
3. **Store Assets:** Сгенерировать финальные иконки и скриншоты (Fastlane/Flutter Launcher Icons).
4. **Smoke Test:** Пройти полный путь "Install -> Select City -> Buy Tour -> Download Offline -> Walk".

**P1: Desirable (Enhancements)**
1. **Free Walking Mode:** Реализовать базовый алгоритм авто-плея.
2. **Analytics Polish:** Убедиться, что воронка продаж отображается корректно.
3. **Kids Mode:** Добавить хотя бы фильтр/тоггл для детского контента.

**P2: Post-MVP**
1. SOS Features.
2. Advanced Itinerary Sharing.
3. Web Payment flow enhancement.
