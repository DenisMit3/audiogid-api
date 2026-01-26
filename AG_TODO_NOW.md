# Antigravity TODO NOW

## Current State: checkpoint-9-store-billing
Платформа готова к релизу в App Store / Google Play.

## Next PRs (Priority Order)

### PR #37 — Mobile SDK Integration (Flutter/Dart Billing Wrapper)
**Цель**: Интеграция сгенерированного Dart API Client с нативным биллингом Flutter.
- Обертка над `BillingApi` для удобного вызова верификации.
- Локальное кеширование entitlements.
- Обработка ошибок сети и повторные попытки.

### PR #38 — Growth & Attribution (Deep Links + Partner Campaigns)
**Цель**: Трекинг источников установок и партнерских кампаний.
- Таблица `partner_campaigns` и `attributions`.
- Эндпоинт `POST /v1/growth/attribute`.
- Интеграция с UTM-параметрами и Deep Links.

### PR #39 — Push Notifications (FCM/APNS)
**Цель**: Возможность отправки уведомлений пользователям.
- Регистрация device tokens.
- Эндпоинт для массовой рассылки (admin).
- Интеграция с Firebase Cloud Messaging.

## Completed Today (2026-01-26)
- [x] PR #33b: Offline Manifests
- [x] PR #34: Launch Hardening (Rate Limit + Security Headers)
- [x] PR #35: Geo Strategy (Oblast Support)
- [x] PR #33c: Offline Assets ZIP
- [x] PR #36: Store Billing (Apple/Google Server Verify)

## Validation URLs
- Production: https://audiogid-api.vercel.app/v1/ops/config-check
- Billing: POST /v1/billing/apple/verify, POST /v1/billing/google/verify
- Entitlements: GET /v1/billing/entitlements?device_anon_id=...
