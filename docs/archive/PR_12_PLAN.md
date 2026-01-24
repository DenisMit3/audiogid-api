# IMPLEMENTATION PLAN — PR-12: Codebase Handover & Cleanup

## 1. Goal
Finalize the repository for handover. Establish a clean Documentation Index (`README.md`), Archive temporary plans, and enforce Repo Hygiene (.gitignore). Ensure zero runtime impact.

## 2. Documentation Indexing (Docs-as-Code)
*   **Root `README.md`**: Create a professional landing page.
    *   **Sections**: Project Overview, Architecture (ADRs), Cloud Validation (Runbook), API & Clients, Compliance.
    *   **Links**: Direct pointers to `docs/api.md`, `packages/contract/openapi.yaml`, `docs/policy/store-compliance.md`.
*   **Docs Structure**:
    *   Move `docs/*_PLAN.md` -> `docs/archive/`.
    *   Create `docs/README.md` indexing the `docs/` folder (Runbooks, Policies, ADRs).

## 3. Repo Hygiene
*   **`.gitignore`**: Audit to exclude `.env`, `__pycache__`, `pass.key`.
*   **Cleanup**: Remove any potential temp files.

## 4. Validation
*   **Zero Drift**: Verify no code changes in `apps/api`.
*   **Ops Check**: Verify `/ops/health` responds.

---

# Task Plan (PR-12)
1.  **Archive**: Move all `*_PLAN.md` files to `docs/archive/`.
2.  **Root README**: Create `README.md` with high-level map.
3.  **Docs Index**: Create `docs/README.md`.
4.  **Gitignore**: Update/Verify `.gitignore`.
5.  **Validation**: Commit and verify no functional regression via Ops endpoints.

---

# ARTIFACT MIGRATION MAP
*   `docs/PR_1_PLAN.md` -> `docs/archive/PR_1_PLAN.md`
*   ...
*   `docs/PR_11_PLAN.md` -> `docs/archive/PR_11_PLAN.md`

# NO ADR REQUIRED (Pure Cleanup)
