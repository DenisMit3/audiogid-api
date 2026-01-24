# PR TEMPLATE (USE LITERALLY)

PR Title: PR-2: Expansion - Ingestion Skeleton & Async Jobs

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Implement async ingestion scaffolding (OSM/Helpers) with staging tables and strict idempotency.
C) Interfaces in play: OpenAPI updated (Admin Enqueue endpoints), Job Callback routed to Worker.
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Schema**: Added `IngestionRun`, `PoiStaging`, `HelperPlace` tables via migration `0003_pr2_ingestion`.
- **API**: Implemented `POST /admin/ingestion/osm/enqueue` and `helpers/enqueue` with **security** (`X-Admin-Token`) and **idempotency**.
- **Async Pattern**: Updated `job_callback` to delegate to `apps/api/core/worker.py` logic.
- **Worker**: Implemented skeleton logic with **Fail-Fast** behavior (Jobs explicitly FAIL with "Not Implemented" instead of returning fake success).
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-006, updated `docs/api.md` (Admin Auth), updated Runbook.

Scope / Non-Goals
- **In Scope**: Ingestion Schema, Async Enqueue/Process Flow, Idempotency, Staging, Admin Security.
- **Out of Scope**: Real HTTP calls to Overpass (Phase 2b), Public POIs promotion (Stage 4).

Key Design Decisions
- **Security**: Admin endpoints guarded by `ADMIN_API_TOKEN` env var.
- **Fail-Fast**: Worker does not pretend to succeed; if logic/config is missing, Job is marked FAILED.
- **Idempotency**: Key derived from `{type}|{city}|{boundary_ref}|{date}`.
- **Staging**: Ingestion writes to `poi_ingestion_staging` to strictly separate raw data from public `poi`.

Docs Updated (docs-as-code)
- docs/api.md: Added Admin Ingestion endpoints and Auth requirements.
- docs/runbook.md: Added Ingestion verification steps.
- docs/adr/006-ingestion-async-design.md: Created.

Files Changed
- `apps/api/core/config.py`
- `apps/api/core/models.py`
- `apps/api/core/worker.py`
- `apps/api/api/ingestion.py`
- `apps/api/api/index.py`
- `apps/api/migrations/versions/0003_pr2_ingestion.py`
- `packages/contract/openapi.yaml`
- `docs/PR_2_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/006-ingestion-async-design.md`
- `packages/api_client/...` (Auto-generated content)

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Redeploy `api` project.
- Env vars to add/update:
    - `ADMIN_API_TOKEN` (Crucial new secret).
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  `GET https://<host>/v1/api/health` -> 200 OK.
    2.  `POST /v1/admin/ingestion/osm/enqueue` MUST fail 403/401 without Token.
    3.  `POST /v1/admin/ingestion/osm/enqueue` with Token -> 202 Accepted.
    4.  `GET /v1/jobs/{job_id}` -> Expect `FAILED` (Status: "Import Logic not yet implemented") - **Correct Behavior**.
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: New migration if staging tables are corrupt.

Validation step
- URLs:
  - <Preview URL> /v1/api/health
- Logs:
  - Vercel Logs: Confirm "NotImplementedError" logged by worker (proving execution).
  - QStash Logs: Confirm delivery.

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: done
- DB / migrations: done
- Security: done (Admin Token + Idempotency)
- Performance / caching: n/a
- Observability / ops: done
- Testing: n/a
- Mobile offline-first: n/a
- Publish gates: done
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: n/a
- Privacy / Data safety / deletion: n/a
- Docs-as-code: done
- No-local: done
