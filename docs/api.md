# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Offline & Entitlements
*   **Manifest**: `GET /tours/{id}/manifest` is the **Premium** endpoint. It requires a purchased Entitlement (checked via `device_anon_id`).
*   **Public Detail**: `GET /tours/{id}` is the **Store Page**. It is public but omits description/assets.

## Endpoints

### Public
*   `GET /manifest`: **Premium**. Returns full offline package.
*   `GET /tours`: List.
*   `GET /tours/{id}`: Detail (Metadata).
*   `POST /purchases/...`: Purchase flow.

### Admin
*   **Publish Gates**:
    *   Sources required.
    *   Licensed Media required.
    *   **Audio Coverage**: All POIs must have Audio.
    *   All POIs must be Published.
