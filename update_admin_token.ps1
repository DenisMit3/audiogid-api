$token = "sec_" + (python -c "import secrets; print(secrets.token_hex(16))").Trim()
Write-Host "NEW_ADMIN_TOKEN=$token"

Write-Host "Removing old keys..."
cmd /c "npx vercel env rm ADMIN_API_TOKEN production -y"
cmd /c "npx vercel env rm ADMIN_API_TOKEN preview -y"

Write-Host "Adding new key..."
cmd /c "echo $token | npx vercel env add ADMIN_API_TOKEN production"
cmd /c "echo $token | npx vercel env add ADMIN_API_TOKEN preview"
