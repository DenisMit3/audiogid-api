# PowerShell скрипт для экспорта данных из Neon
# Требует установленный PostgreSQL (pg_dump)

$NEON_HOST = "ep-restless-pond-af40wky4.c-2.us-west-2.aws.neon.tech"
$NEON_DB = "neondb"
$NEON_USER = "neondb_owner"
$NEON_PASS = "npg_mRMN7C3ohGHz"

$env:PGPASSWORD = $NEON_PASS

Write-Host "Exporting data from Neon..." -ForegroundColor Cyan

# Проверяем наличие pg_dump
$pgDump = Get-Command pg_dump -ErrorAction SilentlyContinue
if (-not $pgDump) {
    Write-Host "pg_dump not found. Please install PostgreSQL or add it to PATH" -ForegroundColor Red
    Write-Host "Download: https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
    exit 1
}

# Экспорт
pg_dump `
    -h $NEON_HOST `
    -U $NEON_USER `
    -d $NEON_DB `
    --no-owner `
    --no-privileges `
    -F c `
    -f neon_backup.dump

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item neon_backup.dump).Length / 1KB
    Write-Host "✅ Backup saved to neon_backup.dump ($([math]::Round($size, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "❌ Export failed" -ForegroundColor Red
}
