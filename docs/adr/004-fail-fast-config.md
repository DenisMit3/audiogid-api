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
