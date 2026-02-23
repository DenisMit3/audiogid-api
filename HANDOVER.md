# Аудиогид - Передача проекта

## Структура проекта

```
1Audiogid/
├── apps/
│   └── mobile_flutter/     # Flutter мобильное приложение
├── backend/                # Python FastAPI бэкенд
├── packages/
│   └── api_client/         # Сгенерированный API клиент для Flutter
└── docs/                   # Документация
```

## Быстрый старт

### Требования
- Flutter SDK (D:\flutter)
- Python 3.11+
- Node.js (для утилит)
- Android SDK / Android Studio
- PostgreSQL + PostGIS (локально на сервере Cloud.ru)

### Бэкенд

```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
# Настроить .env (см. .env.example)
uvicorn app.main:app --reload
```

### Flutter приложение

```bash
cd apps/mobile_flutter
D:\flutter\bin\flutter.bat pub get
D:\flutter\bin\flutter.bat build apk --debug
```

## Ключевые файлы

### Бэкенд
- `backend/app/main.py` - точка входа FastAPI
- `backend/app/api/` - API endpoints
- `backend/app/models/` - SQLAlchemy модели
- `backend/app/core/config.py` - конфигурация

### Flutter
- `apps/mobile_flutter/lib/main.dart` - точка входа
- `apps/mobile_flutter/lib/core/` - ядро (API, роутинг, аудио)
- `apps/mobile_flutter/lib/data/` - репозитории, сервисы, БД
- `apps/mobile_flutter/lib/domain/` - сущности
- `apps/mobile_flutter/lib/presentation/` - UI экраны

### Конфигурация Android
- `apps/mobile_flutter/android/settings.gradle` - версии AGP/Kotlin
- `apps/mobile_flutter/android/gradle/wrapper/gradle-wrapper.properties` - версия Gradle
- `apps/mobile_flutter/android/app/build.gradle` - настройки приложения

## Текущие версии (важно!)

```
Android Gradle Plugin: 8.9.1
Kotlin: 2.1.0
Gradle: 8.11.1
Flutter: 3.x (D:\flutter)
compileSdk: 36
targetSdk: 36
desugar_jdk_libs: 2.1.4
```

## Известные проблемы и решения

### 1. Flutter не найден
Путь к Flutter: `D:\flutter\bin\flutter.bat`

### 2. Ошибки сборки Android
- Обновить AGP/Kotlin/Gradle до версий выше
- Создать ресурсы в `android/app/src/main/res/` (иконки, стили)

### 3. Riverpod миграция
Проект использует новый Riverpod с `@riverpod` аннотациями.
После изменений запускать:
```bash
D:\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
```

### 4. API клиент
Генерируется из OpenAPI спецификации бэкенда.
Находится в `packages/api_client/`

## Архитектура Flutter приложения

```
Presentation (UI)
    ↓
Domain (Entities, Use Cases)
    ↓
Data (Repositories, Services, DAOs)
    ↓
Core (API, Audio, Location, Router)
```

### State Management: Riverpod
- Providers в файлах `*_provider.dart` или с аннотацией `@riverpod`
- Сгенерированные файлы: `*.g.dart`

### Локальная БД: Drift (SQLite)
- Схема: `lib/data/local/app_database.dart`
- DAO: `lib/data/local/daos/`

### Навигация: GoRouter
- Роуты: `lib/core/router/app_router.dart`

## Контакты и ресурсы

- Git репозиторий: текущая папка
- API документация: запустить бэкенд, открыть /docs

## Что делать дальше

1. Исправить оставшиеся ошибки сборки Flutter
2. Настроить signing для release сборки
3. Подключить реальный бэкенд
4. Добавить иконку приложения (flutter_launcher_icons)
