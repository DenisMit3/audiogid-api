
import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

// API URL with port 8000 - required for Cloud.ru deployment (updated 2026-02-24)
const ENV_API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64:8000/v1';
const BACKEND_URL = ENV_API_URL.endsWith('/v1') ? ENV_API_URL : `${ENV_API_URL}/v1`;


export async function GET(request: Request, { params }: { params: { path: string[] } }) {
    return proxy(request, params.path, 'GET');
}

export async function POST(request: Request, { params }: { params: { path: string[] } }) {
    return proxy(request, params.path, 'POST');
}

export async function PATCH(request: Request, { params }: { params: { path: string[] } }) {
    return proxy(request, params.path, 'PATCH');
}

export async function DELETE(request: Request, { params }: { params: { path: string[] } }) {
    return proxy(request, params.path, 'DELETE');
}

async function proxy(request: Request, pathSegments: string[], method: string) {
    if (!BACKEND_URL) return NextResponse.json({ error: 'API URL not configured' }, { status: 500 });
    const path = pathSegments.join('/');
    const cookieStore = cookies();
    const token = cookieStore.get('token');

    const headers: Record<string, string> = {
        'Content-Type': 'application/json',
    };
    if (token) {
        headers['Authorization'] = `Bearer ${token.value}`;
    }

    try {
        const body = (method !== 'GET' && method !== 'HEAD') ? await request.text() : undefined;

        // Forward query params
        const url = new URL(request.url);
        const query = url.search;

        const path = pathSegments.join('/');

        // Robust URL joining
        let base = BACKEND_URL;
        if (base.endsWith('/')) base = base.slice(0, -1);

        let targetPath = path;
        if (targetPath.startsWith('/')) targetPath = targetPath.slice(1);

        // Handle potential double /v1 if path already includes it and base also has it
        if (base.endsWith('/v1') && targetPath.startsWith('v1/')) {
            targetPath = targetPath.slice(3);
        } else if (base.endsWith('/v1') && targetPath === 'v1') {
            targetPath = '';
        }

        const finalUrl = `${base}/${targetPath}${query}`;

        const res = await fetch(finalUrl, {
            method,
            headers,
            body
        });

        const data = await res.json().catch(() => ({}));

        const response = NextResponse.json(data, { status: res.status });
        response.headers.set('X-Debug-Upstream-Url', finalUrl);
        return response;
    } catch (e) {
        return NextResponse.json({ error: 'Proxy Error', details: String(e) }, { status: 502 });
    }
}
