# ADR-013: Offline Manifests (Contract)

## Status
Accepted

## Context
Mobile users need to access tours and narratives without an internet connection (roaming, remote areas). 
The ingestion pipeline currently imports data from OpenStreetMap and Wikidata into the Postgres database, but this data is only accessible via online REST APIs.
We need a mechanism to package this data into downloadable "bundles" that the mobile app can sync and store locally.

Requirements:
- **Offline-first:** App must function without network after initial sync.
- **Stable Artifacts:** Bundle content must be deterministic and immutable once generated.
- **Fail-fast:** If configuration or critical dependencies are missing, operations should fail immediately.
- **Serverless:** Heavy build operations must run asynchronously (jobs), not blocking HTTP requests.
- **Observability:** Traceable build process from request to completion.

## Decision

We will implement an **Offline Manifests** system following the "Manifest as Source of Truth" pattern.

### 1. Manifest Structure
A "Manifest" is a JSON file that acts as the entry point for an offline bundle. It describes:
- Content metadata (title, version, city).
- List of assets (audio files, images) with their remote URLs, local paths, sizes, and content hashes (SHA-256).
- Structured data (POI details, routes) embedded directly or referenced as sidecar JSONs.

### 2. Versioning & Caching
- **Content-Addressing:** Artifacts (manifests and bundles) typically use content-hash based naming (e.g., `manifest_{sha256}.json`) or robust ETags.
- **Immutable Headers:** Served with `Cache-Control: public, max-age=31536000, immutable` where appropriate.
- **Identity:** A bundle's identity is defined by the hash of its content.

### 3. Async Build Pipeline
The build process is heavy (fetching assets, compressing, calculating hashes) and cannot run in a synchronous HTTP handler.
We will reuse the existing Job System (QStash + Worker):

1.  **Request:** Client (Admin/System) `POST /v1/offline/bundles:build` → Enqueues Job.
2.  **Job Execution:** Worker fetches graph data, signs asset URLs, generates JSON manifest. 
3.  **Storage:** Uploads manifest (and potentially zip bundles in future) to Blob Storage (Vercel Blob).
4.  **Callback:** Updates Job status.
5.  **Status Check:** Client polls `GET /v1/offline/bundles/{job_id}`.

### 4. Storage
- **Vercel Blob** is the canonical storage for generated manifests.
- Temporary build artifacts may use `/tmp` within the worker execution limit, but final outputs must be persisted to Blob storage.

### 5. Security
- Manifests may contain signed URLs. These URLs have expirations (TTL).
- If long-lived offline access is required, the mobile app downloads the assets immediately upon receiving the manifest.
- **Constraint:** Logs must NOT contain full signed URLs to prevent leak.

## API Contract (OpenAPI)

### POST /v1/offline/bundles:build
Enqueue a build job.
- **Request:**
  ```json
  {
    "city_slug": "kaliningrad_city",
    "type": "full_city", 
    "idempotency_key": "build_kgd_v1_20260126"
  }
  ```
- **Response:** `202 Accepted` with `job_id`.

### GET /v1/offline/bundles/{job_id}
Check status.
- **Response:** `200 OK`
  ```json
  {
    "id": "...",
    "status": "COMPLETED",
    "result": {
      "manifest_url": "https://...",
      "content_hash": "sha256:..."
    }
  }
  ```

## Consequences
- **Positive:** Standardizes offline data access; decouples build process from consumption; leverages existing async infrastructure.
- **Negative:** Adds complexity to the worker (manifest generation logic); introduces storage costs (Vercel Blob).
- **Mitigation:** Start with light JSON-only manifests; implement binary zipping later if needed. Use retention policies on Blob storage.
