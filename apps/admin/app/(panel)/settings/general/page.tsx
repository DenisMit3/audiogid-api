'use client';

import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Loader2, Save } from 'lucide-react';

const API_URL = '/api/proxy';

type GeneralSettings = {
    app_name: string;
    support_email: string;
    default_language: string;
    maintenance_mode: boolean;
    app_version_min: string;
};

export default function GeneralSettingsPage() {
    const queryClient = useQueryClient();
    const [form, setForm] = useState<GeneralSettings>({
        app_name: 'Аудиогид',
        support_email: 'support@audiogid.app',
        default_language: 'ru',
        maintenance_mode: false,
        app_version_min: '1.0.0'
    });

    const { data, isLoading } = useQuery({
        queryKey: ['settings-general'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/settings/general`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch settings');
            return res.json() as Promise<GeneralSettings>;
        }
    });

    useEffect(() => {
        if (data) {
            setForm(data);
        }
    }, [data]);

    const mutation = useMutation({
        mutationFn: async (settings: GeneralSettings) => {
            const res = await fetch(`${API_URL}/admin/settings/general`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify(settings)
            });
            if (!res.ok) throw new Error('Failed to save settings');
            return res.json();
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-general'] });
        }
    });

    if (isLoading) {
        return (
            <div className="flex items-center justify-center py-12">
                <Loader2 className="w-6 h-6 animate-spin" />
            </div>
        );
    }

    return (
        <div className="space-y-6 max-w-2xl p-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Основные настройки</h1>
                <p className="text-muted-foreground">Базовая конфигурация приложения.</p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Идентификация приложения</CardTitle>
                    <CardDescription>Отображается в письмах и метаданных приложения.</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="grid gap-2">
                        <Label>Название приложения</Label>
                        <Input 
                            value={form.app_name}
                            onChange={(e) => setForm({ ...form, app_name: e.target.value })}
                        />
                    </div>
                    <div className="grid gap-2">
                        <Label>Email поддержки</Label>
                        <Input 
                            type="email"
                            value={form.support_email}
                            onChange={(e) => setForm({ ...form, support_email: e.target.value })}
                        />
                    </div>
                    <div className="grid gap-2">
                        <Label>Язык по умолчанию</Label>
                        <Select
                            value={form.default_language}
                            onValueChange={(v) => setForm({ ...form, default_language: v })}
                        >
                            <SelectTrigger>
                                <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="ru">Русский</SelectItem>
                                <SelectItem value="en">English</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Версионирование</CardTitle>
                    <CardDescription>Управление версиями приложения.</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="grid gap-2">
                        <Label>Минимальная версия приложения</Label>
                        <Input 
                            value={form.app_version_min}
                            onChange={(e) => setForm({ ...form, app_version_min: e.target.value })}
                            placeholder="1.0.0"
                        />
                        <p className="text-xs text-muted-foreground">
                            Пользователи с версией ниже будут вынуждены обновиться
                        </p>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Режим обслуживания</CardTitle>
                    <CardDescription>Временно отключить доступ к приложению.</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="flex items-center justify-between">
                        <div>
                            <Label>Режим обслуживания</Label>
                            <p className="text-sm text-muted-foreground">
                                При включении пользователи увидят сообщение о техработах
                            </p>
                        </div>
                        <Switch
                            checked={form.maintenance_mode}
                            onCheckedChange={(checked) => setForm({ ...form, maintenance_mode: checked })}
                        />
                    </div>
                </CardContent>
            </Card>

            <div className="flex justify-end">
                <Button 
                    onClick={() => mutation.mutate(form)}
                    disabled={mutation.isPending}
                >
                    {mutation.isPending ? (
                        <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                    ) : (
                        <Save className="w-4 h-4 mr-2" />
                    )}
                    Сохранить
                </Button>
            </div>
        </div>
    );
}
