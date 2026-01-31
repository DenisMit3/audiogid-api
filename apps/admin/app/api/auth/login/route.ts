
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
    const body = await request.json();

    // Use the internal proxy to handle backend routing and env vars
    const origin = new URL(request.url).origin;

    let endpoint = '/v1/auth/login/dev-admin';
    if ('phone' in body && 'code' in body) endpoint = '/v1/auth/login/sms/verify';
    else if ('hash' in body) endpoint = '/v1/auth/login/telegram';
    else if ('email' in body && 'password' in body) endpoint = '/v1/auth/login/email';
    else if ('secret' in body) endpoint = '/v1/auth/login/dev-admin';

    try {
        const backendRes = await fetch(`${origin}/api/proxy${endpoint}`, {
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

    } catch (e: any) {
        console.error('Login Proxy Error:', e);
        return NextResponse.json({
            detail: 'Internal Server Error',
            error: e.message,
            url: `${origin}/api/proxy${endpoint}`
        }, { status: 500 });
    }
}
