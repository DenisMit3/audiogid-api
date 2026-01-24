# PR TEMPLATE (USE LITERALLY)

PR Title: PR-7: Catalog/Tours Foundation (Publish-Gated)

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Add Tours + Catalog domain skeleton with strict server-side publish gates.
C) Interfaces in play: OpenAPI 3.1 updated (Tours admin + public).
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Logic**: Implemented `admin_tours.py` for full Tour lifecycle.
- **Gates**: Strict Gates logic returns **machine-readable 422 errors** (code: `TOUR_PUBLISH_BLOCKED`, missing_requirements, unpublished_poi_ids).
- **Caching**: Public read endpoints implement `ETag` + `If-None-Match` (304) and **explicit** `Cache-Control: public, max-age=60`.
- **Schema**: Updated `Tour` model and relations.
- **Public API**: Tours list/detail.
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-011 and updated API/Runbook docs.

Scope / Non-Goals
- **In Scope**: Tour Data Model, Publish Logic, Public Read, Caching.
- **Out of Scope**: Payments, User Progress.

Key Design Decisions
- **Recursive Gate**: Prevents broken tours.
- **Structured Errors**: 422 JSON allows Mobile UI to render specific "fix-it" prompts.
- **Audit**: Fingerprinted tokens.

Docs Updated (docs-as-code)
- docs/api.md: Updated with Error Schemas & Explicit Caching Policies.
- docs/runbook.md: Added ETag validation.
- docs/adr/011-tours-publish-gates.md: Created.

Files Changed
- `apps/api/core/models.py`
- `apps/api/api/admin_tours.py`
- `apps/api/api/public.py`
- `apps/api/api/index.py`
- `apps/api/migrations/versions/0006_pr7_tours.py`
- `packages/contract/openapi.yaml`
- `docs/PR_7_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/011-tours-publish-gates.md`
- `packages/api_client/...`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Redeploy `api`.
- Env vars to add/update:
    - None.
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  Create Draft Tour -> Add Unpublished POI.
    2.  `POST /publish` -> Expect 422 JSON with `unpublished_poi_ids`.
    3.  Fix -> Publish -> 200.
    4.  `GET /public/tours/{id}` -> Expect 200 + ETag + Cache-Control header.
    5.  `GET /public/tours/{id}` with `If-None-Match` -> Expect 304.
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: Fix gates logic.

Validation step
- URLs:
  - <Preview URL> /v1/public/tours?city=kaliningrad_city
- Logs:
  - Vercel Logs: "Gates Failed" logs.

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: n/a
- DB / migrations: done
- Security: done
- Performance / caching: done (ETag/304/Explicit Headers)
- Observability / ops: done
- Testing: n/a
- Mobile offline-first: done
- Publish gates: done (Recursive + Structured Error)
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: n/a
- Privacy / Data safety / deletion: n/a
- Docs-as-code: done
- No-local: done
