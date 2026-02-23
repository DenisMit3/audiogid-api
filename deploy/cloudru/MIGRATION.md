# Миграция с Neon на Cloud.ru PostgreSQL

## Обзор

Переносим базу данных с Neon (serverless PostgreSQL) на локальный PostgreSQL на сервере Cloud.ru (82.202.159.64).

## Преимущества локального PostgreSQL

- ✅ Стабильное соединение (без разрывов как у Neon)
- ✅ Нет лимитов на размер данных
- ✅ Быстрее (нет сетевой задержки до US-West)
- ✅ Полный контроль над настройками
- ✅ Бесплатно (входит в стоимость VPS)

## Шаги миграции

### 1. Экспорт данных из Neon (на локальном ПК)

```powershell
cd deploy\cloudru
.\export-neon.ps1
```

Это создаст файл `neon_backup.dump`

### 2. Загрузка файлов на сервер

```powershell
.\upload.ps1
```

Или вручную через SCP/SFTP:
- `neon_backup.dump` → `/opt/audiogid/`
- `setup-postgres.sh` → `/opt/audiogid/`
- `import-data.sh` → `/opt/audiogid/`
- `update-config.sh` → `/opt/audiogid/`

### 3. На сервере Cloud.ru (через SSH)

```bash
cd /opt/audiogid

# Установка PostgreSQL
chmod +x setup-postgres.sh
./setup-postgres.sh

# Импорт данных
chmod +x import-data.sh
./import-data.sh

# Обновление конфигурации API
chmod +x update-config.sh
./update-config.sh
```

### 4. Проверка

```bash
# Проверка API
curl http://localhost:8000/health

# Проверка базы данных
PGPASSWORD=audiogid_secure_pass_2026 psql -h localhost -U audiogid -d audiogid -c "SELECT COUNT(*) FROM tour;"
```

## Новые credentials

После миграции:

```
DATABASE_URL=postgresql://audiogid:audiogid_secure_pass_2026@localhost:5432/audiogid
```

## Откат (если что-то пошло не так)

Вернуть Neon в .env:

```bash
cd /opt/audiogid/api
cp .env.backup.* .env  # восстановить из бэкапа
sudo systemctl restart audiogid-api
```
