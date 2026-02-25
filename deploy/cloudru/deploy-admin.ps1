# Deploy Admin Panel to Cloud.ru
# Run from project root: .\deploy\cloudru\deploy-admin.ps1

$SERVER = "82.202.159.64"
$USER = "user1"
$REMOTE_DIR = "/opt/audiogid/admin"
$SSH_KEY = "$env:USERPROFILE\.ssh\cloudru_audiogid"

Write-Host "=== Deploying Admin Panel to Cloud.ru ===" -ForegroundColor Cyan

# 1. Build admin locally
Write-Host "`n[1/4] Building admin panel..." -ForegroundColor Yellow
Set-Location "$PSScriptRoot\..\..\apps\admin"

# Create production .env.local
@"
NEXT_PUBLIC_API_URL=http://82.202.159.64/v1
BACKEND_URL=http://localhost:8000
"@ | Out-File -FilePath ".env.local" -Encoding UTF8

# Build
pnpm install
pnpm build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# 2. Create archive
Write-Host "`n[2/4] Creating archive..." -ForegroundColor Yellow
$archivePath = "$PSScriptRoot\admin-build.tar.gz"

# Remove old archive
if (Test-Path $archivePath) {
    Remove-Item $archivePath
}

# Create tar.gz with necessary files
tar -czvf $archivePath `
    .next `
    public `
    package.json `
    pnpm-lock.yaml `
    next.config.js `
    .env.local

# 3. Upload to server
Write-Host "`n[3/4] Uploading to server..." -ForegroundColor Yellow
scp -i $SSH_KEY $archivePath "${USER}@${SERVER}:/tmp/admin-build.tar.gz"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Upload failed! Check SSH connection." -ForegroundColor Red
    exit 1
}

# 4. Deploy on server
Write-Host "`n[4/4] Deploying on server..." -ForegroundColor Yellow

# Upload deploy script
$deployScriptPath = "$PSScriptRoot\deploy-admin-remote.sh"
scp -i $SSH_KEY $deployScriptPath "${USER}@${SERVER}:/tmp/deploy-admin.sh"

# Execute deploy script
ssh -i $SSH_KEY "${USER}@${SERVER}" "chmod +x /tmp/deploy-admin.sh && /tmp/deploy-admin.sh && rm /tmp/deploy-admin.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deploy failed!" -ForegroundColor Red
    exit 1
}

# Cleanup local archive
Remove-Item $archivePath -ErrorAction SilentlyContinue

Write-Host "`n=== Deploy Complete ===" -ForegroundColor Green
Write-Host "Admin panel: http://82.202.159.64:3080" -ForegroundColor Cyan
Write-Host "`nTo check status on server:" -ForegroundColor Gray
Write-Host "  ssh ${USER}@${SERVER} 'sudo systemctl status audiogid-admin'"
