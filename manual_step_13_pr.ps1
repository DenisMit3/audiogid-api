Write-Host "Starting Step 13 Manual Completion..."

# 1. GitHub Auth
Write-Host "`n[1/2] Authenticating GitHub CLI (Browser will open)..."
gh auth login -h github.com -p https -w

# 2. PR Creation
Write-Host "`n[2/2] Creating Pull Request..."
gh pr create --repo DenisMit3/audiogid-api --base master --head fix/manifest-no-store-strict --title "fix(api): manifest Cache-Control no-store" --body "Step 13: git integration verified; manifest fix."

Write-Host "`nDone! Please check the output above for the PR URL."
