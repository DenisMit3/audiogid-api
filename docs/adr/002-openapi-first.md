# ADR-002: OpenAPI-First Strategy

## Context
To prevent "drift" between Backend and Frontend/Mobile, and to ensure rigorous API contracts (required for `fail-on-diff` CI checks).

## Decision
*   **Source of Truth**: `packages/contract/openapi.yaml`.
*   **Workflow**:
    1.  Edit `openapi.yaml`.
    2.  Run compile scripts to update `packages/api_client` and `docs`.
    3.  Implement Backend to satisfy contract.
    4.  Update Frontend to use new Client.

## Consequences
*   Backend code must align with schema.
*   Mobile/Web teams are unblocked by mocks/types immediately after YAML merge.
*   CI will enforce consistency via `fail-on-diff`.
