# Antigravity TODO NOW

## Current State: checkpoint-11
Store Billing (Verify + Restore) implemented. Google Batch Restore supported.

## Next PRs (Priority Order)

### PR #41 — Growth & Attribution (Deep Links + Partner Campaigns)
**Цель**: Трекинг источников установок и партнерских кампаний.
- Таблица `partner_campaigns` и `attributions`.
- Эндпоинт `POST /v1/growth/attribute`.
- Интеграция с UTM-параметрами и Deep Links.

### PR #42 — Push Notifications (FCM/APNS)
**Цель**: Возможность отправки уведомлений пользователям.
- Регистрация device tokens.
- Эндпоинт для массовой рассылки (admin).
- Интеграция с Firebase Cloud Messaging.

## Completed Today (2026-01-26)
- [x] PR #40: Google Restore Batch (Android)
- [x] PR #36: Store Billing (Apple/Google Server Verify)
- [x] PR #38: Billing Idempotency Hardening
- [x] Checkpoint-11 reached.

## Validation URLs
- Production: https://audiogid-api.vercel.app/v1/ops/config-check
- Billing Verify: POST /v1/billing/apple/verify
