# Operations Runbook

## Валидация конфигурации (Cloud/CI Only)
Для проверки готовности платформы используйте следующие инструменты:

### 1. Prerequisites / Environment Variables
#### Core & Billing (Strict Startup)
Эти переменные обязательны для старта API (Fail-fast).

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | Neon Postgres Connection String |
| `PUBLIC_APP_BASE_URL` | Базовый URL для генерации абсолютных ссылок (webhooks, sharing) |
| `YOOKASSA_*` | Учетные данные YooKassa (Shop ID, Secret Key, Webhook Secret) |
| `PAYMENT_WEBHOOK_BASE_PATH` | Путь вебхука (must start with `/`) |

### 2. Проверка конфигурации биллинга
Вызовите эндпоинт `GET /v1/ops/config-check`. 
- Ожидаемый результат: JSON со списком ключей и значениями `true/false`.
- Все 5 параметров YooKassa должны быть `true`.
- Поле `PAYMENT_WEBHOOK_BASE_PATH` должно быть `true` (путь не раскрывается).

### 2. Проверка Ingestion (Strategy A: Readiness)
API стартует без обязательных переменных `QSTASH_TOKEN` и `OVERPASS_API_URL`.
Их состояние видно в `GET /v1/ops/config-check`.

**Поведение при отсутствии:**
- Если `QSTASH_TOKEN: false`: попытка Enqueue (`POST /admin/ingestion/...`) вернет **503 Service Unavailable**.
- Если `OVERPASS_API_URL: false`: Job начнется, но упадет с ошибкой `FAILED` (RuntimeError).

### 3. Тестирование кеширования (ETag/304)
Используйте `curl` или браузерную консоль:
```bash
# Первый запрос - получаем ETag
curl -I https://audiogid-api.vercel.app/v1/public/cities

# Второй запрос с заголовком If-None-Match
curl -I -H "If-None-Match: [ETag_из_предыдущего_ответа]" https://audiogid-api.vercel.app/v1/public/cities
```
- Ожидаемый результат: `HTTP/1.1 304 Not Modified`.

### 4. Проверка безопасности (Gated Cache)
Вызовите детальный эндпоинт POI.
- Ожидаемый результат: `Cache-Control: private, no-store`.

## Working with Antigravity (Context Pack)
Каждая рабочая сессия с AI-ассистентом Antigravity должна начинаться со следующих шагов:
1. Выполнить `view_file` для `AG_CONTEXT.md` для понимания текущих ограничений и стадии проекта.
2. Выполнить `view_file` для `AG_TODO_NOW.md` для получения текущей задачи.
3. Любое архитектурное решение должно проверяться на соответствие разделу "Non-negotiables".

### Branch Reset Procedure
1. После каждого успешного Merge в `main` и прохождения CI, создается Git Tag `checkpoint-N`.
2. Новые фичи стартуют ТОЛЬКО от `main` или актуального `checkpoint`.
3. Обязательное обновление `AG_TODO_NOW.md` после завершения задачи.

## Синхронизация контракта API (Contract Sync)
Если пайплайн `API Contract Sync Check` упал:
- Перегенерируйте SDK локально с помощью `openapi-generator-cli`.
- Закоммитьте изменения в папке `packages/api_client`.
- В логах Vercel ищите `trace_id` для отладки конкретных запросов. Логи никогда не содержат секреты или полные подписанные URL.
## Ingestion Troubleshooting

### Диагностика
1. Получите список запусков через Admin API: `GET /v1/admin/ingestion/runs`.
2. В ответе найдите поле `trace_id` для интересующего запуска.
3. Используйте `trace_id` в логах Vercel (Functions Tab) для фильтрации всех событий, связанных с этим запуском.
   - Ищите события: `job_started`, `osm_import_success`, `osm_import_failed`.

## Store Reviewability Plan (Mobile)
Для прохождения ревью в Apple App Store и Google Play, ревьюеры должны иметь возможность бесплатно протестировать платный контент.

### Стратегия A: Sandbox (Основная)
Ревью проводится в "песочнице" (Sandbox environment).
1. Приложение на девайсе ревьюера определяет, что оно запущено в TestFlight/Sandbox.
2. Покупка совершается через тестовый аккаунт (без списания денег).
3. Приложение отправляет чек (receipt) на `POST /v1/billing/apple/verify`.
4. Сервер пробует проверить чек на Prod URL. Если получает статус `21007` (Sandbox receipt used in production), он **автоматически** переключается на Sandbox Verify URL.
5. Результат: `verified: true`, `environment: Sandbox`.
6. Грант создается как обычно.

### Настройка переменных
Для работы биллинга требуются переменные окружения Vercel (Production & Preview):
*   `APPLE_SHARED_SECRET`: Секрет для валидации чеков (App Store Connect -> Users and Access -> Shared Secret).
*   `GOOGLE_SERVICE_ACCOUNT_JSON_BASE64`: JSON-ключ Service Account с правами на Android Publisher API (в base64).
