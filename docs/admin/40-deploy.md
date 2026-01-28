# Deployment Guide

## Prerequisites

- **Next.js** Frontend (Admin Panel)
- **FastAPI** Backend (API)
- **PostgreSQL** Database (with PostGIS)
- **Object Storage** (Vercel Blob or S3)

## Environment Variables (.env)

```bash
# Database
DATABASE_URL="postgresql://user:pass@host:5432/audiogid"

# Auth
JWT_SECRET="changeme_production_secret"
JWT_ALGORITHM="HS256"

# Object Storage
VERCEL_BLOB_READ_WRITE_TOKEN="vercel_blob_token_here"

# Frontend (Next.js)
NEXT_PUBLIC_API_URL="https://api.audiogid.app"
API_SECRET="shared_secret_if_needed"
```

## Vercel Deployment (Admin)

**IMPORTANT**: The Admin Panel is designed for Vercel. Do not build locally if environments differ.

1.  **Push code** to GitHub/GitLab.
2.  **Import project** in Vercel Dashboard.
3.  **Root Directory**: Set to `apps/admin`.
4.  **Framework Preset**: Next.js (Default).
5.  **Environment Variables**:
    - `NEXT_PUBLIC_API_URL`: `https://api.audiogid.app` (or your PythonAnywhere/VPS URL).
    - `JWT_SECRET`: Must match backend.
    - `VERCEL_BLOB_READ_WRITE_TOKEN`: For media uploads.
6.  **Deploy**: Vercel will handle `pnpm install`, `pnpm build`, and routing via `vercel.json` / `next.config.js`.
7.  **Rewrites**: The `vercel.json` (and `next.config.js`) maps `/api/proxy/*` -> `$NEXT_PUBLIC_API_URL/v1/*`.

### Note on Local Development
If running locally, ensure `caniuse-lite` and other build dependencies are intact. If errors occur, rely on the Vercel cloud build which is the source of truth.

## Python Anywhere / VPS (API)

1.  Clone repo.
2.  `pip install -r apps/api/requirements.txt`.
3.  Run migrations: `alembic upgrade head`.
4.  Start server: `uvicorn index:app --host 0.0.0.0 --port 8000`.
5.  Set up Reverse Proxy (Nginx) and SSL.
