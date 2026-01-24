# ADR-015: Launch Hardening Strategy

## Context
Preparing for public internet exposure. We need to mitigate basic attacks and ensure compliance/privacy.

## Decision
*   **Security Headers**: Enforced globally via Middleware (HSTS, No-Sniff).
*   **Rate Limiting**:
    *   *Strategy*: Application-level payload limits + Vercel Platform DDoS protection.
    *   *Rationale*: Adding a dedicated Redis just for Rate Limiting complicates the Day 1 stack. We rely on Platform limits + expensive endpoint caps.
*   **Logging**:
    *   *Format*: JSON Structured Logs in Production.
    *   *Redaction*: Middleware strips sensitive headers (`authorization`, `proof`). App logic hashes PII identities.
*   **Deletion Token**: now includes `exp` (Expiry) timestamp in the message signature to prevent replay attacks after 1 hour.

## Consequences
*   Logs are machine-readable but safe for storage.
*   Ops probes allow automated uptime monitoring.
*   Serverless cold starts might reset memory-based counters (accepted for MVP).
