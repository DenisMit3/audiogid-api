# PR TEMPLATE (USE LITERALLY)

PR Title: PR-4: Expansion - Helpers Import & Map Attribution

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Implement Real OSM ingestion for Helpers (toilets/water/cafe) and Public Map Attribution config.
C) Interfaces in play: OpenAPI updated (`/public/map/attribution`, `/public/helpers`), Worker logic expanded.
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Logic**: Implemented `_process_helpers_import` in `worker.py` (Overpass -> `HelperPlace` upsert). Added boundary mapping fallback for Kaliningrad.
- **Public API**: Added `/public/map/attribution` (Returns compliant ODbL/OSM info + ETag) and `/public/helpers` (filtered list).
- **Safety**: Helpers import uses Overpass timeouts and atomic DB commits.
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-008 (Helpers/Attribution), updated `docs/api.md` (physically included) and `docs/runbook.md`.

Scope / Non-Goals
- **In Scope**: Helpers ingestion (async), Helper retrieval (public), Map Attribution (public).
- **Out of Scope**: Dynamic Administrative Boundary resolution (currently hardcoded/config-based per tenant for Day 1), Tour content.

Key Design Decisions
- **Separation**: Helpers stored in dedicated `helper_places` table, not mixed with curated POIs.
- **Attribution**: Centralized API endpoint providing strict OSM/ODbL compliance text/links.
- **Data Freshness**: Public endpoints always serve last persisted DB state; no fake fallbacks.

Docs Updated (docs-as-code)
- docs/api.md: Added Map Attribution and Helpers endpoints.
- docs/runbook.md: Added Helpers validation.
- docs/adr/008-helpers-attribution.md: Created.

Files Changed
- `apps/api/core/worker.py`
- `apps/api/api/map.py` (New)
- `apps/api/api/index.py`
- `packages/contract/openapi.yaml`
- `docs/PR_4_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/008-helpers-attribution.md`
- `packages/api_client/...`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Redeploy `api` project.
- Env vars to add/update:
    - None (Uses existing `OVERPASS_API_URL` and `ADMIN_API_TOKEN`).
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  `GET /v1/public/map/attribution?city=kaliningrad_city` -> 200 OK + "OpenStreetMap contributors" text.
    2.  `POST /v1/admin/ingestion/helpers/enqueue` (Auth required) -> 202 Accepted.
    3.  Wait for Job `COMPLETED`.
    4.  `GET /v1/public/helpers?city=kaliningrad_city&category=toilet` -> JSON List > 0 items.
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: Fix worker logic.

Validation step
- URLs:
  - <Preview URL> /v1/public/map/attribution
- Logs:
  - Vercel Logs: "Overpass API Success" for Helpers job.

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: done
- DB / migrations: done (Schema existed, Logic added)
- Security: done
- Performance / caching: done (ETag on public endpoints)
- Observability / ops: done
- Testing: n/a
- Mobile offline-first: done
- Publish gates: n/a
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: done (Attribution included)
- Privacy / Data safety / deletion: n/a
- Docs-as-code: done
- No-local: done
