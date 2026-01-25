# API Contract

## OpenAPI Specification
The source of truth for the Audio Guide 2026 API is the [openapi.yaml](../apps/api/openapi.yaml) file.

## Порядок внесения изменений (STRICT)
Соблюдение этого порядка обязательно для прохождения проверок в CI:
1. **OpenAPI Change**: Внесите изменения в [openapi.yaml](../apps/api/openapi.yaml).
2. **SDK Regeneration**: Запустите генератор (см. раздел Tools ниже) для обновления `packages/api_client`.
3. **Commit**: Закоммитьте спецификацию и сгенерированный SDK в одном коммите.
4. **Backend Implementation**: Реализуйте изменения в FastAPI (в `apps/api/api/public.py` и др.).
5. **Mobile Integration**: Используйте обновленные методы SDK в мобильном приложении.

## Интерпретация ошибок CI
Если пайплайн `API Contract Sync Check` завершился ошибкой:
- Это означает, что код в `packages/api_client` не соответствует спецификации в `apps/api/openapi.yaml`.
- На вкладке "Files changed" в GitHub вы увидите разницу (diff).
- **Решение**: Запустите команду генерации локально, проверьте изменения и закоммитьте их.

## Инструменты
- Генератор: `@openapitools/openapi-generator-cli`
- Команда для запуска: `npx @openapitools/openapi-generator-cli generate -i apps/api/openapi.yaml -g dart -o packages/api_client --additional-properties=pubName=api_client`

