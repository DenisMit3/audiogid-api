
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
    ColumnDef,
    flexRender,
    getCoreRowModel,
    useReactTable,
    getPaginationRowModel,
    getSortedRowModel,
    getFilteredRowModel,
    SortingState
} from '@tanstack/react-table';
import { Plus, Search, MoreHorizontal, Edit, Trash, Eye, MapPin } from 'lucide-react';
import Link from 'next/link';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow
} from "@/components/ui/table";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";

const API_URL = process.env.NEXT_PUBLIC_API_URL;

type Poi = {
    id: string;
    title_ru: string;
    city_slug: string;
    status: string;
    published_at: string | null;
    lat: number | null;
    lon: number | null;
    updated_at: string;
};

// Fetcher
const fetchPois = async ({ page, search, status }: { page: number, search: string, status: string }) => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    params.append('per_page', '20');
    if (search) params.append('search', search);
    if (status && status !== 'all') params.append('status', status);

    const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';

    const res = await fetch(`${API_URL}/admin/pois?${params.toString()}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Failed to fetch POIs');
    return res.json();
};

export default function PoiListPage() {
    const [sorting, setSorting] = useState<SortingState>([]);
    const [search, setSearch] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [rowSelection, setRowSelection] = useState({});
    const [page, setPage] = useState(1);

    const queryClient = useQueryClient();

    const { data, isLoading } = useQuery({
        queryKey: ['pois', page, search, statusFilter],
        queryFn: () => fetchPois({ page, search, status: statusFilter }),
        placeholderData: (prev) => prev
    });

    // Columns
    const columns: ColumnDef<Poi>[] = [
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
            accessorKey: "city_slug",
            header: "City",
        },
        {
            accessorKey: "published_at",
            header: "Status",
            cell: ({ row }) => {
                const isPublished = !!row.getValue("published_at");
                return (
                    <Badge variant={isPublished ? "default" : "secondary"}>
                        {isPublished ? "Published" : "Draft"}
                    </Badge>
                );
            },
        },
        {
            accessorKey: "lat",
            header: "Geo",
            cell: ({ row }) => {
                const lat = row.original.lat;
                const lon = row.original.lon;
                if (!lat || !lon) return <span className="text-muted-foreground text-xs">No Geo</span>;
                return (
                    <div className="flex items-center gap-1 text-xs">
                        <MapPin className="w-3 h-3" />
                        {lat.toFixed(4)}, {lon.toFixed(4)}
                    </div>
                );
            }
        },
        {
            id: "actions",
            cell: ({ row }) => {
                const poi = row.original;
                return (
                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                                <span className="sr-only">Open menu</span>
                                <MoreHorizontal className="h-4 w-4" />
                            </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                            <DropdownMenuLabel>Actions</DropdownMenuLabel>
                            <DropdownMenuItem asChild>
                                <Link href={`/content/pois/${poi.id}`}>
                                    <Edit className="mr-2 h-4 w-4" /> Edit
                                </Link>
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => navigator.clipboard.writeText(poi.id)}>
                                Copy ID
                            </DropdownMenuItem>
                            {/* Add Delete/Publish here */}
                        </DropdownMenuContent>
                    </DropdownMenu>
                );
            },
        },
    ];

    const table = useReactTable({
        data: data?.items || [],
        columns,
        getCoreRowModel: getCoreRowModel(),
        getPaginationRowModel: getPaginationRowModel(),
        onSortingChange: setSorting,
        getSortedRowModel: getSortedRowModel(),
        onRowSelectionChange: setRowSelection,
        state: {
            sorting,
            rowSelection,
        },
        pageCount: data?.pages || -1,
        manualPagination: true,
    });

    return (
        <div className="space-y-4 p-4">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold tracking-tight">Points of Interest</h1>
                <Link href="/content/pois/new">
                    <Button>
                        <Plus className="mr-2 h-4 w-4" /> Add POI
                    </Button>
                </Link>
            </div>

            <div className="flex items-center gap-2">
                <div className="relative flex-1 max-w-sm">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                        placeholder="Search POIs..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="pl-8"
                    />
                </div>
                {/* Add City Filter Select here */}
            </div>

            {Object.keys(rowSelection).length > 0 && (
                <div className="bg-muted/50 p-2 rounded flex items-center gap-2">
                    <span className="text-sm font-medium ml-2">
                        {Object.keys(rowSelection).length} selected
                    </span>
                    <div className="flex-1" />
                    <Button
                        size="sm"
                        variant="default"
                        onClick={async () => {
                            const ids = Object.keys(rowSelection);
                            await fetch(`${API_URL}/admin/pois/bulk-publish`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                                },
                                body: JSON.stringify({ ids })
                            });
                            queryClient.invalidateQueries({ queryKey: ['pois'] });
                            setRowSelection({});
                        }}
                    >
                        Publish
                    </Button>
                    <Button
                        size="sm"
                        variant="secondary"
                        onClick={async () => {
                            const ids = Object.keys(rowSelection);
                            await fetch(`${API_URL}/admin/pois/bulk-unpublish`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                                },
                                body: JSON.stringify({ ids })
                            });
                            queryClient.invalidateQueries({ queryKey: ['pois'] });
                            setRowSelection({});
                        }}
                    >
                        Unpublish
                    </Button>
                    <Button
                        size="sm"
                        variant="destructive"
                        onClick={async () => {
                            if (!confirm("Are you sure?")) return;
                            const ids = Object.keys(rowSelection);
                            await fetch(`${API_URL}/admin/pois/bulk-delete`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                                },
                                body: JSON.stringify({ ids })
                            });
                            queryClient.invalidateQueries({ queryKey: ['pois'] });
                            setRowSelection({});
                        }}
                    >
                        Delete
                    </Button>
                </div>
            )}

            <div className="rounded-md border bg-white">
                <Table>
                    <TableHeader>
                        {table.getHeaderGroups().map((headerGroup) => (
                            <TableRow key={headerGroup.id}>
                                {headerGroup.headers.map((header) => {
                                    return (
                                        <TableHead key={header.id}>
                                            {header.isPlaceholder
                                                ? null
                                                : flexRender(
                                                    header.column.columnDef.header,
                                                    header.getContext()
                                                )}
                                        </TableHead>
                                    );
                                })}
                            </TableRow>
                        ))}
                    </TableHeader>
                    <TableBody>
                        {isLoading ? (
                            <TableRow>
                                <TableCell colSpan={columns.length} className="h-24 text-center">
                                    Loading...
                                </TableCell>
                            </TableRow>
                        ) : table.getRowModel().rows?.length ? (
                            table.getRowModel().rows.map((row) => (
                                <TableRow
                                    key={row.id}
                                    data-state={row.getIsSelected() && "selected"}
                                >
                                    {row.getVisibleCells().map((cell) => (
                                        <TableCell key={cell.id}>
                                            {flexRender(
                                                cell.column.columnDef.cell,
                                                cell.getContext()
                                            )}
                                        </TableCell>
                                    ))}
                                </TableRow>
                            ))
                        ) : (
                            <TableRow>
                                <TableCell colSpan={columns.length} className="h-24 text-center">
                                    No results.
                                </TableCell>
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </div>

            {/* Pagination Controls */}
            <div className="flex items-center justify-end gap-2">
                <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page === 1}
                >
                    Previous
                </Button>
                <div className="text-sm">Page {page} of {data?.pages || 1}</div>
                <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setPage((p) => p + 1)}
                    disabled={!data || page >= data.pages}
                >
                    Next
                </Button>
            </div>
        </div>
    );
}

