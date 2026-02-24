# IMPLEMENTATION PLAN — PR-6: Nearby Discovery

## 1. Schema & Indexes
*   **Strategy**: Use PostGIS for robust distance calculation (`geography` type). PostgreSQL + PostGIS on Cloud.ru.
    *   *Fallback if not available*: Haversine formula on indexed float lat/lon. 
    *   **Decision**: Attempt to enable PostGIS via migration. If fails, basic Haversine (ADR-010).
*   **Schema**: Add `location` column (Geography(Point)) to `Poi` and `HelperPlace`. Sync from lat/lon columns or existing data? Lat/Lon currently stored as floats?
    *   Wait, `Poi` model (PR-1) didn't have lat/lon explicitly mentioned in previous prompt context, only `HelperPlace` had it.
    *   *Correction*: I must check `Poi` model. If lat/lon missing, I must add them.
*   **Migration**: `0005_pr6_nearby.py` -> Add `lat`, `lon` (float) and `location` (geography) to `Poi`. Update `HelperPlace` to have `location`. Add GiST indexes.

## 2. API Endpoint
*   `GET /public/nearby`:
    *   Params: `city` (req), `lat` (req), `lon` (req), `radius` (def 1000m, max 5000m), `types` (poi, helper).
    *   Logic:
        1.  Query `Poi` (Published only) within radius using `ST_DWithin`.
        2.  Query `HelperPlace` with radius using `ST_DWithin`.
        3.  Merge, Sort by distance, Limit 50.
*   **Response**: Unified GeoJSON-like or custom list structure? Prompt implies "unified list". We'll use a `NearbyItem` schema.

## 3. Caching & Performance
*   **Cache-Control**: `private, max-age=10` or `no-store`. User location changes often; caching exact lat/lon queries is low hit-rate.
*   **Limits**: Radius max 5km. Limit 50 items. Fail 422 if radius > 5000.

## 4. Documentation
*   **ADR-010**: Geo Strategy (PostGIS Usage).
*   **Runbook**: Steps to validate `nearby` results.

---

# Task Plan (PR-6)
1.  **Contract**: Add `GET /public/nearby` to `openapi.yaml`.
2.  **Models**: Update `Poi` and `HelperPlace` with Geo columns in `models.py`.
3.  **Migration**: `0005_pr6_nearby.py` (Add columns + PostGIS extension + Indexes).
4.  **API**: Update `apps/api/api/public.py` with `get_nearby`.
5.  **Client**: Regenerate SDK.
6.  **Docs**: Create `docs/adr/010-geo-strategy.md`, update `docs/api.md` & `docs/runbook.md`.

---

# ADR-010: Geospatial Strategy

## Context
We need "Nearby" discovery for POIs and Helpers.

## Decision
*   **Engine**: PostGIS (Geometry/Geography type).
*   **Reasoning**: Provides efficient KNN/Radius queries via GiST indexes compared to bounding box + Haversine in app code. Supported by PostgreSQL + PostGIS on Cloud.ru.
*   **Columns**:
    *   `lat` / `lon` (float): Source of truth for simple inputs/outputs.
    *   `geom` (Geography Point): Derived/Synced column for queries.
*   **Fallback**: If `CREATE EXTENSION postgis` fails (unlikely), we use `ST_DistanceSphere` or Haversine formula in SQL.
*   **Privacy**: Randomized fuzzing? No, these are public POIs. User location is sent to server; we do NOT log user lat/lon in audit logs.
