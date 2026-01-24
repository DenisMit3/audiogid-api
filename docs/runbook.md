# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Env Variables**: 
    *   `ADMIN_API_TOKEN` (Required)
    *   `STORE_SANDBOX` (Set to "true" for Preview/Testing)

## Validation Procedures

### Purchases (Sandbox Mode)
1.  **Prerequisite**: Ensure env var `STORE_SANDBOX=true`.
2.  **Create Intent**:
    `POST /v1/public/purchases/tours/intent`
    Body: `{"city_slug": "kaliningrad_city", "tour_id": "EXISTING_TOUR_UUID", "device_anon_id": "test-device-1", "platform": "ios", "idempotency_key": "ik-1"}`
    *Response*: `{"id": "INTENT_UUID", "status": "PENDING"}`.

3.  **Confirm (Success)**:
    `POST /v1/public/purchases/tours/confirm`
    Body: `{"intent_id": "INTENT_UUID", "platform": "ios", "store_proof": "SANDBOX_SUCCESS", "idempotency_key": "ik-confirm-1"}`
    *Response*: `{"status": "COMPLETED", "entitlement_granted": true}`.

4.  **Check Entitlements**:
    `GET /v1/public/entitlements?city=kaliningrad_city&device_anon_id=test-device-1`
    *Response*: JSON Array containing `EXISTING_TOUR_UUID`.

### Publishing Flow
(See PR-7 Runbook section)

## Disaster Recovery
*   **Rollback**: Revert + Instant Rollback.
