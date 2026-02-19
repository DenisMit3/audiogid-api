
'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
    ColumnDef,
    flexRender,
    getCoreRowModel,
    useReactTable,
    getPaginationRowModel,
    getSortedRowModel,
    SortingState
} from '@tanstack/react-table';
import { Plus, Search, MoreHorizontal, Edit, Trash, Map, Clock } from 'lucide-react';
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

const API_URL = '/api/proxy';

type Tour = {
    id: string;
    title_ru: string;
    city_slug: string;
    duration_minutes: number;
    published_at: string | null;
    updated_at: string;
};

const fetchTours = async ({ page, search, status }: { page: number, search: string, status: string }) => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    params.append('per_page', '20');
    if (search) params.append('search', search);
    if (status && status !== 'all') params.append('status', status);

    const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';

    const res = await fetch(`${API_URL}/admin/tours?${params.toString()}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Не удалось загрузить туры');
    return res.json();
};

export default function TourListPage() {
    const [sorting, setSorting] = useState<SortingState>([]);
    const [search, setSearch] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [page, setPage] = useState(1);

    const { data, isLoading } = useQuery({
        queryKey: ['tours', page, search, statusFilter],
        queryFn: () => fetchTours({ page, search, status: statusFilter }),
        placeholderData: (prev) => prev
    });

    const columns: ColumnDef<Tour>[] = [
        {
            accessorKey: "title_ru",
            header: "Название",
            cell: ({ row }) => <div className="font-medium">{row.getValue<string>("title_ru")}</div>,
        },
        {
            accessorKey: "city_slug",
            header: "Город",
        },
        {
            accessorKey: "duration_minutes",
            header: "Длительность",
            cell: ({ row }) => (
                <div className="flex items-center gap-1 text-xs">
                    <Clock className="w-3 h-3" />
                    {row.getValue("duration_minutes") || '-'} мин
                </div>
            )
        },
        {
            accessorKey: "published_at",
            header: "Статус",
            cell: ({ row }) => {
                const isPublished = !!row.getValue("published_at");
                return (
                    <Badge variant={isPublished ? "default" : "secondary"}>
                        {isPublished ? "Опубликовано" : "Черновик"}
                    </Badge>
                );
            },
        },
        {
            id: "actions",
            cell: ({ row }) => {
                const tour = row.original;
                return (
                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                                <span className="sr-only">Открыть меню</span>
                                <MoreHorizontal className="h-4 w-4" />
                            </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                            <DropdownMenuLabel>Действия</DropdownMenuLabel>
                            <DropdownMenuItem asChild>
                                <Link href={`/content/tours/${tour.id}`}>
                                    <Edit className="mr-2 h-4 w-4" /> Редактировать
                                </Link>
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => navigator.clipboard.writeText(tour.id)}>
                                Копировать ID
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
        state: {
            sorting,
        },
        pageCount: data?.pages || -1,
        manualPagination: true,
    });

    return (
        <div className="space-y-4 p-4">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold tracking-tight">Аудиотуры</h1>
                <Link href="/content/tours/new">
                    <Button>
                        <Plus className="mr-2 h-4 w-4" /> Создать тур
                    </Button>
                </Link>
            </div>

            <div className="flex items-center gap-2">
                <div className="relative flex-1 max-w-sm">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                        placeholder="Поиск туров..."
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
                                    Загрузка...
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
                                    Туры не найдены.
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
                    Назад
                </Button>
                <div className="text-sm">Страница {page} из {data?.pages || 1}</div>
                <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setPage((p) => p + 1)}
                    disabled={!data || page >= data.pages}
                >
                    Вперёд
                </Button>
            </div>
        </div>
    );
}




