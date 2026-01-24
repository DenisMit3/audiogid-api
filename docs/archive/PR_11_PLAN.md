# IMPLEMENTATION PLAN — PR-11: Final Polish & Launch Prep

## 1. Goal
Harden the API for production launch. Implement strict security headers, rate limiting middleware, redacting logger configuration, and comprehensive health probes. Update docs/runbook for "Day 1 Deployment".

## 2. API Hardening
*   **Security Middleware**:
    *   `Strict-Transport-Security` (HSTS).
    *   `X-Content-Type-Options: nosniff`.
    *   `Referrer-Policy: no-referrer`.
    *   `Cache-Control: no-store` default for sensitive paths (overriding others).
*   **Rate Limiting**:
    *   Use `upstash/ratelimit` (or basic memory shim for MVP if Redis not strictly mandated, but Redis is available in stack via QStash context? No, Upstash Redis is separate. Prompt says "no wallet... purchases only Catalog/Tours... QStash". I'll implement a **Basic In-Memory Rate Limiter** for MVP to avoid adding strict Redis dependency unless config has it. Actually, `apps/api` is serverless (Vercel), memory won't persist.
    *   *Decision*: For MVP PR-11, I will implement **User-Agent/IP based simple throttling** inside the middleware, recognizing it's imperfect on Serverless without Redis. Or, if available, utilize Vercel's Edge Config / KV.
    *   *Better*: Since I cannot adding new infra deps effectively without config, I will add `SlowAPI` or similar decorator patterns, but simply rely on **hard limits** in the code (e.g. `nearby` radius cap, payload size cap) and assume Vercel platform-level DDoS protection. I will add explicit **Payload Size Checks** in middleware.

## 3. Observability
*   **Structured Logging**: Ensure `structlog` or standard logging uses JSON formatter in Prod.
    *   Field Redaction: `token`, `authorization`, `receipt`, `proof`, `device_anon_id`.
*   **Probes**:
    *   `/v1/ops/health`: Returns 200 OK.
    *   `/v1/ops/ready`: Checks DB connection. Returns 500 if DB down.

## 4. Documentation
*   **ADR-015**: Launch Hardening.
*   **Runbook**: Consolidate all validation steps into a "Master Validation" flow.
*   **Store Policy**: Update checklist to "Ready".

---

# Task Plan (PR-11)
1.  **Middleware**: Create `security_middleware.py` (Headers + Payload Size). Update `index.py`.
2.  **Logging**: Configure `logger_config.py` with redaction filters.
3.  **Ops**: Add `apps/api/api/ops.py` (Health/Ready).
4.  **Harden Deletion**: Add `exp` (1 hour) to Deletion Token logic in `deletion.py` (Follow-up from PR-10 request).
5.  **Contract**: No major schema changes, just Ops endpoints.
6.  **Docs**: ADR-015, `runbook.md` (Master), `policy/store-compliance.md`.

---

# ADR-015: Launch Hardening Strategy

## Context
Preparing for public internet exposure. We need to mitigate basic attacks and ensure compliance/privacy.

## Decision
*   **Security Headers**: Enforced globally via Middleware.
*   **Rate Limiting**:
    *   *Strategy*: Application-level payload limits + Vercel Platform DDoS protection.
    *   *Rationale*: Adding a dedicated Redis just for Rate Limiting complicates the Day 1 stack. We rely on Platform limits + expensive endpoint caps (e.g. max radius).
*   **Logging**:
    *   *Format*: JSON Structured Logs.
    *   *Redaction*: Middleware strips sensitive headers. App logic hashes PII before logging.
*   **Deletion Token**: now includes `exp` (Expiry) timestamp in the message signature to prevent replay attacks after 1 hour.

## Consequences
*   Logs are machine-readable but safe for storage.
*   Ops probes allow automated uptime monitoring.
*   Serverless cold starts might reset memory-based counters (accepted for MVP).
