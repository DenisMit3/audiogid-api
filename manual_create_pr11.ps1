Write-Host "Please ensure you are logged in to GitHub CLI ('gh auth login')."
Write-Host "Creating PR 11 (Audio Security / Narrations)..."

gh pr create --base master --head feat/audio-security --title "feat(content): narration schema & manifest integration" --body "PR 11: Adds Narration table (Audio) and integrates them into the secured Manifest. Also adds AssetSigner foundation."

Write-Host "Done. Check output for PR URL."
