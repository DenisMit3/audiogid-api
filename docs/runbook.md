# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Env**: `STORE_SANDBOX` (Preview), `ADMIN_API_TOKEN` (Prod/Prev).

## Validation Procedures

### Offline Manifest (Entitled)
1.  **Prereq**: Ensure you have an Entitlement for `TOUR_ID` + `DEVICE_ID` (via Purchase Sandbox).
2.  **Request**:
    `GET /v1/public/tours/{TOUR_ID}/manifest?city=...&device_anon_id=DEVICE_ID`
    *Expect*: 200 OK. JSON contains `assets` list (URLs).

### Offline Manifest (Unpaid)
1.  **Request**:
    Same as above but with a random `device_anon_id`.
    *Expect*: 403 Forbidden.

### Audio Gate (Publishing)
1.  **Draft**: Create Tour with 1 POI.
2.  **Ensure POI has NO Audio** (only images).
3.  **Publish**: `POST /publish`.
    *Expect*: 422 JSON: `missing_requirements: ["audio_coverage"]`.
4.  **Fix**: Add Audio media to POI.
5.  **Publish**:
    *Expect*: 200 OK.

## Disaster Recovery
*   **Rollback**: Revert + Instant Rollback.
