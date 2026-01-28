
"use client"

import { DataTable } from "@/components/data-table"
import { ColumnDef } from "@tanstack/react-table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { AlertCircle, CheckCircle, RotateCw } from "lucide-react"
import useSWR from "swr"
import Link from "next/link"
import { useState } from "react"

const fetcher = (url: string) => fetch(url).then(r => r.json())

export default function ValidationPage() {
    const { data: issues, error, mutate } = useSWR('/api/proxy/admin/content/issues', fetcher);
    const [scanning, setScanning] = useState(false);

    const runScan = async () => {
        setScanning(true);
        try {
            await fetch('/api/proxy/admin/content/validation-report', { method: 'POST' });
            mutate();
        } finally {
            setScanning(false);
        }
    };

    const columns: ColumnDef<any>[] = [
        {
            accessorKey: "severity",
            header: "Severity",
            cell: ({ row }) => {
                const s = row.getValue("severity") as string;
                return s === 'blocker' ? <Badge variant="destructive">{s}</Badge> : <Badge variant="secondary">{s}</Badge>
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
        <div className="w-full space-y-4">
            <div className="flex items-center justify-between py-4">
                <div>
                    <h1 className="text-2xl font-bold">Content Validation</h1>
                    <p className="text-muted-foreground">Global quality check report</p>
                </div>
                <Button onClick={runScan} disabled={scanning}>
                    {scanning ? <RotateCw className="mr-2 h-4 w-4 animate-spin" /> : <RotateCw className="mr-2 h-4 w-4" />}
                    Run Scan
                </Button>
            </div>

            {error && <div>Failed to load issues</div>}
            {!issues ? (
                <div>Loading...</div>
            ) : (
                <DataTable columns={columns} data={issues} />
            )}
        </div>
    )
}
