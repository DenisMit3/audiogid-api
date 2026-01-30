
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
    SortingState
} from '@tanstack/react-table';
import { Plus, Search, MoreHorizontal, Edit, Trash, Map } from 'lucide-react';
import Link from 'next/link';
import { format } from 'date-fns';

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
    DropdownMenuSeparator
} from "@/components/ui/dropdown-menu";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import { useToast } from "@/components/ui/use-toast";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "https://audiogid-api.vercel.app/v1";

type City = {
    id: string;
    slug: string;
    name_ru: string;
    is_active: boolean;
    poi_count: number;
    tour_count: number;
    updated_at: string;
};

const fetchCities = async ({ page, search }: { page: number, search: string }) => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    params.append('per_page', '20');
    if (search) params.append('search', search);

    const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';

    const res = await fetch(`${API_URL}/admin/cities?${params.toString()}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Failed to fetch cities');
    return res.json();
};

const deleteCity = async (id: string) => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/cities/${id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) {
        const error = await res.json();
        throw new Error(error.detail || 'Failed to delete city');
    }
    return res.json();
};

export default function CitiesListPage() {
    const [sorting, setSorting] = useState<SortingState>([]);
    const [search, setSearch] = useState('');
    const [page, setPage] = useState(1);
    const { toast } = useToast();

    const queryClient = useQueryClient();

    const { data, isLoading } = useQuery({
        queryKey: ['cities', page, search],
        queryFn: () => fetchCities({ page, search }),
        placeholderData: (prev) => prev
    });

    const deleteMutation = useMutation({
        mutationFn: deleteCity,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['cities'] });
            toast({ title: "City deleted successfully" });
        },
        onError: (error) => {
            toast({
                title: "Failed to delete city",
                description: error.message,
                variant: "destructive"
            });
        }
    });

    const columns: ColumnDef<City>[] = [
        {
            accessorKey: "slug",
            header: "Slug",
            cell: ({ row }) => <code className="text-xs bg-muted p-1 rounded">{row.getValue("slug")}</code>,
        },
        {
            accessorKey: "name_ru",
            header: "Name (RU)",
            cell: ({ row }) => <div className="font-medium">{row.getValue("name_ru")}</div>,
        },
        {
            header: "Content",
            cell: ({ row }) => (
                <div className="flex gap-2">
                    <Badge variant="outline">{row.original.poi_count} POIs</Badge>
                    <Badge variant="outline">{row.original.tour_count} Tours</Badge>
                </div>
            )
        },
        {
            accessorKey: "is_active",
            header: "Status",
            cell: ({ row }) => {
                const isActive = row.getValue("is_active");
                return (
                    <Badge variant={isActive ? "default" : "secondary"}>
                        {isActive ? "Active" : "Inactive"}
                    </Badge>
                );
            },
        },
        {
            accessorKey: "updated_at",
            header: "Updated",
            cell: ({ row }) => <span className="text-xs text-muted-foreground">{format(new Date(row.original.updated_at), "dd MMM yyyy")}</span>,
        },
        {
            id: "actions",
            cell: ({ row }) => {
                const city = row.original;
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
                                <Link href={`/cities/${city.id}`}>
                                    <Edit className="mr-2 h-4 w-4" /> Edit
                                </Link>
                            </DropdownMenuItem>
                            <DropdownMenuItem asChild>
                                <Link href={`/content/pois?city=${city.slug}`}>
                                    <Map className="mr-2 h-4 w-4" /> View Content
                                </Link>
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                                className="text-destructive focus:text-destructive"
                                onClick={() => {
                                    if (confirm(`Are you sure you want to delete ${city.name_ru}?`)) {
                                        deleteMutation.mutate(city.id);
                                    }
                                }}
                            >
                                <Trash className="mr-2 h-4 w-4" /> Delete
                            </DropdownMenuItem>
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
        pageCount: data?.pages || -1,
        manualPagination: true,
        state: {
            sorting,
        },
    });

    return (
        <div className="space-y-4 p-4">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold tracking-tight">Cities & Regions</h1>
                <Link href="/cities/new">
                    <Button>
                        <Plus className="mr-2 h-4 w-4" /> Add City
                    </Button>
                </Link>
            </div>

            <div className="flex items-center gap-2">
                <div className="relative flex-1 max-w-sm">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                        placeholder="Search cities..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="pl-8"
                    />
                </div>
            </div>

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
                                    No cities found.
                                </TableCell>
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </div>

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
