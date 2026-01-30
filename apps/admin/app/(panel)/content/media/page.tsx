'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, Filter, Trash2, Image as ImageIcon, Music, Link as LinkIcon, ExternalLink } from 'lucide-react';
import Link from 'next/link';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Card, CardContent, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/components/ui/use-toast";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { AspectRatio } from "@/components/ui/aspect-ratio";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "https://audiogid-api.vercel.app/v1";

type MediaItem = {
    id: string;
    url: string;
    media_type: string;
    license_type: string;
    author: string;
    source_page_url: string;
    entity_type: 'poi' | 'tour';
    entity_id: string;
};

const fetchMedia = async ({ page, search, type }: { page: number, search: string, type: string }) => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    params.append('per_page', '24'); // Grid layout usually fits 3 or 4 cols
    if (search) params.append('search', search);
    if (type && type !== 'all') params.append('type', type);

    const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';

    const res = await fetch(`${API_URL}/admin/media?${params.toString()}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Failed to fetch media');
    return res.json();
};

const deleteMedia = async ({ id, entity_type }: { id: string, entity_type: string }) => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/media/${id}?entity_type=${entity_type}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Failed to delete media');
    return res.json();
};

export default function MediaLibraryPage() {
    const [search, setSearch] = useState('');
    const [typeFilter, setTypeFilter] = useState('all');
    const [page, setPage] = useState(1);
    const { toast } = useToast();
    const queryClient = useQueryClient();

    const { data, isLoading } = useQuery({
        queryKey: ['media', page, search, typeFilter],
        queryFn: () => fetchMedia({ page, search, type: typeFilter }),
        placeholderData: (prev) => prev
    });

    const deleteMutation = useMutation({
        mutationFn: deleteMedia,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['media'] });
            toast({ title: "Media deleted successfully" });
        },
        onError: () => {
            toast({ title: "Failed to delete media", variant: "destructive" });
        }
    });

    return (
        <div className="space-y-6 p-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Media Library</h1>
                    <p className="text-muted-foreground">Manage images and audio files across all content.</p>
                </div>
            </div>

            <div className="flex items-center gap-4">
                <div className="relative flex-1 max-w-sm">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                        placeholder="Search by author or URL..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="pl-8"
                    />
                </div>
                <Select value={typeFilter} onValueChange={setTypeFilter}>
                    <SelectTrigger className="w-[180px]">
                        <SelectValue placeholder="Filter by type" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="all">All Types</SelectItem>
                        <SelectItem value="image">Images</SelectItem>
                        <SelectItem value="audio">Audio</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            {isLoading ? (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
                    {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
                        <Card key={i} className="animate-pulse">
                            <AspectRatio ratio={16 / 9} className="bg-muted" />
                            <CardContent className="h-20" />
                        </Card>
                    ))}
                </div>
            ) : data?.items?.length ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    {data.items.map((item: MediaItem) => (
                        <Card key={item.id} className="overflow-hidden group">
                            <div className="relative">
                                <AspectRatio ratio={16 / 9} className="bg-slate-100 flex items-center justify-center">
                                    {item.media_type.startsWith('image') ? (
                                        <img
                                            src={item.url}
                                            alt="Media Preview"
                                            className="object-cover w-full h-full"
                                            loading="lazy"
                                        />
                                    ) : (
                                        <Music className="w-12 h-12 text-slate-300" />
                                    )}
                                </AspectRatio>
                                <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <AlertDialog>
                                        <AlertDialogTrigger asChild>
                                            <Button variant="destructive" size="icon" className="h-8 w-8">
                                                <Trash2 className="h-4 w-4" />
                                            </Button>
                                        </AlertDialogTrigger>
                                        <AlertDialogContent>
                                            <AlertDialogHeader>
                                                <AlertDialogTitle>Delete Media?</AlertDialogTitle>
                                                <AlertDialogDescription>
                                                    This will remove the file from the database. It might break the {item.entity_type} displaying it.
                                                </AlertDialogDescription>
                                            </AlertDialogHeader>
                                            <AlertDialogFooter>
                                                <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                <AlertDialogAction onClick={() => deleteMutation.mutate({ id: item.id, entity_type: item.entity_type })}>
                                                    Delete
                                                </AlertDialogAction>
                                            </AlertDialogFooter>
                                        </AlertDialogContent>
                                    </AlertDialog>
                                </div>
                                <Badge className="absolute top-2 left-2" variant="secondary">
                                    {item.media_type.split('/')[0]}
                                </Badge>
                            </div>
                            <CardContent className="p-3">
                                <div className="text-xs text-muted-foreground truncate" title={item.author}>
                                    Author: {item.author || "Unknown"}
                                </div>
                                <div className="text-xs text-muted-foreground truncate" title={item.license_type}>
                                    License: {item.license_type || "Unknown"}
                                </div>
                                <div className="flex items-center justify-between mt-2">
                                    <Link href={item.source_page_url || '#'} target="_blank" className="text-xs flex items-center hover:underline text-blue-500">
                                        <ExternalLink className="w-3 h-3 mr-1" /> Source
                                    </Link>
                                    <Link href={`/content/${item.entity_type}s/${item.entity_id}`} className="text-xs flex items-center hover:underline">
                                        <LinkIcon className="w-3 h-3 mr-1" /> View Context
                                    </Link>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            ) : (
                <div className="text-center py-20 text-muted-foreground">
                    No media found.
                </div>
            )}

            <div className="flex items-center justify-end gap-2 mt-6">
                <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page === 1}
                >
                    Previous
                </Button>
                <div className="text-sm">Page {page} of {data?.pages || 1}</div>
                <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setPage((p) => p + 1)}
                    disabled={!data || page >= data.pages}
                >
                    Next
                </Button>
            </div>
        </div>
    );
}
