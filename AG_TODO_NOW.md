# Antigravity TODO NOW

## Current State: checkpoint-10
Store Billing (Verify + Idempotency) реализован. Платформа готова к приему платежей.

## Next PRs (Priority Order)

### PR #39 — Restore Purchases / Server Reconcile (P0 for App Store)
**Цель**: Реализовать механизм восстановления покупок (Restore Transactions).
- **Endpoint**: `POST /v1/billing/restore`
- **Logic**: Принимает receipt/token, проверяет в сторе, находит ВСЕ транзакции в истории чека (включая прошлые), создает/обновляет гранты для всех найденных items.
- **Requirement**: Критично для App Store Review (Guideline 3.1.1).

### PR #40 — Growth & Attribution (Deep Links + Partner Campaigns)
**Цель**: Трекинг источников установок и партнерских кампаний.
- Таблица `partner_campaigns` и `attributions`.
- Эндпоинт `POST /v1/growth/attribute`.
- Интеграция с UTM-параметрами и Deep Links.

### PR #41 — Push Notifications (FCM/APNS)
**Цель**: Возможность отправки уведомлений пользователям.
- Регистрация device tokens.
- Эндпоинт для массовой рассылки (admin).
- Интеграция с Firebase Cloud Messaging.

## Completed Today (2026-01-26)
- [x] PR #36: Store Billing (Apple/Google Server Verify)
- [x] PR #38: Billing Idempotency Hardening
- [x] Checkpoint-10 reached.

## Validation URLs
- Production: https://audiogid-api.vercel.app/v1/ops/config-check
- Billing Verify: POST /v1/billing/apple/verify
