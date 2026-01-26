# API Contract & Caching Policy

## Каноническая спецификация
Файл [openapi.yaml](../apps/api/openapi.yaml) является единственным источником истины.

## Политика кеширования (Caching Safety)
Для обеспечения производительности и безопасности в Serverless среде применяются следующие правила:

1. **Public Read-Only (Общедоступные данные)**
   - Применяется для: `/public/cities`, `/public/catalog`, `/public/tours`.
   - Заголовки: `Cache-Control: public, max-age=60, s-maxage=3600, stale-while-revalidate=86400`.
   - Механизм: ETag на основе версионных маркеров БД. Поддерживается `304 Not Modified`.

2. **Gated/User-Specific (Защищенный контент)**
   - Применяется для: `/public/poi/{id}` (полные детали), `/manifest`, любая выдача с `signed_asset_url`.
   - Заголовки: `Cache-Control: private, no-store`.
   - Безопасность: Добавляется заголовок `Vary: Authorization` (или аналог), чтобы кеши не смешивали контент разных пользователей.

## Порядок внесения изменений
1. Обновить `openapi.yaml`.
2. Перегенерировать SDK в `packages/api_client`.
3. Закоммитить изменения.
4. CI проверит соответствие через `fail-on-diff`.
