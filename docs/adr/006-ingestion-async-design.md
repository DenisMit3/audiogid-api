# ADR-006: Async Ingestion & Idempotency

## Context
Ingestion of OSM data is heavy and must be robust against failures. We support multiple tenants (cities) and must prevent race conditions or duplicate runs.

## Decision
*   **Async-Only**: All ingestion is triggered via `enqueue` endpoints which return a `job_id` immediately.
*   **Idempotency Strategy**:
    *   Key construction: `{job_type}|{city_slug}|{boundary_ref}|{YYYY-MM-DD}`.
    *   Before Enqueue: Check DB for existing job with this key in `PENDING` or `RUNNING` state.
    *   If exists: Return existing `job_id` (409 Conflict or 200 OK with status).
*   **Staging Strategy**:
    *   Import writes to `PoiStaging` first.
    *   Promotion to public `Poi` is a separate step (Stage 4, future PR).

## Consequences
*   Prevents accidental "double click" triggers of heavy jobs.
*   Allows safely retrying the *callback* (QStash logic) because the *business logic* inside the worker will handle "already done" checks via `IngestionRun` tracking if needed, though QStash guarantees at-least-once delivery, so we must be idempotent.
