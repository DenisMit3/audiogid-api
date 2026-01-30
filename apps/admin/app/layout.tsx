'use client';
import React from 'react';
import './globals.css';

import Providers from './providers';

import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error }: { error: Error }) {
    return (
        <div>
            <h1>Something went wrong</h1>
            <pre>{error.message}</pre>
        </div>
    );
}

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <html lang="ru" suppressHydrationWarning>
            <body className="font-sans antialiased">
                <ErrorBoundary FallbackComponent={ErrorFallback}>
                    <Providers>
                        {children}
                    </Providers>
                </ErrorBoundary>
            </body>
        </html>
    );
}




