'use client';

import { Database, Download, Upload, AlertTriangle } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

export default function BackupSettingsPage() {
    return (
        <div className="space-y-6 p-6 max-w-4xl">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Резервные копии базы данных</h1>
                <p className="text-muted-foreground">Управление снимками данных и политиками хранения.</p>
            </div>

            <Alert>
                <AlertTriangle className="h-4 w-4" />
                <AlertTitle>Управляемая инфраструктура</AlertTitle>
                <AlertDescription>
                    Ваша база данных размещена на <strong>Neon Serverless Postgres</strong>.
                    Восстановление на момент времени (PITR) включено автоматически с хранением 7 дней.
                </AlertDescription>
            </Alert>

            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Upload className="w-5 h-5" />
                            Прямой экспорт
                        </CardTitle>
                        <CardDescription>Скачать полный SQL-дамп текущего состояния базы данных.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="bg-slate-950 text-slate-50 p-4 rounded-md font-mono text-xs overflow-x-auto">
                            pg_dump -h ep-plain-frog-123456.us-east-1.aws.neon.tech -U admin audiogid {'>'} backup_$(date +%F).sql
                        </div>
                    </CardContent>
                    <CardFooter>
                        <Button variant="outline" className="w-full" onClick={() => {
                            fetch('/api/proxy/admin/pois/export')
                                .then(res => res.blob())
                                .then(blob => {
                                    const url = window.URL.createObjectURL(blob);
                                    const a = document.createElement('a');
                                    a.href = url;
                                    a.download = `pois_export_${new Date().toISOString().split('T')[0]}.csv`;
                                    a.click();
                                });
                        }}>
                            <Download className="mr-2 w-4 h-4" />
                            Скачать CSV-архивы
                        </Button>
                    </CardFooter>
                </Card>

                <Card className="opacity-75 relative overflow-hidden">
                    <div className="absolute inset-0 bg-slate-50/50 backdrop-blur-[1px] flex items-center justify-center z-10">
                        <span className="bg-slate-900 text-white px-3 py-1 rounded-full text-xs font-medium">Скоро</span>
                    </div>
                    <CardHeader>
                        <CardTitle>Точка восстановления</CardTitle>
                        <CardDescription>Откатить базу данных к определённому моменту времени.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <p className="text-sm text-muted-foreground">
                            Восстановление перезапишет текущие данные. Это действие нельзя отменить без другой резервной копии.
                        </p>
                    </CardContent>
                    <CardFooter>
                        <Button variant="destructive" className="w-full" disabled>
                            Восстановить данные...
                        </Button>
                    </CardFooter>
                </Card>
            </div>
        </div>
    );
}




