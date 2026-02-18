import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

export async function POST(request: Request) {
    const token = cookies().get('token')?.value;
    const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL;

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
