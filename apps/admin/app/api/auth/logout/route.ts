import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

export async function POST(request: Request) {
    const token = cookies().get('token')?.value;
    const ENV_API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64/v1';
    const BACKEND_URL = ENV_API_URL.endsWith('/v1') ? ENV_API_URL : `${ENV_API_URL}/v1`;

    if (token && BACKEND_URL) {
        // Silently notify backend about logout
        await fetch(`${BACKEND_URL}/auth/logout`, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${token}` }
        }).catch(e => console.error('Backend logout failed', e));
    }

    const response = NextResponse.json({ success: true });
    response.cookies.delete('token');
    return response;
}
