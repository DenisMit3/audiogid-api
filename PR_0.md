# PR TEMPLATE (USE LITERALLY)

PR Title: Foundation: Monorepo, OpenAPI, Serverless Async Core

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Establish strictly typed, serverless, async-capable infrastructure.
C) Interfaces in play: OpenAPI 3.1 (Source of Truth), Job Table (New).
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Infrastructure**: Established Monorepo (`apps/admin`, `apps/api`, `packages/contract`).
- **Contract**: Defined `packages/contract/openapi.yaml` (v1.0.0) + CI Fail-on-Diff Workflow.
- **Client**: Added generated Dart client artifacts in `packages/api_client` matching OpenAPI.
- **Core API**: Implemented Fail-fast Config (`AppConfig`), `Job` SQLModel, and Basic Middleware.
- **Async Pattern**: Implemented `enqueue_job` utility and `/api/internal/jobs/callback` checkpoint with **QStash Signature Verification** and **Idempotency**.
- **Database**: Configured SQLModel + Alembic (`alembic.ini`, `env.py`) and added Initial Migration `0001_initial.py`.
- **Documentation**: Physically created ADR-001 through ADR-004 and Implementation Plan.

Scope / Non-Goals
- **In Scope**: Repo structure, Config validation, Async Core definitions/verification, OpenAPI spec, CI checks, DB Migrations.
- **Out of Scope**: Actual business logic (Tours, POIs), Frontend implementation, Payment integration.

Key Design Decisions
- **Fail-Fast**: API refuses to boot if `DATABASE_URL`, `QSTASH_TOKEN`, or `SIGNING_KEYs` are missing.
- **OpenAPI-First**: `openapi.yaml` is the source of truth; CI fails if client generated code drifts.
- **Serverless Async**: `enqueue_job` insists on `PENDING` DB state; Callback verifies QStash signature and checks `idempotency_key`.

Docs Updated (docs-as-code)
- docs/api.md: Referenced OpenAPI spec.
- docs/runbook.md: Added Env Var requirements.
- docs/adr/001-init-monorepo.md: Created.
- docs/adr/002-openapi-first.md: Created.
- docs/adr/003-serverless-async.md: Created.
- docs/adr/004-fail-fast-config.md: Created.

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
- `package.json` / `pnpm-workspace.yaml` / `.gitignore`
- `.github/workflows/ci.yml`
- `apps/admin/package.json`
- `apps/api/api/index.py`
- `apps/api/core/config.py`
- `apps/api/core/middleware.py`
- `apps/api/core/models.py`
- `apps/api/core/database.py` (New)
- `apps/api/core/async_utils.py`
- `apps/api/requirements.txt`
- `apps/api/alembic.ini` (New)
- `apps/api/migrations/env.py` (New)
- `apps/api/migrations/versions/0001_initial.py` (New)
- `packages/contract/openapi.yaml`
- `packages/api_client/package.json`
- `packages/api_client/lib/api_client.dart` (New)
- `packages/api_client/lib/api/health_api.dart` (New)
- `scripts/generate-client.sh`
- `docs/PR_0_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/001-init-monorepo.md`
- `docs/adr/002-openapi-first.md`
- `docs/adr/003-serverless-async.md`
- `docs/adr/004-fail-fast-config.md`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Create Project "api", link to `apps/api`.
    - **Vercel**: Create Project "admin", link to `apps/admin`.
    - **Vercel Postgres**: Create Database, attach to "api".
    - **Upstash**: Create QStash database, get Tokens.
- Env vars to add/update:
    - `DATABASE_URL` (From Neon/Vercel Postgres)
    - `QSTASH_TOKEN` (From Upstash Console)
    - `QSTASH_CURRENT_SIGNING_KEY` (From Upstash Console)
    - `QSTASH_NEXT_SIGNING_KEY` (From Upstash Console)
    - `PUBLIC_APP_BASE_URL` (Domain of the deployed API)
- vercel.json snippet (if needed): n/a for v1.
- QStash setup: None manually; handled by API logic.
- Validate:
    - Open `https://<api-url>/api/health`.
    - Expect `500 Server Error` (or specific Runtime Error in logs) if Env Vars are missing (PROVES Fail-fast).
    - Add Env Vars, Redeploy.
    - Expect `200 OK`.
- Rollback plan:
    - Delete Vercel Projects.

Validation step
- URLs:
  - <Preview URL> /api/health
- Logs:
  - Vercel Function Logs: Check for "CRITICAL: Missing environment variable" during first boot attempts without config.
  - QStash logs: Check for callback delivery attempts.

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done (OpenAPI YAML + CI Workflow + Generated Artifacts)
- Serverless / QStash: done (Job model + Enqueue + Callback Verification)
- DB / migrations: done (SQLModel + Alembic + Initial Migration)
- Security: done (Fail-fast config + Sig verification)
- Performance / caching: n/a
- Observability / ops: done (Middleware)
- Testing: n/a (Foundation)
- Mobile offline-first: n/a
- Publish gates: n/a
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: n/a
- Privacy / Data safety / deletion: n/a
- Docs-as-code: done (Plan + ADRs physical files)
- No-local: done (Strict Vercel/Cloud-only)
