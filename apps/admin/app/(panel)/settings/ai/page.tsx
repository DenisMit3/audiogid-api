'use client';

import { useMutation, useQuery } from '@tanstack/react-query';
import { Bot, Save, Loader2, Sparkles, Mic2 } from 'lucide-react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/components/ui/use-toast";

const API_URL = '/api/proxy';

const aiSchema = z.object({
    tts_provider: z.enum(['openai', 'google', 'azure']),
    openai_api_key: z.string().optional().default(''),
    default_voice: z.string().min(1),
    enable_translation: z.boolean().default(true),
});

type AIValues = z.infer<typeof aiSchema>;

const fetchAISettings = async () => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/settings/ai`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    
    if (!res.ok) {
        // Возвращаем дефолтные значения если endpoint еще не настроен
        if (res.status === 404) {
            return {
                tts_provider: 'openai',
                openai_api_key: '',
                default_voice: 'alloy',
                enable_translation: true
            };
        }
        throw new Error("Не удалось загрузить настройки ИИ");
    }
    
    return res.json();
};

export default function AISettingsPage() {
    const { toast } = useToast();

    const { data: settings, isLoading } = useQuery({
        queryKey: ['settings-ai'],
        queryFn: fetchAISettings
    });

    const form = useForm<any>({
        resolver: zodResolver(aiSchema),
        values: settings,
        defaultValues: {
            tts_provider: 'openai',
            openai_api_key: '',
            default_voice: 'alloy',
            enable_translation: true
        }
    });

    const saveMutation = useMutation({
        mutationFn: async (values: AIValues) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/settings/ai`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(values)
            });
            if (!res.ok) throw new Error("Не удалось сохранить настройки ИИ");
            return res.json();
        },
        onSuccess: () => {
            toast({ title: "Настройки ИИ сохранены", description: "Конфигурация озвучки и перевода обновлена." });
        },
        onError: () => toast({ title: "Ошибка", description: "Не удалось сохранить настройки", variant: "destructive" })
    });

    if (isLoading) return <div className="p-8"><Loader2 className="animate-spin" /></div>;

    return (
        <div className="space-y-6 p-6 max-w-4xl">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">ИИ и автоматизация</h1>
                <p className="text-muted-foreground">Настройка синтеза речи (TTS) и автоматических переводов.</p>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit(data => saveMutation.mutate(data))} className="space-y-8">

                    <Card>
                        <CardHeader>
                            <div className="flex items-center gap-2">
                                <Mic2 className="w-5 h-5 text-primary" />
                                <CardTitle>Синтез речи (TTS)</CardTitle>
                            </div>
                            <CardDescription>Движок для генерации аудио-озвучки из описаний туров.</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <FormField
                                control={form.control}
                                name="tts_provider"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Провайдер</FormLabel>
                                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Выберите провайдера" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="openai">OpenAI (Рекомендуется)</SelectItem>
                                                <SelectItem value="google">Google Cloud TTS</SelectItem>
                                                <SelectItem value="azure">Azure Cognitive Services</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormDescription>
                                            OpenAI предоставляет наиболее естественные голоса "Alloy" и "Nova".
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="default_voice"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>ID голоса по умолчанию</FormLabel>
                                        <FormControl>
                                            <Input placeholder="alloy" {...field} />
                                        </FormControl>
                                        <FormDescription>
                                            Для OpenAI: alloy, echo, fable, onyx, nova, shimmer.
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="openai_api_key"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>API-ключ</FormLabel>
                                        <FormControl>
                                            <Input type="password" placeholder="sk-..." {...field} />
                                        </FormControl>
                                        <FormDescription>
                                            Оставьте пустым для использования системной переменной окружения.
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </CardContent>
                    </Card>

                    <Button type="submit" disabled={saveMutation.isPending}>
                        {saveMutation.isPending ? <Loader2 className="mr-2 animate-spin" /> : <Save className="mr-2 w-4 h-4" />}
                        Сохранить настройки
                    </Button>
                </form>
            </Form>
        </div>
    );
}




