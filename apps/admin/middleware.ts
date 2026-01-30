
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { jwtVerify } from 'jose';

// Public paths that don't require auth
const PUBLIC_PATHS = ['/login', '/_next', '/favicon.ico', '/api/auth'];

export async function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    if (PUBLIC_PATHS.some(path => pathname.startsWith(path))) {
        return NextResponse.next();
    }

    const token = request.cookies.get('token')?.value;

    if (!token) {
        const url = request.nextUrl.clone();
        url.pathname = '/login';
        return NextResponse.redirect(url);
    }

    try {
        // Verify JWT signature using Jose
        // Allow fallback for dev, but in prod it should be set
        const secretText = process.env.JWT_SECRET;
        if (!secretText) throw new Error("JWT_SECRET is required");
        const secret = new TextEncoder().encode(secretText);
        await jwtVerify(token, secret);

        return NextResponse.next();

    } catch (error) {
        console.error('Middleware Auth Error:', error);
        const url = request.nextUrl.clone();
        url.pathname = '/login';
        const response = NextResponse.redirect(url);
        response.cookies.delete('token');
        return response;
    }
}

export const config = {
    matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
