# API Examples

Ниже минимальные примеры использования основных endpoint'ов API.

## 1) Получить города

```bash
curl -s "http://82.202.159.64:8000/v1/public/cities"
```

## 2) Получить каталог туров по городу

```bash
curl -s "http://82.202.159.64:8000/v1/public/catalog?city=kaliningrad_city"
```

## 3) Логин по email

```bash
curl -s -X POST "http://82.202.159.64:8000/v1/auth/login/email" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"your-password"}'
```

## 4) Обновить токен

```bash
curl -s -X POST "http://82.202.159.64:8000/v1/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"<refresh-token>"}'
```

## 5) Проверить доступы (entitlements)

```bash
curl -s "http://82.202.159.64:8000/v1/billing/entitlements?device_anon_id=<device-id>"
```

## 6) Запустить сборку offline bundle

```bash
curl -s -X POST "http://82.202.159.64:8000/v1/offline/bundles:build" \
  -H "Content-Type: application/json" \
  -d '{"city_slug":"kaliningrad_city","idempotency_key":"example-123","type":"full_city"}'
```

## 7) Проверить статус background job

```bash
curl -s "http://82.202.159.64:8000/v1/offline/bundles/<job-id>"
```
