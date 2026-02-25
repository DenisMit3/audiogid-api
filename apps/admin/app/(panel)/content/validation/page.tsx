
"use client"

import { DataTable } from "@/components/data-table"
import { ColumnDef } from "@tanstack/react-table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { AlertCircle, CheckCircle, RotateCw } from "lucide-react"
import { useQuery } from '@tanstack/react-query';
import Link from "next/link"
import { useState } from "react"
import { useToast } from "@/components/ui/use-toast"

const API_URL = '/api/proxy';


type ValidationIssue = {
    id: string;
    entity_id: string;
    entity_type: string;
    issue_type: string;
    severity: 'blocker' | 'warning' | 'info';
    message: string;
};

const fetchIssues = async (): Promise<ValidationIssue[]> => {
    // throw removed for build
    const res = await fetch(`${API_URL}/admin/content/issues`, {
        credentials: 'include'
    });
    if (!res.ok) throw new Error("Не удалось загрузить проблемы");
    return res.json();
};

export default function ValidationPage() {
    const { toast } = useToast();
    const { data: issues, isLoading, error, refetch } = useQuery({
        queryKey: ['validation-issues'],
        queryFn: fetchIssues
    });

    const [scanning, setScanning] = useState(false);

    const runScan = async () => {
        setScanning(true);
        try {
            await refetch();
            toast({ title: "Сканирование завершено", description: "Проблемы валидации обновлены." });
        } catch (e) {
            toast({ title: "Сканирование не удалось", variant: "destructive" });
        } finally {
            setScanning(false);
        }
    };

    const columns: ColumnDef<ValidationIssue>[] = [
        {
            accessorKey: "severity",
            header: "Критичность",
            cell: ({ row }) => {
                const s = row.getValue("severity") as string;
                if (s === 'blocker') return <Badge variant="destructive">Блокер</Badge>;
                if (s === 'warning') return <Badge className="bg-yellow-500 hover:bg-yellow-600">Предупреждение</Badge>;
                return <Badge variant="secondary">Инфо</Badge>;
            }
        },
        {
            accessorKey: "entity_type",
            header: "Тип",
            cell: ({ row }) => <span className="uppercase text-xs font-bold">{row.getValue("entity_type")}</span>
        },
        {
            accessorKey: "issue_type",
            header: "Проблема",
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue("issue_type")}</span>
        },
        {
            accessorKey: "message",
            header: "Сообщение",
        },
        {
            id: "actions",
            cell: ({ row }) => {
                const i = row.original;
                const link = i.entity_type === 'tour' ? `/content/tours/${i.entity_id}` : `/content/pois/${i.entity_id}`;
                return (
                    <Button variant="ghost" size="sm" asChild>
                        <Link href={link}>Исправить</Link>
                    </Button>
                )
            },
        },
    ]

    return (
        <div className="w-full space-y-4 p-6">
            <div className="flex items-center justify-between py-4">
                <div>
                    <h1 className="text-2xl font-bold">Валидация контента</h1>
                    <p className="text-muted-foreground">Глобальный отчёт проверки качества</p>
                </div>
                <Button onClick={runScan} disabled={scanning || isLoading}>
                    {scanning || isLoading ? <RotateCw className="mr-2 h-4 w-4 animate-spin" /> : <RotateCw className="mr-2 h-4 w-4" />}
                    Запустить сканирование
                </Button>
            </div>

            {error && <div className="text-red-500">Не удалось загрузить проблемы: {(error as Error).message}</div>}

            {isLoading ? (
                <div>Загрузка проблем...</div>
            ) : (
                <div className="rounded-md border">
                    <DataTable columns={columns} data={issues || []} />
                </div>
            )}
        </div>
    )
}




