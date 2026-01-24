# IMPLEMENTATION PLAN — PR-5: Publish Gates & Audit

## 1. Schema Expansion
*   **Models**: Update `Poi` to include `published_at` (nullable).
*   **Dependencies**: Add `PoiSource`, `PoiMedia`, `AuditLog` tables.
*   **Constraints**: `PoiSource` and `PoiMedia` foreign keys to `Poi`. Strict license fields on `PoiMedia`.
*   **Migration**: `0004_pr5_gates.py`.

## 2. Admin API
*   **Workflow**:
    *   `POST /admin/pois/{id}/sources`: Add source metadata.
    *   `POST /admin/pois/{id}/media`: Add media with license info.
    *   `POST /admin/pois/{id}/publish`: Transactional check + update.
    *   `GET /admin/pois/{id}/publish_check`: Dry-run validation.
*   **Security**: Guard with `ADMIN_API_TOKEN`.

## 3. Public API (Visibility Enforcement)
*   **Filter**: Update `get_catalog` / `get_tours` / `get_poi` to strictly filter by `published_at IS NOT NULL`.
*   **Detail View**: Implement `GET /public/poi/{id}`.

## 4. Documentation
*   **ADR-009**: Publish Gates Strategy.
*   **Runbook**: Steps to debug blocked publishing.

---

# Task Plan (PR-5)
1.  **Contract**: Add Admin Publish endpoints & Public POI detail to `openapi.yaml`.
2.  **Models**: Define `PoiSource`, `PoiMedia`, `AuditLog`. Updating `Poi`.
3.  **Migration**: Generate `0004_pr5_gates.py`.
4.  **API**: Implement `apps/api/api/publish.py` covering Admin inputs + Publish Logic.
5.  **Public**: Update `apps/api/api/public.py` to enforce visibility + add detail view.
6.  **Router**: Mount publish router in `apps/api/api/index.py`.
7.  **Client**: Regenerate SDK.
8.  **Docs**: Create `docs/adr/009-publish-gates.md`, update `docs/runbook.md`.

---

# ADR-009: Publish Gates & Licensing Compliance

## Context
We aggregate content from multiple sources (OSM, Wikipedia, manual). We must strictly respect licenses (CC BY-SA, ODbL). Publishing bare content without attribution is a legal risk.

## Decision
*   **Hard Gate**: A POI *cannot* be set to `published` status unless:
    1.  It has at least one associated `PoiSource` record (e.g., "OpenStreetMap" or "Wikipedia").
    2.  It has at least one associated `PoiMedia` record, AND that media record has valid `license`, `author`, and `source_url` fields.
*   **Audit Trail**: Every publish/unpublish action is logged to `audit_logs` with the actor (Admin Token ID) and timestamp.
*   **Idempotency**: Publishing an already published POI is a no-op (200 OK).

## Consequences
*   Content ingestion (Stage 1) does not automatically result in live content. A secondary "enrichment & review" step (Stage 2/3) is required to add sources/media before Stage 4 (Publishing) can succeed.
*   Public API queries become slightly more complex (`WHERE published_at IS NOT NULL`).
