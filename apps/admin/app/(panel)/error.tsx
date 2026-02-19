'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { AlertCircle, RefreshCw, Home } from 'lucide-react'

export default function Error({
    error,
    reset,
}: {
    error: Error & { digest?: string }
    reset: () => void
}) {
    useEffect(() => {
        console.error('Panel Error:', error)
    }, [error])

    return (
        <div className="flex h-full min-h-[60vh] flex-col items-center justify-center p-8 text-center fade-in">
            {/* Background decoration */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-red-500/5 rounded-full blur-3xl"></div>
                <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-orange-500/5 rounded-full blur-3xl"></div>
            </div>

            <div className="relative z-10 flex flex-col items-center">
                {/* Error Icon */}
                <div className="relative mb-6">
                    <div className="absolute inset-0 bg-red-500/20 rounded-full blur-xl animate-pulse"></div>
                    <div className="relative bg-gradient-to-br from-red-50 to-red-100 dark:from-red-950/50 dark:to-red-900/30 p-5 rounded-2xl border border-red-200/50 dark:border-red-800/50 shadow-xl">
                        <AlertCircle className="h-10 w-10 text-red-500" />
                    </div>
                </div>

                {/* Error Message */}
                <h2 className="text-3xl font-bold tracking-tight mb-3">Что-то пошло не так</h2>
                <p className="text-muted-foreground max-w-md mb-8 text-lg">
                    {error.message || "Произошла непредвиденная ошибка. Пожалуйста, попробуйте снова."}
                </p>

                {/* Error Code */}
                {error.digest && (
                    <div className="mb-6 px-4 py-2 rounded-lg bg-muted/50 border border-border/50">
                        <code className="text-xs text-muted-foreground font-mono">
                            Код ошибки: {error.digest}
                        </code>
                    </div>
                )}

                {/* Action Buttons */}
                <div className="flex gap-4">
                    <Button onClick={reset} className="shadow-lg shadow-primary/20 group">
                        <RefreshCw className="mr-2 h-4 w-4 group-hover:rotate-180 transition-transform duration-500" />
                        Попробовать снова
                    </Button>
                    <Button onClick={() => window.location.href = '/dashboard'} variant="outline">
                        <Home className="mr-2 h-4 w-4" />
                        На главную
                    </Button>
                </div>
            </div>
        </div>
    )
}




