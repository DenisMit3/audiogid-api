
"use client"

import { DataTable } from "@/components/data-table"
import { ColumnDef } from "@tanstack/react-table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Plus } from "lucide-react"
import { useRouter } from "next/navigation"
import useSWR from "swr"
import Link from "next/link"

const fetcher = (url: string) => fetch(url).then(r => r.json())

export default function ToursPage() {
    const router = useRouter();
    const { data: tours, error, mutate } = useSWR('/api/proxy/admin/tours', fetcher);

    const columns: ColumnDef<any>[] = [
        {
            id: "select",
            header: ({ table }) => (
                <Checkbox
                    checked={table.getIsAllPageRowsSelected()}
                    onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                    aria-label="Select all"
                />
            ),
            cell: ({ row }) => (
                <Checkbox
                    checked={row.getIsSelected()}
                    onCheckedChange={(value) => row.toggleSelected(!!value)}
                    aria-label="Select row"
                />
            ),
            enableSorting: false,
            enableHiding: false,
        },
        {
            accessorKey: "title_ru",
            header: "Title",
            cell: ({ row }) => <div className="font-medium">{row.getValue("title_ru")}</div>,
        },
        {
            accessorKey: "duration_minutes",
            header: "Duration (min)",
        },
        {
            accessorKey: "status",
            header: "Status",
            cell: ({ row }) => {
                const published = row.original.published_at;
                return (
                    <div className="flex gap-1">
                        {published ? <Badge>Published</Badge> : <Badge variant="secondary">Draft</Badge>}
                    </div>
                )
            }
        },
        {
            id: "actions",
            cell: ({ row }) => {
                const tour = row.original
                return (
                    <Button variant="ghost" size="sm" asChild>
                        <Link href={`/content/tours/${tour.id}`}>Edit</Link>
                    </Button>
                )
            },
        },
    ]

    const handleBulk = async (rows: any[], action: string) => {
        const ids = rows.map(r => r.id);
        const endpoint = action === 'publish' ? 'bulk-publish' : 'bulk-unpublish';

        await fetch(`/api/proxy/admin/tours/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ids })
        });
        mutate();
    }

    if (error) return <div>Failed to load</div>
    if (!tours) return <div>Loading...</div>

    return (
        <div className="w-full">
            <div className="flex items-center justify-between py-4">
                <h1 className="text-2xl font-bold">Tours</h1>
                <Button asChild>
                    <Link href="/content/tours/new"><Plus className="mr-2 h-4 w-4" /> Create Tour</Link>
                </Button>
            </div>
            <DataTable columns={columns} data={tours} onBulkAction={handleBulk} />
        </div>
    )
}
