
import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

// API URL - Cloud.ru nginx proxies API on port 80
const ENV_API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64/v1';
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
    
    // Also check for x-admin-token header (used by route-builder)
    const adminTokenHeader = request.headers.get('x-admin-token');
    
    // Check if this is a file upload (multipart/form-data)
    const contentType = request.headers.get('content-type') || '';
    const isMultipart = contentType.includes('multipart/form-data');

    const headers: Record<string, string> = {};
    
    // Only set Content-Type for JSON requests, let fetch set it for multipart
    if (!isMultipart) {
        headers['Content-Type'] = 'application/json';
    }
    
    // Forward x-admin-token header directly to backend (required by publish.py routes)
    // Priority: 1) x-admin-token header, 2) Authorization header from request (if valid), 3) token cookie
    const authHeader = request.headers.get('authorization');
    
    if (adminTokenHeader) {
        headers['x-admin-token'] = adminTokenHeader;
        headers['Authorization'] = `Bearer ${adminTokenHeader}`;
    } else if (authHeader && authHeader.toLowerCase().startsWith('bearer ') && !authHeader.includes('null') && !authHeader.includes('undefined')) {
        // Use Authorization header from request only if it contains a valid token
        headers['Authorization'] = authHeader;
    } else if (token) {
        headers['Authorization'] = `Bearer ${token.value}`;
    }

    try {
        let body: BodyInit | undefined;
        
        if (method !== 'GET' && method !== 'HEAD') {
            if (isMultipart) {
                // For file uploads, pass the request body as-is
                body = await request.arrayBuffer();
                // Preserve the original content-type with boundary
                headers['Content-Type'] = contentType;
            } else {
                const textBody = await request.text();
                // Only set body and Content-Type if there's actual content
                if (textBody && textBody.length > 0) {
                    body = textBody;
                } else {
                    // Don't send Content-Type for empty body requests (like publish/unpublish)
                    delete headers['Content-Type'];
                }
            }
        }

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

        const responseText = await res.text();

        let data = {};
        try {
            data = JSON.parse(responseText);
        } catch {
            data = { rawResponse: responseText.substring(0, 500) };
        }

        const response = NextResponse.json(data, { status: res.status });
        response.headers.set('X-Debug-Upstream-Url', finalUrl);
        return response;
    } catch (e) {
        return NextResponse.json({ error: 'Proxy Error', details: String(e) }, { status: 502 });
    }
}
