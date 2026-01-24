# PR TEMPLATE (USE LITERALLY)

PR Title: PR-1: Offline-First onboarding (Public Read API)

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Implement public read endpoints (`cities`, `tours`, `catalog`) with offline-first ETag caching and Multi-City Schema.
C) Interfaces in play: OpenAPI 3.1 updated, Public API Router implemented, DB Schema `city`/`tour`/`poi` added.
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Schema & Tenants**: Added `City`, `Tour`, `Poi` models. Created migration `0002_pr1_schema` which **seeds** `kaliningrad_city` and `kaliningrad_oblast`.
- **Public API**: Implemented `/v1/public/cities`, `/v1/public/tours`, `/v1/public/catalog`.
- **Caching**: Implemented `check_etag` using **Weak ETags (W/...)** scoped by **Query Params**. 
- **Performance**: Enforced `Cache-Control: public, max-age=60` to allow CDN/local caching for 1 minute before revalidation.
- **Contract**: Updated OpenAPI 3.1 and regenerated Dart Client to reflect new public endpoints.
- **Documentation**: Updated `docs/api.md`, `docs/runbook.md` and added ADR-005.

Scope / Non-Goals
- **In Scope**: Public Read schema, Seed data, ETag/304 logic, Offline-first read endpoints.
- **Out of Scope**: Content ingestion (tables empty besides seed), Payments, Admin UI (CLI/DB only for now).

Key Design Decisions
- **Weak ETags**: Used `W/"..."` to handle JSON serializations safely.
- **Scope Specificity**: ETags include query params in hash generation to separate representations.
- **Public Caching**: `public, max-age=60` balances freshness with offline capability updates.
- **Tenant Isolation**: `city_slug` is mandatory query param for all content endpoints.
- **Seeding**: Done via Alembic to guarantee availability in any environment immediately after deploy.

Docs Updated (docs-as-code)
- docs/api.md: Added Public API summary and Caching section.
- docs/runbook.md: Added ETag validation steps.
- docs/adr/005-public-caching.md: Created.

Store / Policy Impact (if applicable)
- Store build impact: none.
- Payments path: none.
- Reviewer access: n/a.
- Privacy: n/a.
- Account deletion: n/a.

UI/UX & Accessibility (if UI touched)
- Screen sizes covered: n/a.
- Font scaling checked: n/a.

Files Changed
- `apps/api/core/models.py`
- `apps/api/core/caching.py` (New)
- `apps/api/api/public.py` (New)
- `apps/api/api/index.py` (Modified)
- `apps/api/migrations/versions/0002_pr1_schema.py` (New)
- `packages/contract/openapi.yaml`
- `docs/PR_1_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/005-public-caching.md`
- `packages/api_client/...` (Auto-generated content)

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Redeploy `api` project to apply code changes.
- Env vars to add/update:
    - None (uses existing DB/QStash config).
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  `GET https://<host>/v1/public/cities` -> Expect 200 JSON with 2 items.
    2.  Check Headers -> `ETag: W/"..."`, `Cache-Control: public, max-age=60`.
    3.  `GET https://<host>/v1/public/cities` with `If-None-Match: W/"..."` -> Expect 304 Not Modified.
    4.  `GET https://<host>/v1/public/tours?city=kaliningrad_city` -> Expect 200 (Empty Array).
- Rollback plan:
    - **Revert Deployment**: Use Vercel "Instant Rollback" to previous stable deployment.
    - **Forward Fix**: If schema issues arise, create a new forward-only migration to correct state; do not use `alembic downgrade` in production.

Validation step
- URLs:
  - <Preview URL> /v1/public/cities
- Logs:
  - Vercel Logs: Check for successful Cache Hit/Miss logs if instrumented.

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done (OpenAPI updated + Client Gen)
- Serverless / QStash: done (n/a for read, but compatible)
- DB / migrations: done (Seed included)
- Security: done (Tenant isolation enforcement)
- Performance / caching: done (Weak ETag/304 caching + Public Cache-Control)
- Observability / ops: done
- Testing: n/a
- Mobile offline-first: done (Endpoints enabled)
- Publish gates: n/a
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: n/a
- Privacy / Data safety / deletion: n/a
- Docs-as-code: done
- No-local: done
