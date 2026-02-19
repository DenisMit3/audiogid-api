'use client';
import React from 'react';
import './globals.css';

import Providers from './providers';
import { DebugPanel } from '@/components/debug-panel';
import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error }: { error: Error }) {
    return (
        <div className="min-h-screen flex items-center justify-center bg-background p-4">
            <div className="max-w-md w-full p-6 rounded-lg border border-destructive/50 bg-destructive/5">
                <h1 className="text-lg font-bold text-destructive mb-2">❌ Критическая ошибка</h1>
                <pre className="text-sm text-destructive/80 whitespace-pre-wrap break-all bg-destructive/10 p-3 rounded">{error.message}</pre>
                <pre className="mt-2 text-xs text-muted-foreground whitespace-pre-wrap break-all max-h-[200px] overflow-auto">{error.stack}</pre>
                <button 
                    onClick={() => window.location.reload()} 
                    className="mt-4 w-full py-2 bg-destructive text-white rounded hover:bg-destructive/90"
                >
                    Перезагрузить
                </button>
            </div>
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
                        <DebugPanel />
                    </Providers>
                </ErrorBoundary>
            </body>
        </html>
    );
}




