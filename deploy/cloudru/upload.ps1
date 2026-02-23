# PowerShell скрипт для загрузки файлов на Cloud.ru
# Использует SCP (требует OpenSSH или PuTTY)

$SERVER = "82.202.159.64"
$USER = "user1"
$REMOTE_DIR = "/opt/audiogid"

$files = @(
    "neon_backup.dump",
    "setup-postgres.sh",
    "import-data.sh",
    "update-config.sh"
)

Write-Host "=== Uploading files to Cloud.ru ===" -ForegroundColor Cyan
Write-Host "Server: $USER@$SERVER" -ForegroundColor Gray
Write-Host ""

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Uploading $file..." -ForegroundColor Yellow
        scp $file "${USER}@${SERVER}:${REMOTE_DIR}/"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ $file uploaded" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Failed to upload $file" -ForegroundColor Red
        }
    } else {
        Write-Host "  ⚠️ File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Upload Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps on server:" -ForegroundColor White
Write-Host "  ssh $USER@$SERVER" -ForegroundColor Gray
Write-Host "  cd $REMOTE_DIR" -ForegroundColor Gray
Write-Host "  chmod +x *.sh" -ForegroundColor Gray
Write-Host "  ./setup-postgres.sh" -ForegroundColor Gray
Write-Host "  ./import-data.sh" -ForegroundColor Gray
Write-Host "  ./update-config.sh" -ForegroundColor Gray
