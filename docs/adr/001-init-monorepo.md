# ADR-001: Monorepo & Stack Initialization

## Context
We are starting the "Audio Guide 2026" project. We need a structure that supports a web Admin panel, a serverless API, and potential shared packages, deployable to Vercel.

## Decision
*   **Monorepo**: Use npm workspaces for simplicity.
*   **Structure**:
    *   `apps/admin`: Next.js (App Router) for the Admin Panel.
    *   `apps/api`: Python (FastAPI) for the Backend, deploying as Serverless Functions on Vercel.
    *   `docs/`: Documentation (Docs-as-code source of truth).
*   **Styling (Admin)**: Vanilla CSS (CSS Modules) to maintain flexibility and minimize dependencies.
*   **Deployment**: Vercel (Zero configuration where possible).

## Consequences
*   Deployments managed via Vercel Git integration.
*   Python/Node.js mixed runtime in one repo supported natively by Vercel.
