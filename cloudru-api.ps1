# Cloud.ru Evolution API Helper
# Использование: . .\cloudru-api.ps1

$script:KEY_ID = "b7fdf2ebc005b930093ae6be479c9f16"
$script:SECRET = "19e39cab3c2222fca8c527128cb176bb"
$script:PROJECT_ID = "2949ae42-fa75-49fc-a86f-da04209606ee"
$script:TOKEN = $null

# Получение токена
function Get-CloudToken {
    $body = @{ keyId = $script:KEY_ID; secret = $script:SECRET } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "https://iam.api.cloud.ru/api/v1/auth/token" -Method POST -Body $body -ContentType "application/json"
    $script:TOKEN = $response.access_token
    return $script:TOKEN
}

# Вызов API
function Invoke-CloudAPI {
    param(
        [string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body = $null
    )
    
    if (-not $script:TOKEN) { Get-CloudToken | Out-Null }
    
    $headers = @{ 
        Authorization = "Bearer $script:TOKEN"
        "Content-Type" = "application/json"
    }
    
    $params = @{
        Uri = $Endpoint
        Headers = $headers
        Method = $Method
    }
    
    if ($Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 10)
    }
    
    try {
        return Invoke-RestMethod @params
    } catch {
        # Если 401 - обновляем токен и пробуем снова
        if ($_.Exception.Response.StatusCode -eq 401) {
            Get-CloudToken | Out-Null
            $params.Headers.Authorization = "Bearer $script:TOKEN"
            return Invoke-RestMethod @params
        }
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Список ВМ
function Get-VMs {
    $response = Invoke-CloudAPI -Endpoint "https://compute.api.cloud.ru/api/v1/vms?project_id=$script:PROJECT_ID"
    return $response.items
}

# Информация о ВМ
function Get-VM {
    param([string]$VMId)
    return Invoke-CloudAPI -Endpoint "https://compute.api.cloud.ru/api/v1/vms/$VMId"
}

# Запуск ВМ
function Start-VM {
    param([string]$VMId)
    return Invoke-CloudAPI -Endpoint "https://compute.api.cloud.ru/api/v1/vms/$VMId/start" -Method POST
}

# Остановка ВМ
function Stop-VM {
    param([string]$VMId)
    return Invoke-CloudAPI -Endpoint "https://compute.api.cloud.ru/api/v1/vms/$VMId/stop" -Method POST
}

# Перезагрузка ВМ
function Restart-VM {
    param([string]$VMId)
    return Invoke-CloudAPI -Endpoint "https://compute.api.cloud.ru/api/v1/vms/$VMId/reboot" -Method POST
}

# Инициализация
Write-Host "Cloud.ru Evolution API Helper" -ForegroundColor Green
Write-Host "Project ID: $script:PROJECT_ID"
Get-CloudToken | Out-Null
Write-Host "Token OK (expires in 1 hour)" -ForegroundColor Green
Write-Host ""
Write-Host "Команды:"
Write-Host "  Get-VMs              - список ВМ"
Write-Host "  Get-VM -VMId 'id'    - информация о ВМ"
Write-Host "  Start-VM -VMId 'id'  - запустить ВМ"
Write-Host "  Stop-VM -VMId 'id'   - остановить ВМ"
Write-Host "  Restart-VM -VMId 'id'- перезагрузить ВМ"
Write-Host ""

# Показать ВМ
$vms = Get-VMs
Write-Host "=== Виртуальные машины ===" -ForegroundColor Cyan
$vms | ForEach-Object {
    $ip = if ($_.interfaces) { $_.interfaces[0].ip_address } else { "no ip" }
    Write-Host "  $($_.name) [$($_.state)] - $ip - ID: $($_.id)"
}
