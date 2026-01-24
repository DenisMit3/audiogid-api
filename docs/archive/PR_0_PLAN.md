# IMPLEMENATION PLAN — Audio Guide 2026 (Refined)

## 1. Foundation & Contracts (Current PR)
*   **Monorepo**: Workspaces for `apps/admin`, `apps/api`, `packages/api_client`.
*   **OpenAPI 3.1**: `packages/contracts/openapi.yaml` is source of truth.
*   **Client Gen**: Scripts to generate TypeScript/Dart clients; enforce CI check.
*   **Serverless Core**:
    *   **Async/Jobs**: `jobs` table + state machine + QStash enqueue/callback handlers.
    *   **Fail-fast Config**: Application boot strictly verifies `DATABASE_URL`, `QSTASH_TOKEN`, `QSTASH_CURRENT_SIGNING_KEY`.
    *   **Observability**: JSON logging middleware with `trace_id`.

## 2. Data Layer & Migrations (Next)
*   **Schema**: `tenants`, `users`, `poi`, `tours` tables.
*   **Migrations**: Alembic setup with auto-generation from SQLModel.
*   **Seed**: Initial mandatory tenants (`kaliningrad_city`, `kaliningrad_oblast`).

## 3. Ingestion & Content Security (Phase 3)
*   **Policy Enforcer**: Logic to reject publish if `sources` or `license` missing.
*   **Import Job**: Async job to fetch OSM data -> process -> insert helpers/poi.

## 4. Client Vertical Slice (Phase 4)
*   **Mobile**: Flutter setup + Generated Client integration.
*   **Offline**: SQLite Sync logic.

---

# Task Plan (PR-0 Foundation)
1.  **Contracts**: Create `packages/contract/openapi.yaml`.
2.  **API Core**: Setup `apps/api` with FastAPI, SQLModel, and Fail-fast Config.
3.  **Async Engine**: Implement `Job` parsing, `QStash` client wrapper, and Callback endpoint in `apps/api`.
4.  **Client Gen**: Create `packages/api_client` structure and `scripts/generate-client.sh`.
5.  **Admin Scaffolding**: Basic `apps/admin` (Next.js) linking to `api_client` (conceptually).
6.  **Docs**: Obligatory ADRs and Runbook updates.

---

# ADR-001: Monorepo & Technology Stack

## Context
Project requires a managed Admin web UI, a serverless API, and shared type definitions/clients for a multi-platform (Web + Mobile) environment. NFRs dictate Vercel deployment, Strict Typing, and Fail-fast behavior.

## Decision
*   **Monorepo**: npm workspaces.
*   **Admin**: Next.js App Router (Vercel).
*   **API**: Python FastAPI (Vercel Runtime).
*   **Contracts**: OpenAPI 3.1 manually maintained in `packages/contract`.
*   **Client Generation**: `openapi-typescript` / `openapi-generator` driven by scripts.

## Consequences
*   Single commit ensures API <-> Client sync.
*   Vercel handles build/deploy of multiple apps from one repo.

---

# ADR-002: OpenAPI-First Strategy

## Context
To prevent "drift" between Backend and Frontend/Mobile, and to ensure rigorous API contracts (required for `fail-on-diff` CI checks).

## Decision
*   **Source of Truth**: `openapi.yaml`.
*   **Workflow**:
    1.  Edit `openapi.yaml`.
    2.  Run compile scripts to update `packages/api_client` and `docs`.
    3.  Implement Backend to satisfy contract.
    4.  Update Frontend to use new Client.

## Consequences
*   Backend code must align with schema.
*   Mobile/Web teams are unblocked by mocks/types immediately after YAML merge.

---

# ADR-003: Serverless Async Architecture

## Context
Vercel Functions have strict timeout limits (10s-60s). Heavy operations (OSM import, Audio generation) cannot run synchronously. We must adhere to the `Cron -> Enqueue -> Callback` pattern.

## Decision
*   **Provider**: Upstash QStash.
*   **Persistence**: `jobs` table in Postgres.
*   **Flow**:
    1.  Endpoint A (start import) -> `INSERT INTO jobs (PENDING)` -> `qstash.publish(callback_url, job_id)`.
    2.  Endpoint A returns `202 Accepted { job_id }`.
    3.  QStash calls `POST /jobs/callback`.
    4.  Callback verifies signature -> `UPDATE jobs SET status=RUNNING` -> Execute Logic -> `UPDATE jobs SET status=COMPLETED`.
*   **Idempotency**: `idempotency_key` unique constraint on critical jobs.

## Consequences
*   Complex local debugging (requires public URL tunnel or real deploy).
*   Robustness against timeouts and retries provided by QStash.

---

# ADR-004: Fail-Fast Configuration

## Context
"Fake success" paths mask configuration errors, leading to runtime failures in production or security holes.

## Decision
*   **Strict Loading**: On app startup (global scope), all required Env Vars are read.
*   **Action**: If any are missing/empty, the app raises an unhandled `RuntimeError` immediately during init/build.
*   **Scope**: Database URLs, API Keys, Signing Secrets.

## Consequences
*   Deployment fails immediately if env vars are missing (Good).
*   No conditional logic allows the app to run in a "degraded" state without explicit overrides.
