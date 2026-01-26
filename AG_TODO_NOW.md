# Antigravity TODO NOW

## Next PR: PR #24 — Extension: Ingestion Pipeline Polish
**Цель**: Оптимизация процесса импорта данных из внешних источников (OSM/Wikidata) с поддержкой новых NFR.

## Non-goals
- Изменение моделей данных (только логика обработки).
- Изменение UI/Мобильного клиента.

## Target Files
- `apps/api/api/ingestion.py`
- `apps/api/api/core/worker.py`

## Acceptance Criteria
- [ ] Ingestion сохраняет `updated_at` для корректной работы ETag.
- [ ] Ошибки импорта пишутся в `AuditLog` с `trace_id`.
- [ ] Процесс не блокирует API (Serverless timeouts).
- [ ] Добавлен мониторинг прогресса в `ops.py`.

## Validation
- **Logs**: Проверка Vercel Logs на отсутствие секретов при импорте.
- **URL**: `GET /v1/ops/config-check` должен показывать статус интеграций.
