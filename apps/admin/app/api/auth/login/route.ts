import { NextResponse } from 'next/server';

// Direct API URL - Cloud.ru nginx proxies API on port 80
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64/v1';

export async function POST(request: Request) {
    const body = await request.json();

    // Определяем endpoint по типу логина
    let endpoint = '/auth/login/email';
    if ('phone' in body && 'code' in body) endpoint = '/auth/login/sms/verify';
    else if ('hash' in body) endpoint = '/auth/login/telegram';
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

        if (!token) {
            return NextResponse.json({ detail: 'No token in response' }, { status: 500 });
        }

        // Создаём response с Set-Cookie header напрямую
        const response = new NextResponse(
            JSON.stringify({ success: true }),
            {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Set-Cookie': `token=${token}; Path=/; HttpOnly; SameSite=Lax; Max-Age=86400`
                }
            }
        );

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
