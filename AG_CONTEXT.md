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

## 2. Current Stage: Hardening
Платформа доведена до Production-ready состояния NFR:
- Безопасная работа со сторонним биллингом (Idempotency + Signature Verify).
- Эффективное кеширование (ETag 304 на маркерах БД).
- Строгая синхронизация контракта (OpenAPI-first).

## 3. What’s Implemented (PR#19–PR#22b)
- **Billing**: `EntitlementGrant` + YooKassa Webhook + fail-closed gating.
- **Contract**: `apps/api/openapi.yaml` -> `packages/api_client` (Dart SDK) + CI Sync Check.
- **Caching**: ETag на основе `MAX(updated_at)` + `Cache-Control` (Public/Private) + `Vary`.
- **Security**: HMAC+TTL signing для ассетов.

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
