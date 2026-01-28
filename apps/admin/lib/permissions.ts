
export type Role = 'admin' | 'editor' | 'viewer';

export const PERMISSIONS = {
    'poi:read': 'View POIs',
    'poi:write': 'Create/Edit POIs',
    'tour:read': 'View Tours',
    'tour:write': 'Create/Edit Tours',
    'tour:publish': 'Publish Tours',
} as const;

export type Permission = keyof typeof PERMISSIONS;

export const ROLE_PERMISSIONS: Record<Role, Permission[]> = {
    admin: ['poi:read', 'poi:write', 'tour:read', 'tour:write', 'tour:publish'],
    editor: ['poi:read', 'poi:write', 'tour:read', 'tour:write'],
    viewer: ['poi:read', 'tour:read'],
};

export function hasPermission(role: Role, permission: Permission): boolean {
    return ROLE_PERMISSIONS[role]?.includes(permission) ?? false;
}
