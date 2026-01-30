
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Link from 'next/link'

export default function ForbiddenPage() {
    return (
        <div className="flex h-full w-full items-center justify-center p-10">
            <Card className="w-[400px]">
                <CardHeader>
                    <CardTitle className="text-red-500">403 Forbidden</CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="mb-4 text-muted-foreground">
                        У вас нет прав для просмотра этой страницы.
                    </p>
                    <Button asChild>
                        <Link href="/dashboard">На главную</Link>
                    </Button>
                </CardContent>
            </Card>
        </div>
    )
}




