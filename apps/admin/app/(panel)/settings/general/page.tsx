
'use client';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function GeneralSettings() {
    return (
        <div className="space-y-6 max-w-2xl p-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Основные настройки</h1>
                <p className="text-muted-foreground">Базовая конфигурация приложения.</p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Идентификация приложения</CardTitle>
                    <CardDescription>Отображается в письмах и метаданных приложения.</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="grid gap-2">
                        <Label>Название приложения</Label>
                        <Input defaultValue="Аудиогид" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Email поддержки</Label>
                        <Input defaultValue="support@audiogid.app" />
                    </div>
                </CardContent>
            </Card>

            <div className="flex justify-end">
                <Button>Сохранить</Button>
            </div>
        </div>
    );
}




