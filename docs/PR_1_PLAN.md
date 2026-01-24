# IMPLEMENTATION PLAN — PR-1: Onboarding Data & Caching

## 1. Schema & Tenants (Day 1 Multi-City)
*   **Models**: Define `City`, `Tour`, `Poi` (and related join models) in `apps/api/core/models.py`.
*   **Tenancy**: Enforce `city_slug` Foreign Key on content tables.
*   **Migration**: Create `0002_pr1_schema.py` to:
    1.  Create tables.
    2.  **Seed Data**: Insert `kaliningrad_city` and `kaliningrad_oblast` into `cities`.

## 2. Public Read Layer (Offline-First Support)
*   **Endpoints**:
    *   `GET /v1/public/cities`: Returns list of available tenants.
    *   `GET /v1/public/tours`: Filtered by `city`.
    *   `GET /v1/public/catalog`: Filtered by `city` (POIs).
*   **Contract**: Update `openapi.yaml` with strict schemas; regenerate Dart Client.

## 3. Caching & Performance (Non-Negotiable)
*   **ETag Logic**: Implement a Dependency `check_etag` that:
    1.  Generates hash of the response data.
    2.  Compares with `If-None-Match`.
    3.  Raises `304 Not Modified` if match.
    4.  Sets `ETag` and `Cache-Control` headers on response.

## 4. Documentation
*   **API**: Document endpoints and response codes.
*   **Runbook**: Add validation steps for ETag.
*   **ADR**: Record caching strategy.

---

# Task Plan (PR-1)
1.  **Contract**: Add Public endpoints to `packages/contract/openapi.yaml`.
2.  **Models**: Define `City`, `Tour`, `Poi`, `PoiSource`, `PoiMedia`.
3.  **Migration**: Generate and edit migration to include seed data.
4.  **Utils**: Implement `apps/api/core/caching.py` (ETag helper).
5.  **API**: Implement `apps/api/api/public.py` using `Session` and `select`.
6.  **Integration**: Mount router in `apps/api/api/index.py`.
7.  **Client**: Regenerate SDK.
8.  **Docs**: Update `docs/api.md`, `docs/runbook.md`, create `docs/adr/005-public-caching.md`.

---

# ADR-005: Public API Caching Strategy

## Context
Mobile clients need to work offline-first. Downloading the entire catalog every launch is inefficient. We need a standard mechanism to tell the client "nothing changed".

## Decision
*   **Mechanism**: HTTP ETag + Conditional Requests.
*   **Implementation**:
    *   Server computes a strong ETag (SHA-256 hash) of the JSON serialization of the result set.
    *   Server checks `If-None-Match` header.
    *   If matches: Return `304 Not Modified` (body empty).
    *   If new: Return `200 OK` + `ETag` header + `Cache-Control: private, max-age=60`. (Short max-age allows frequent re-checks, relying on 304 for bandwidth saving).
*   **Scope**: All `GET /v1/public/*` endpoints.

## Consequences
*   **Bandwidth**: drastically reduced for repeating users.
*   **Compute**: Server still queries DB to compute hash (unless we implement higher-level cache, but DB query is cheap compared to payload transfer).
*   **Client**: Must store ETag and send `If-None-Match`.
