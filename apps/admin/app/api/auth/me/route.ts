
import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

// Mock endpoint to get current user from Backend using the Cookie
export async function GET(request: Request) {
    const cookieStore = cookies();
    const token = cookieStore.get('token');

    if (!token) return NextResponse.json({ error: 'Not authenticated' }, { status: 401 });

    // Proxy to backend /admin/me or decode locally if we had secret.
    // Ideally we call Backend.
    // Note: We need to pass the Cookie header to the backend.

    // Fallback: If backend doesn't have /me yet (Step 1 didn't explicitly add it but we have get_current_user),
    // we can add it OR decode if we share secret.
    // Safe bet: Fetch from backend /admin/me (we need to add this endpoint or use /auth/me).

    // Let's assume we proxy to /api/users/me or similar.
    // Or simpler: We added `get_current_user` in deps.
    // Let's try GET /admin/profile ?

    // For this Turn, I'll mock the response based on the token presence 
    // OR try to hit an existing endpoint.
    // But honestly, the cleanest is to add a proper /me endpoint in Backend next turn or now.
    // For now, I'll return a dummy user with role='admin' to unblock UI dev.
    // TODO: Connect to real backend /me

    return NextResponse.json({
        id: '123',
        role: 'admin',
        first_name: 'Admin',
        username: 'admin'
    });
}
