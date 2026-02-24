
import { NextResponse } from 'next/server';

// Direct API URL - Cloud.ru nginx proxies API on port 80
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64/v1';

export async function POST(request: Request) {
    const body = await request.json();

    let endpoint = '/auth/login/dev-admin';
    if ('phone' in body && 'code' in body) endpoint = '/auth/login/sms/verify';
    else if ('hash' in body) endpoint = '/auth/login/telegram';
    else if ('email' in body && 'password' in body) endpoint = '/auth/login/email';
    else if ('secret' in body) endpoint = '/auth/login/dev-admin';

    const apiUrl = `${API_BASE_URL}${endpoint}`;

    try {
        const backendRes = await fetch(apiUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        const responseText = await backendRes.text();

        if (!backendRes.ok) {
            let err = { detail: 'Backend Error' };
            try { err = JSON.parse(responseText); } catch {}
            return NextResponse.json(err, { status: backendRes.status });
        }

        const data = JSON.parse(responseText);
        const token = data.access_token;

        const response = NextResponse.json({ success: true });

        // Set HttpOnly Cookie - always use secure:false for HTTP
        response.cookies.set({
            name: 'token',
            value: token,
            httpOnly: true,
            path: '/',
            maxAge: 60 * 60 * 24, // 1 day
            secure: false,
            sameSite: 'lax'
        });

        return response;

    } catch (e: any) {
        console.error('Login Error:', e);
        return NextResponse.json({
            detail: 'Internal Server Error',
            error: e.message,
            url: apiUrl
        }, { status: 500 });
    }
}
