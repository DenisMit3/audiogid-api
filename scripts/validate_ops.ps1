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
curl.exe -sS -i -X POST "$BASE/v1/billing/restore" `
  -H "Content-Type: application/json" `
  -d '{"platform":"google","device_anon_id":"val_user_script","google_purchases":[{"product_id":"test_sku","purchase_token":"test_token"}]}'

Write-Host "`nDone."
