import { redirect } from 'next/navigation';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL;

if (!API_BASE_URL) {
    throw new Error("NEXT_PUBLIC_API_URL is required");
}

type RequestOptions = RequestInit & {
    token?: string;
};

export const apiClient = {
    get: async (path: string, options: RequestOptions = {}) => {
        return request(path, { ...options, method: 'GET' });
    },
    post: async (path: string, body: any, options: RequestOptions = {}) => {
        return request(path, { ...options, method: 'POST', body: JSON.stringify(body) });
    },
    put: async (path: string, body: any, options: RequestOptions = {}) => {
        return request(path, { ...options, method: 'PUT', body: JSON.stringify(body) });
    },
    delete: async (path: string, options: RequestOptions = {}) => {
        return request(path, { ...options, method: 'DELETE' });
    },
};

async function request(path: string, options: RequestOptions) {
    // Use provided token or fallback to localStorage (client-side only)
    let token = options.token;
    if (!token && typeof window !== 'undefined') {
        token = localStorage.getItem('admin_token') || undefined;
    }

    const headers = new Headers(options.headers);
    if (token) {
        headers.set('Authorization', `Bearer ${token}`);
    }
    if (!headers.has('Content-Type') && options.body) {
        headers.set('Content-Type', 'application/json');
    }

    const res = await fetch(`${API_BASE_URL}${path}`, {
        ...options,
        headers,
    });

    if (res.status === 401) {
        // Handle unauthorized - maybe redirect to login if on client
        if (typeof window !== 'undefined') {
            window.location.href = '/login';
        }
    }

    if (!res.ok) {
        const errorText = await res.text();
        throw new Error(`API Error ${res.status}: ${errorText}`);
    }

    // Handle empty responses
    const contentLength = res.headers.get('content-length');
    if (contentLength === '0') return null;

    try {
        return await res.json();
    } catch (e) {
        return null;
    }
}
