# Project Status Tracker

Living document tracking the implementation status of features defined in `PRODUCT.md` and `FIX_DEPLOY_PLAN.md`.

**Последнее обновление:** 2026-02-25

## Legend
- ✅ **Done**: Implemented, tested, and merged.
- 🚧 **In Progress**: Currently being developed.
- ⚠️ **Partial**: API exists, but Client/UI is missing or incomplete.
- ❌ **Not Started**: Planned but not yet touched.

---

## 0) Tenants
- ✅ **kaliningrad_city**: Supported in DB & API.
- ✅ **kaliningrad_oblast**: Supported in DB & API.

## 1) Core
- ✅ **Offline-first API**: Public endpoints support ETag/Caching.
- ✅ **Offline-first Client**: Flutter app implements drift (SQLite), Background Downloader, and local asset serving.
- ✅ **Entitlements**: Server-side logic implemented & Verified via App Store/Google Play.

## 2) Onboarding & Auth
- ✅ **Offline-first onboarding**: City selection and initial setup flow.
- ✅ **Authentication**: JWT-based auth with blacklisting and token rotation.
- ✅ **User Management**: Admin panel user search (by phone/email) and role management.

## 3) Monetization & Payments
- ✅ **YooKassa Webhook**: Implemented & verified.
- ✅ **Apple Receipt Verify**: Implemented.
- ✅ **Google Play Verify**: Implemented (including Batch Restore).
- ✅ **Billing Restore**: Server-side reconcile implemented.
- ✅ **Client Purchase Flow**: In-App Purchase Service, Paywall, and Multi-select batch purchasing.

## 4) Feature Set (API / Mobile / Admin)
| Feature | API | Mobile | Admin |
| :--- | :---: | :---: | :---: |
| **City Select** | ✅ | ✅ | ✅ |
| **Tours List/Detail** | ✅ | ✅ | ✅ (Route Builder) |
| **Catalog** | ✅ | ✅ | N/A |
| **Nearby** | ✅ | ✅ | N/A |
| **POI Detail** | ✅ | ✅ | ✅ |
| **Tour Mode (Nav)** | N/A | ✅ | N/A |
| **Map Previews** | N/A | ✅ | ✅ |
| **Museum Mode (QR)** | ✅ | ✅ | ✅ |
| **Helpers Nearby** | ✅ | ✅ | ✅ |
| **Push Notifications** | ✅ | ✅ | ✅ |
| **Audio Player** | N/A | ✅ | N/A |

## 5) Ingestion & Content (Admin Panel)
- ✅ **OSM Import**: Implemented (City + Helpers).
- ✅ **Async Jobs**: QStash worker pipeline operational with WebSocket monitoring.
- ✅ **Offline Bundles**: Generator implemented (ZIP + Manifest).
- ✅ **Manual Editing**: Full CRUD for POIs and Tours.
- ✅ **Media Library**: Uploads with S3/Blob storage integration.
- ✅ **Route Builder**: Drag & Drop ordering with Mapbox/Leaflet visualization.
- ✅ **QR Management**: Generator and Scan analytics.

## 6) Growth & Attribution
- ✅ **Deep Links**: `DeepLinkService` implemented for attribution tracking.
- ✅ **Push Notifications**: FCM Token registration and token refresh handling.
- ✅ **Analytics**: Custom `AnalyticsService` with offline batching (30s interval) + Firebase.
- 🚧 **Partners**: Schema not designed.

## 7) Compliance & Ops
- ✅ **Fail-fast Config**: Implemented.
- ✅ **Observability**: Structured JSON logs.
- ✅ **OpenAPI Sync**: Up to date.
- ✅ **Delete Account**: Client UI and Backend endpoint implemented.
- ✅ **App Icons**: Android and iOS assets generated.

## Next High Priority Targets
1. **Production Deployment**: Deploy API to production env, release mobile app to TestFlight/Closed Testing.
2. **User Testing**: Validate Tour Mode in real-world conditions.
3. **Analytics**: Verify data events in Firebase/PostHog.

---

## Recent Changes (2026-02-25)
- ✅ Исправлена авторизация в админ-панели - переход с localStorage на HttpOnly cookies
- ✅ Исправлены bulk-операции POI (публикация, снятие, удаление)
- ✅ Исправлена сериализация GeoAlchemy2 в PoiVersion
- ✅ Исправлена загрузка медиа (source_page_url теперь опционален)
- ✅ Удалены дублирующие API роуты с x-admin-token
- ✅ Улучшены сообщения валидации публикации (русский язык, конкретные подсказки)
- ✅ Исправлено модальное окно публикации POI

## Recent Changes (2026-02-24)
- ✅ Route Builder улучшен с расчетом расстояний и drag-n-drop маркерами
- ✅ Миграция на локальный PostgreSQL на Cloud.ru завершена
- ✅ Удалены все API заглушки в мобильном приложении
- ✅ Добавлен endpoint проверки версии приложения
- ✅ Исправлена аутентификация и URL админ-панели
- ✅ Добавлен offline manifest для ресурсов города
