import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// Public paths that don't require auth
const PUBLIC_PATHS = ['/login', '/_next', '/favicon.ico', '/api/auth'];

export async function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    // Allow public paths
    if (PUBLIC_PATHS.some(path => pathname.startsWith(path))) {
        return NextResponse.next();
    }

    // Check for token cookie (validation happens on API calls)
    const token = request.cookies.get('token')?.value;

    if (!token) {
        const url = request.nextUrl.clone();
        url.pathname = '/login';
        return NextResponse.redirect(url);
    }

    // Token exists - allow access, API will validate on each request
    return NextResponse.next();
}

export const config = {
    matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
