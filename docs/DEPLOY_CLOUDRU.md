# Инструкция по деплою Audiogid на Cloud.ru

Пошаговая инструкция для развертывания проекта на сервере Cloud.ru (82.202.159.64).

## Предварительные требования

- Доступ к серверу по SSH (user1@82.202.159.64)
- SSH-ключ настроен на локальной машине
- На сервере установлен Ubuntu/Debian

---

## Шаг 1: Подключение к серверу

```bash
ssh user1@82.202.159.64
```

Если спрашивает пароль - введите пароль от пользователя user1.

---

## Шаг 2: Установка необходимого ПО

### 2.1 Обновление системы
```bash
sudo apt update && sudo apt upgrade -y
```

### 2.2 Установка Python 3.11
```bash
sudo apt install -y python3.11 python3.11-venv python3-pip
```

### 2.3 Установка Node.js 20
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### 2.4 Установка pnpm
```bash
sudo npm install -g pnpm
```

### 2.5 Установка MinIO (хранилище файлов)
```bash
# Скачиваем MinIO
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/

# Создаем директорию для данных
sudo mkdir -p /data/minio
sudo chown user1:user1 /data/minio
```

---

## Шаг 3: Загрузка проекта на сервер

### Вариант А: С локальной машины (Windows PowerShell)

Откройте PowerShell в папке проекта и выполните:

```powershell
.\deploy\cloudru\upload.ps1
```

### Вариант Б: Через Git на сервере

```bash
cd /opt
sudo mkdir -p audiogid
sudo chown user1:user1 audiogid
cd audiogid
git clone https://github.com/YOUR_REPO/audiogid.git .
```

---

## Шаг 4: Настройка MinIO

### 4.1 Создание systemd сервиса для MinIO

```bash
sudo tee /etc/systemd/system/minio.service > /dev/null << 'EOF'
[Unit]
Description=MinIO Object Storage
After=network.target

[Service]
Type=simple
User=user1
Group=user1
Environment="MINIO_ROOT_USER=minioadmin"
Environment="MINIO_ROOT_PASSWORD=minioadmin"
ExecStart=/usr/local/bin/minio server /data/minio --console-address ":9001"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### 4.2 Запуск MinIO

```bash
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio
```

### 4.3 Создание bucket для проекта

```bash
# Установка mc (MinIO Client)
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

# Настройка подключения
mc alias set local http://localhost:9000 minioadmin minioadmin

# Создание bucket
mc mb local/audiogid

# Установка публичного доступа на чтение
mc anonymous set download local/audiogid
```

---

## Шаг 5: Настройка API

### 5.1 Переход в папку API

```bash
cd /opt/audiogid/api
```

### 5.2 Создание .env файла

```bash
cat > .env << 'EOF'
# Database (локальный PostgreSQL)
DATABASE_URL=postgresql://audiogid:CHANGE_ME_SECURE_PASSWORD@localhost:5432/audiogid

# Environment
DEPLOY_ENV=production

# Auth
JWT_SECRET=very-secure-jwt-secret-for-audiogid-2026-gen-by-agent-v1
JWT_ALGORITHM=HS256
ADMIN_API_TOKEN=temp-admin-key-2026
OTP_TTL_SECONDS=300

# Telegram Bot
TELEGRAM_BOT_TOKEN=8346337210:AAFbeka9ot5aBpwbPl-3ggD6on37pQ2tAoM

# S3 Storage (MinIO)
S3_ENDPOINT_URL=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_NAME=audiogid
S3_PUBLIC_URL=http://82.202.159.64:9000/audiogid

# Public URL
PUBLIC_URL=http://82.202.159.64:8000
EOF
```

### 5.3 Установка зависимостей Python

```bash
pip3 install --user -r requirements.txt
```

### 5.4 Запуск миграций базы данных

```bash
~/.local/bin/alembic upgrade head
```

---

## Шаг 6: Настройка Admin Panel

### 6.1 Переход в папку Admin

```bash
cd /opt/audiogid/admin
```

### 6.2 Создание .env файла

```bash
cat > .env << 'EOF'
NEXT_PUBLIC_API_URL=http://82.202.159.64:8000
BACKEND_URL=http://82.202.159.64:8000
DEPLOY_ENV=production
EOF
```

### 6.3 Установка зависимостей и сборка

```bash
pnpm install
pnpm build
```

---

## Шаг 7: Создание systemd сервисов

### 7.1 Сервис API

```bash
sudo tee /etc/systemd/system/audiogid-api.service > /dev/null << 'EOF'
[Unit]
Description=Audiogid API Service
After=network.target

[Service]
Type=simple
User=user1
Group=user1
WorkingDirectory=/opt/audiogid/api
EnvironmentFile=/opt/audiogid/api/.env
ExecStart=/home/user1/.local/bin/uvicorn index:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### 7.2 Сервис Admin Panel

```bash
sudo tee /etc/systemd/system/audiogid-admin.service > /dev/null << 'EOF'
[Unit]
Description=Audiogid Admin Panel
After=network.target

[Service]
Type=simple
User=user1
Group=user1
WorkingDirectory=/opt/audiogid/admin
EnvironmentFile=/opt/audiogid/admin/.env
ExecStart=/usr/bin/npx next start -p 3080
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

## Шаг 8: Запуск всех сервисов

```bash
sudo systemctl daemon-reload
sudo systemctl enable audiogid-api audiogid-admin
sudo systemctl start audiogid-api audiogid-admin
```

---

## Шаг 9: Проверка работы

### 9.1 Проверка статуса сервисов

```bash
sudo systemctl status audiogid-api
sudo systemctl status audiogid-admin
sudo systemctl status minio
```

### 9.2 Проверка API

```bash
curl http://localhost:8000/v1/ops/health
```

Должен вернуть: `{"status":"ok",...}`

### 9.3 Проверка из браузера

- API: http://82.202.159.64:8000/docs
- Admin: http://82.202.159.64:3080
- MinIO Console: http://82.202.159.64:9001

---

## Шаг 10: Открытие портов (если нужно)

Если сервисы не доступны извне, нужно открыть порты в файрволе:

```bash
sudo ufw allow 8000/tcp  # API
sudo ufw allow 3080/tcp  # Admin
sudo ufw allow 9000/tcp  # MinIO API
sudo ufw allow 9001/tcp  # MinIO Console
```

Также проверьте Security Groups в панели Cloud.ru!

---

## Полезные команды

### Просмотр логов

```bash
# Логи API
sudo journalctl -u audiogid-api -f

# Логи Admin
sudo journalctl -u audiogid-admin -f

# Логи MinIO
sudo journalctl -u minio -f
```

### Перезапуск сервисов

```bash
sudo systemctl restart audiogid-api
sudo systemctl restart audiogid-admin
sudo systemctl restart minio
```

### Остановка сервисов

```bash
sudo systemctl stop audiogid-api
sudo systemctl stop audiogid-admin
```

---

## Обновление проекта

### Быстрое обновление API

```bash
cd /opt/audiogid/api
git pull  # или загрузите новые файлы
pip3 install --user -r requirements.txt
~/.local/bin/alembic upgrade head
sudo systemctl restart audiogid-api
```

### Быстрое обновление Admin

```bash
cd /opt/audiogid/admin
git pull  # или загрузите новые файлы
pnpm install
pnpm build
sudo systemctl restart audiogid-admin
```

---

## Решение проблем

### API не запускается

1. Проверьте логи: `sudo journalctl -u audiogid-api -n 50`
2. Проверьте .env файл: `cat /opt/audiogid/api/.env`
3. Проверьте права: `ls -la /opt/audiogid/api/`

### Admin не запускается

1. Проверьте логи: `sudo journalctl -u audiogid-admin -n 50`
2. Убедитесь что build прошел: `ls /opt/audiogid/admin/.next/`
3. Пересоберите: `cd /opt/audiogid/admin && pnpm build`

### MinIO не работает

1. Проверьте логи: `sudo journalctl -u minio -n 50`
2. Проверьте директорию: `ls -la /data/minio/`
3. Проверьте порты: `ss -tlnp | grep 9000`

### Нет доступа извне

1. Проверьте файрвол: `sudo ufw status`
2. Проверьте Security Groups в Cloud.ru
3. Проверьте что сервис слушает на 0.0.0.0: `ss -tlnp | grep 8000`

---

## Контакты и ссылки

- Сервер: 82.202.159.64
- API: http://82.202.159.64:8000
- Admin: http://82.202.159.64:3080
- MinIO: http://82.202.159.64:9001
- База данных: PostgreSQL + PostGIS (локально на сервере)
