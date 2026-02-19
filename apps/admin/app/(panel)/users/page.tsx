
'use client';

import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
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
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { MoreHorizontal, Shield, UserX, Loader2 } from "lucide-react";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useToast } from "@/components/ui/use-toast";

const API_URL = '/api/proxy';
// throw removed for build

type User = {
    id: string;
    role: string;
    is_active: boolean;
    created_at: string;
    identities_count: number;
    last_login: string | null;
    phone: string | null;
};

const fetchUsers = async (search: string = "") => {
    const token = localStorage.getItem('admin_token');
    const query = search ? `?search=${encodeURIComponent(search)}` : '';
    const res = await fetch(`${API_URL}/admin/users${query}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Не удалось загрузить пользователей");
    return res.json();
};

export default function UsersPage() {
    const [search, setSearch] = useState("");
    const [selectedUser, setSelectedUser] = useState<User | null>(null);
    const [roleDialogOpen, setRoleDialogOpen] = useState(false);
    const [newRole, setNewRole] = useState("user");
    const { toast } = useToast();
    const queryClient = useQueryClient();

    // Debounce search for query
    const [debouncedSearch, setDebouncedSearch] = useState("");

    // Effect to handle debounce
    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedSearch(search);
        }, 300);
        return () => clearTimeout(timer);
    }, [search]);

    const { data: users, isLoading } = useQuery({
        queryKey: ['users', debouncedSearch],
        queryFn: () => fetchUsers(debouncedSearch)
    });

    const updateMutation = useMutation({
        mutationFn: async ({ id, data }: { id: string, data: any }) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/users/${id}`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(data)
            });
            if (!res.ok) throw new Error("Не удалось обновить пользователя");
            return res.json();
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['users'] });
            toast({ title: "Пользователь обновлён" });
            setRoleDialogOpen(false);
        },
        onError: (err) => {
            toast({ title: "Ошибка", description: err.message, variant: "destructive" });
        }
    });

    const handleRoleChange = () => {
        if (!selectedUser) return;
        updateMutation.mutate({ id: selectedUser.id, data: { role: newRole } });
    };

    const handleToggleActive = (user: User) => {
        if (!confirm(`Вы уверены, что хотите ${user.is_active ? 'деактивировать' : 'активировать'} этого пользователя?`)) return;
        updateMutation.mutate({ id: user.id, data: { is_active: !user.is_active } });
    };

    const openRoleDialog = (user: User) => {
        setSelectedUser(user);
        setNewRole(user.role);
        setRoleDialogOpen(true);
    };

    return (
        <div className="space-y-6 p-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Пользователи</h1>
                <div className="flex w-full max-w-sm items-center space-x-2">
                    <Input
                        placeholder="Поиск пользователей..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                    />
                </div>
            </div>

            <Card>
                <CardHeader><CardTitle>Все пользователи</CardTitle></CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="space-y-2">
                            <Skeleton className="h-4 w-full" />
                            <Skeleton className="h-4 w-full" />
                            <Skeleton className="h-4 w-full" />
                        </div>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>ID / Телефон</TableHead>
                                    <TableHead>Роль</TableHead>
                                    <TableHead>Статус</TableHead>
                                    <TableHead>Последний вход</TableHead>
                                    <TableHead className="text-right">Действия</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {users?.map((user: User) => (
                                    <TableRow key={user.id}>
                                        <TableCell>
                                            <div className="font-medium">{user.phone || 'Нет телефона'}</div>
                                            <div className="text-xs text-muted-foreground font-mono">{user.id.slice(0, 8)}...</div>
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant="outline">{user.role}</Badge>
                                        </TableCell>
                                        <TableCell>
                                            <Badge className={user.is_active ? "bg-green-100 text-green-800 hover:bg-green-100" : "bg-red-100 text-red-800 hover:bg-red-100"}>
                                                {user.is_active ? 'Активен' : 'Заблокирован'}
                                            </Badge>
                                        </TableCell>
                                        <TableCell>{user.last_login ? new Date(user.last_login).toLocaleDateString() : 'Никогда'}</TableCell>
                                        <TableCell className="text-right">
                                            <DropdownMenu>
                                                <DropdownMenuTrigger asChild>
                                                    <Button variant="ghost" className="h-8 w-8 p-0">
                                                        <span className="sr-only">Открыть меню</span>
                                                        <MoreHorizontal className="h-4 w-4" />
                                                    </Button>
                                                </DropdownMenuTrigger>
                                                <DropdownMenuContent align="end">
                                                    <DropdownMenuLabel>Действия</DropdownMenuLabel>
                                                    <DropdownMenuItem onClick={() => openRoleDialog(user)}>
                                                        <Shield className="mr-2 h-4 w-4" /> Изменить роль
                                                    </DropdownMenuItem>
                                                    <DropdownMenuSeparator />
                                                    <DropdownMenuItem onClick={() => handleToggleActive(user)} className="text-red-600">
                                                        <UserX className="mr-2 h-4 w-4" />
                                                        {user.is_active ? 'Деактивировать' : 'Активировать'}
                                                    </DropdownMenuItem>
                                                </DropdownMenuContent>
                                            </DropdownMenu>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    )}
                </CardContent>
            </Card>

            <Dialog open={roleDialogOpen} onOpenChange={setRoleDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Изменить роль</DialogTitle>
                        <DialogDescription>
                            Назначьте новую роль пользователю. Права изменятся немедленно.
                        </DialogDescription>
                    </DialogHeader>
                    <div className="grid gap-4 py-4">
                        <Select value={newRole} onValueChange={setNewRole}>
                            <SelectTrigger>
                                <SelectValue placeholder="Выберите роль" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="user">Пользователь</SelectItem>
                                <SelectItem value="editor">Редактор</SelectItem>
                                <SelectItem value="admin">Администратор</SelectItem>
                                <SelectItem value="superadmin">Суперадмин</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setRoleDialogOpen(false)}>Отмена</Button>
                        <Button onClick={handleRoleChange} disabled={updateMutation.isPending}>
                            {updateMutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Сохранить
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}




