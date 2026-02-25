'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import * as z from 'zod';
import { Bell, Send, Save, AlertCircle, Loader2 } from 'lucide-react';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { useToast } from "@/components/ui/use-toast";
import { Separator } from "@/components/ui/separator";
import { Badge } from "@/components/ui/badge";

const API_URL = '/api/proxy';

// Schema for Push Settings
const notificationsSchema = z.object({
    fcm_server_key: z.string().optional(), // In real app, might validation this
    email_sender_name: z.string().min(2),
    email_sender_address: z.string().email(),
    enable_push: z.boolean(),
    enable_email: z.boolean(),
});

type NotificationsValues = z.infer<typeof notificationsSchema>;

// Mock fetch settings
const fetchSettings = async () => {
    const res = await fetch(`${API_URL}/admin/settings/notifications`, {
        credentials: 'include'
    });
    // Fallback if endpoint doesn't exist yet
    if (!res.ok && res.status === 404) {
        return {
            fcm_server_key: '',
            email_sender_name: 'Audiogid Support',
            email_sender_address: 'support@audiogid.app',
            enable_push: true,
            enable_email: false,
        };
    }
    if (!res.ok) throw new Error("Не удалось загрузить настройки");
    return res.json();
};

export default function NotificationsSettingsPage() {
    const { toast } = useToast();
    const queryClient = useQueryClient();
    const [sendTestOpen, setSendTestOpen] = useState(false);

    // Fetch initial data
    const { data: settings, isLoading } = useQuery({
        queryKey: ['settings-notifications'],
        queryFn: fetchSettings,
    });

    const form = useForm<any>({
        resolver: zodResolver(notificationsSchema),
        values: settings, // Auto-populate when data is loaded
        defaultValues: {
            fcm_server_key: '',
            email_sender_name: '',
            email_sender_address: '',
            enable_push: true,
            enable_email: false,
        }
    });

    const saveMutation = useMutation({
        mutationFn: async (values: NotificationsValues) => {
            const res = await fetch(`${API_URL}/admin/settings/notifications`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify(values)
            });
            if (!res.ok) throw new Error("Не удалось сохранить настройки");
            return res.json();
        },
        onSuccess: () => {
            toast({ title: "Настройки сохранены", description: "Конфигурация уведомлений успешно обновлена." });
            queryClient.invalidateQueries({ queryKey: ['settings-notifications'] });
        },
        onError: () => {
            toast({ title: "Ошибка", description: "Не удалось сохранить настройки.", variant: "destructive" });
        }
    });

    const sendPushMutation = useMutation({
        mutationFn: async (data: { title: string, body: string, topic?: string }) => {
            const res = await fetch(`${API_URL}/admin/notifications/push`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({
                    target: data.topic || 'all',
                    title: data.title,
                    body: data.body
                })
            });
            if (!res.ok) throw new Error("Не удалось отправить push");
            return res.json();
        },
        onSuccess: (data) => {
            toast({ title: "Push отправлен", description: `Сообщение доставлено на ${data.success_count || 0} из ${data.recipient_count || 0} устройств.` });
            setSendTestOpen(false);
        },
        onError: (error: any) => {
            toast({ 
                title: "Ошибка отправки", 
                description: error.message || "Не удалось отправить push-уведомление. Проверьте настройки FCM.", 
                variant: "destructive" 
            });
        }
    });

    // Test form state
    const [testTitle, setTestTitle] = useState("Тестовое уведомление");
    const [testBody, setTestBody] = useState("Привет от админ-панели Аудиогид!");

    if (isLoading) {
        return <div className="p-8 flex items-center justify-center"><Loader2 className="w-8 h-8 animate-spin" /></div>;
    }

    return (
        <div className="space-y-6 p-6 max-w-4xl">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Настройки уведомлений</h1>
                <p className="text-muted-foreground">Настройка Push-уведомлений (FCM) и Email.</p>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit((data) => saveMutation.mutate(data))} className="space-y-8">

                    {/* Push Configuration */}
                    <Card>
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <Bell className="w-5 h-5 text-primary" />
                                    <CardTitle>Push-уведомления</CardTitle>
                                </div>
                                <FormField
                                    control={form.control}
                                    name="enable_push"
                                    render={({ field }) => (
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    )}
                                />
                            </div>
                            <CardDescription>
                                Использует Firebase Cloud Messaging (FCM) для доставки уведомлений в мобильные приложения.
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <FormField
                                control={form.control}
                                name="fcm_server_key"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>FCM Server Key (Legacy) или Service Account JSON</FormLabel>
                                        <FormControl>
                                            <div className="relative">
                                                <Input type="password" placeholder="AAAA..." {...field} />
                                            </div>
                                        </FormControl>
                                        <FormDescription>
                                            Находится в Firebase Console {'>'} Project Settings {'>'} Cloud Messaging.
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </CardContent>
                    </Card>

                    {/* Email Configuration */}
                    <Card>
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <Send className="w-5 h-5 text-primary" />
                                    <CardTitle>Настройки Email</CardTitle>
                                </div>
                                <FormField
                                    control={form.control}
                                    name="enable_email"
                                    render={({ field }) => (
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    )}
                                />
                            </div>
                            <CardDescription>Данные отправителя для транзакционных писем (приветствие, чеки).</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <FormField
                                    control={form.control}
                                    name="email_sender_name"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Имя отправителя</FormLabel>
                                            <FormControl>
                                                <Input placeholder="Команда Аудиогид" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <FormField
                                    control={form.control}
                                    name="email_sender_address"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Email отправителя</FormLabel>
                                            <FormControl>
                                                <Input placeholder="noreply@audiogid.app" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </div>
                        </CardContent>
                    </Card>

                    <div className="flex items-center gap-4">
                        <Button type="submit" disabled={saveMutation.isPending}>
                            {saveMutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            <Save className="mr-2 h-4 w-4" /> Сохранить
                        </Button>

                        <Separator orientation="vertical" className="h-8" />

                        <Button
                            type="button"
                            variant="secondary"
                            onClick={() => setSendTestOpen(!sendTestOpen)}
                        >
                            Тест Push...
                        </Button>
                    </div>
                </form>
            </Form>

            {/* Test Push Console */}
            {sendTestOpen && (
                <Card className="border-blue-200 bg-blue-50/50">
                    <CardHeader>
                        <CardTitle className="text-base text-blue-900">Отправить тестовую рассылку</CardTitle>
                        <CardDescription>Отправляет push-уведомление на ВСЕ зарегистрированные тестовые устройства.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-3">
                        <div className="grid gap-2">
                            <FormLabel>Заголовок</FormLabel>
                            <Input value={testTitle} onChange={e => setTestTitle(e.target.value)} />
                        </div>
                        <div className="grid gap-2">
                            <FormLabel>Текст</FormLabel>
                            <Textarea value={testBody} onChange={e => setTestBody(e.target.value)} rows={2} />
                        </div>
                    </CardContent>
                    <CardFooter>
                        <Button
                            onClick={() => sendPushMutation.mutate({ title: testTitle, body: testBody })}
                            disabled={sendPushMutation.isPending}
                        >
                            {sendPushMutation.isPending ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Send className="mr-2 h-4 w-4" />}
                            Отправить рассылку
                        </Button>
                    </CardFooter>
                </Card>
            )}
        </div>
    );
}




