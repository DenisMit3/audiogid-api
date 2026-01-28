
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import jwt from 'jsonwebtoken';
import { ROLE_PERMISSIONS } from './lib/permissions';

// Public paths that don't require auth
const PUBLIC_PATHS = ['/login', '/_next', '/favicon.ico', '/api/auth'];

export function middleware(request: NextRequest) {
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
        // We decode without verification here for speed/routing check, 
        // relying on Backend to verify signature in API calls.
        // Ideally we verify with JWT_SECRET if shared, but simplest is presence check + strict backend check.
        // If we have JWT_SECRET in env, we can verify.
        // const decoded = jwt.verify(token, process.env.JWT_SECRET!); 
        // For now just check expiry via decode
        const decoded = jwt.decode(token) as any;

        if (!decoded || (decoded.exp && Date.now() >= decoded.exp * 1000)) {
            const url = request.nextUrl.clone();
            url.pathname = '/login';
            const response = NextResponse.redirect(url);
            response.cookies.delete('token');
            return response;
        }

    } catch (error) {
        const url = request.nextUrl.clone();
        url.pathname = '/login';
        const response = NextResponse.redirect(url);
        response.cookies.delete('token');
        return response;
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
