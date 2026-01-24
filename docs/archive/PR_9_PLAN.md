# IMPLEMENTATION PLAN — PR-9: Secure Content Delivery (Offline Manifests)

## 1. Goal
Enable "Offline-First" Audio Guide experience by allowing entitled users to download the full tour package (Metadata + POI Details + Audio/Image Assets). Enforce "Audio Guide" quality by gating Tour Publish on presence of Audio.

## 2. API Schema
*   `GET /v1/public/tours/{id}/manifest`:
    *   **Params**: `city`, `device_anon_id`.
    *   **Security**: Checks `Entitlements` table. If no active entitlement -> **403 Forbidden**.
    *   **Response**: `TourManifest` object.
        *   `tour`: Full metadata.
        *   `pois`: List of full POI objects (Title, Description, Coords).
        *   `assets`: List of downloadable files `{url, type, hash, size}` (Aggregated from Tour Media + POI Media).
*   **Updates**: 
    *   `PoiRead` / `PoiDetail` schema update (ensure `description_ru` is present - wait, `Poi` model has `description`? Let's check. `Poi` has `title_ru`. PR-7 didn't add description to POI? PR-1 `Poi` model was `title_ru`. I might need to add `description_ru` to POI if it's missing!).
    *   *Correction*: Check `models.py`. `Poi` has `title_ru`, `published_at`, `lat`, `lon`... NO `description_ru`!
    *   **Task**: Add `description_ru` to `Poi` model (Migration required). An Audio Guide POI needs a text description too.

## 3. Strict Gates (Refinement)
*   **Audio Gate**: A `Tour` cannot be published unless **every** linked `Poi` has at least one `media` entry with `media_type='audio'`.
    *   *Why?* It's an "Audio Guide". A silent tour is a broken product.

## 4. Documentation
*   **ADR-013**: Offline Manifest Strategy.
*   **Runbook**: Validate Manifest download (403 vs 200).

---

# Task Plan (PR-9)
1.  **Models**: Add `description_ru` to `Poi`. Fix `Media` assumption (ensure 'audio' type is supported/used).
2.  **Migration**: `0008_pr9_poi_desc.py`.
3.  **Admin Logic**: Update `check_publish` in `admin_tours.py` to verify POI Audio.
4.  **Public Logic**: Implement `get_tour_manifest` in `public.py`.
5.  **Contract**: Update OpenAPI (`/manifest`, `Poi` schema).
6.  **Docs**: ADR-013, `api.md`, `runbook.md`.

---

# ADR-013: Offline Manifests & Audio Gates

## Context
Users pay for Tours. They need to download them for offline use (roaming/connection issues). The "Product" is the content.

## Decision
*   **Manifest Endpoint**: A consolidated endpoint returns *all* necessary data to render the tour offline.
*   **Entitlement Check**: The Manifest is the "Premium" asset. It is strictly gated by `Entitlement`.
*   **Audio Mandate**: We contractually enforce that every Stop (POI) in a Tour has an Audio track before the Tour can be published.
*   **Asset Aggregation**: The Manifest provides a flat list of URL assets to simplify the mobile client's "Download All" logic.

## Consequences
*   Mobile client must implement a "Download Manager".
*   Server handles "packaging" logic (aggregating URLs).
*   Ensures users can't "scrape" the full tour content just by querying the public detail endpoint.
