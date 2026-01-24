# Audio Guide 2026 (Serverless Backend)

Welcome to the **Audio Guide 2026** backend repository. This project provides a scalable, serverless API for a multi-tenant audio guide application focused on Offline-First experiences, Store Compliance, and Premium Content delivery.

## 🏗 Architecture
*   **Stack**: Python (FastAPI), SQLModel, Vercel (Serverless), Neon (Postgres), QStash (Async Jobs).
*   **Tenancy**: Multi-tenant by design (`city_slug`).
*   **Offline-First**: Supports secure Manifest downloads for full offline usage.
*   **Compliance**: Strict adherence to Apple/Google deletion & privacy policies.

## 📚 Documentation Index
Everything is strictly documented as code.

### 🚀 Getting Started & Ops
*   [Master Runbook](docs/runbook.md): The single source of truth for deployment, validation, and ops procedures. **Use this for Day 1 checks.**
*   [API Documentation](docs/api.md): Detailed endpoint reference.
*   [OpenAPI Spec](packages/contract/openapi.yaml): The machine-readable contract.

### ⚖️ Policies & Decisions
*   [Store Compliance Policy](docs/policy/store-compliance.md): Ready-to-go checklist for App Store / Google Play reviews.
*   [Architecture Decision Records (ADRs)](docs/adr/): History of all major technical decisions (e.g., Geo-partitioning, Deletion Strategy, Manifests).

## 🧩 Key Features
1.  **Tours & Catalog**: Geo-spatial discovery with MapLibre compatibility.
2.  **Premium Access**: Server-side Purchase Validation (Stub/Sandbox) and Entitlement management.
3.  **Secure Delivery**: `Manifest` endpoints gated by payment.
4.  **Compliance**: Privacy-first logging (Redaction) and User Data Deletion (Async).

## 🛠 Usage
This is a Vercel-ready monorepo.
*   **Deploy**: Push to `main`. Vercel automatically builds `apps/api`.
*   **Validate**: Follow the [Runbook](docs/runbook.md).

## 📝 Generated Clients
*   **Dart/Flutter**: Located in `packages/api_client`. (Generated via OpenAPI).

---
*Maintained by the Audio Guide Team.*
