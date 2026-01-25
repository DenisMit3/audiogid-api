Write-Host "Creating PR 14 (AI Narrations Foundation)..."
gh pr create --base master --head feat/ai-narrations --title "feat(audio): ai narration generation foundation" --body "PR 14: Implements the foundation for AI-generated audio narrations. Adds OpenAI TTS integration and Vercel Blob storage logic for POI audio tracks. Integrated with the Async Worker."
