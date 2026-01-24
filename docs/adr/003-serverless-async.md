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
