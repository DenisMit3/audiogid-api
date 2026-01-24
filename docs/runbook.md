# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Env**: `ADMIN_API_TOKEN`, `STORE_SANDBOX`.

## Validation Procedures

### Deletion Flow (Data Safety)
1.  **Create Entitlement**: Purchase a tour (Sandbox) for `test-delete-1`.
2.  **Verify Active**: `GET /entitlements?device_anon_id=test-delete-1` -> Returns tour.
3.  **Request Deletion**:
    `POST /v1/public/account/delete/request`
    Body: `{"subject_id": "test-delete-1", "idempotency_key": "del-1"}`
    *Response*: `{"id": "REQ_ID", "status": "PENDING"}`.
4.  **Wait**: Job processes in background (simulated or real worker).
5.  **Poll Status**:
    `GET /v1/public/account/delete/status?deletion_request_id=REQ_ID`
    *Expect*: `status: "COMPLETED"`.
6.  **Verify Revocation**:
    `GET /entitlements?device_anon_id=test-delete-1`
    *Expect*: Empty list `[]`.

### Web Deletion Form
1.  **Visit**: `/v1/delete` in browser.
2.  **Submit**: Form with ID.
3.  **Result**: HTML page confirmation.

## Disaster Recovery
*   **Rollback**: Revert + Instant Rollback.
