'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { AlertCircle } from 'lucide-react'

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
        <div className="flex h-full flex-col items-center justify-center p-8 text-center animate-in fade-in duration-500">
            <div className="bg-red-50 p-4 rounded-full mb-4">
                <AlertCircle className="h-12 w-12 text-red-500" />
            </div>
            <h2 className="text-2xl font-bold tracking-tight mb-2">Что-то пошло не так!</h2>
            <p className="text-muted-foreground max-w-md mb-6">
                {error.message || "Произошла непредвиденная ошибка в админ-панели. Пожалуйста, попробуйте снова."}
            </p>
            <div className="flex gap-4">
                <Button onClick={reset} variant="default">
                    Попробовать снова
                </Button>
                <Button onClick={() => window.location.href = '/dashboard'} variant="outline">
                    На главную
                </Button>
            </div>
        </div>
    )
}




