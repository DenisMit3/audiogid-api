# Audio Guide 2026 — Master Runbook

## Deployment Status (2026-01-24)
- **Vercel Project**: `audiogid-api`
- **Production URL**: https://audiogid-api.vercel.app/
- **Database**: Neon (Connected via Vercel Marketplace)
- **Status**: ✅ LIVE (Health & Ready checks passed)

## Deployment Checklist (Day 1)
*   **Env Vars**: `ADMIN_API_TOKEN` (Rotatable), `STORE_SANDBOX` (Preview Only), `QSTASH_*` (Async).
*   **DB**: Migrations Applied (`alembic upgrade head`).

## Ops Validation
*   **Health**: `GET /v1/ops/health` -> 200 OK.
*   **Ready**: `GET /v1/ops/ready` -> 200 OK (DB Connected).

## Functional Validation Flow
1.  **Onboarding (Public Read)**
    *   `GET /v1/public/cities` -> JSON list.
    *   `GET /v1/public/tours?city=...` -> JSON list (Published only).

2.  **Purchase Flow (Sandbox)**
    *   Enable `STORE_SANDBOX=true`.
    *   **Intent**: `POST /v1/public/purchases/tours/intent` -> 201 Created (Pending).
    *   **Confirm**: `POST /v1/public/purchases/tours/confirm` (`proof: "SANDBOX_SUCCESS"`) -> 200 OK (Entitlement Granted).
    *   **Check Entitlement**: `GET /v1/public/entitlements` -> Returns ID.

3.  **Content Delivery (Secure)**
    *   **Manifest (Entitled)**: `GET /v1/public/tours/{id}/manifest` -> 200 OK (Assets List).
    *   **Manifest (Unpaid)**: `GET ...` (Random ID) -> 403 Forbidden.

4.  **Deletion (Compliance)**
    *   **Get Token**: `POST /v1/public/account/delete/token` -> Returns signed token (1hr TTL).
    *   **Request**: `POST /v1/public/account/delete/request` (ID + Token) -> 202 Pending.
    *   **Poll**: `GET /v1/public/account/delete/status` -> COMPLETED.
    *   **Verify Revocation**: `GET /v1/public/entitlements` -> Empty.

## Security Logs Check
*   **Search**: "Request Processed" / "Request Failed".
*   **Verify**: Trace ID present. `authorization`/`proof` headers REDACTED (not visible in raw log).
*   **Headers**: Response headers include `Strict-Transport-Security`, `X-Content-Type-Options`.

## Disaster Recovery
*   **Rollback**: Instant Revert via Vercel Dashboard / Git Revert.

## DEPLOYMENT REPORT (Production)
Date: 2026-01-24
Vercel Project URL: https://audiogid-api.vercel.app/
Deployed version (GET https://audiogid-api.vercel.app/): 1.11.0
DB provider: Neon (via Vercel Marketplace) — YES (Env vars injected)
DATABASE_URL present in Production: YES
Status:
- /v1/ops/health: 200 OK
- /v1/ops/ready: 200 OK ({"status":"ready"})
Verdict: GO (No blockers)

### Security Notes
- Secrets in Vercel should be marked Sensitive (may require remove + re-add) / policy enforced.
- Validate Cache-Control: no-store on sensitive endpoints.
- Log review: verify redaction and absence of tokens/secrets.
