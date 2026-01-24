# IMPLEMENTATION PLAN — PR-3: Real OSM Ingestion

## 1. Dependencies & Infrastructure
*   **Deps**: Add `httpx` to `requirements.txt` (required for Overpass calls).
*   **Config**: Add `OVERPASS_API_URL` (default: `https://overpass-api.de/api/interpreter`) to config.

## 2. Async Worker Logic (Real Implementation)
*   **Handler**: Update `_process_osm_import` in `apps/api/core/worker.py`.
*   **Overpass QL**: Construct query using `boundary_ref` (OSM Relation ID).
    *   Query: `[out:json][timeout:25]; rel({id}); map_to_area->.a; (node["tourism"](area.a); way["tourism"](area.a); relation["tourism"](area.a);); out center;`
*   **Network**: Execute POST to Overpass. Handle timeouts/non-200.
*   **Staging Write**:
    *   Iterate results.
    *   Extract: `osm_id` (type+id), `name:ru` (or name), raw `tags`.
    *   **Upsert**: Check if `osm_id` exists in `PoiStaging` for this `city_slug`. Update or Insert.
*   **Stats**: Update `IngestionRun` with count of processed items.

## 3. Admin Inspection Endpoints
*   **Endpoint**: `GET /v1/admin/ingestion/runs` (List recent runs).
*   **Contract**: Update OpenAPI to include this debug/inspection endpoint.

## 4. Documentation
*   **ADR-007**: Overpass Import Strategy (Timeouts, Vercel Constraints).
*   **Runbook**: Update with "How to validate Staging data".

---

# Task Plan (PR-3)
1.  **Deps**: Update `apps/api/requirements.txt`.
2.  **Config**: Update `apps/api/core/config.py` (Overpass URL).
3.  **Contract**: Add `GET /admin/ingestion/runs` to `openapi.yaml`.
4.  **API**: Implement `get_ingestion_runs` in `apps/api/api/ingestion.py`.
5.  **Worker**: Implement real `_process_osm_import` in `apps/api/core/worker.py`.
6.  **Client**: Regenerate SDK.
7.  **Docs**: Create `docs/adr/007-overpass-import.md`, update `docs/runbook.md`.

---

# ADR-007: Overpass Import Strategy

## Context
We need to import POIs from OpenStreetMap for specific cities. Vercel Functions have a hard timeout (10s on Hobby, 60s on Pro). Overpass API can be slow.

## Decision
*   **Query Strategy**: Use `map_to_area` derived from the Administrative Boundary Relation ID. This limits the search strictly to the city.
*   **Timeout Management**:
    *   Set Overpass `[timeout:25]` (seconds).
    *   If query exceeds time, Overpass kills it.
    *   If Vercel kills us first, the Job remains `RUNNING` (stale) or we catch `asyncio.CancelledError` if possible.
    *   *Mitigation*: We accept that large cities might fail on Serverless and require a dedicated runner or breaking into tiles (Future work). For Day 1 (Kaliningrad), 25s is usually sufficient.
*   **Staging Upsert**:
    *   We write to `PoiStaging` using `city_slug` + `osm_id` as unique constraint.
    *   We do *not* delete old POIs in this step (Append/Update only).

## Consequences
*   Imports are atomic per-job but "Eventual Consistency" in Staging.
*   Large areas might require custom Overpass instance or smaller bounding boxes.
