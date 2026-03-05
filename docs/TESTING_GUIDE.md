# Руководство по тестированию интеграции

## Обзор

Это руководство описывает процесс тестирования взаимодействия между:
- **Админ-панелью** (Next.js) и backend API
- **Мобильным приложением** (Flutter) и backend API
- **Backend API** и базой данных PostgreSQL на сервере (82.202.159.64 или ckaud.ru)

## Быстрый старт

### 1. Проверка доступности Backend API

```bash
# Простая проверка health check
curl http://82.202.159.64/v1/ops/health

# Если домен настроен
curl https://ckaud.ru/v1/ops/health
# или
curl http://ckaud.ru/v1/ops/health
```

**Ожидаемый результат:** `{"status":"ok"}` или `{"status":"healthy"}`

### 2. Запуск автоматизированных тестов API

**В Git Bash или WSL:**
```bash
cd scripts
./test-api-integration.sh
```

**В PowerShell (альтернатива):**
```powershell
# Простая проверка через curl
curl.exe http://82.202.159.64/v1/ops/health
curl.exe http://82.202.159.64/v1/public/cities
curl.exe "http://82.202.159.64/v1/public/catalog?city=kaliningrad_city"
```

### 3. Ручное тестирование админ-панели

1. Открыть админ-панель в браузере
2. Войти с валидными credentials
3. Проверить основные операции (см. `scripts/test-admin-integration.md`)

### 4. Ручное тестирование мобильного приложения

1. Запустить приложение в режиме отладки
2. Проверить основные сценарии (см. `scripts/test-mobile-integration.md`)

---

## Детальные инструкции

### Тестирование Backend API

См. полный план в `docs/INTEGRATION_TEST_PLAN.md`, раздел "1. Проверка доступности Backend API"

**Основные проверки:**
- Health check endpoint
- OpenAPI schema
- Публичные endpoints (cities, catalog, tours)
- ETag кэширование
- CORS (если применимо)

### Тестирование Админ-панели

См. `scripts/test-admin-integration.md`

**Основные проверки:**
- Аутентификация
- API Proxy
- CRUD операции (POI, Tours, Entitlements)
- Загрузка файлов
- Analytics

### Тестирование Мобильного приложения

См. `scripts/test-mobile-integration.md`

**Основные проверки:**
- Инициализация и выбор города
- Загрузка данных (туры, POI)
- Offline режим
- Аудио плеер
- Entitlements и покупки
- Tour Mode

---

## Конфигурация для тестирования

### Backend API

**URL по умолчанию:** `http://82.202.159.64/v1`

**Если домен настроен:** `https://ckaud.ru/v1` или `http://ckaud.ru/v1`

**Проверка конфигурации:**
- Проверить настройки nginx на сервере
- Проверить переменные окружения API (`DATABASE_URL`, `ADMIN_API_TOKEN`, etc.)

### Админ-панель

**Переменная окружения:**
```env
NEXT_PUBLIC_API_URL=http://82.202.159.64/v1
```

**Проверка в коде:**
- `apps/admin/app/api/proxy/[...path]/route.ts` - должен использовать правильный API URL
- `apps/admin/app/api/auth/login/route.ts` - должен использовать правильный API URL

### Мобильное приложение

**Конфигурация:**
- `apps/mobile_flutter/lib/core/config/app_config.dart`
- По умолчанию использует `http://82.202.159.64/v1`
- Можно переопределить через переменную окружения `API_BASE_URL`

---

## Чек-лист для быстрой проверки

### Backend API
- [ ] Health check возвращает 200 OK
- [ ] OpenAPI schema доступна
- [ ] Публичные endpoints работают
- [ ] ETag кэширование работает

### Админ-панель
- [ ] Логин работает
- [ ] API Proxy работает
- [ ] CRUD операции работают
- [ ] Все кнопки реагируют

### Мобильное приложение
- [ ] Данные загружаются
- [ ] Offline режим работает
- [ ] Аудио плеер работает
- [ ] Все кнопки реагируют

### База данных
- [ ] Подключение работает
- [ ] Миграции применены
- [ ] Данные корректны

---

## Отладка проблем

### Проблема: API недоступен

**Проверка:**
1. Проверить доступность сервера: `ping 82.202.159.64`
2. Проверить порт 80: `telnet 82.202.159.64 80`
3. Проверить логи API на сервере: `journalctl -u audiogid-api -f`

**Решение:**
- Проверить настройки firewall
- Проверить статус сервиса API: `systemctl status audiogid-api`
- Проверить логи nginx: `tail -f /var/log/nginx/error.log`

### Проблема: Админ-панель не подключается к API

**Проверка:**
1. Проверить переменную окружения `NEXT_PUBLIC_API_URL`
2. Проверить Network tab в браузере
3. Проверить логи админки

**Решение:**
- Убедиться, что `NEXT_PUBLIC_API_URL` правильный
- Проверить CORS настройки (если админка на другом домене)
- Проверить, что API доступен с админки

### Проблема: Мобильное приложение не загружает данные

**Проверка:**
1. Проверить логи приложения (flutter logs)
2. Проверить Network Inspector в DevTools
3. Проверить конфигурацию API в `app_config.dart`

**Решение:**
- Убедиться, что API URL правильный
- Проверить интернет-соединение
- Проверить, что API доступен с устройства/эмулятора

### Проблема: Данные не синхронизируются

**Проверка:**
1. Проверить ETag в запросах
2. Проверить локальную БД (Drift) в мобильном приложении
3. Проверить логи синхронизации

**Решение:**
- Проверить работу EtagInterceptor
- Проверить работу репозиториев (sync методы вызываются)
- Проверить логику кэширования

---

## Полезные команды

### Проверка API

```bash
# Health check
curl http://82.202.159.64/v1/ops/health

# Получить города
curl http://82.202.159.64/v1/public/cities

# Получить каталог
curl "http://82.202.159.64/v1/public/catalog?city=kaliningrad_city"

# Получить туры
curl "http://82.202.159.64/v1/public/tours?city=kaliningrad_city"
```

### Проверка БД на сервере

```bash
# Подключение к БД
ssh user1@82.202.159.64
psql -h localhost -U postgres -d audiogid

# Проверка таблиц
\dt

# Проверка данных
SELECT COUNT(*) FROM cities;
SELECT COUNT(*) FROM pois WHERE city_slug = 'kaliningrad_city';
SELECT COUNT(*) FROM tours WHERE city_slug = 'kaliningrad_city';
```

### Логи на сервере

```bash
# Логи API
journalctl -u audiogid-api -f

# Логи nginx
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

---

## Контакты и ресурсы

- **Документация:** `docs/INTEGRATION_TEST_PLAN.md`
- **План тестирования API:** `scripts/test-api-integration.sh`
- **План тестирования админки:** `scripts/test-admin-integration.md`
- **План тестирования мобильного приложения:** `scripts/test-mobile-integration.md`

---

## Примечания

- Если домен `ckaud.ru` настроен, использовать его вместо IP адреса
- Проверить настройки nginx на сервере для проксирования запросов
- Убедиться, что все переменные окружения настроены корректно
- При возникновении ошибок проверять логи на сервере

