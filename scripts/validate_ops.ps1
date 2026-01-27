$BASE="https://audiogid-api.vercel.app"
$TS=Get-Date -UFormat %s
Write-Host "Validating Prod Ops... TS=$TS"

Write-Host "--- 1. Commit SHA ---"
curl.exe -sS "$BASE/v1/ops/commit?ts=$TS"
Write-Host "`n"

Write-Host "--- 2. Health ---"
curl.exe -sS -i "$BASE/v1/ops/health?ts=$TS"
Write-Host "`n"

Write-Host "--- 3. Billing Restore Smoke Test (Google) ---"
$UniqueKey="val_check_ops_$TS"
$Body = '{\"platform\":\"google\",\"idempotency_key\":\"' + $UniqueKey + '\",\"device_anon_id\":\"val_user_script\",\"google_purchases\":[{\"package_name\":\"com.test\",\"product_id\":\"test_sku\",\"purchase_token\":\"test_token_FAIL_SAFE\"}]}'

$RespJson = curl.exe -sS "$BASE/v1/billing/restore" -H "Content-Type: application/json" -d "$Body"
Write-Host "Enqueued: $RespJson"

# Parse Job ID (Simple string manipulation to avoid PS JSON issues if curl output varies)
# Assume {"job_id":"..." ...}
if ($RespJson -match '"job_id":"([^"]+)"') {
    $JobId = $matches[1]
    Write-Host "Polling Job $JobId (Max 60s)..."
    
    for ($i=0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        $StatusResp = curl.exe -sS "$BASE/v1/billing/restore/$JobId"
        if ($StatusResp -match '"status":"([^"]+)"') {
            $Status = $matches[1]
            Write-Host "[$i] Status: $Status"
            
            if ($Status -eq "COMPLETED") {
                 Write-Host "✅ Validation Passed: Job Completed Successfully."
                 exit 0
            }
            if ($Status -eq "FAILED") {
                 Write-Host "❌ Validation Failed: Job Reported Failure."
                 Write-Host "Response: $StatusResp"
                 # Warning: fail-fast smoke test might fail if tokens are invalid, that is acceptable for smoke?
                 # Actually for smoke test with dummy token, we EXPECT failure or partial failure?
                 # No, the code catches InvalidToken and logs it but might mark job as partial?
                 # If job handles exception cleanly, it might be COMPLETED with failed_count > 0.
                 # Let's inspect final logic.
                 exit 1
            }
        } else {
             Write-Host "[$i] Status Unknown (Response parse error)"
        }
    }
    Write-Host "⚠️ Validation Timeout: Job stuck in PENDING/RUNNING > 60s."
    exit 1
}
Write-Host "`nDone."
