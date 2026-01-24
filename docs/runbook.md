# Audio Guide 2026 — Master Runbook

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
