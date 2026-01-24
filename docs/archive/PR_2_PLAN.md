# IMPLEMENTATION PLAN — PR-2: Ingestion Skeleton

## 1. Schema Expansion
*   **Models**: Add `IngestionRun`, `PoiStaging`, `HelperPlace` to `apps/api/core/models.py`.
*   **Indexes**: Enforce tenant (`city_slug`) indexing on all new tables.
*   **Migration**: `0003_pr2_ingestion.py`.

## 2. Ingestion API (Admin)
*   **Enqueue Endpoints**:
    *   `POST /v1/admin/ingestion/osm/enqueue`: Triggers OSM import job.
    *   `POST /v1/admin/ingestion/helpers/enqueue`: Triggers Helpers import job.
*   **Idempotency**: Use `hash(type + city + date)` as `idempotency_key` for the Job.

## 3. Async Worker Layer
*   **Dispatch**: detailed logic in `POST /jobs/callback`.
*   **Handlers**: `apps/api/core/worker.py` containing:
    *   `process_osm_import(job)`
    *   `process_helpers_import(job)`
*   **Fail-Fast**: Worker checks for `OVERPASS_URL` env var (or strict default) and fails job if missing.

## 4. Documentation
*   **API**: Document new Admin endpoints.
*   **Runbook**: How to trigger ingestion and check logs.
*   **ADR-006**: Async Ingestion Design.

---

# Task Plan (PR-2)
1.  **Contract**: Add Admin Ingestion endpoints to `openapi.yaml`.
2.  **Models**: Define new tables in `models.py`.
3.  **Migration**: Generate schema migration `0003_pr2_ingestion.py`.
4.  **Worker**: Create `apps/api/core/worker.py` with scaffolding for Overpass/Helpers logic.
5.  **API**: Create `apps/api/api/ingestion.py` (Enqueue endpoints).
6.  **Callback**: Update `apps/api/api/index.py` to route to `worker.py`.
7.  **Client**: Regenerate SDK.
8.  **Docs**: Create `docs/adr/006-ingestion-async.md`, update `docs/api.md`, `docs/runbook.md`.

---

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
