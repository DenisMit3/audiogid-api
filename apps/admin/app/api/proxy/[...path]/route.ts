
import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || 'https://api.audiogid.app';

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

        const res = await fetch(`${BACKEND_URL}/${path}${query}`, {
            method,
            headers,
            body
        });

        const data = await res.json().catch(() => ({}));

        return NextResponse.json(data, { status: res.status });
    } catch (e) {
        return NextResponse.json({ error: 'Proxy Error' }, { status: 502 });
    }
}
