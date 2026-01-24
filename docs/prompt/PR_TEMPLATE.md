# PR TEMPLATE (USE LITERALLY)

PR Title: <60–90 chars>

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: <goal> + non-goals (2–6 bullets).
C) Interfaces in play: OpenAPI sections touched + DB tables touched.
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- ...
- ...

Scope / Non-Goals
- ...
- ...

Key Design Decisions
- ...

Docs Updated (docs-as-code)
- docs/api.md: ...
- docs/runbook.md: ...
- docs/adr/ADR-....md: ...

Store / Policy Impact (if applicable)
- Store build impact: none / Google Play / App Store / both.
- Payments path: YooKassa / Store billing.
- Reviewer access: описать путь (App access / demo access), без OTP-зависимости.
- Privacy: какие декларации/URLs затрагиваются (Privacy Policy, App Privacy, Data safety).
- Account deletion: затрагивается? да/нет.

UI/UX & Accessibility (if UI touched)
- Screen sizes covered: small phone / typical / large / tablet.
- Font scaling checked: 100% / 130% / 160%.
- No overlap, readable text, safe areas respected.
- Map attribution visible where needed.

Files Changed
- apps/api/...
- apps/mobile/...
- apps/admin/...
- packages/...
- docs/adr/ADR-...
- docs/api.md
- docs/runbook.md

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks: ...
- Env vars to add/update: ...
- vercel.json snippet (if needed): ...
- QStash setup (if needed): token, env vars, callback URL.
- Webhook setup (if needed): URL, secret, events.
- Store console setup (if needed):
  - Google Play: App access, Data safety, Account deletion, Store listing.
  - App Store: App Review info (demo access), App Privacy, Export compliance, IAP products.
- Validate: Preview/Prod URLs, logs to check.
- Rollback plan: ...

Validation step
- URLs:
  - <Preview URL> ...
  - <Prod URL> ...
- Logs:
  - Vercel Function Logs: ...
  - QStash logs: ...
  - DB checks (if any): ...
- Store reviewability (if applicable):
  - App access instructions verified / demo access verified (no OTP dependency).

Rollback plan
- ...

PR Definition of Done checklist
- Contract / API: done / n/a (reason)
- Serverless / QStash: done / n/a (reason)
- DB / migrations: done / n/a (reason)
- Security: done / n/a (reason)
- Performance / caching: done / n/a (reason)
- Observability / ops: done / n/a (reason)
- Testing: done / n/a (reason)
- Mobile offline-first: done / n/a (reason)
- Publish gates: done / n/a (reason)
- UI/UX & Accessibility: done / n/a (reason)
- Store compliance & reviewer access: done / n/a (reason)
- Privacy / Data safety / deletion: done / n/a (reason)
- Docs-as-code: done / n/a (reason)
- No-local: done / n/a (reason)
