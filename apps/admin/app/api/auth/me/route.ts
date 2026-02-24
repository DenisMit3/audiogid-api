
import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

// Mock endpoint to get current user from Backend using the Cookie
export async function GET(request: Request) {
    const cookieStore = cookies();
    const token = cookieStore.get('token');

    if (!token) return NextResponse.json({ error: 'Not authenticated' }, { status: 401 });

    const ENV_API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64:8000/v1';
    const BACKEND_URL = ENV_API_URL.endsWith('/v1') ? ENV_API_URL : `${ENV_API_URL}/v1`;

    if (!BACKEND_URL) return NextResponse.json({ error: 'API URL not configured' }, { status: 500 });

    try {
        const res = await fetch(`${BACKEND_URL}/auth/me`, {
            headers: {
                'Authorization': `Bearer ${token.value}`
            }
        });

        if (!res.ok) {
            return NextResponse.json({ error: 'Failed to fetch user' }, { status: res.status });
        }

        const data = await res.json();
        const response = NextResponse.json(data);
        response.headers.set('X-Debug-Url', `${BACKEND_URL}/auth/me`);
        return response;
    } catch (e) {
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
