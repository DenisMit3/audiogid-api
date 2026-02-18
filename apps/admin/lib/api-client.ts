// Use proxy in browser to support HttpOnly cookies and avoid CORS/CSP issues
const API_BASE_URL = (typeof window !== 'undefined')
  ? '/api/proxy'
  : (process.env.NEXT_PUBLIC_API_URL || '');

if (!API_BASE_URL && typeof window !== 'undefined') {
  console.warn("API base URL is not set");
}

export type FetchOptions = RequestInit & {
  token?: string;
};

export async function apiClient<T>(
  endpoint: string,
  options: FetchOptions = {}
): Promise<T | null> {
  // Ensure endpoint starts with / for joining
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  const url = `${API_BASE_URL}${cleanEndpoint}`;

  // If in browser, the proxy handles the token from HttpOnly cookie automatically.
  // We only pull token from options if manually provided (e.g. for specific overrides).
  let token = options.token;

  const headers = new Headers(options.headers);
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }
  if (!headers.has('Content-Type') && options.body && !(options.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json');
  }

  const res = await fetch(url, {
    ...options,
    headers,
  });

  if (res.status === 401) {
    if (typeof window !== 'undefined') {
      window.location.href = '/login';
    }
  }

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`API Error ${res.status}: ${errorText}`);
  }

  const contentLength = res.headers.get('content-length');
  if (contentLength === '0') return null as T;

  try {
    return await res.json() as T;
  } catch (e) {
    return null as T;
  }
}
