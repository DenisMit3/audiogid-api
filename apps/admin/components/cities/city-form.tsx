
'use client';

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { useEffect } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { useToast } from "@/components/ui/use-toast";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const API_URL = '/api/proxy';

const citySchema = z.object({
    slug: z.string().min(2, "Slug должен содержать минимум 2 символа").regex(/^[a-z0-9-_]+$/, "Slug должен содержать только строчные буквы, цифры, дефисы или подчёркивания"),
    name_ru: z.string().min(2, "Название (RU) должно содержать минимум 2 символа"),
    name_en: z.string().optional(),
    description_ru: z.string().optional(),
    description_en: z.string().optional(),
    cover_image: z.string().url("Должен быть корректный URL").optional().or(z.literal("")),
    timezone: z.string().optional(),
    is_active: z.boolean().default(true),

    // Map Config
    bounds_lat_min: z.coerce.number().min(-90).max(90).optional(),
    bounds_lat_max: z.coerce.number().min(-90).max(90).optional(),
    bounds_lon_min: z.coerce.number().min(-180).max(180).optional(),
    bounds_lon_max: z.coerce.number().min(-180).max(180).optional(),
    default_zoom: z.coerce.number().min(0).max(22).optional(),
});

type CityFormValues = z.infer<typeof citySchema>;

interface CityFormProps {
    initialData?: any;
    isEdit?: boolean;
}

export function CityForm({ initialData, isEdit }: CityFormProps) {
    const { toast } = useToast();
    const router = useRouter();
    const queryClient = useQueryClient();

    const form = useForm<any>({
        resolver: zodResolver(citySchema),
        defaultValues: {
            slug: initialData?.slug || "",
            name_ru: initialData?.name_ru || "",
            name_en: initialData?.name_en || "",
            description_ru: initialData?.description_ru || "",
            description_en: initialData?.description_en || "",
            cover_image: initialData?.cover_image || "",
            timezone: initialData?.timezone || "",
            is_active: initialData?.is_active ?? true,
            bounds_lat_min: initialData?.bounds_lat_min,
            bounds_lat_max: initialData?.bounds_lat_max,
            bounds_lon_min: initialData?.bounds_lon_min,
            bounds_lon_max: initialData?.bounds_lon_max,
            default_zoom: initialData?.default_zoom,
        },
    });

    const mutation = useMutation({
        mutationFn: async (values: CityFormValues) => {
            const token = localStorage.getItem('admin_token');
            const url = isEdit
                ? `${API_URL}/admin/cities/${initialData.id}`
                : `${API_URL}/admin/cities`;

            const method = isEdit ? 'PATCH' : 'POST';

            const res = await fetch(url, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(values),
            });

            if (!res.ok) {
                const error = await res.json();
                throw new Error(error.detail || 'Не удалось сохранить город');
            }
            return res.json();
        },
        onSuccess: (data) => {
            toast({
                title: isEdit ? "Город обновлён" : "Город создан",
                description: `Успешно сохранено: ${data.name_ru}`,
            });
            queryClient.invalidateQueries({ queryKey: ['cities'] });
            router.push('/cities');
        },
        onError: (error) => {
            toast({
                title: "Ошибка",
                description: error.message,
                variant: "destructive",
            });
        }
    });

    function onSubmit(data: CityFormValues) {
        mutation.mutate(data);
    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                <Tabs defaultValue="general" className="w-full">
                    <TabsList>
                        <TabsTrigger value="general">Основное</TabsTrigger>
                        <TabsTrigger value="details">Детали и медиа</TabsTrigger>
                        <TabsTrigger value="map">Настройки карты</TabsTrigger>
                    </TabsList>

                    <TabsContent value="general" className="space-y-4">
                        <Card>
                            <CardHeader>
                                <CardTitle>Основная информация</CardTitle>
                                <CardDescription>
                                    Основные настройки города или региона.
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="grid gap-6">
                                <FormField
                                    control={form.control}
                                    name="slug"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Слаг</FormLabel>
                                            <FormControl>
                                                <Input placeholder="moscow" {...field} disabled={isEdit} />
                                            </FormControl>
                                            <FormDescription>
                                                Уникальный идентификатор для URL. Нельзя изменить после создания.
                                            </FormDescription>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <div className="grid grid-cols-2 gap-4">
                                    <FormField
                                        control={form.control}
                                        name="name_ru"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Название (русский)</FormLabel>
                                                <FormControl>
                                                    <Input placeholder="Москва" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                    <FormField
                                        control={form.control}
                                        name="name_en"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Название (английский)</FormLabel>
                                                <FormControl>
                                                    <Input placeholder="Moscow" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                </div>
                                <div className="grid grid-cols-2 gap-4">
                                    <FormField
                                        control={form.control}
                                        name="timezone"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Часовой пояс</FormLabel>
                                                <FormControl>
                                                    <Input placeholder="Europe/Moscow" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                    <FormField
                                        control={form.control}
                                        name="is_active"
                                        render={({ field }) => (
                                            <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4 shadow-sm h-[88px] mt-2">
                                                <div className="space-y-0.5">
                                                    <FormLabel className="text-base">Статус активности</FormLabel>
                                                    <FormDescription>
                                                        Видимость для пользователей в приложении.
                                                    </FormDescription>
                                                </div>
                                                <FormControl>
                                                    <Switch
                                                        checked={field.value}
                                                        onCheckedChange={field.onChange}
                                                    />
                                                </FormControl>
                                            </FormItem>
                                        )}
                                    />
                                </div>
                            </CardContent>
                        </Card>
                    </TabsContent>

                    <TabsContent value="details" className="space-y-4">
                        <Card>
                            <CardHeader>
                                <CardTitle>Детали и контент</CardTitle>
                            </CardHeader>
                            <CardContent className="grid gap-6">
                                <FormField
                                    control={form.control}
                                    name="description_ru"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Описание (русский)</FormLabel>
                                            <FormControl>
                                                <Textarea
                                                    placeholder="Опишите город..."
                                                    className="resize-none h-32"
                                                    {...field}
                                                />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <FormField
                                    control={form.control}
                                    name="description_en"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Описание (английский)</FormLabel>
                                            <FormControl>
                                                <Textarea
                                                    placeholder="Опишите город на английском..."
                                                    className="resize-none h-32"
                                                    {...field}
                                                />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <FormField
                                    control={form.control}
                                    name="cover_image"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>URL обложки</FormLabel>
                                            <FormControl>
                                                <Input placeholder="https://..." {...field} />
                                            </FormControl>
                                            <FormDescription>
                                                URL главного изображения для карточки города.
                                            </FormDescription>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </CardContent>
                        </Card>
                    </TabsContent>

                    <TabsContent value="map" className="space-y-4">
                        <Card>
                            <CardHeader>
                                <CardTitle>Настройки карты</CardTitle>
                                <CardDescription>
                                    Задайте вид по умолчанию и границы для города.
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="grid gap-6">
                                <div className="grid grid-cols-2 gap-4">
                                    <FormField
                                        control={form.control}
                                        name="bounds_lat_min"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Мин. широта</FormLabel>
                                                <FormControl>
                                                    <Input type="number" step="0.000001" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                    <FormField
                                        control={form.control}
                                        name="bounds_lat_max"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Макс. широта</FormLabel>
                                                <FormControl>
                                                    <Input type="number" step="0.000001" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                    <FormField
                                        control={form.control}
                                        name="bounds_lon_min"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Мин. долгота</FormLabel>
                                                <FormControl>
                                                    <Input type="number" step="0.000001" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                    <FormField
                                        control={form.control}
                                        name="bounds_lon_max"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Макс. долгота</FormLabel>
                                                <FormControl>
                                                    <Input type="number" step="0.000001" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                </div>
                                <FormField
                                    control={form.control}
                                    name="default_zoom"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Масштаб по умолчанию</FormLabel>
                                            <FormControl>
                                                <Input type="number" step="0.1" {...field} />
                                            </FormControl>
                                            <FormDescription>
                                                От 1 (мир) до 20 (здание). Типичный город: 11-13.
                                            </FormDescription>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </CardContent>
                        </Card>
                    </TabsContent>
                </Tabs>

                <div className="flex justify-end gap-4">
                    <Button type="button" variant="outline" onClick={() => router.back()}>
                        Отмена
                    </Button>
                    <Button type="submit" disabled={mutation.isPending}>
                        {mutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                        {isEdit ? "Обновить город" : "Создать город"}
                    </Button>
                </div>
            </form>
        </Form>
    );
}




