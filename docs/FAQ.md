# Frequently Asked Questions

## What is this project?
Audio Guide API is a FastAPI backend for a mobile audio guide application with offline-first support, billing, auth, and an admin panel.

## What is the source of truth for API contracts?
`apps/api/openapi.yaml` (OpenAPI 3.1).

## How do users authenticate?
Supported methods are SMS (`/auth/login/sms/*`), Telegram (`/auth/login/telegram`), and email (`/auth/login/email`).

## How is paid access managed?
The backend verifies store receipts/tokens (`/billing/apple/verify`, `/billing/google/verify`) and grants entitlements via `EntitlementGrant` records.

## How does offline mode work?
Clients request bundle build jobs (`/offline/bundles:build`) and then poll job status (`/offline/bundles/{job_id}`).

## Where can I check service health?
Use `/v1/ops/health`, `/v1/ops/ready`, and `/v1/ops/config-check`.

## Where are deployment endpoints?
Production API: `http://82.202.159.64:8000/v1`
Admin Panel: `http://82.202.159.64:3080/login`
