# Helper script to sync environments and run database migrations
# Works with local PostgreSQL on Cloud.ru

Write-Host "--- AudioGid Database Sync & Migrate ---" -ForegroundColor Cyan

# 1. Pull latest production environment variables from Vercel
Write-Host "1. Pulling Production Environment Variables from Vercel..."
cmd /c "npx vercel env pull .env.prod --environment=production --yes"

if (-not (Test-Path .env.prod)) {
    Write-Error "Failed to pull .env.prod from Vercel. Make sure you are logged in to Vercel."
    exit 1
}

# 2. Extract DATABASE_URL
$db_url = Get-Content .env.prod | Select-String "DATABASE_URL=" | ForEach-Object { 
    $_.ToString().Split('=', 2)[1].Trim().Trim('"').Trim("'") 
}

if (-not $db_url) {
    Write-Error "DATABASE_URL not found in .env.prod. Please check your Vercel Project Settings."
    exit 1
}

# 3. Apply Migrations
Write-Host "2. Applying Migrations to Database..." -ForegroundColor Yellow
$env:DATABASE_URL = $db_url

Push-Location apps/api
try {
    # Check if alembic is installed
    & alembic version | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installing alembic and dependencies..."
        pip install alembic sqlmodel psycopg2-binary GeoAlchemy2
    }
    
    alembic upgrade head
    Write-Host "SUCCESS: Database schema is up to date!" -ForegroundColor Green
} catch {
    Write-Error "Migration failed: $_"
} finally {
    Pop-Location
}

Write-Host "--- Done ---"
