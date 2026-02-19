
'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { Loader2, Save, MoreVertical, MapPin, Globe, Mic, Image as ImageIcon, BookOpen, Send, Plus } from 'lucide-react';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";

import { MediaUploader } from './media-upload';
import { SourcesManager } from './sources-manager';
import { NarrationsManager } from './narrations-manager';
import dynamic from 'next/dynamic';
const LocationPicker = dynamic(() => import('./location-picker').then(mod => mod.LocationPicker), {
    ssr: false,
    loading: () => <div className="h-[400px] w-full flex items-center justify-center bg-slate-100 font-mono text-xs border rounded-md">Загрузка карты...</div>
});
import { PublishCheckModal } from './publish-check-modal';

const API_URL = '/api/proxy';
// throw removed for build

const poiSchema = z.object({
    title_ru: z.string().min(3, "Название (RU) должно содержать минимум 3 символа"),
    title_en: z.string().optional(),
    city_slug: z.string().min(1, "Город обязателен"),
    description_ru: z.string().optional(),
    description_en: z.string().optional(),
    category: z.string().optional(),
    address: z.string().optional(),
    cover_image: z.string().optional(),
    lat: z.coerce.number().min(-90).max(90).optional(),
    lon: z.coerce.number().min(-180).max(180).optional(),
    is_active: z.boolean().default(true),
    // TODO: opening_hours, external_links json support
});

type PoiFormValues = z.infer<typeof poiSchema>;

type PoiData = PoiFormValues & {
    id: string;
    media: any[];
    sources: any[];
    narrations: any[];
    published_at?: string;
    can_publish: boolean;
    publish_issues: string[];
};

export default function PoiForm({ poi, onSuccess }: { poi?: PoiData, onSuccess?: (id: string) => void }) {
    const [activeTab, setActiveTab] = useState('general');
    const [isPublishModalOpen, setIsPublishModalOpen] = useState(false);
    const router = useRouter();
    const queryClient = useQueryClient();

    const form = useForm<any>({
        resolver: zodResolver(poiSchema),
        defaultValues: {
            title_ru: poi?.title_ru || '',
            title_en: poi?.title_en || '',
            city_slug: poi?.city_slug || 'kaliningrad_city', // default
            description_ru: poi?.description_ru || '',
            description_en: poi?.description_en || '',
            category: poi?.category || 'landmark',
            address: poi?.address || '',
            cover_image: poi?.cover_image || '',
            lat: poi?.lat,
            lon: poi?.lon,
            is_active: poi?.is_active ?? true,
        }
    });

    const mutation = useMutation({
        mutationFn: async (values: PoiFormValues) => {
            const token = localStorage.getItem('admin_token');
            const url = poi ? `${API_URL}/admin/pois/${poi.id}` : `${API_URL}/admin/pois`;
            const method = poi ? 'PATCH' : 'POST';

            const res = await fetch(url, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(values)
            });

            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || 'Не удалось сохранить');
            }
            return res.json();
        },
        onSuccess: (data) => {
            queryClient.invalidateQueries({ queryKey: ['pois'] });
            queryClient.invalidateQueries({ queryKey: ['poi', data.id] });

            if (onSuccess) onSuccess(data.id);
            if (!poi) {
                router.push(`/content/pois/${data.id}`);
            } else {
                // alert("Saved successfully");
            }
        },
        onError: (err) => alert(err.message)
    });

    const publishMutation = useMutation({
        mutationFn: async (action: 'publish' | 'unpublish') => {
            const res = await fetch(`${API_URL}/admin/pois/${poi!.id}/${action}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
            });
            if (!res.ok) throw new Error(`${action} не удалось`);
            return res.json();
        },
        onSuccess: () => {
            setIsPublishModalOpen(false);
            queryClient.invalidateQueries({ queryKey: ['poi', poi?.id] });
        }
    });

    const onSubmit = (values: PoiFormValues) => {
        mutation.mutate(values);
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
                    <div className="flex justify-between w-full border-b pb-px">
                        <TabsList className="bg-transparent p-0 h-auto">
                            <TabsTrigger value="general" className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2">
                                <BookOpen className="w-4 h-4" /> Основное
                            </TabsTrigger>
                            <TabsTrigger value="location" className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2" disabled={!poi}>
                                <MapPin className="w-4 h-4" /> Местоположение
                            </TabsTrigger>
                            <TabsTrigger value="media" className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2" disabled={!poi}>
                                <ImageIcon className="w-4 h-4" /> Медиа
                            </TabsTrigger>
                            <TabsTrigger value="narrations" className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2" disabled={!poi}>
                                <Mic className="w-4 h-4" /> Озвучка
                            </TabsTrigger>
                            <TabsTrigger value="sources" className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2" disabled={!poi}>
                                <Globe className="w-4 h-4" /> Источники
                            </TabsTrigger>
                        </TabsList>

                        <div className="flex items-center gap-2 mb-1">
                            {poi && (
                                <>
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => setIsPublishModalOpen(true)}
                                        className={poi.published_at ? "border-green-500 text-green-700 bg-green-50" : ""}
                                    >
                                        <Send className="w-3 h-3 mr-2" />
                                        {poi.published_at ? 'Опубликовано' : 'Опубликовать'}
                                    </Button>
                                    <DropdownMenu>
                                        <DropdownMenuTrigger asChild>
                                            <Button variant="ghost" size="icon"><MoreVertical className="w-4 h-4" /></Button>
                                        </DropdownMenuTrigger>
                                        <DropdownMenuContent align="end">
                                            <DropdownMenuItem className="text-red-500">Удалить точку</DropdownMenuItem>
                                        </DropdownMenuContent>
                                    </DropdownMenu>
                                </>
                            )}
                        </div>
                    </div>

                    <div className="pt-6">
                        {/* TAB: GENERAL */}
                        <TabsContent value="general">
                            <Card>
                                <CardContent className="pt-6">
                                    <Form {...form}>
                                        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                                            <div className="grid grid-cols-2 gap-4">
                                                <FormField
                                                    control={form.control}
                                                    name="title_ru"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Название (русский) *</FormLabel>
                                                            <FormControl><Input {...field} /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                                <FormField
                                                    control={form.control}
                                                    name="title_en"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Название (английский)</FormLabel>
                                                            <FormControl><Input {...field} /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                            </div>

                                            <div className="grid grid-cols-2 gap-4">
                                                <FormField
                                                    control={form.control}
                                                    name="city_slug"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Город</FormLabel>
                                                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                                                                <FormControl><SelectTrigger><SelectValue placeholder="Выберите город" /></SelectTrigger></FormControl>
                                                                <SelectContent>
                                                                    <SelectItem value="kaliningrad_city">Калининград</SelectItem>
                                                                    <SelectItem value="zelenogradsk">Зеленоградск</SelectItem>
                                                                    <SelectItem value="svetlogorsk">Светлогорск</SelectItem>
                                                                </SelectContent>
                                                            </Select>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                                <FormField
                                                    control={form.control}
                                                    name="category"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Категория</FormLabel>
                                                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                                                                <FormControl><SelectTrigger><SelectValue /></SelectTrigger></FormControl>
                                                                <SelectContent>
                                                                    <SelectItem value="landmark">Достопримечательность</SelectItem>
                                                                    <SelectItem value="museum">Музей</SelectItem>
                                                                    <SelectItem value="park">Парк</SelectItem>
                                                                    <SelectItem value="monument">Памятник</SelectItem>
                                                                    <SelectItem value="church">Церковь</SelectItem>
                                                                </SelectContent>
                                                            </Select>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                            </div>

                                            <div className="grid grid-cols-2 gap-4">
                                                <FormField
                                                    control={form.control}
                                                    name="description_ru"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Описание (RU)</FormLabel>
                                                            <FormControl><Textarea className="h-32" {...field} /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                                <FormField
                                                    control={form.control}
                                                    name="description_en"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Описание (EN)</FormLabel>
                                                            <FormControl><Textarea className="h-32" {...field} /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                            </div>

                                            <div className="grid grid-cols-2 gap-4">
                                                <FormField
                                                    control={form.control}
                                                    name="address"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Адрес</FormLabel>
                                                            <FormControl><Input {...field} /></FormControl>
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
                                                            <FormControl><Input {...field} placeholder="https://..." /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                            </div>

                                            <div className="flex justify-between items-center bg-slate-50 p-4 rounded-lg">
                                                <FormField
                                                    control={form.control}
                                                    name="is_active"
                                                    render={({ field }) => (
                                                        <FormItem className="flex items-center space-x-3 space-y-0">
                                                            <FormControl>
                                                                <Checkbox checked={field.value} onCheckedChange={field.onChange} />
                                                            </FormControl>
                                                            <div className="space-y-1 leading-none">
                                                                <FormLabel>Статус активности</FormLabel>
                                                                <FormDescription>Видимость в приложении</FormDescription>
                                                            </div>
                                                        </FormItem>
                                                    )}
                                                />
                                                <Button type="submit" disabled={mutation.isPending}>
                                                    {mutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                                    <Save className="mr-2 h-4 w-4" />
                                                    {poi ? 'Обновить информацию' : 'Создать точку'}
                                                </Button>
                                            </div>
                                        </form>
                                    </Form>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        {/* TAB: LOCATION */}
                        <TabsContent value="location">
                            <Card>
                                <CardContent className="pt-6">
                                    <div className="grid grid-cols-3 gap-6">
                                        <div className="col-span-1 space-y-4">
                                            <div>
                                                <h3 className="font-semibold mb-2">Координаты</h3>
                                                <p className="text-sm text-muted-foreground mb-4">
                                                    Кликните на карту или найдите адрес для установки местоположения.
                                                </p>
                                            </div>
                                            <div className="space-y-4">
                                                <div className="grid gap-2">
                                                    <Label>Широта</Label>
                                                    <Input type="number" step="any" value={form.watch('lat') || ''} onChange={e => form.setValue('lat', parseFloat(e.target.value))} />
                                                </div>
                                                <div className="grid gap-2">
                                                    <Label>Долгота</Label>
                                                    <Input type="number" step="any" value={form.watch('lon') || ''} onChange={e => form.setValue('lon', parseFloat(e.target.value))} />
                                                </div>
                                                <Button onClick={() => mutation.mutate(form.getValues())} className="w-full">
                                                    Сохранить местоположение
                                                </Button>
                                            </div>
                                        </div>
                                        <div className="col-span-2">
                                            <LocationPicker
                                                lat={form.watch('lat')}
                                                lon={form.watch('lon')}
                                                onChange={(lat, lon) => {
                                                    form.setValue('lat', lat);
                                                    form.setValue('lon', lon);
                                                }}
                                            />
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        {/* TAB: MEDIA */}
                        <TabsContent value="media">
                            {poi && <MediaUploader entityId={poi.id} entityType="poi" media={poi.media} />}
                        </TabsContent>

                        {/* TAB: NARRATIONS */}
                        <TabsContent value="narrations">
                            {poi && <NarrationsManager poiId={poi.id} narrations={poi.narrations} />}
                        </TabsContent>

                        {/* TAB: SOURCES */}
                        <TabsContent value="sources">
                            {poi && <SourcesManager poiId={poi.id} sources={poi.sources} entityType="poi" />}
                        </TabsContent>

                    </div>
                </Tabs>
            </div>

            {/* Modals */}
            {poi && (
                <PublishCheckModal
                    isOpen={isPublishModalOpen}
                    onClose={() => setIsPublishModalOpen(false)}
                    onPublish={() => publishMutation.mutate('publish')}
                    onUnpublish={() => publishMutation.mutate('unpublish')}
                    isPublishing={publishMutation.isPending}
                    checkResult={{
                        can_publish: poi.can_publish,
                        issues: poi.publish_issues || []
                    }}
                    currentStatus={poi.published_at ? 'published' : 'draft'}
                />
            )}
        </div>
    );
}




