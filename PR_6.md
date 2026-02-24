# PR TEMPLATE (USE LITERALLY)

PR Title: PR-6: Features - Public Nearby Discovery (PostGIS Geography)

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Implement Public Nearby Endpoint using **PostGIS geography type**.
C) Interfaces in play: `GET /public/nearby`.
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Logic**: Implemented `get_nearby` using `ST_DWithin` (radius in meters) on `geography` type.
- **Schema**: Enabled `postgis`. Added `geo` (geography[Point, 4326]) and GiST indexes to `Poi` and `HelperPlace`.
- **Ingestion**: Worker writes `geo` column via `WKTElement`.
- **Security**: Logs redacted.
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-010 (PostGIS Geography), updated docs.

Scope / Non-Goals
- **In Scope**: PostGIS setup, Nearby using Geography type.
- **Out of Scope**: Geometry type (using Geography for native meter support).

Key Design Decisions
- **Geography Type**: Used `geography` instead of `geometry` to ensure all radius/distance operations are naturally in meters, avoiding SRID projection confusion.
- **PostGIS**: Enabled via migration `CREATE EXTENSION IF NOT EXISTS`.

Docs Updated (docs-as-code)
- docs/api.md: Added Nearby endpoint.
- docs/runbook.md: Added PostGIS validation steps.
- docs/adr/010-geo-strategy.md: Created/Updated.

Files Changed
- `apps/api/requirements.txt`
- `apps/api/core/models.py`
- `apps/api/core/worker.py`
- `apps/api/api/public.py`
- `apps/api/migrations/versions/0005_pr6_nearby.py`
- `packages/contract/openapi.yaml`
- `docs/PR_6_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/010-geo-strategy.md`
- `packages/api_client/...`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Cloud.ru**: Confirm PostGIS is installed.
    - **Cloud.ru**: Redeploy `api`.
- Env vars to add/update:
    - None.
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  `GET /v1/public/nearby?city=kaliningrad_city&lat=54.7&lon=20.5&radius_m=2000`
    2.  Expect 200 OK.
    3.  Check Logs: "Nearby Query" present, redacted.
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: Drop `geo` columns.

Validation step
- URLs:
  - <Preview URL> /v1/public/nearby
- Logs:
  - Vercel Logs: "Nearby Query" (Redacted).

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: n/a
- DB / migrations: done (PostGIS Geography)
- Security: done
- Performance / caching: done
- Observability / ops: done
- Testing: n/a
- Mobile offline-first: done
- Publish gates: done
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: n/a
- Privacy / Data safety / deletion: done
- Docs-as-code: done
- No-local: done
