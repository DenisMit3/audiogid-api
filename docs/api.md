# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Purchases & Entitlements
*   **Flow**: Intent -> Store Payment (Client) -> Confirm (Server) -> Entitlement.
*   **Sandbox**: On Preview envs, use `store_proof="SANDBOX_SUCCESS"`.

## Endpoints

### Public (Purchases)
*   `POST /purchases/tours/intent`: Start transaction.
*   `POST /purchases/tours/confirm`: Validate receipt & Grant.
*   `GET /entitlements`: List accessible tours.

### Public (Content)
*   `GET /tours`: List.
*   `GET /tours/{id}`: Detail.
*   `GET /nearby`: Geo discovery.

### Admin (Auth: X-Admin-Token)
*   `POST /admin/tours`: Manage Tours.
*   `POST /admin/tours/{id}/publish`: Publish.
