# RBAC Matrix

## Roles

1.  **Admin** (`admin`)
    - Full access to all resources.
    - Can manage users and roles.
    - Can view audit logs.
2.  **Editor** (`editor`)
    - Can Create/Read/Update/Publish Content (POIs, Tours).
    - Cannot manage users.
    - Cannot view sensitive analytics or audit logs (configurable).
3.  **User** (`user`)
    - Default role.
    - Read-only access to public API.
    - No access to Admin Panel.

## Permissions

| Permission | Admin | Editor | User |
| :--- | :---: | :---: | :---: |
| `content:read` | ✅ | ✅ | - |
| `content:write` | ✅ | ✅ | - |
| `content:publish` | ✅ | ✅ | - |
| `analytics:read` | ✅ | - | - |
| `analytics:write` | ✅ | - | - |
| `users:manage` | ✅ | - | - |
| `audit:read` | ✅ | - | - |
