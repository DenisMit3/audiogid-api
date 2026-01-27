# Validation Runbook (Production)

To verify the health and billing integrity of the Production environment:

## End-to-End Validation
Run the PowerShell script from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate_ops.ps1
```

### Checks Performed:
1.  **Commit Sync**: Checks `/ops/commit` to verify the deployed version matches expectations.
2.  **Health Check**: Checks `/ops/health` (Database connectivity + Configuration).
3.  **Billing Restore Smoke Test**:
    -   Submits a dummy Google Restore Job.
    -   Polls the job status for up to 60 seconds.
    -   Expects `COMPLETED` state.
    -   Note: Since the token is dummy, the result might list errors, but the Job itself must succeed (resilience check).

## Troubleshooting
-   **Timeout (PENDING > 60s)**: Vercel Function might be sleeping, or QStash is delayed. Check QStash/Vercel logs.
-   **FAILED**: Inspect the `failed_items` in the response. If `invalid_token` is reported but the job marks as FAILED, verify the Error Policy. (Usually, invalid tokens result in COMPLETED with errors).
-   **500 Error**: Critical system failure (DB connection or unhandled exception).
