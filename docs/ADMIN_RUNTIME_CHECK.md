# Admin Runtime Check: operability and API interaction

Date: 2026-03-28

## What was checked

1. Static contract of admin auth routes:
   - `app/api/auth/login/route.ts`
   - `app/api/auth/me/route.ts`
   - `app/api/auth/logout/route.ts`
2. Proxy bridge admin -> backend:
   - `app/api/proxy/[...path]/route.ts`
   - `lib/api-client.ts`
3. Middleware access control:
   - `middleware.ts`
4. Automated checks:
   - `pnpm -s lint` (successful with warnings)
   - `pnpm -s test:e2e` (failed due missing Playwright browser binaries in environment)

## Fixes applied in this pass

1. **Login cookie hardened**
   - Added `Secure` flag for `token` cookie in production mode.
2. **Logout backend URL normalization fixed**
   - `logout` route now uses the same `.../v1` normalization logic as other auth routes.
   - Prevents broken backend logout call when `NEXT_PUBLIC_API_URL` is set without `/v1`.

## Shortlist of potential issues to monitor

1. Proxy does not set fetch timeout to backend.
2. `login` route allows selecting `/auth/login/dev-admin` if `secret` is present in body; this should be constrained by environment/feature-flag.
3. E2E suite currently cannot run in this container without `playwright install` browser binaries.
