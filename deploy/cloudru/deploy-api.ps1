# Deploy API to Cloud.ru
# Run this script from the project root

Write-Host "=== Deploying API to Cloud.ru ===" -ForegroundColor Cyan

$SERVER = "user1@82.202.159.64"
$API_DIR = "/opt/audiogid/api"

# 1. Copy API files
Write-Host "[1/3] Copying API files..." -ForegroundColor Yellow
scp -r apps/api/api/* "${SERVER}:${API_DIR}/api/"

# 2. Restart API service
Write-Host "[2/3] Restarting API service..." -ForegroundColor Yellow
ssh $SERVER "sudo systemctl restart audiogid-api"

# 3. Check status
Write-Host "[3/3] Checking API status..." -ForegroundColor Yellow
ssh $SERVER "sudo systemctl status audiogid-api --no-pager"

Write-Host ""
Write-Host "=== Deploy Complete ===" -ForegroundColor Green
Write-Host "Test: curl http://82.202.159.64/v1/ops/health"
