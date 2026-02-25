
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Download, QrCode, RefreshCcw, Search, ExternalLink, Printer, Activity } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from "@/components/ui/dialog";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Label } from '@/components/ui/label';

const API_URL = '/api/proxy';

type QRMapping = {
    id: string;
    code: string;
    target_type: string;
    target_id: string;
    label?: string;
    is_active: boolean;
    scans_count: number;
    created_at: string;
};

const fetchQRs = async ({ page, search }: { page: number, search: string }) => {
    const params = new URLSearchParams({ page: page.toString(), search });
    const res = await fetch(`${API_URL}/admin/qr?${params}`, {
        credentials: 'include'
    });
    if (!res.ok) throw new Error("Не удалось загрузить QR-коды");
    return res.json();
};

export default function QRManagementPage() {
    const [page, setPage] = useState(1);
    const [search, setSearch] = useState('');
    const [isCreateOpen, setIsCreateOpen] = useState(false);

    // Create Form State
    const [targetType, setTargetType] = useState('poi');
    const [targetId, setTargetId] = useState('');
    const [label, setLabel] = useState('');

    const queryClient = useQueryClient();

    const { data, isLoading } = useQuery({
        queryKey: ['qrs', page, search],
        queryFn: () => fetchQRs({ page, search }),
    });

    const createMutation = useMutation({
        mutationFn: async () => {
            const res = await fetch(`${API_URL}/admin/qr`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({
                    target_type: targetType,
                    target_id: targetId, // User must copy paste ID for now or implement search combo
                    label
                })
            });
            if (!res.ok) throw new Error("Не удалось создать");
            return res.json();
        },
        onSuccess: () => {
            setIsCreateOpen(false);
            setTargetId('');
            setLabel('');
            queryClient.invalidateQueries({ queryKey: ['qrs'] });
        }
    });

    const bulkGenerateMutation = useMutation({
        mutationFn: async () => {
            const res = await fetch(`${API_URL}/admin/qr/bulk_generate`, {
                method: 'POST',
                credentials: 'include'
            });
            if (!res.ok) throw new Error("Не удалось сгенерировать массово");
            return res.json();
        },
        onSuccess: (data) => {
            alert(`Сгенерировано ${data.created_count} недостающих QR-кодов!`);
            queryClient.invalidateQueries({ queryKey: ['qrs'] });
        }
    });

    return (
        <div className="space-y-6 p-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold tracking-tight">Менеджер QR-кодов</h1>
                    <p className="text-sm text-muted-foreground">Управление физическими QR-кодами и короткими ссылками.</p>
                </div>
                <div className="flex gap-2">
                    <Button variant="outline" onClick={() => bulkGenerateMutation.mutate()} disabled={bulkGenerateMutation.isPending}>
                        <RefreshCcw className="w-4 h-4 mr-2" />
                        Автогенерация недостающих
                    </Button>
                    <Button onClick={() => setIsCreateOpen(true)}>
                        <QrCode className="w-4 h-4 mr-2" />
                        Создать QR вручную
                    </Button>
                </div>
            </div>

            <Card>
                <CardHeader>
                    <div className="flex items-center justify-between">
                        <CardTitle className="text-lg">Активные привязки</CardTitle>
                        <div className="relative w-64">
                            <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                            <Input
                                placeholder="Поиск по коду или метке..."
                                className="pl-8"
                                value={search}
                                onChange={e => setSearch(e.target.value)}
                            />
                        </div>
                    </div>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Код</TableHead>
                                <TableHead>Метка</TableHead>
                                <TableHead>Цель</TableHead>
                                <TableHead>Сканирования</TableHead>
                                <TableHead className="text-right">Действия</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {isLoading && <TableRow><TableCell colSpan={5} className="text-center h-24">Загрузка...</TableCell></TableRow>}

                            {!isLoading && data?.items.map((qr: QRMapping) => (
                                <TableRow key={qr.id}>
                                    <TableCell className="font-mono font-bold text-blue-600">
                                        {qr.code}
                                    </TableCell>
                                    <TableCell>{qr.label || '-'}</TableCell>
                                    <TableCell className="text-sm">
                                        <Badge variant="outline" className="mr-2 uppercase text-[10px]">{qr.target_type}</Badge>
                                        <span className="font-mono text-xs text-muted-foreground">{qr.target_id.slice(0, 8)}...</span>
                                    </TableCell>
                                    <TableCell>
                                        <div className="flex items-center gap-1 font-medium">
                                            <Activity className="w-3 h-3 text-green-500" />
                                            {qr.scans_count}
                                        </div>
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <div className="flex justify-end gap-2">
                                            <Button size="sm" variant="ghost" asChild>
                                                <a href={`${API_URL}/public/qr/${qr.code}`} target="_blank">
                                                    <ExternalLink className="w-4 h-4" />
                                                </a>
                                            </Button>
                                            <Button size="sm" variant="ghost">
                                                <Download className="w-4 h-4" />
                                            </Button>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>

                    {/* Pagination - Simplified */}
                    <div className="flex items-center justify-end gap-2 mt-4">
                        <Button variant="outline" size="sm" onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}>Назад</Button>
                        <span className="text-sm">Страница {page}</span>
                        <Button variant="outline" size="sm" onClick={() => setPage(p => p + 1)} disabled={!data || data.items.length < 20}>Вперёд</Button>
                    </div>
                </CardContent>
            </Card>

            {/* Create Dialog */}
            <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Создать новый QR-код</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="grid gap-2">
                            <Label>Тип цели</Label>
                            <Select value={targetType} onValueChange={setTargetType}>
                                <SelectTrigger><SelectValue /></SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="poi">Точка интереса (POI)</SelectItem>
                                    <SelectItem value="tour">Тур</SelectItem>
                                    <SelectItem value="city">Город</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="grid gap-2">
                            <Label>ID целевой сущности (UUID)</Label>
                            <Input value={targetId} onChange={e => setTargetId(e.target.value)} placeholder="напр. 550e8400-e29b..." />
                        </div>
                        <div className="grid gap-2">
                            <Label>Внутренняя метка</Label>
                            <Input value={label} onChange={e => setLabel(e.target.value)} placeholder="напр. Наклейка у главного входа" />
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsCreateOpen(false)}>Отмена</Button>
                        <Button onClick={() => createMutation.mutate()} disabled={!targetId || createMutation.isPending}>
                            {createMutation.isPending ? 'Создание...' : 'Создать код'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}




