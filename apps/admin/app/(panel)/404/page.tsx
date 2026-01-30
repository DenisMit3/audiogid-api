
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Link from 'next/link'

export default function NotFoundPage() {
    return (
        <div className="flex h-full w-full items-center justify-center p-10">
            <Card className="w-[400px]">
                <CardHeader>
                    <CardTitle>404 Not Found</CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="mb-4 text-muted-foreground">
                        Страница не найдена.
                    </p>
                    <Button asChild>
                        <Link href="/dashboard">На главную</Link>
                    </Button>
                </CardContent>
            </Card>
        </div>
    )
}




