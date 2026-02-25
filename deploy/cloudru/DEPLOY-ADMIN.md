# Деплой админки на Cloud.ru - Инструкция

## Автоматический деплой (PowerShell)

```powershell
cd c:\Users\Denis\Desktop\vse boty\1Audiogid
.\deploy\cloudru\deploy-admin.ps1
```

## Ручной деплой

### 1. Сборка на локальной машине

```powershell
cd c:\Users\Denis\Desktop\vse boty\1Audiogid\apps\admin

# Создать .env.local
@"
NEXT_PUBLIC_API_URL=http://82.202.159.64/v1
BACKEND_URL=http://localhost:8000
"@ | Out-File -FilePath ".env.local" -Encoding UTF8

# Установить зависимости и собрать
pnpm install
pnpm build
```

### 2. Копирование на сервер

```powershell
# Создать архив
tar -czvf admin-build.tar.gz .next public package.json pnpm-lock.yaml next.config.js .env.local

# Скопировать на сервер
scp admin-build.tar.gz user1@82.202.159.64:/tmp/
```

### 3. Установка на сервере

```bash
ssh user1@82.202.159.64

# На сервере:
sudo mkdir -p /opt/audiogid/admin
cd /opt/audiogid/admin
sudo tar -xzvf /tmp/admin-build.tar.gz
sudo chown -R user1:user1 /opt/audiogid/admin

# Установить зависимости
pnpm install --prod

# Создать systemd сервис (если еще нет)
sudo tee /etc/systemd/system/audiogid-admin.service > /dev/null << 'EOF'
[Unit]
Description=Audiogid Admin Panel
After=network.target

[Service]
Type=simple
User=user1
Group=user1
WorkingDirectory=/opt/audiogid/admin
ExecStart=/usr/bin/npx next start -p 3080
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Запустить сервис
sudo systemctl daemon-reload
sudo systemctl enable audiogid-admin
sudo systemctl restart audiogid-admin

# Проверить статус
sudo systemctl status audiogid-admin
```

### 4. Проверка

Админка будет доступна по адресу: http://82.202.159.64:3080

## Важно

- На сервере должен быть установлен Node.js 18+ и pnpm
- MinIO должен быть запущен на localhost:9000
- API должен быть запущен на localhost:8000

## Проверка сервисов на сервере

```bash
# Статус всех сервисов
sudo systemctl status audiogid-api
sudo systemctl status audiogid-admin
sudo systemctl status minio

# Логи
sudo journalctl -u audiogid-admin -f
```
