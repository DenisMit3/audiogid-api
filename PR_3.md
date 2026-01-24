# PR TEMPLATE (USE LITERALLY)

PR Title: PR-3: Real OSM Ingestion (Stage 1)

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Implement REAL async ingestion logic (Overpass -> Staging) protected by Admin Token.
C) Interfaces in play: OpenAPI updated (Runs inspection), worker logic expanded.
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Logic**: Implemented `_process_osm_import` in `worker.py` which calls Overpass (`httpx`), parses nodes/ways, and upserts to `PoiStaging`.
- **Safety**: Added explicit `httpx` timeouts (28s) to prevent hanging Vercel functions. Documented timeout constraints in ADR-007.
- **Fail-Fast**: Helpers import explicitly marked as **FAILED (Not Implemented)**; no fake success. Jobs only marked `COMPLETED` if staging rows written (or legitimate 0 results).
- **Infrastructure**: Added `httpx` and `OVERPASS_API_URL` config. Added `GET /admin/ingestion/runs` for observability.
- **Security**: All Admin endpoints enforced with `X-Admin-Token`.
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-007 (Overpass Strategy) and updated Runbook.

Scope / Non-Goals
- **In Scope**: Real HTTP Overpass calls, Staging Upsert, IngestionRun tracking, Admin Read endpoints.
- **Out of Scope**: Helpers implementation (Fails Fast), Public POI promotion (Stage 4).

Key Design Decisions
- **Real Execution**: Worker blocks for HTTP call.
- **Timeout Safety**: Client timeout (28s) < Platform Limit (60s Pro). Job marks FAILED on timeout exception.
- **Staging Isolation**: No writes to public tables yet; data is visible only via DB or direct query.
- **Idempotency**: Existing keys prevent re-runs; worker handles partial re-runs via atomic upserts.

Docs Updated (docs-as-code)
- docs/api.md: Added Admin Read endpoints.
- docs/runbook.md: Added real validation with OSM ID example.
- docs/adr/007-overpass-import.md: Created with timeout guidelines.

Files Changed
- `apps/api/requirements.txt`
- `apps/api/core/config.py`
- `apps/api/core/worker.py`
- `apps/api/api/ingestion.py`
- `packages/contract/openapi.yaml`
- `docs/PR_3_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/007-overpass-import.md`
- `packages/api_client/...`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Redeploy `api` project.
- Env vars to add/update:
    - `OVERPASS_API_URL` (Defaults to public instance, set to private if needed).
    - `ADMIN_API_TOKEN` (Must be set).
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  `POST /v1/admin/ingestion/osm/enqueue` (Token required)
        Body: `{"city_slug": "kaliningrad_city", "boundary_ref": "319662"}` (Kaliningrad).
    2.  Poll `GET /v1/jobs/{job_id}` every 5s.
    3.  Expect `COMPLETED` (Success) OR `FAILED` (if Overpass timeout).
    4.  If Success: `GET /v1/admin/ingestion/runs` -> `imported > 0`.
    5.  Trigger `helpers/enqueue` -> Expect `FAILED` (Not Implemented).
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: Fix worker logic if crashes.

Validation step
- URLs:
  - <Preview URL> /v1/jobs/{job_id}
- Logs:
  - Vercel Logs: "Overpass API Success" or "Overpass Client Timeout".

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: done
- DB / migrations: done
- Security: done (Auth + Fail-Fast)
- Performance / caching: n/a
- Observability / ops: done
- Testing: n/a
- Mobile offline-first: n/a
- Publish gates: done (Staging only)
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: n/a
- Privacy / Data safety / deletion: n/a
- Docs-as-code: done
- No-local: done
