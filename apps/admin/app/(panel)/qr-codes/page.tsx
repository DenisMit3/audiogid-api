
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

const API_URL = process.env.NEXT_PUBLIC_API_URL;

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
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/qr?${params}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to fetch QRs");
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
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                },
                body: JSON.stringify({
                    target_type: targetType,
                    target_id: targetId, // User must copy paste ID for now or implement search combo
                    label
                })
            });
            if (!res.ok) throw new Error("Create failed");
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
                headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
            });
            if (!res.ok) throw new Error("Bulk generate failed");
            return res.json();
        },
        onSuccess: (data) => {
            alert(`Generated ${data.created_count} missing QR codes!`);
            queryClient.invalidateQueries({ queryKey: ['qrs'] });
        }
    });

    return (
        <div className="space-y-6 p-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold tracking-tight">QR Code Manager</h1>
                    <p className="text-sm text-muted-foreground">Manage physical QR codes and short links.</p>
                </div>
                <div className="flex gap-2">
                    <Button variant="outline" onClick={() => bulkGenerateMutation.mutate()} disabled={bulkGenerateMutation.isPending}>
                        <RefreshCcw className="w-4 h-4 mr-2" />
                        Auto-Generate Missing
                    </Button>
                    <Button onClick={() => setIsCreateOpen(true)}>
                        <QrCode className="w-4 h-4 mr-2" />
                        Create Manual QR
                    </Button>
                </div>
            </div>

            <Card>
                <CardHeader>
                    <div className="flex items-center justify-between">
                        <CardTitle className="text-lg">Active Mappings</CardTitle>
                        <div className="relative w-64">
                            <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                            <Input
                                placeholder="Search by code or label..."
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
                                <TableHead>Code</TableHead>
                                <TableHead>Label</TableHead>
                                <TableHead>Target</TableHead>
                                <TableHead>Scans</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {isLoading && <TableRow><TableCell colSpan={5} className="text-center h-24">Loading...</TableCell></TableRow>}

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
                        <Button variant="outline" size="sm" onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}>Prev</Button>
                        <span className="text-sm">Page {page}</span>
                        <Button variant="outline" size="sm" onClick={() => setPage(p => p + 1)} disabled={!data || data.items.length < 20}>Next</Button>
                    </div>
                </CardContent>
            </Card>

            {/* Create Dialog */}
            <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Create New QR Code</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="grid gap-2">
                            <Label>Target Type</Label>
                            <Select value={targetType} onValueChange={setTargetType}>
                                <SelectTrigger><SelectValue /></SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="poi">Point of Interest (POI)</SelectItem>
                                    <SelectItem value="tour">Tour</SelectItem>
                                    <SelectItem value="city">City</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="grid gap-2">
                            <Label>Target Entity ID (UUID)</Label>
                            <Input value={targetId} onChange={e => setTargetId(e.target.value)} placeholder="e.g. 550e8400-e29b..." />
                        </div>
                        <div className="grid gap-2">
                            <Label>Internal Label</Label>
                            <Input value={label} onChange={e => setLabel(e.target.value)} placeholder="e.g. Sticker at Main Entrance" />
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsCreateOpen(false)}>Cancel</Button>
                        <Button onClick={() => createMutation.mutate()} disabled={!targetId || createMutation.isPending}>
                            {createMutation.isPending ? 'Creating...' : 'Create Code'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}




