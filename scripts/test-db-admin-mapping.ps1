# Script to verify database table relationships and admin panel mapping
# Проверка соответствия таблиц БД и админки

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Database-Admin Mapping Verification" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if models.py exists
$modelsPath = "apps\api\api\core\models.py"
if (Test-Path $modelsPath) {
    Write-Host "✓ Models file found: $modelsPath" -ForegroundColor Green
    
    # Read and analyze models
    $modelsContent = Get-Content $modelsPath -Raw
    
    # Extract table definitions
    $tables = @()
    if ($modelsContent -match 'class (\w+)\(.*table=True\)') {
        $matches = [regex]::Matches($modelsContent, 'class (\w+)\(.*table=True\)')
        foreach ($match in $matches) {
            $tables += $match.Groups[1].Value
        }
    }
    
    Write-Host ""
    Write-Host "Found Tables:" -ForegroundColor Yellow
    foreach ($table in $tables) {
        Write-Host "  - $table" -ForegroundColor Gray
    }
    
    # Extract foreign keys
    Write-Host ""
    Write-Host "Foreign Key Relationships:" -ForegroundColor Yellow
    $fkMatches = [regex]::Matches($modelsContent, 'foreign_key="([^"]+)"')
    foreach ($match in $fkMatches) {
        Write-Host "  - FK: $($match.Groups[1].Value)" -ForegroundColor Gray
    }
    
    # Extract relationships
    Write-Host ""
    Write-Host "SQLModel Relationships:" -ForegroundColor Yellow
    $relMatches = [regex]::Matches($modelsContent, 'Relationship\(back_populates="([^"]+)"\)')
    foreach ($match in $relMatches) {
        Write-Host "  - Relationship: $($match.Groups[1].Value)" -ForegroundColor Gray
    }
    
} else {
    Write-Host "✗ Models file not found: $modelsPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Admin Panel Forms Check" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check admin forms
$adminForms = @(
    "apps\admin\components\PoiForm.tsx",
    "apps\admin\components\tour-editor.tsx",
    "apps\admin\components\cities\city-form.tsx"
)

foreach ($form in $adminForms) {
    if (Test-Path $form) {
        Write-Host "✓ Form found: $form" -ForegroundColor Green
    } else {
        Write-Host "✗ Form not found: $form" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "API Endpoints Check" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check admin API endpoints
$adminEndpoints = @(
    "apps\api\api\admin\poi.py",
    "apps\api\api\admin\tour.py",
    "apps\api\api\admin\city.py"
)

foreach ($endpoint in $adminEndpoints) {
    if (Test-Path $endpoint) {
        Write-Host "✓ API endpoint found: $endpoint" -ForegroundColor Green
    } else {
        Write-Host "✗ API endpoint not found: $endpoint" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "For detailed mapping analysis, see: docs\DB_ADMIN_MAPPING_REPORT.md" -ForegroundColor Yellow

