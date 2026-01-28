
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
    const body = await request.json();

    // Use backend URL from env or default to localhost
    const API_URL = process.env.backend_url || 'http://localhost:8000';

    let endpoint = '/auth/login/dev-admin';
    if ('phone' in body && 'code' in body) endpoint = '/auth/login/sms/verify';
    else if ('hash' in body) endpoint = '/auth/login/telegram';
    else if ('secret' in body) endpoint = '/auth/login/dev-admin';

    try {
        const backendRes = await fetch(`${API_URL}${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        if (!backendRes.ok) {
            const err = await backendRes.json().catch(() => ({ detail: 'Backend Error' }));
            return NextResponse.json(err, { status: backendRes.status });
        }

        const data = await backendRes.json();
        const token = data.access_token;

        const response = NextResponse.json({ success: true });

        // Set HttpOnly Cookie
        response.cookies.set({
            name: 'token',
            value: token,
            httpOnly: true,
            path: '/',
            maxAge: 60 * 60 * 24, // 1 day
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'lax'
        });

        return response;

    } catch (e) {
        console.error('Login Proxy Error:', e);
        return NextResponse.json({ detail: 'Internal Server Error' }, { status: 500 });
    }
}
