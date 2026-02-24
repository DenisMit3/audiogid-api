
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

    // #region agent log
    fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'e1d8fd'},body:JSON.stringify({sessionId:'e1d8fd',location:'auth/login/route.ts:15',message:'Login request',data:{endpoint,origin,bodyKeys:Object.keys(body)},timestamp:Date.now(),hypothesisId:'C'})}).catch(()=>{});
    // #endregion

    try {
        const proxyUrl = `${origin}/api/proxy${endpoint}`;
        // #region agent log
        fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'e1d8fd'},body:JSON.stringify({sessionId:'e1d8fd',location:'auth/login/route.ts:22',message:'Calling proxy',data:{proxyUrl},timestamp:Date.now(),hypothesisId:'E'})}).catch(()=>{});
        // #endregion

        const backendRes = await fetch(proxyUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        const responseText = await backendRes.text();
        // #region agent log
        fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'e1d8fd'},body:JSON.stringify({sessionId:'e1d8fd',location:'auth/login/route.ts:33',message:'Proxy response',data:{status:backendRes.status,responsePreview:responseText.substring(0,500)},timestamp:Date.now(),hypothesisId:'B,D'})}).catch(()=>{});
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
        // Only set Secure flag if using HTTPS (check via X-Forwarded-Proto or request URL)
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
        fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'e1d8fd'},body:JSON.stringify({sessionId:'e1d8fd',location:'auth/login/route.ts:65',message:'Login error',data:{error:e.message},timestamp:Date.now(),hypothesisId:'D'})}).catch(()=>{});
        // #endregion
        console.error('Login Proxy Error:', e);
        return NextResponse.json({
            detail: 'Internal Server Error',
            error: e.message,
            url: `${origin}/api/proxy${endpoint}`
        }, { status: 500 });
    }
}
