
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

    // #region agent log
    fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'e1d8fd'},body:JSON.stringify({sessionId:'e1d8fd',location:'auth/login/route.ts:18',message:'Login request direct',data:{apiUrl,bodyKeys:Object.keys(body)},timestamp:Date.now(),hypothesisId:'F'})}).catch(()=>{});
    // #endregion

    try {
        const backendRes = await fetch(apiUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        const responseText = await backendRes.text();
        // #region agent log
        fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'e1d8fd'},body:JSON.stringify({sessionId:'e1d8fd',location:'auth/login/route.ts:30',message:'Backend response direct',data:{status:backendRes.status,responsePreview:responseText.substring(0,300)},timestamp:Date.now(),hypothesisId:'F'})}).catch(()=>{});
        // #endregion

        if (!backendRes.ok) {
            let err = { detail: 'Backend Error' };
            try { err = JSON.parse(responseText); } catch {}
            return NextResponse.json(err, { status: backendRes.status });
        }

        const data = JSON.parse(responseText);
        const token = data.access_token;

        const response = NextResponse.json({ success: true });

        // Set HttpOnly Cookie
        const origin = new URL(request.url).origin;
        const isHttps = request.headers.get('x-forwarded-proto') === 'https' || origin.startsWith('https');
        response.cookies.set({
            name: 'token',
            value: token,
            httpOnly: true,
            path: '/',
            maxAge: 60 * 60 * 24, // 1 day
            secure: isHttps,
            sameSite: 'lax'
        });

        return response;

    } catch (e: any) {
        // #region agent log
        fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'e1d8fd'},body:JSON.stringify({sessionId:'e1d8fd',location:'auth/login/route.ts:60',message:'Login error',data:{error:e.message},timestamp:Date.now(),hypothesisId:'F'})}).catch(()=>{});
        // #endregion
        console.error('Login Error:', e);
        return NextResponse.json({
            detail: 'Internal Server Error',
            error: e.message,
            url: apiUrl
        }, { status: 500 });
    }
}
