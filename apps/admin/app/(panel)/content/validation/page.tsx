
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

const API_URL = process.env.NEXT_PUBLIC_API_URL;


type ValidationIssue = {
    id: string;
    entity_id: string;
    entity_type: string;
    issue_type: string;
    severity: 'blocker' | 'warning' | 'info';
    message: string;
};

const fetchIssues = async (): Promise<ValidationIssue[]> => {
    if (!API_URL) throw new Error("NEXT_PUBLIC_API_URL is required");
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/content/issues`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to fetch issues");
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
            toast({ title: "Scan Complete", description: "Validation issues updated." });
        } catch (e) {
            toast({ title: "Scan Failed", variant: "destructive" });
        } finally {
            setScanning(false);
        }
    };

    const columns: ColumnDef<ValidationIssue>[] = [
        {
            accessorKey: "severity",
            header: "Severity",
            cell: ({ row }) => {
                const s = row.getValue("severity") as string;
                if (s === 'blocker') return <Badge variant="destructive">Blocker</Badge>;
                if (s === 'warning') return <Badge className="bg-yellow-500 hover:bg-yellow-600">Warning</Badge>;
                return <Badge variant="secondary">Info</Badge>;
            }
        },
        {
            accessorKey: "entity_type",
            header: "Type",
            cell: ({ row }) => <span className="uppercase text-xs font-bold">{row.getValue("entity_type")}</span>
        },
        {
            accessorKey: "issue_type",
            header: "Issue",
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue("issue_type")}</span>
        },
        {
            accessorKey: "message",
            header: "Message",
        },
        {
            id: "actions",
            cell: ({ row }) => {
                const i = row.original;
                const link = i.entity_type === 'tour' ? `/content/tours/${i.entity_id}` : `/content/pois/${i.entity_id}`;
                return (
                    <Button variant="ghost" size="sm" asChild>
                        <Link href={link}>Fix</Link>
                    </Button>
                )
            },
        },
    ]

    return (
        <div className="w-full space-y-4 p-6">
            <div className="flex items-center justify-between py-4">
                <div>
                    <h1 className="text-2xl font-bold">Content Validation</h1>
                    <p className="text-muted-foreground">Global quality check report</p>
                </div>
                <Button onClick={runScan} disabled={scanning || isLoading}>
                    {scanning || isLoading ? <RotateCw className="mr-2 h-4 w-4 animate-spin" /> : <RotateCw className="mr-2 h-4 w-4" />}
                    Run Scan
                </Button>
            </div>

            {error && <div className="text-red-500">Failed to load issues: {(error as Error).message}</div>}

            {isLoading ? (
                <div>Loading issues...</div>
            ) : (
                <div className="rounded-md border">
                    <DataTable columns={columns} data={issues || []} />
                </div>
            )}
        </div>
    )
}


