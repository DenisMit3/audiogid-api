# Upload and deploy Audiogid to Cloud.ru server
# Run from project root: .\deploy\cloudru\upload.ps1

$SERVER = "82.202.159.64"
$USER = "user1"
$APP_DIR = "/opt/audiogid"

Write-Host "=== Uploading Audiogid to $SERVER ===" -ForegroundColor Green

# Check SSH connection
Write-Host "Testing SSH connection..." -ForegroundColor Yellow
ssh ${USER}@${SERVER} "echo 'SSH OK'"
if ($LASTEXITCODE -ne 0) {
    Write-Host "SSH connection failed. Check your SSH key or password." -ForegroundColor Red
    exit 1
}

# Create directories on server
Write-Host "Creating directories..." -ForegroundColor Yellow
ssh ${USER}@${SERVER} "sudo mkdir -p $APP_DIR/api $APP_DIR/admin && sudo chown -R ${USER}:${USER} $APP_DIR"

# Upload API files
Write-Host "Uploading API files..." -ForegroundColor Yellow
scp -r apps/api/* ${USER}@${SERVER}:${APP_DIR}/api/

# Upload Admin files
Write-Host "Uploading Admin files..." -ForegroundColor Yellow
scp -r apps/admin/* ${USER}@${SERVER}:${APP_DIR}/admin/

# Upload deploy script
Write-Host "Uploading deploy script..." -ForegroundColor Yellow
scp deploy/cloudru/deploy-full.sh ${USER}@${SERVER}:${APP_DIR}/

# Create .env files on server
Write-Host "Creating .env files..." -ForegroundColor Yellow

# API .env
ssh ${USER}@${SERVER} @"
cat > $APP_DIR/api/.env << 'EOF'
DATABASE_URL=postgresql://neondb_owner:npg_mRMN7C3ohGHz@ep-restless-pond-af40wky4-pooler.c-2.us-west-2.aws.neon.tech/neondb?sslmode=require
JWT_SECRET=very-secure-jwt-secret-for-audiogid-2026-gen-by-agent-v1
JWT_ALGORITHM=HS256
ADMIN_API_TOKEN=temp-admin-key-2026
OTP_TTL_SECONDS=300
TELEGRAM_BOT_TOKEN=8346337210:AAFbeka9ot5aBpwbPl-3ggD6on37pQ2tAoM
DEPLOY_ENV=production
S3_ENDPOINT_URL=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_NAME=audiogid
S3_PUBLIC_URL=http://82.202.159.64:9000/audiogid
PUBLIC_URL=http://82.202.159.64:8000
EOF
"@

# Admin .env
ssh ${USER}@${SERVER} @"
cat > $APP_DIR/admin/.env << 'EOF'
NEXT_PUBLIC_API_URL=http://82.202.159.64:8000
BACKEND_URL=http://82.202.159.64:8000
DEPLOY_ENV=production
EOF
"@

Write-Host ""
Write-Host "=== Files uploaded ===" -ForegroundColor Green
Write-Host ""
Write-Host "Now SSH to server and run:" -ForegroundColor Cyan
Write-Host "  ssh ${USER}@${SERVER}"
Write-Host "  cd $APP_DIR"
Write-Host "  chmod +x deploy-full.sh"
Write-Host "  ./deploy-full.sh"
Write-Host ""
Write-Host "Or run manually:" -ForegroundColor Cyan
Write-Host "  # Install deps and start API:"
Write-Host "  cd $APP_DIR/api"
Write-Host "  pip3 install --user -r requirements.txt"
Write-Host "  ~/.local/bin/uvicorn index:app --host 0.0.0.0 --port 8000"
Write-Host ""
Write-Host "  # In another terminal - build and start Admin:"
Write-Host "  cd $APP_DIR/admin"
Write-Host "  pnpm install && pnpm build"
Write-Host "  pnpm start -p 3080"
