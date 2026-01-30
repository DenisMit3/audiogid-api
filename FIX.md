# 🚀 ГОТОВНОСТЬ К ДЕПЛОЮ - СПИСОК РУЧНЫХ ДЕЙСТВИЙ

Все критические ошибки в коде исправлены. Недостающий функционал реализован.
Для успешного деплоя необходимо выполнить следующие ручные действия.

## 🔐 1. Настройка Secrets и Environment Variables

### Использовать Vercel Dashboard
`https://vercel.com/dashboard`

**Project: audiogid-api**
Добавить в Environment Variables (Production & Preview):
- `DATABASE_URL`: `postgresql://user:pass@host.neon.tech/db?sslmode=require` (взять из Neon)
- `JWT_SECRET`: Сгенерировать новый (openssl rand -hex 32)
- `ADMIN_API_TOKEN`: Сгенерировать новый (openssl rand -hex 32)
- `QSTASH_TOKEN`: Из Upstash Console
- `QSTASH_CURRENT_SIGNING_KEY`: Из Upstash Console
- `QSTASH_NEXT_SIGNING_KEY`: Из Upstash Console
- `VERCEL_BLOB_READ_WRITE_TOKEN`: Из Vercel Storage

**Project: admin**
Добавить в Environment Variables (Production & Preview):
- `NEXT_PUBLIC_API_URL`: `https://audiogid-api.vercel.app/v1`
- `JWT_SECRET`: **ТОТ ЖЕ CАМЫЙ**, что и в API!

### Использовать GitHub Secrets
`https://github.com/your-repo/settings/secrets/actions`

Добавить:
- `VERCEL_TOKEN`: Токен от Vercel аккаунта
- `VERCEL_ORG_ID`: ID организации Vercel
- `VERCEL_PROJECT_ID`: ID проекта API
- `ADMIN_API_TOKEN`: Тот же, что в Vercel
- `DATABASE_URL`: Тот же, что в Vercel
- `KEYSTORE_PASSWORD`: `changeit123` (или ваш собственный)
- `KEY_PASSWORD`: `changeit123` (или ваш собственный)
- `KEYSTORE_BASE64`: Base64 строка файла keystore (см. ниже)

---

## 🔑 2. Создание Keystore (Android)

Автоматическое создание не удалось. Выполните вручную:

1. Откройте терминал:
   ```bash
   cd apps/mobile_flutter/android
   keytool -genkey -v -keystore audiogid-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias audiogid -storepass changeit123 -keypass changeit123 -dname "CN=Audiogid, OU=Dev, O=Audiogid, L=Unknown, S=Unknown, C=US"
   ```

2. Сгенерируйте Base64 для GitHub Secret:
   ```bash
   # MacOS / Linux
   openssl base64 < audiogid-release.jks | tr -d '\n' | pbcopy
   
   # Windows (PowerShell)
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("audiogid-release.jks")) | Set-Clipboard
   ```

3. Вставьте содержимое буфера обмена в GitHub Secret `KEYSTORE_BASE64`.

---

## 🗄️ 3. База данных

Убедитесь, что база данных в Neon создана. Миграции запустятся автоматически при первом деплое API через GitHub Actions (или можно запустить локально, если настроен .env).

Локальный запуск миграций:
```bash
cd apps/api
# Создать .env и прописать DATABASE_URL
alembic upgrade head
```

---

## ✅ Следующие шаги

1. Закоммитить и запушить изменения: `git push origin main`
2. Следить за GitHub Actions в репозитории.
3. Проверить деплой API и Admin панели.
