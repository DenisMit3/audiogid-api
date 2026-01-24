# IMPLEMENTATION PLAN — PR-7: Tours & Catalog Foundation

## 1. Schema Updates
*   **Tour Model**: Upgrade existing `Tour` model.
    *   Add: `description_ru`, `duration_minutes`, `published_at`, `created_at`, `updated_at`.
    *   Deprecate/Drop: `is_published` (migrating to `published_at` pattern).
*   **New Relations**:
    *   `TourItem`: Links Tour to POI (ordered).
    *   `TourSource`: Attribution for the tour content itself.
    *   `TourMedia`: Images/Audio for the tour (Gate: License required).

## 2. Admin API (`/v1/admin/tours`)
*   **Endpoints**:
    *   `POST /` (Draft creation)
    *   `POST /{id}/sources`, `POST /{id}/media` (Attribution)
    *   `POST /{id}/items` (Add POIs to tour - wait, prompt didn't strictly list generic item management endpoints, but implied we need to check items. I should add at least a basic "Add Item" or "Set Items" endpoint to allow building a tour to test the gate. I will add `POST /{id}/items` to append an item).
    *   `POST /{id}/publish` (Strict Gate)
    *   `POST /{id}/unpublish`
    *   `GET /{id}/publish_check`
*   **Gates Logic**:
    *   `Tour.sources` count > 0.
    *   `Tour.media` count > 0 (checked for strict license fields).
    *   **Recursive Gate**: All `TourItem.poi.published_at` MUST be present. If a Tour includes an unpublished POI, Tour publish fails 422.

## 3. Public API (`/v1/public/tours`)
*   **List**: Filter `published_at IS NOT NULL`. Scope by `city`.
*   **Detail**: Return full tour info + items + media sources. Strict 404 if unpublished.
*   **Caching**: `ETag` + `Cache-Control: public, max-age=60`.

## 4. Documentation
*   **ADR-011**: Tours Publish Gates.
*   **Runbook**: Steps to create tour, fail publish (missing limits), fix, verify.

---

# Task Plan (PR-7)
1.  **Contract**: Update OpenAPI with Tour Admin endpoints & Public Detail schema.
2.  **Models**: Update `Tour` in `models.py` and define `TourItem`, `TourSource`, `TourMedia`.
3.  **Migration**: `0006_pr7_tours.py`.
4.  **Admin Logic**: Create `apps/api/api/admin_tours.py`.
5.  **Public Logic**: Update `apps/api/api/public.py`.
6.  **Router**: Mount `admin_tours` in `index.py`.
7.  **Client**: Regenerate.
8.  **Docs**: ADR-011, `api.md`, `runbook.md`.

---

# ADR-011: Tours Publish Gates

## Context
Tours are premium content products. They aggregate POIs. Licensing risks multiply when aggregating content.

## Decision
*   **Gate 1 (Attribution)**: Tour entity itself must have Source + Licensed Media (Cover image, etc.).
*   **Gate 2 (Constituency)**: A Tour cannot be published if ANY of its constituent POIs are unpublished.
    *   *Why?* It prevents broken user experiences (Tour Stop -> 404) and leaks unpublished data.
*   **Audit**: Publish actions logged with `actor_fingerprint`.

## Consequences
*   Publishing a Tour is a multi-step process: Publish all POIs first -> Add Tour Metadata -> Publish Tour.
*   Unpublishing a POI that is part of a Published Tour?
    *   *Current Scope*: We don't block POI unpublish, but the Tour Stop would likely break or disappear from API response if we join on published POIs. Ideally, we should warn, but for strict MVP, we focus on the Gate at Tour Publish time.
    *   *Runtime*: Public API `get_tour_detail` should gracefully handle or filter out stops that are unpublished (or 404 the stop), but the Tour itself remains published.
