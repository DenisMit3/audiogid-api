# Antigravity TODO NOW

## Current State: checkpoint-15 (API Stable)
- ✅ API is Production Ready (Billing, Ingestion, Workers).
- ✅ Worker issues resolved (QStash EU, Imports fixed).
- ❌ **No Mobile App** (Flutter).
- ❌ **No Auth** (SMS/Telegram).
- ❌ **No Admin UI** for Content.

## Immediate Roadmap (Priority Order)

### PR #58 — Auth Foundation (SMS + Telegram)
**Цель**: Безопасная авторизация для Админки и Пользователей.
- Интеграция SMS.RU (OTP).
- Интеграция Telegram Login Widget.
- JWT Session Management (`auth.py`).
- Эндпоинты `/auth/login/sms`, `/auth/login/telegram`.

### PR #59 — Admin Panel Content Management
**Цель**: Интерфейс для наполнения контента (Калининград).
- UI для списка/редактирования POI.
- UI для списка/редактирования Туров.
- Загрузка аудио/фото (Vercel Blob).
- Интеграция с Auth (доступ только для админов).

### PR #60 — Flutter App Bootstrap
**Цель**: Первый запуск мобильного приложения.
- `flutter create`.
- Architecture setup (Riverpod/Bloc).
- API Client integration (`packages/api_client`).
- Offline-first structure setup (Isar/Hive/SQLite).

## Later
- PR #61: Deep Links & Attribution.
- PR #62: Push Notifications.
- PR #63: QR Mappings + Museum Mode.

## Completed Recently
- [x] PR #40-#57: Worker Stability, QStash EU Fix, Billing Restore, Import Fixes.
