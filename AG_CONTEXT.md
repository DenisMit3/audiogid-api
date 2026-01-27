# Antigravity Context Pack

## 1. Non-negotiables (POLICY)
- Никаких заглушек (stubs) или fake success paths.
- Никаких локальных запусков (docker/localhost). Валидация только Cloud/CI.
- OpenAPI 3.1 — единственный источник истины.
- Генерируемый SDK в `packages/api_client` коммитится в Git.
- CI блокирует Merge при наличии Diff в SDK (fail-on-diff).
- Приватный контент: `Cache-Control: private, no-store` + `Vary: Authorization`.
- Подпись ассетов: HMAC + TTL обязательно.
- Fail-fast при отсутствии критических ENV (YooKassa, BaseURL).

## 2. Current Stage: Pre-Launch (Mobile & Content)
API is Production-ready (NFRs, Billing, Ingestion verified).
Focus shifts to:
1.  **Mobile App**: Flutter Bootstrap (MVP UI).
2.  **Auth**: SMS.RU + Telegram Login (for Admin & User).
3.  **Content**: Admin Panel tools for data population.
4.  **Growth**: Attribution & Deep Links.

## 3. What’s Implemented (PR#19–PR#57)
-   **Billing**: EntitlementGrant + YooKassa/Google/Apple Verify + Restore (Batch).
-   **Contract**: OpenAPI-first + Dart SDK Sync Check.
-   **Ingestion**: OSM Import + QStash Worker Pipeline + Offline Bundles (ZIP).
-   **Ops**: Structured Logs, Health Checks, Fail-fast Config.
-   **Security**: HMAC Signing, Gating, Idempotency.

## 4. Source of Truth
- **Spec**: `apps/api/openapi.yaml`
- **SDK**: `packages/api_client`
- **Config**: `apps/api/api/core/config.py`
- **Logic**: `apps/api/api/public.py` (Public API), `apps/api/api/billing/yookassa.py` (Billing).

## 5. Active Risks (Do NOT regress)
- Не ломать подпись URL (аудио перестанет играть).
- Не удалять `Vary: Authorization` (утечка кеша между пользователями).
- Не добавлять эндпоинты без записи в `openapi.yaml`.
- Не печатать PII/PaymentID в логи Vercel.

## 6. Branch Reset Procedure
1. После каждого успешного Merge в `main` и прохождения CI, создается Git Tag `checkpoint-N`.
2. Новые фичи стартуют ТОЛЬКО от `main` или актуального `checkpoint`.
3. Один PR = Одна цель (Scope).
4. Каждое изменение в `openapi.yaml` требует немедленного обновления `packages/api_client` в том же коммите.
5. Перед завершением сессии — обновление `AG_TODO_NOW.md`.
