
'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { Loader2, Save, MoreVertical, Eye, Share, Map as MapIcon, Image as ImageIcon, Settings as SettingsIcon } from 'lucide-react';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
    Form,
    FormControl,
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
import { RouteBuilder } from './route-builder';
import { PublishCheckModal } from './publish-check-modal';

const API_URL = process.env.NEXT_PUBLIC_API_URL;
// throw removed for build

const tourSchema = z.object({
    title_ru: z.string().min(3, "Title must be at least 3 characters"),
    title_en: z.string().optional(),
    city_slug: z.string().min(1, "City is required"),
    description_ru: z.string().optional(),
    description_en: z.string().optional(),
    duration_minutes: z.coerce.number().min(0).optional(),
    tour_type: z.string().default('walking'),
    difficulty: z.string().default('easy'),
    cover_image: z.string().optional(),
});

type TourFormValues = z.infer<typeof tourSchema>;

type TourData = TourFormValues & {
    id: string;
    media: any[];
    sources: any[];
    items: any[];
    can_publish: boolean;
    publish_issues: string[];
    published_at?: string;
};

export default function TourEditor({ tour, onSuccess }: { tour?: TourData, onSuccess?: (id: string) => void }) {
    const [activeTab, setActiveTab] = useState('overview');
    const [isPublishModalOpen, setIsPublishModalOpen] = useState(false);
    const [items, setItems] = useState<any[]>(tour?.items || []);
    const router = useRouter();
    const queryClient = useQueryClient();

    const form = useForm<any>({
        resolver: zodResolver(tourSchema),
        defaultValues: {
            title_ru: tour?.title_ru || '',
            title_en: tour?.title_en || '',
            city_slug: tour?.city_slug || 'kaliningrad_city',
            description_ru: tour?.description_ru || '',
            description_en: tour?.description_en || '',
            duration_minutes: tour?.duration_minutes || 0,
            tour_type: tour?.tour_type || 'walking',
            difficulty: tour?.difficulty || 'easy',
            cover_image: tour?.cover_image || '',
        }
    });

    // 1. Save Basic Info
    const saveMutation = useMutation({
        mutationFn: async (values: TourFormValues) => {
            const token = localStorage.getItem('admin_token');
            const url = tour ? `${API_URL}/admin/tours/${tour.id}` : `${API_URL}/admin/tours`;
            const method = tour ? 'PATCH' : 'POST';

            const res = await fetch(url, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(values)
            });

            if (!res.ok) throw new Error('Failed to save tour info');
            return res.json();
        },
        onSuccess: (data) => {
            if (!tour) {
                router.push(`/content/tours/${data.id}`);
            } else {
                queryClient.invalidateQueries({ queryKey: ['tour', tour.id] });
                // alert("Info saved");
            }
        }
    });

    // 2. Route Management
    const addItemMutation = useMutation({
        mutationFn: async ({ poiId, order }: { poiId: string, order: number }) => {
            const res = await fetch(`${API_URL}/admin/tours/${tour!.id}/items`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                },
                body: JSON.stringify({ poi_id: poiId, order_index: order })
            });
            if (!res.ok) throw new Error("Failed to add item");
            return res.json();
        },
        onSuccess: () => queryClient.invalidateQueries({ queryKey: ['tour', tour?.id] })
    });

    const removeItemMutation = useMutation({
        mutationFn: async (itemId: string) => {
            await fetch(`${API_URL}/admin/tours/${tour!.id}/items/${itemId}`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
            });
        },
        onSuccess: () => queryClient.invalidateQueries({ queryKey: ['tour', tour?.id] })
    });

    const reorderMutation = useMutation({
        mutationFn: async (itemIds: string[]) => {
            await fetch(`${API_URL}/admin/tours/${tour!.id}/items`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                },
                body: JSON.stringify({ item_ids: itemIds })
            });
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['tour', tour?.id] });
        }
    });

    const updateItemMutation = useMutation({
        mutationFn: async ({ itemId, data }: { itemId: string, data: any }) => {
            const res = await fetch(`${API_URL}/admin/tours/${tour!.id}/items/${itemId}`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                },
                body: JSON.stringify(data)
            });
            if (!res.ok) throw new Error("Failed to update item");
            return res.json();
        },
        onSuccess: () => queryClient.invalidateQueries({ queryKey: ['tour', tour?.id] })
    });

    // 3. Publish Actions
    const publishMutation = useMutation({
        mutationFn: async (action: 'publish' | 'unpublish') => {
            const res = await fetch(`${API_URL}/admin/tours/${tour!.id}/${action}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
            });
            if (!res.ok) throw new Error(`${action} failed`);
            return res.json();
        },
        onSuccess: () => {
            setIsPublishModalOpen(false);
            queryClient.invalidateQueries({ queryKey: ['tour', tour?.id] });
        }
    });

    // Handlers
    const handleReorder = (newItems: any[]) => {
        setItems(newItems);
        const ids = newItems.map(i => i.id);
        reorderMutation.mutate(ids);
    };

    const handleAddItem = (poiId: string, poiTitle: string) => {
        addItemMutation.mutate({ poiId, order: items.length });
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
                    <div className="flex justify-between w-full border-b pb-px">
                        <TabsList className="bg-transparent p-0 h-auto">
                            <TabsTrigger
                                value="overview"
                                className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2"
                            >
                                <SettingsIcon className="w-4 h-4" /> Overview
                            </TabsTrigger>
                            <TabsTrigger
                                value="route" disabled={!tour}
                                className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2"
                            >
                                <MapIcon className="w-4 h-4" /> Route Builder
                            </TabsTrigger>
                            <TabsTrigger
                                value="media" disabled={!tour}
                                className="rounded-b-none data-[state=active]:bg-white data-[state=active]:border-x data-[state=active]:border-t data-[state=active]:border-b-white py-2 px-4 gap-2"
                            >
                                <ImageIcon className="w-4 h-4" /> Media
                            </TabsTrigger>
                        </TabsList>

                        <div className="flex items-center gap-2 mb-1">
                            {tour && (
                                <>
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => setIsPublishModalOpen(true)}
                                        className={tour.published_at ? "border-green-500 text-green-700 bg-green-50" : ""}
                                    >
                                        {tour.published_at ? 'Published' : 'Publish'}
                                    </Button>
                                    <DropdownMenu>
                                        <DropdownMenuTrigger asChild>
                                            <Button variant="ghost" size="icon"><MoreVertical className="w-4 h-4" /></Button>
                                        </DropdownMenuTrigger>
                                        <DropdownMenuContent align="end">
                                            <DropdownMenuItem>Duplicate Tour</DropdownMenuItem>
                                            <DropdownMenuItem className="text-red-500">Delete Tour</DropdownMenuItem>
                                        </DropdownMenuContent>
                                    </DropdownMenu>
                                </>
                            )}
                        </div>
                    </div>

                    <div className="pt-6">
                        <TabsContent value="overview">
                            <Card>
                                <CardContent className="pt-6">
                                    <Form {...form}>
                                        <form onSubmit={form.handleSubmit((v) => saveMutation.mutate(v))} className="space-y-6">
                                            <div className="grid grid-cols-2 gap-4">
                                                <FormField
                                                    control={form.control}
                                                    name="title_ru"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Title (RU) *</FormLabel>
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
                                                            <FormLabel>Title (EN)</FormLabel>
                                                            <FormControl><Input {...field} /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                            </div>

                                            <div className="grid grid-cols-3 gap-4">
                                                <FormField
                                                    control={form.control}
                                                    name="city_slug"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>City</FormLabel>
                                                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                                                                <FormControl><SelectTrigger><SelectValue /></SelectTrigger></FormControl>
                                                                <SelectContent>
                                                                    <SelectItem value="kaliningrad_city">Kaliningrad City</SelectItem>
                                                                    <SelectItem value="zelenogradsk">Zelenogradsk</SelectItem>
                                                                    <SelectItem value="svetlogorsk">Svetlogorsk</SelectItem>
                                                                </SelectContent>
                                                            </Select>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                                <FormField
                                                    control={form.control}
                                                    name="tour_type"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Type</FormLabel>
                                                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                                                                <FormControl><SelectTrigger><SelectValue /></SelectTrigger></FormControl>
                                                                <SelectContent>
                                                                    <SelectItem value="walking">Walking</SelectItem>
                                                                    <SelectItem value="driving">Driving</SelectItem>
                                                                    <SelectItem value="cycling">Cycling</SelectItem>
                                                                    <SelectItem value="boat">Boat</SelectItem>
                                                                </SelectContent>
                                                            </Select>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                                <FormField
                                                    control={form.control}
                                                    name="difficulty"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Difficulty</FormLabel>
                                                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                                                                <FormControl><SelectTrigger><SelectValue /></SelectTrigger></FormControl>
                                                                <SelectContent>
                                                                    <SelectItem value="easy">Easy</SelectItem>
                                                                    <SelectItem value="moderate">Moderate</SelectItem>
                                                                    <SelectItem value="hard">Hard</SelectItem>
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
                                                            <FormLabel>Description (RU)</FormLabel>
                                                            <FormControl><Textarea {...field} className="h-32" /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                                <FormField
                                                    control={form.control}
                                                    name="description_en"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Description (EN)</FormLabel>
                                                            <FormControl><Textarea {...field} className="h-32" /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                            </div>

                                            <div className="grid grid-cols-2 gap-4">
                                                <FormField
                                                    control={form.control}
                                                    name="duration_minutes"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Total Duration (min)</FormLabel>
                                                            <FormControl><Input type="number" {...field} /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                                <FormField
                                                    control={form.control}
                                                    name="cover_image"
                                                    render={({ field }) => (
                                                        <FormItem>
                                                            <FormLabel>Cover Image URL</FormLabel>
                                                            <FormControl><Input {...field} placeholder="https://..." /></FormControl>
                                                            <FormMessage />
                                                        </FormItem>
                                                    )}
                                                />
                                            </div>

                                            <div className="flex justify-end">
                                                <Button type="submit" disabled={saveMutation.isPending}>
                                                    {saveMutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                                    <Save className="mr-2 h-4 w-4" /> Save Overview
                                                </Button>
                                            </div>
                                        </form>
                                    </Form>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="route">
                            {tour && (
                                <RouteBuilder
                                    items={items}
                                    onReorder={handleReorder}
                                    onAddItem={handleAddItem}
                                    onRemoveItem={(id) => removeItemMutation.mutate(id)}
                                    onUpdateItem={(itemId, data) => updateItemMutation.mutate({ itemId, data })}
                                />
                            )}
                        </TabsContent>

                        <TabsContent value="media">
                            {tour && <MediaUploader entityId={tour.id} entityType="tour" media={tour.media} />}
                        </TabsContent>
                    </div>
                </Tabs>
            </div>

            {/* Modals */}
            {tour && (
                <PublishCheckModal
                    isOpen={isPublishModalOpen}
                    onClose={() => setIsPublishModalOpen(false)}
                    onPublish={() => publishMutation.mutate('publish')}
                    onUnpublish={() => publishMutation.mutate('unpublish')}
                    isPublishing={publishMutation.isPending}
                    checkResult={{
                        can_publish: tour.can_publish,
                        issues: tour.publish_issues,
                        unpublished_poi_ids: [] // Add this if needed
                    }}
                    currentStatus={tour.published_at ? 'published' : 'draft'}
                />
            )}
        </div>
    );
}




