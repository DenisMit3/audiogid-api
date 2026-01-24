# API Documentation

## Overview
*   **Base URL**: `/api/v1`

## Deletion & Privacy
*   **Security**: All deletion requests require a `proof` token.
    *   **Get Token**: `POST /public/account/delete/token` (In-App).
    *   **Request Deletion**: `POST /public/account/delete/request` (Requires Token).
*   **Web Deletion**: `GET /delete` (HTML Form, requires Token).
*   **Status**: `GET /public/account/delete/status`.
*   **Cache-Control**: `no-store` on all deletion flow endpoints.

### Public Endpoints
*   `GET /tours`: List.
*   `GET /tours/{id}/manifest`: **Premium**.
*   `POST /purchases/tours/intent`: Purchase.
*   `GET /entitlements`: Check access.
*   `GET /nearby`: Geo search.

### Admin Endpoints
*   `POST /admin/tours`: Manage.
*   `POST /admin/tours/{id}/publish`: Gate check.
