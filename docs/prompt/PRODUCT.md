# PRODUCT — Audio Guide 2026 (RU-only MVP)

## 0) Tenants day 1
- kaliningrad_city
- kaliningrad_oblast (отдельный city tenant)

## 1) Glossary (canonical terms)
- City tenant: изолированный “город/регион” (данные, publish, каталоги).
- Published POI: POI доступный пользователям (каталог/туры/офлайн-бандлы).
- Sources: источники фактов POI; publish запрещён без sources.
- Media: изображения/аудио/видео с обязательными license/author/attribution/source_page_url.
- Entitlement: серверное право доступа к SKU (POI/tour/bundle/offer).
- Entitlement grant: выдача доступа пользователю (server-side, атомарно, идемпотентно).
- Preview: бесплатное аудио 10–25 сек + preview_bullets 3–6; можно кешировать офлайн.
- Job: асинхронная задача через QStash; есть status/progress/attempts/last_error.

## 2) Offline-first onboarding (required)
Без логина пользователь может:
- выбрать город,
- увидеть туры/каталог,
- слушать бесплатные превью,
- скачать бесплатный стартовый офлайн‑пакет (если есть free контент).

Логин нужен только когда:
- покупка,
- redeem gift code (опционально),
- позже — синхронизация между устройствами.

## 3) UI/UX principles (product-level)
- Концепция: “держит за руку”, спокойная типографика, чёткая иерархия.
- На каждом экране: читаемость, отсутствие overlap, корректные переносы, корректный overflow в контейнерах.
- Адаптивность: small phone → large phone → tablet; safe areas; landscape не ломает критические сценарии.
- Accessibility: font scaling не ломает layout; есть доступные подписи/семантика на интерактивных элементах.

## 4) ASO / Store metadata schema (required)
RU-only метаданные для MVP.

### 4.1 Google Play (limits)
- Title: <= 30 chars
- Short description: <= 80 chars
- Full description: <= 4000 chars
Правило: без keyword stuffing; ключи (“аудиогид”, “гид”, “экскурсии”, “путеводитель”) — естественно в Title/Short/Full.

### 4.2 App Store (limits)
- Keywords field: <= 100 chars (через запятую, без пробелов; без брендов конкурентов).
Правило: не позиционировать как “Kids Category” без отдельного решения.

## 5) Location + Audio policies
Location:
- Foreground-first.
- Background location: opt-in; behind flag; включать только если есть core value + policy pack (disclosure + store declarations).
- Geofence/trigger: cooldown/anti-repeat, energy saving.

Audio:
- Audio focus: pause/duck/interrupt; fast resume.
- No freezes on calls/music/navigation.
- Offline playback must work for downloaded audio; preview cacheable.

## 6) Deep links / QR / partner link security
- Все QR/партнерские ссылки ведут на домен под вашим контролем (HTTPS).
- Deep link params:
  utm_source, utm_medium, utm_campaign, utm_content, utm_term,
  partner_campaign_id,
  signed token (HMAC) + TTL.
- Deep link router хранит атрибуцию 30 дней и прикрепляет к ключевым событиям.

Destination types:
- /dl/city/{slug}
- /dl/tour/{tour_id}
- /dl/offer/{offer_id}
- /dl/gift/{code}
- /dl/offline/{bundle_type}/{id}

## 7) Feature set (required)
A) City Select
- First run: select city tenant (kaliningrad_city / kaliningrad_oblast). Persist.

B) Tours (primary)
- Featured curated tours (city-scoped).
- Tour detail: route on map, stops list, duration/distance.
- Multi-select POI cards + bottom bar “Buy selected”.
- Buy whole tour bundle discount.
- Preview first 2 stops free.

C) Catalog
- Categories + search + filters.
- Multi-select POI cards + bottom bar “Buy selected”.
- Favorites/bookmarks.

D) Nearby (discovery-only)
- Map+list; can favorite/add-to-selection; checkout only in Catalog/Tours.

E) POI Detail
- Photos with credits/license.
- Sources list.
- Transcript.
- Buttons: Preview / Listen (gated) / Ask (gated) / Favorite / Add to selection / Download (gated).

F) Tour Mode (“держит за руку”)
- step-by-step to next point, distance/ETA,
- auto-play on radius entry,
- auto-advance,
- off-route handling,
- offline bundle prompt before start,
- progress + resume.

G) Free Walking Mode (hands-free)
- Auto-select nearest POIs + auto-play by proximity.
- Cooldown/anti-repeat; energy-saving strategy.

H) Museum Mode (QR)
- QR scan → resolve to POI → play narration.
- Works offline if downloaded.

I) Itineraries / Routes
- Manual itinerary: select POIs + reorder.
- Generated itinerary: heuristic MVP allowed.
- Start itinerary uses Tour Mode engine.
- Share itinerary deep link.
- Offline bundle for itinerary.

J) Helpers Nearby
- “Полезное рядом” (toilets/drinking_water/cafe; optional pharmacy/transport).
- One-tap navigate, save for later.
- Import from OSM.

K) Kids Mode (NOT kids category by default)
- Toggle “С детьми”: 30–60 sec, проще язык, optional mini-question.
- Kids Mode не означает, что приложение “для детей” по политике стора; любые внешние ссылки/покупки — за parental gate (если появятся).

L) SOS / Share location
- SOS: send coordinates/link to trusted contacts (SMS/Telegram).
- Share trip (non-emergency) with TTL.

## 8) Preview / try-before-buy
- Each paid POI: preview_audio 10–25 sec + preview_bullets 3–6.
- Preview free and cacheable offline.
- Full audio + QA gated by entitlements.

## 9) Monetization (no wallet)
- Batch buy selected POIs (from Tours/Catalog).
- Bundles/Offers: Tour bundle discount; City pack optional R1.
- Coupons MVP-lite.
- Gift codes:
  - single-use default,
  - store only hash,
  - atomic redeem + idempotency,
  - grants = entitlements/entitlement_grants.

Payments hard rule:
- Access only after server confirm (webhook/receipt verify) and persisted entitlement_grant.
- Client payment events are UX-only.

## 10) Payments architecture for stores (required)
- Store build (App Store / Google Play):
  - purchase via StoreKit / Play Billing,
  - server-side verify receipt,
  - grant entitlement_grant atomically and idempotently,
  - restore purchases UX triggers server reconcile.
- Non-store distribution (если есть веб/внешняя оплата):
  - YooKassa webhook verify,
  - entitlement_grant только после confirm.

## 11) Partner program (B2B)
- partner + campaign + links + codes.
- Attribution events: open/signup/order/payment/redeem + rollups.
- QR-to-app flow:
  - installed → deep link,
  - not installed → store redirect with attribution,
  - desktop → landing page.
- Offline partner onboarding screen: propose offline bundle download immediately.

## 12) Privacy / policy requirements (product-level)
- Privacy Policy URL обязателен (публичный HTTPS).
- Для Google Play: Data safety декларации должны соответствовать фактическому сбору/использованию данных.
- Для аккаунтов: user account deletion (in-app) + публичный web URL deletion (если аккаунты есть).
- Purpose strings для permissions (особенно location) должны объяснять ценность и кейсы использования, без общих фраз.

## 13) Reviewability plan (required)
- Должен быть устойчивый путь для ревьюеров в gated-функции:
  - инструкции для Google Play “App access”,
  - демо-доступ/инструкции для App Store review,
  - не полагаться на SMS OTP для ревьюеров (нужен обходной безопасный путь, например review entitlement).

## 14) Content ingestion (async only)
Goal: kaliningrad_city + kaliningrad_oblast filled via import + moderation.

Pipeline:
- Stage 1: OSM Overpass boundary-driven import for POIs.
- Stage 1b: Helpers import to separate table.
- Stage 2: Wikidata enrichment (confidence scoring).
- Stage 3: Commons media ingestion:
  - store license/author/attribution/source_page_url,
  - publish forbidden without these.
- Stage 4: Import report + dedupe/merge:
  - do not overwrite editor long_ru if editor_lock_long_ru=true.
- Stage 5 jobs (async):
  - generate previews,
  - generate narrations,
  - build offline manifests/bundles.

## 15) Map attribution (required)
- На всех экранах карты должна быть корректная атрибуция источников данных/тайлов/стиля (и соответствовать лицензиям).
- При смене style_url атрибуция должна оставаться корректной.

## 16) Data model (high-level)
Core: cities, pois, poi_sources, poi_media
Tours: tours, tour_items
Routes: itineraries, itinerary_items
Triggers: qr_mappings, (optional) beacon_triggers behind flag
Helpers: helper_places
Monetization: products, offers, offer_items, orders, order_items, entitlements, entitlement_grants
Growth: coupons, coupon_redemptions, gift_codes, gift_redemptions, partners, partner_campaigns, partner_links, partner_events, partner_rollups
AI/Audio: narrations, qa_sessions, qa_messages
Ops: jobs (status/attempts/error), audit_logs

## 17) Quality gate — Kaliningrad release pack
- kaliningrad_city:
  - curated POIs >= 80 (>=2 sources, >=1 licensed image, preview, transcript, narration, pricing set),
  - featured tours >= 8 (8–15 stops, route shown, hints >=50% stops),
  - QR mappings >= 30.
- kaliningrad_oblast:
  - published POIs >= 120 (sources+media required),
  - featured tours >= 5.
- Offline-first onboarding works without login.
- Entitlements unlock fast after confirmed verify.
- Partner QR-to-offline flow passes 3 scenarios (installed/not installed/desktop).

## 18) Admin panel (de-prioritized, must not block core)
Minimum MVP admin:
- publish gates: sources + media license/attribution/source_page_url,
- pricing/SKU mapping,
- QR mappings CRUD,
- jobs statuses + error inspection.

Everything else: phase 2.
