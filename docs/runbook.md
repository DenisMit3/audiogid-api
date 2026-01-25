# Operations Runbook

## Deployment
All apps are deployed to Vercel via `vercel deploy --prod`.

## Database
Migrations are handled by Alembic in `apps/api`.
Command: `alembic upgrade head` (Run in CI or via `/v1/ops/migrate` if safe).

## Синхронизация контракта API (Contract Sync)
Если CI упал с ошибкой "API Client SDK is out of sync":
1. **Проверьте логи CI**: В шаге "Check for Diff" будет выведен список изменившихся файлов.
2. **Как исправить**:
   - При наличии локального окружения (Java 11+): Выполните команду генерации.
   - Если окружения нет: Вы можете скачать сгенерированный SDK из артефактов GitHub Actions (если настроено сохранение) или скопировать изменения из вывода команды `git diff` в логах.
   - Закоммитьте новые файлы и пушьте в ветку PR.

Команда генерации (pinned version):
```bash
npx @openapitools/openapi-generator-cli@2.15.0 generate -i apps/api/openapi.yaml -g dart -o packages/api_client --additional-properties=pubName=api_client
```


