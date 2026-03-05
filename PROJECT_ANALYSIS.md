## App architecture

Приложение `apps/mobile_flutter` построено по Clean Architecture c разделением на слои:

- `core/` — оболочка приложения и кросс-срезовые сервисы
  - `app.dart` — корневой `AudiogidApp` (MaterialApp.router, темы, локализация, глобальные обёртки: connectivity, soft-update banner, accessibility).
  - `router/app_router.dart` — навигация на GoRouter с ShellRoute (`MainShell`) и deep links (`/dl/*`).
  - `theme/app_theme.dart` — кастомная тема (M3-подобная, glass/gradient стиль, токены цветов/радиусов/spacing/durations).
  - `audio/` — интеграция с `audio_service` (`AudiogidAudioHandler`, провайдеры).
  - `location/location_service.dart` — поток геолокации и права доступа.
  - `network/connectivity_service.dart` — мониторинг подключения.
  - `config/app_config.dart` — FLAVOR/URLs, режимы dev/staging/prod.
  - `services/` — health-check API, app-update service, share-service и т.д.
  - `api/` — обёртки над сгенерированным Dart SDK `packages/api_client` (Dio + interceptors).

- `domain/` — бизнес-сущности и интерфейсы репозиториев
  - `entities/` — `City`, `Poi`, `Tour`, `Helper`, `EntitlementGrant`, `User`.
  - `repositories/` — абстракции `CityRepository`, `TourRepository`, `PoiRepository`, `EntitlementRepository`, `HelperRepository`.

- `data/` — реализация хранилища и сервисов
  - `local/app_database.dart` + `daos/*` — Drift (SQLite) как offline source-of-truth для городов, туров, POI, etag’ов, entitlement’ов.
  - `repositories/*` — реализации domain‑репозиториев с комбинированием API + Drift (offline-first).
  - `services/*` — оркестрационные сервисы:
    - `sync_service` — ETag/If-None-Match синхронизация с `/public/*` API.
    - `download_service` / `direct_download_service` — оффлайн‑бандлы и прямые загрузки через `OfflineApi` + `StorageManager`.
    - `tour_mode_service` — логика Tour Mode: текущий шаг, геофенс, off‑route, auto‑play.
    - `free_walking_service` — прототип Free Walking Mode (авто‑прослушивание вблизи POI).
    - `purchase_service` — In‑App Purchase + серверная верификация через `BillingApi` (Apple/Google/YooKassa), restore‑флоу.
    - `analytics_service` — события приложений/контента, offline‑очередь и отправка на backend.
    - `notification_service`, `deep_link_service`, `security_service` и др.

- `presentation/` — UI слой
  - `screens/` — отдельные экраны/флоу (см. ниже Screen map).
  - `providers/` — Riverpod‑стейт для selection, nearby и др.
  - `widgets/` — переиспользуемые компоненты (glass cards, skeletons, mini player, paywall, баннер обновления).

- `l10n/arb` — русская и английская локализация (на практике MVP — ru‑only).

Состояние управляется через Riverpod (hook‑free, `@riverpod` codegen), бизнес‑логика сервисов живёт в data/core, UI подписывается на провайдеры/streams (Drift, audio_service, location).

## Folder structure (Flutter клиент)

- `apps/mobile_flutter/lib/main.dart` — инициализация Flutter, audio_service, FlutterDownloader, глобальные сервисы и force‑update экран.
- `core/`
  - `app.dart`, `router/`, `theme/`, `audio/`, `location/`, `network/`, `services/`, `constants/`, `error/`.
- `domain/`
  - `entities/`, `repositories/` (абстракции).
- `data/`
  - `local/app_database.dart`, `local/daos/*` (Drift).
  - `repositories/*` (реализации).
  - `services/*` (sync/tour_mode/offline/purchase/analytics/...).
- `presentation/`
  - `screens/` — фичи и флоу.
  - `providers/selection_provider.dart`, `nearby_providers.dart`.
  - `widgets/common/*`, `widgets/audio/mini_player.dart`, `offline_progress_indicator.dart`, `paywall_widget.dart`, `soft_update_banner.dart`.

## Screen map (основные экраны)

Маршруты заданы в `core/router/app_router.dart` (GoRouter + ShellRoute):

- Онбординг и выбор города
  - `/welcome` → `WelcomeScreen` — приветствие и ввод в продукт.
  - `/onboarding` → `OnboardingScreen` — пошаговый онбординг.
  - `/city-select` (`/select-city` legacy) → `CitySelectScreen` — выбор tenant’а (`kaliningrad_city`, `kaliningrad_oblast`).

- Главный shell (`MainShell`)
  - `/` → `ToursListScreen` — список туров по выбранному городу, фильтры, мультивыбор и batch‑покупка.
  - `/nearby` → `NearbyScreen` — карта + bottom‑sheet с POI и helper‑точками.
  - `/catalog` → `CatalogScreen` — каталог POI (поиск, фильтры).
  - `/favorites` → `FavoritesScreen` — избранные POI/туры.

- Детали, аудио и оффлайн
  - `/tour/:id` → `TourDetailScreen` — детали тура, список точек, CTA «начать тур», предпрослушка, покупка.
  - `/poi/:id` → `PoiDetailScreen` — детали точки, медиа, предпрослушка, навигация.
  - `/player` → `AudioPlayerScreen` — полноэкранный аудиоплеер (сейчас базовый).
  - `/tour_mode` → `TourModeScreen` — режим экскурсии: карта, маршрут, off‑route баннер, авто‑плей.
  - `/offline-manager` → `OfflineManagerScreen` — управление оффлайн‑бандлами городов.

- Итинерарии и Free Walking
  - `/itinerary` → `ItineraryScreen` — список маршрутов пользователя.
  - `/itinerary/create` → `ItineraryCreateScreen` — конструктор маршрута.
  - `/itinerary/view/:id` → `ItineraryViewerScreen` — просмотр маршрута.
  - `/free_walking` → `FreeWalkingModeScreen` — режим свободной прогулки (UX и визуал частично готовы, логика в `free_walking_service`).

- Auth & Settings
  - `/login` → `LoginScreen` — авторизация (SMS/Telegram/Email в связке с backend).
  - `/settings` → `SettingsScreen` — настройки (аккаунт, уведомления, оффлайн, дети, безопасность и др.).

- SOS / Share / Trusted Contacts
  - `/sos` → `SosScreen` — SOS‑функции (UX частично реализован).
  - `/trusted_contacts` → `TrustedContactsScreen` — доверенные контакты.
  - `/share_trip` → `SharedLocationScreen` (через query `lat`, `lon`, `time`) — просмотр расшаренной геолокации.

- Музейный режим, QR и прочее
  - `/qr_scanner` → `QrScannerScreen` — сканирование QR, переход к POI.
  - `/force_update` — отдельный `ForceUpdateScreen`, показывается до загрузки `AudiogidApp` при необходимости.

- Deep Links
  - `/dl/tour/:id` → `/tour/:id`
  - `/dl/poi/:id` → `/poi/:id`
  - `/dl/city/:slug` → `/catalog?city=:slug`
  - `/dl/itinerary/:id` → `/itinerary/view/:id`

## Feature map (по статусам)

По документации (`docs/PROJECT_STATUS.md`, `docs/PROJECT_STATUS.md`, `docs/STATUS.md`) и коду клиента:

- Core / Offline‑first
  - ✅ ETag/caching для публичных эндпоинтов (`PublicApi`).
  - ✅ Drift‑кэш города/туров/POI/entitlements/ETag’ов.
  - ✅ Offline Bundles (через `OfflineApi`, `download_service`, `direct_download_service`, `offline_manager_screen`).

- Онбординг и аутентификация
  - ✅ Offline‑friendly onboarding (город можно выбрать без логина, превью/бесплатные точки доступны).
  - ✅ JWT‑auth + blacklist на backend; в приложении есть `auth_service`, login экраны и хранение токенов через secure storage.

- Монетизация
  - ✅ In‑App Purchase (Apple/Google) + restore purchases; клиентский `purchase_service` использует `BillingApi` (`verifyAppleReceipt`, `verifyGooglePurchase`, `batchPurchase`, `restore`).
  - ✅ YooKassa для гос/вэб (используется только сервером, клиент работает через серверный `BillingApi`). Batch‑покупка туров реализована в `ToursListScreen` (multi‑select + `/billing/batch-purchase`). 

- Аудио и туры
  - ✅ Tour Mode: `tour_mode_service` + `TourModeScreen` с картой, off‑route, auto‑play, ETA, step‑контролами.
  - ✅ Audio pipeline: audio_service + `AudiogidAudioHandler` + `AudioPlayerService`, мини‑плеер, глобальный плеер.
  - ✅ Museum Mode (QR): `QrScannerScreen` открывает POI/тур по QR/DeepLink.
  - ⚠️ Free Walking Mode: сервис и UI есть, но поведение/UX ещё не доведены до финального (см. `free_walking_service`, `_FreeWalkButton`).
  - ✅ Offline Manager: городские бандлы, прогресс, ошибки, удаление.

- Карта и nearby
  - ✅ Nearby: `NearbyScreen` + `flutter_map` + marker clusters + helpers (туалеты/кафе/вода) + POI‑markers, фильтры, Free Walking toggle, share location.\n  - ✅ Tour Mode map: маршрут тура, пользователь на карте, path до следующей точки.

- SOS и шэринг
  - ⚠️ SOS Screen: UI присутствует, но необходимо проверить/улучшить UX и поток (отправка координат в доверенным контактам, сценарии «SOS»).
  - ⚠️ SharedLocationScreen: отображает ссылку с lat/lon/time, UX можно улучшить (карта, кнопки навигации).\n

- Детский режим / Kids Mode
  - ✅ Поддержка на уровне моделей (Narration.kidsUrl, настройки Kids Mode в `settings_repository`).
  - ⚠️ UI/UX детского режима ещё не выведен в явный toggle/режим (требуется доработка).

## API integrations (по группам openapi.yaml / api_client)

Мобильное приложение использует Dart SDK `packages/api_client` (OpenAPI‑генерация). Основные группы:\n\n- `PublicApi` / `DefaultApi`\n  - `/public/cities`, `/public/catalog`, `/public/tours`, `/public/poi/{id}`.\n  - Используются через `city_repository`, `tour_repository`, `poi_repository` (вместе с Drift для offline‑кэша).\n\n- `BillingApi`\n  - `/billing/batch-purchase`, `/billing/entitlements`, `/billing/restore`, `/billing/apple/verify`, `/billing/google/verify`.\n  - Инкапсулированы в `purchase_service`, `entitlement_repository`.\n\n- `OfflineApi`\n  - `/offline/bundles:build`, `/offline/bundles/{job_id}`.\n  - Используются `download_service`, `direct_download_service` для менеджера оффлайн‑данных.\n\n- `AccountApi`\n  - `/public/account/delete/request`, `/public/account/delete/status` — запрос/статус удаления аккаунта.\n  - Обёртка в `auth/settings`‑флоу (проверить, что UI даёт доступ к удалению аккаунта в Settings).\n\n- `OpsApi`\n  - `/ops/health`, `/ops/commit`, `/ops/config-check` — health‑чек и статус конфигурации.\n  - Используются `api_health_service`, диагностика/внутренний мониторинг.\n\n- `AdminApi`/`IngestionApi` (через токен), `MediaApi`\n  - Прямо в мобильном клиенте почти не используются (это зона admin‑панели); мобильный клиент косвенно зависит от ingestion/контента.\n\n## Admin panel data flow (с точки зрения mobile)\n\n- Контент (города, POI, туры, медиа, нарративы, helpers, SKUs) создаётся и публикуется в админ‑панели (`apps/admin`) поверх API (`/v1/admin/*`).\n- Backend (`apps/api`) хранит:\n  - `City`, `Poi`, `Tour`, `TourItem`, `Narration`, `PoiMedia`, `PoiSource`.\n  - Entitlements / Purchases / IngestionRuns / Jobs / Analytics.\n- Мобильный клиент:\n  - Читает только опубликованный контент через `PublicApi` + offline манифесты (`OfflineApi`).\n  - Получает текущие entitlements через `BillingApi` и решает, какие нарративы/туры доступны.\n  - Не модифицирует контент — только читает и логирует события (analytics).\n\n## Audio pipeline\n\n- Источник данных\n  - `TourRepository` / `PoiRepository` отдают `Tour` и `Poi` с полями `narrations`, `media`, `previewAudioUrl`, `transitionAudioUrl` и др.\n  - Проверка прав доступа (`EntitlementGrant`) через `entitlement_repository` и `entitlementGrantsProvider`.\n\n- Сервис\n  - `AudioPlayerService`:\n    - Собирает очередь `MediaItem` по `TourItemEntity` (список точек тура).\n    - Выбирает URL для аудио в порядке приоритета:\n      1. Если есть entitlement & Narration → `narration.url`/`narration.localPath` (или `kidsUrl`, если Kids Mode).\n      2. Если есть `transitionAudioUrl` → использует его как маршрутный аудио‑переход.\n      3. Если нет доступа, но есть `previewAudioUrl` → воспроизводит превью.\n    - Обновляет очередь AudioService (`_handler.updateQueue`), выставляет правильный стартовый индекс и автозапуск.\n    - Учитывает сохранённую скорость воспроизведения (из `settings_repository`).\n\n- Плеер/обработчик\n  - `AudiogidAudioHandler` (в `core/audio/audio_handler.dart`) управляет состоянием плеера, очередью, системой Android/iOS (но содержимое не анализировалось детально в этом файле; предполагается стандартный audio_service handler).\n  - Analytics: `AudioPlayerService._initAnalytics` подписывается на `mediaItem` и `playbackState`, логирует `poi_played`, `poi_completed` и др. через `analytics_service`.\n\n- UI\n  - Мини‑плеер (`presentation/widgets/audio/mini_player.dart`):\n    - StreamBuilder по `audioHandler.mediaItem` и `playbackState`.\n    - Прогресс‑бар по `AudioService.position`.\n    - Картинка (artUri/CachedNetworkImage), play/pause, закрытие.\n    - Нажатие переводит на `/player` (full screen).\n  - Full player (`audio_player_screen.dart`) существует, но визуально более базовый — есть пространство для улучшения UX (обложка, очередь треков, better timeline).\n\n## Map / location pipeline\n\n- `location_service` использует `geolocator` и стримит `Position` (включая heading) через Riverpod.\n- `NearbyScreen`:\n  - `flutter_map` + `flutter_map_marker_cluster`.\n  - Использует helpers (туалеты/кафе/вода) через `nearbyHelpersProvider` и POI через `poiRepository.watchPoisForCity`.\n  - Рисует кастомные маркеры (POI/Helper) и кластеры, фильтры (`HelperType`), user‑location, attribution OSM/CartoDB.\n  - Bottom sheet (`DraggableScrollableSheet`) со списком POI+helpers.\n  - Кнопки: SOS, share location (через `share_plus`), my location, Free Walking toggle.\n\n- `TourModeScreen`:\n  - `flutter_map` рисует полный путь тура (polyline по всем точкам) и dotted‑линию до текущей точки.\n  - Пользователь — маркер с heading (повёрнутый по компасу).\n  - Верхняя карточка: текущий POI, дистанция до него, ETA, переключатель автоплея.\n  - Off‑route баннер при отклонении.\n  - Низ — блок `_TourControls` с прогрессом по шагам, play/pause, prev/next, завершением тура + диалог оценки (`/public/tours/{id}/rate`).\n\n## Missing functionality / UX debt\n\nНа основе кода и документации:\n\n- Free Walking Mode\n  - Логика и UI частично реализованы (toggle, сервис, отображение), но:\n    - Нет полноценного экранного опыта с явным объяснением режима.\n    - Мало визуальных подсказок, когда и почему авто‑плей срабатывает.\n\n- Kids Mode\n  - В моделях есть `Narration.kidsUrl` и настройки в `settings_repository`, но нет явного toggle‑режима и адаптации UI/копирайта под детей.\n\n- SOS / Share\n  - SOS‑флоу и Trusted Contacts нуждаются в доработке UX: сценарии, подтверждения, визуальные статусы отправки/ошибок.\n  - SharedLocationScreen минимален (lat/lon/time); можно добавить карту, CTA («Открыть в навигаторе»).\n\n- Full Player UX\n  - Full‑screen `AudioPlayerScreen` по сравнению с мини‑плеером ещё не дотягивает до уровня Spotify/Headspace (обложка, очередь, переключение тур/карта, жесты/анимации).\n\n- Design System консолидация\n  - Много токенов (AppColors, AppRadius, AppSpacing, AppShadows, AppGradients, ResponsiveExtension) уже есть, но они живут внутри `AppTheme` и `core/theme`.\n  - `glass_widgets.dart`, `common.dart`, skeleton’ы и прочие виджеты используют эти токены напрямую; требуется вынести их в `/design_system` и привести к единому API.\n\n- Разделение UI/бизнес‑логики\n  - Во многих экранах (например, `ToursListScreen`, `NearbyScreen`, `TourModeScreen`) бизнес‑логика (фильтры, выбор, вызовы purchase/tour_mode/free_walking) смешана с UI‑кодом `build`.\n  - Это усложняет переиспользование логики и усложняет анимированный редизайн.\n\n- Admin / API data usage\n  - Есть поля в моделях/контрактах, которые UI использует частично или поверхностно:\n    - `tourType`, `difficulty`, `distanceKm`, `avgRating`, `categories`, featured‑флаги.\n    - Metadata narration’ов (`durationSeconds`, `kidsUrl`, locale).\n  - Требуется доиспользовать их в карточках туров/POI/плеере/фильтрах.\n\n---\n\n```mermaid\nflowchart LR\n  user[\"User\"] --> mobileApp[\"MobileApp(Presentation)\"]\n  mobileApp --> domainLayer[\"DomainLayer(Entities+Repos)\"]\n  domainLayer --> dataLayer[\"DataLayer(Drift+API+Services)\"]\n  dataLayer --> backend[\"Backend(FastAPI /v1)\"]\n  backend --> adminPanel[\"AdminPanel(Next.js)\"]\n```\n+\n*** End Patch```}|()

