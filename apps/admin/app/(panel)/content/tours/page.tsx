
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
import { Plus, Search, Edit, Trash2, Clock, Eye, EyeOff } from 'lucide-react';
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
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from "@/components/ui/alert-dialog";
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
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [tourToDelete, setTourToDelete] = useState<Tour | null>(null);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);
    const queryClient = useQueryClient();

    const { data, isLoading } = useQuery({
        queryKey: ['tours', page, search, statusFilter],
        queryFn: () => fetchTours({ page, search, status: statusFilter }),
        placeholderData: (prev) => prev
    });

    // Delete mutation
    const deleteMutation = useMutation({
        mutationFn: async (tourId: string) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/tours/${tourId}`, {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${token}` }
            });
            if (!res.ok) throw new Error('Не удалось удалить тур');
            return res.json();
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['tours'] });
            setDeleteDialogOpen(false);
            setTourToDelete(null);
        }
    });

    // Publish/Unpublish mutation
    const togglePublishMutation = useMutation({
        mutationFn: async ({ tourId, action }: { tourId: string, action: 'publish' | 'unpublish' }) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/tours/${tourId}/${action}`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${token}` }
            });
            const data = await res.json();
            if (!res.ok) {
                // Формируем понятное сообщение об ошибке
                if (data.error === 'TOUR_PUBLISH_BLOCKED' && data.issues && data.issues.length > 0) {
                    // issues - это массив строк
                    const issueMessages = data.issues.join(', ');
                    throw new Error(issueMessages);
                }
                throw new Error(data.message || `Не удалось ${action === 'publish' ? 'опубликовать' : 'снять с публикации'}`);
            }
            return data;
        },
        onSuccess: () => {
            setErrorMessage(null);
            queryClient.invalidateQueries({ queryKey: ['tours'] });
        },
        onError: (error) => {
            setErrorMessage(error.message);
            // Автоматически скрыть через 5 секунд
            setTimeout(() => setErrorMessage(null), 5000);
        }
    });

    const handleDelete = (tour: Tour) => {
        setTourToDelete(tour);
        setDeleteDialogOpen(true);
    };

    const confirmDelete = () => {
        if (tourToDelete) {
            deleteMutation.mutate(tourToDelete.id);
        }
    };

    const handleTogglePublish = (tour: Tour) => {
        const action = tour.published_at ? 'unpublish' : 'publish';
        togglePublishMutation.mutate({ tourId: tour.id, action });
    };

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
            header: "",
            cell: ({ row }) => {
                const tour = row.original;
                const isPublished = !!tour.published_at;
                return (
                    <div className="flex items-center gap-1">
                        {/* Edit button */}
                        <Button variant="ghost" size="icon" className="h-8 w-8" title="Редактировать" asChild>
                            <Link href={`/content/tours/${tour.id}`}>
                                <Edit className="h-4 w-4 text-slate-500" />
                            </Link>
                        </Button>

                        {/* Publish/Unpublish toggle */}
                        <Button 
                            variant="ghost" 
                            size="icon" 
                            className="h-8 w-8"
                            title={isPublished ? 'Скрыть в приложении' : 'Показать в приложении'}
                            onClick={() => handleTogglePublish(tour)}
                            disabled={togglePublishMutation.isPending}
                        >
                            {isPublished ? (
                                <Eye className="h-4 w-4 text-green-600" />
                            ) : (
                                <EyeOff className="h-4 w-4 text-slate-400" />
                            )}
                        </Button>

                        {/* Delete button */}
                        <Button 
                            variant="ghost" 
                            size="icon" 
                            className="h-8 w-8 text-red-500 hover:text-red-700 hover:bg-red-50"
                            title="Удалить тур"
                            onClick={() => handleDelete(tour)}
                        >
                            <Trash2 className="h-4 w-4" />
                        </Button>
                    </div>
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

            {/* Error message */}
            {errorMessage && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded relative">
                    <span className="block sm:inline">{errorMessage}</span>
                    <button 
                        className="absolute top-0 bottom-0 right-0 px-4 py-3"
                        onClick={() => setErrorMessage(null)}
                    >
                        <span className="text-red-500">×</span>
                    </button>
                </div>
            )}

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

            {/* Delete Confirmation Dialog */}
            <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Удалить тур?</AlertDialogTitle>
                        <AlertDialogDescription>
                            Вы уверены, что хотите удалить тур "{tourToDelete?.title_ru}"? 
                            Это действие нельзя отменить.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Отмена</AlertDialogCancel>
                        <AlertDialogAction 
                            onClick={confirmDelete}
                            className="bg-red-600 hover:bg-red-700"
                            disabled={deleteMutation.isPending}
                        >
                            {deleteMutation.isPending ? 'Удаление...' : 'Удалить'}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </div>
    );
}




