# Antigravity Context Pack

**Последнее обновление:** 2026-02-24

## 1. Non-negotiables (POLICY)
- Никаких заглушек (stubs) или fake success paths.
- Никаких локальных запусков (docker/localhost). Валидация только Cloud/CI.
- OpenAPI 3.1 - единственный источник истины.
- Генерируемый SDK в `packages/api_client` коммитится в Git.
- CI блокирует Merge при наличии Diff в SDK (fail-on-diff).
- Приватный контент: `Cache-Control: private, no-store` + `Vary: Authorization`.
- Подпись ассетов: HMAC + TTL обязательно.
- Fail-fast при отсутствии критических ENV (YooKassa, BaseURL).

## 2. Current Stage: Release Candidate (RC1)
API и Mobile готовы к релизу. Инфраструктура мигрирована на Cloud.ru.

**Завершено:**
1. **API**: Production на Cloud.ru (http://82.202.159.64:8000/v1)
2. **Database**: PostgreSQL + PostGIS локально на Cloud.ru
3. **Mobile App**: Feature Complete, все заглушки удалены
4. **Admin Panel**: CRUD, Media, Jobs, Route Builder
5. **Auth**: SMS.RU + Telegram Login

## 3. What's Implemented (Latest)
- **Route Builder**: Расчет расстояний, drag-n-drop маркеры
- **Billing**: EntitlementGrant + YooKassa/Google/Apple Verify + Restore (Batch)
- **Contract**: OpenAPI-first + Dart SDK Sync Check
- **Ingestion**: OSM Import + QStash Worker Pipeline + Offline Bundles (ZIP)
- **Ops**: Structured Logs, Health Checks, Fail-fast Config
- **Security**: HMAC Signing, Gating, Idempotency
- **Offline**: Manifest endpoint для ресурсов города
- **Versioning**: Endpoint проверки версии приложения

## 4. Source of Truth
- **Spec**: `apps/api/openapi.yaml`
- **SDK**: `packages/api_client`
- **Config**: `apps/api/api/core/config.py`
- **Logic**: `apps/api/api/public.py` (Public API), `apps/api/api/billing/yookassa.py` (Billing)

## 5. Active Risks (Do NOT regress)
- Не ломать подпись URL (аудио перестанет играть).
- Не удалять `Vary: Authorization` (утечка кеша между пользователями).
- Не добавлять эндпоинты без записи в `openapi.yaml`.
- Не печатать PII/PaymentID в логи.

## 6. Branch Reset Procedure
1. После каждого успешного Merge в `main` и прохождения CI, создается Git Tag `checkpoint-N`.
2. Новые фичи стартуют ТОЛЬКО от `main` или актуального `checkpoint`.
3. Один PR = Одна цель (Scope).
4. Каждое изменение в `openapi.yaml` требует немедленного обновления `packages/api_client` в том же коммите.
5. Перед завершением сессии - обновление `AG_TODO_NOW.md`.

## 7. Infrastructure (Cloud.ru)
- **API Server**: http://82.202.159.64:8000
- **Admin Panel**: http://82.202.159.64 (порт 80)
- **Database**: PostgreSQL + PostGIS (локально на сервере)
- **Storage**: MinIO для медиа-файлов
