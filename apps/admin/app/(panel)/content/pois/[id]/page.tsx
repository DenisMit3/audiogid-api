
"use client"

import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import { useRouter } from "next/navigation"
import useSWR from "swr"
import { useEffect } from "react"
import { Button } from "@/components/ui/button"
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { MediaUpload } from "@/components/media-upload"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { PublishCheckModal } from "@/components/publish-check-modal"

const poiSchema = z.object({
    title_ru: z.string().min(2, "Title must be at least 2 characters"),
    description_ru: z.string().optional(),
    city_slug: z.string().min(2),
    lat: z.coerce.number().optional(),
    lon: z.coerce.number().optional(),
})

export default function PoiEditPage({ params }: { params: { id: string } }) {
    const isNew = params.id === 'new';
    const router = useRouter();

    // Fetch if edit
    const { data: poi, error } = useSWR(isNew ? null : `/api/proxy/admin/pois/${params.id}`, (url) => fetch(url).then(r => r.json()));

    const form = useForm<z.infer<typeof poiSchema>>({
        resolver: zodResolver(poiSchema),
        defaultValues: {
            title_ru: "",
            description_ru: "",
            city_slug: "kaliningrad", // Default or fetch list
            lat: 0,
            lon: 0
        },
    })

    useEffect(() => {
        if (poi) {
            form.reset({
                title_ru: poi.title_ru,
                description_ru: poi.description_ru || "",
                city_slug: poi.city_slug,
                lat: poi.lat,
                lon: poi.lon
            });
        }
    }, [poi, form]);

    async function onSubmit(values: z.infer<typeof poiSchema>) {
        const url = isNew ? '/api/proxy/admin/pois' : `/api/proxy/admin/pois/${params.id}`;
        const method = isNew ? 'POST' : 'PATCH';

        try {
            const res = await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(values)
            });

            if (res.ok) {
                router.push('/content/pois');
                router.refresh();
            } else {
                alert("Save failed");
            }
        } catch (e) {
            console.error(e);
        }
    }

    const handleMediaUpload = (url: string) => {
        console.log("Uploaded Media:", url);
        // In real app, we'd add this to a media array via API or field
        // Since API Phase 3 didn't add media update endpoint specifically to POI patch, 
        // we assume we might need a separate call or update JSON snapshot.
        // For MVP, just log or alert.
        alert("Media Uploaded: " + url);
    };

    if (!isNew && !poi) return <div>Loading...</div>

    return (
        <div className="max-w-2xl mx-auto py-6">
            <h1 className="text-2xl font-bold mb-6">{isNew ? 'Create POI' : 'Edit POI'}</h1>
            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                    <Card>
                        <CardHeader><CardTitle>Basic Info</CardTitle></CardHeader>
                        <CardContent className="space-y-4">
                            <FormField
                                control={form.control}
                                name="title_ru"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Title (RU)</FormLabel>
                                        <FormControl>
                                            <Input placeholder="POI Title" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="city_slug"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>City Slug</FormLabel>
                                        <FormControl>
                                            <Input placeholder="kaliningrad" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="description_ru"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Description</FormLabel>
                                        <FormControl>
                                            <Textarea placeholder="Description..." {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <div className="grid grid-cols-2 gap-4">
                                <FormField
                                    control={form.control}
                                    name="lat"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Latitude</FormLabel>
                                            <FormControl>
                                                <Input type="number" step="any" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <FormField
                                    control={form.control}
                                    name="lon"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Longitude</FormLabel>
                                            <FormControl>
                                                <Input type="number" step="any" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader><CardTitle>Media</CardTitle></CardHeader>
                        <CardContent>
                            <MediaUpload onUploadComplete={handleMediaUpload} />
                        </CardContent>
                    </Card>

                    <div className="flex justify-end gap-2">
                        {!isNew && <PublishCheckModal entityId={params.id} entityType="poi" />}
                        <Button variant="outline" type="button" onClick={() => router.back()}>Cancel</Button>
                        <Button type="submit">Save</Button>
                    </div>
                </form>
            </Form>
        </div>
    )
}
