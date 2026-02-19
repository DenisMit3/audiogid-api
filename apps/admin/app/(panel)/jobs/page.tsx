
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
    RefreshCcw,
    Activity,
    CheckCircle2,
    XCircle,
    Clock,
    Play,
    XSquare
} from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';

import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
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
    DialogDescription,
} from "@/components/ui/dialog";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";

import { useJobsWebSocket } from '@/hooks/useJobsWebSocket';

const API_URL = '/api/proxy';

type Job = {
    id: string;
    type: string;
    status: string;
    progress: number;
    created_at: string;
    started_at?: string;
    completed_at?: string;
    error?: string;
    payload?: string;
    result?: string;
};

export default function JobsDashboard() {
    const [selectedJob, setSelectedJob] = useState<Job | null>(null);
    const [statusFilter, setStatusFilter] = useState<string>('all');

    // Fetcher
    const fetchJobs = async () => {
        const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';
        const params = new URLSearchParams({ limit: '20' });
        if (statusFilter && statusFilter !== 'all') params.append('status', statusFilter);

        const res = await fetch(`${API_URL}/admin/jobs?${params}`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        if (!res.ok) throw new Error("Не удалось загрузить задачи");
        return res.json();
    };

    // Initial Data
    const { data, isLoading, refetch } = useQuery({
        queryKey: ['jobs', statusFilter],
        queryFn: fetchJobs,
        refetchInterval: 5000 // Fallback polling
    });

    const queryClient = useQueryClient();

    // mutations
    const cancelMutation = useMutation({
        mutationFn: async (id: string) => {
            const res = await fetch(`${API_URL}/admin/jobs/${id}/cancel`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
            });
            if (!res.ok) throw new Error("Не удалось отменить");
        },
        onSuccess: () => refetch()
    });

    const retryMutation = useMutation({
        mutationFn: async (id: string) => {
            const res = await fetch(`${API_URL}/admin/jobs/${id}/retry`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
            });
            if (!res.ok) throw new Error("Не удалось повторить");
        },
        onSuccess: () => refetch()
    });

    // Realtime
    const { isConnected } = useJobsWebSocket((update) => {
        // Optimistic update in cache
        queryClient.setQueryData(['jobs'], (oldData: any) => {
            if (!oldData) return oldData;
            const newItems = oldData.items.map((job: Job) => {
                if (job.id === update.job_id) {
                    return { ...job, status: update.status, progress: update.progress };
                }
                return job;
            });
            return { ...oldData, items: newItems };
        });
    });

    const getStatusBadge = (status: string) => {
        switch (status) {
            case 'COMPLETED': return <Badge className="bg-green-600">Завершено</Badge>;
            case 'FAILED': return <Badge variant="destructive">Ошибка</Badge>;
            case 'RUNNING': return <Badge className="bg-blue-600 animate-pulse">Выполняется</Badge>;
            case 'PENDING': return <Badge variant="secondary">Ожидает</Badge>;
            case 'CANCELLED': return <Badge variant="outline">Отменено</Badge>;
            default: return <Badge variant="outline">{status}</Badge>;
        }
    };

    return (
        <div className="space-y-6 p-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold tracking-tight">Системные задачи</h1>
                    <div className="flex items-center gap-2 mt-1">
                        <span className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`} />
                        <span className="text-xs text-muted-foreground">{isConnected ? 'Подключено' : 'Отключено'}</span>
                    </div>
                </div>
                <div className="flex items-center gap-2">
                    <Select value={statusFilter} onValueChange={setStatusFilter}>
                        <SelectTrigger className="w-[150px]">
                            <SelectValue placeholder="Все статусы" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">Все статусы</SelectItem>
                            <SelectItem value="PENDING">Ожидает</SelectItem>
                            <SelectItem value="RUNNING">Выполняется</SelectItem>
                            <SelectItem value="COMPLETED">Завершено</SelectItem>
                            <SelectItem value="FAILED">Ошибка</SelectItem>
                            <SelectItem value="CANCELLED">Отменено</SelectItem>
                        </SelectContent>
                    </Select>

                    <Button variant="outline" onClick={() => refetch()} disabled={isLoading}>
                        <RefreshCcw className={`w-4 h-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
                        Обновить
                    </Button>
                </div>
            </div>

            {/* Quick Stats Cards could go here */}

            {/* Jobs Table */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-lg">Последние задачи</CardTitle>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Тип</TableHead>
                                <TableHead>Статус</TableHead>
                                <TableHead>Прогресс</TableHead>
                                <TableHead>Создано</TableHead>
                                <TableHead className="text-right">Действия</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {isLoading && <TableRow><TableCell colSpan={5} className="text-center h-24">Загрузка...</TableCell></TableRow>}

                            {!isLoading && data?.items.map((job: Job) => (
                                <TableRow key={job.id} className="cursor-pointer hover:bg-slate-50" onClick={() => setSelectedJob(job)}>
                                    <TableCell className="font-medium">
                                        <div className="flex flex-col">
                                            <span>{job.type}</span>
                                            <span className="text-xs text-muted-foreground font-mono">{job.id.slice(0, 8)}...</span>
                                        </div>
                                    </TableCell>
                                    <TableCell>{getStatusBadge(job.status)}</TableCell>
                                    <TableCell className="w-[200px]">
                                        {job.status === 'RUNNING' && <Progress value={job.progress} className="h-2" />}
                                        {job.status === 'COMPLETED' && <span className="text-xs text-green-600 flex items-center gap-1"><CheckCircle2 className="w-3 h-3" /> Готово</span>}
                                        {job.status === 'FAILED' && <span className="text-xs text-red-500 flex items-center gap-1"><XCircle className="w-3 h-3" /> Ошибка</span>}
                                    </TableCell>
                                    <TableCell className="text-xs text-muted-foreground">
                                        {formatDistanceToNow(new Date(job.created_at), { addSuffix: true })}
                                    </TableCell>
                                    <TableCell className="text-right" onClick={(e) => e.stopPropagation()}>
                                        <div className="flex justify-end gap-2">
                                            {(job.status === 'PENDING' || job.status === 'RUNNING') && (
                                                <Button size="sm" variant="ghost" onClick={() => cancelMutation.mutate(job.id)} disabled={cancelMutation.isPending}>
                                                    <XSquare className="w-4 h-4 text-red-500" />
                                                </Button>
                                            )}
                                            {job.status === 'FAILED' && (
                                                <Button size="sm" variant="ghost" onClick={() => retryMutation.mutate(job.id)} disabled={retryMutation.isPending}>
                                                    <RefreshCcw className="w-4 h-4 text-blue-500" />
                                                </Button>
                                            )}
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>

            {/* Job Details Modal */}
            <Dialog open={!!selectedJob} onOpenChange={() => setSelectedJob(null)}>
                <DialogContent className="max-w-2xl">
                    <DialogHeader>
                        <DialogTitle className="flex items-center gap-2">
                            Детали задачи
                            {selectedJob && getStatusBadge(selectedJob.status)}
                        </DialogTitle>
                        <DialogDescription className="font-mono text-xs text-slate-500">
                            ID: {selectedJob?.id}
                        </DialogDescription>
                    </DialogHeader>

                    {selectedJob && (
                        <div className="space-y-4 font-mono text-sm bg-slate-50 p-4 rounded-md overflow-auto max-h-[60vh]">
                            <div className="grid grid-cols-2 gap-2">
                                <div><strong>Тип:</strong> {selectedJob.type}</div>
                                <div><strong>Создано:</strong> {selectedJob.created_at}</div>
                                <div><strong>Начато:</strong> {selectedJob.started_at || '-'}</div>
                                <div><strong>Завершено:</strong> {selectedJob.completed_at || '-'}</div>
                            </div>

                            {selectedJob.error && (
                                <div className="p-3 bg-red-50 border border-red-200 rounded text-red-700">
                                    <strong>Ошибка:</strong>
                                    <pre className="whitespace-pre-wrap mt-1 text-xs">{selectedJob.error}</pre>
                                </div>
                            )}

                            <div>
                                <strong>Данные:</strong>
                                <pre className="bg-white p-2 border rounded mt-1 text-xs overflow-auto max-h-[100px]">
                                    {selectedJob.payload ? JSON.stringify(JSON.parse(selectedJob.payload), null, 2) : 'null'}
                                </pre>
                            </div>

                            {selectedJob.result && (
                                <div>
                                    <strong>Результат:</strong>
                                    <pre className="bg-white p-2 border rounded mt-1 text-xs overflow-auto max-h-[200px]">
                                        {JSON.stringify(JSON.parse(selectedJob.result), null, 2)}
                                    </pre>
                                </div>
                            )}
                        </div>
                    )}
                </DialogContent>
            </Dialog>
        </div>
    );
}




