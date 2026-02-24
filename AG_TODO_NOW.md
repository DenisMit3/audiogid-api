# Antigravity TODO NOW

**Последнее обновление:** 2026-02-24

## Current State: Release Candidate (RC1)
- ✅ **API**: Production Ready (Cloud.ru, PostgreSQL локально).
- ✅ **Mobile App**: Feature Complete, Tested (Unit/Widget/Smoke), Configured for Release.
- ✅ **Admin Panel**: Feature Complete (CRUD, Media, Jobs, Route Builder).
- ✅ **Store Readiness**: Assets Generated, Compliances Done.
- ✅ **Infrastructure**: Миграция на Cloud.ru завершена.

## Recent Completed (2026-02-24)
- [x] Route Builder: расчет расстояний, drag-n-drop маркеры
- [x] Миграция с Neon на локальный PostgreSQL (Cloud.ru)
- [x] Удалены все API заглушки в мобильном приложении
- [x] Endpoint проверки версии приложения
- [x] Исправлена аутентификация и URL админ-панели
- [x] Offline manifest для ресурсов города
- [x] Расширенное логирование для туров и маршрутов

## Final Steps (Manual / External)

### 1. Local Build & Generation
```bash
cd apps/mobile_flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run flutter_launcher_icons
```

### 2. Manual QA
- Test on physical iOS/Android devices.
- Verify GPS behavior in "Tour Mode".
- Verify "Off-route" notifications.
- Check Battery usage.
- Проверить Route Builder с новыми маркерами.

### 3. Store Submission
- **Screenshots**: Take on device.
- **Upload**: Submit `.aab` and `.ipa`.

## Completed Code Tasks
- [x] Admin Panel: CRUD, Media, Jobs, Auth, Route Builder.
- [x] Mobile: Testing Infrastructure, Security Hardening, iOS Config.
- [x] DevOps: GitHub Actions, Fastlane.
- [x] Content: Store Descriptions, Feature Graphic.
- [x] Infrastructure: Cloud.ru deployment, PostgreSQL migration.
- [x] API: Version check endpoint, offline manifests.

## Known Issues
- Нет критических блокеров для релиза.

## Post-Release TODO
- [ ] Free Walking Mode - базовый алгоритм
- [ ] Kids Mode - фильтр детского контента
- [ ] Deep Links v2 - улучшенный шеринг
- [ ] SOS Features
