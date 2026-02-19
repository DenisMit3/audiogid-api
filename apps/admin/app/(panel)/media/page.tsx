
'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
    Search, Trash, ExternalLink, Filter, Image as ImageIcon, Music, FileAudio
} from 'lucide-react';
import { format } from 'date-fns';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import {
    Card,
    CardContent,
    CardHeader,
    CardTitle,
    CardDescription
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/components/ui/use-toast";

const API_URL = '/api/proxy';

type MediaItem = {
    id: string;
    url: string;
    media_type: 'image' | 'audio';
    license_type: string;
    author: string;
    source_page_url: string;
    entity_type: 'poi' | 'tour';
    entity_id: string;
};

const fetchMedia = async ({ page, search, type, entity_type }: { page: number, search: string, type: string, entity_type: string }) => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    params.append('per_page', '24'); // Grid friendly
    if (search) params.append('search', search);
    if (type && type !== 'all') params.append('type', type);
    if (entity_type && entity_type !== 'all') params.append('entity_type', entity_type);

    const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';

    const res = await fetch(`${API_URL}/admin/media?${params.toString()}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Не удалось загрузить медиа');
    return res.json();
};

const deleteMedia = async (item: MediaItem) => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/media/${item.id}?entity_type=${item.entity_type}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error('Не удалось удалить медиа');
    return res.json();
};

export default function MediaLibraryPage() {
    const [search, setSearch] = useState('');
    const [mediaType, setMediaType] = useState('all');
    const [entityType, setEntityType] = useState('all');
    const [page, setPage] = useState(1);

    const { toast } = useToast();
    const queryClient = useQueryClient();

    const { data, isLoading } = useQuery({
        queryKey: ['media', page, search, mediaType, entityType],
        queryFn: () => fetchMedia({ page, search, type: mediaType, entity_type: entityType }),
        placeholderData: (prev) => prev
    });

    const deleteMutation = useMutation({
        mutationFn: deleteMedia,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['media'] });
            toast({ title: "Медиа удалено" });
        },
        onError: (error) => {
            toast({
                title: "Не удалось удалить",
                description: error.message,
                variant: "destructive"
            });
        }
    });

    return (
        <div className="space-y-4 p-4">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold tracking-tight">Медиатека</h1>
                    <p className="text-muted-foreground">Управление изображениями и аудиофайлами.</p>
                </div>
            </div>

            <Card>
                <CardContent className="p-4 flex flex-col md:flex-row gap-4 items-center">
                    <div className="relative flex-1 w-full">
                        <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                        <Input
                            placeholder="Поиск по автору или URL..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            className="pl-8"
                        />
                    </div>
                    <Select value={mediaType} onValueChange={setMediaType}>
                        <SelectTrigger className="w-[180px]">
                            <SelectValue placeholder="Тип медиа" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">Все типы</SelectItem>
                            <SelectItem value="image">Изображения</SelectItem>
                            <SelectItem value="audio">Аудио</SelectItem>
                        </SelectContent>
                    </Select>
                    <Select value={entityType} onValueChange={setEntityType}>
                        <SelectTrigger className="w-[180px]">
                            <SelectValue placeholder="Тип сущности" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">Все сущности</SelectItem>
                            <SelectItem value="poi">Точка</SelectItem>
                            <SelectItem value="tour">Тур</SelectItem>
                        </SelectContent>
                    </Select>
                </CardContent>
            </Card>

            {isLoading ? (
                <div className="text-center py-10">Загрузка медиа...</div>
            ) : (
                <div className="grid grid-cols-2 lg:grid-cols-4 xl:grid-cols-6 gap-4">
                    {data?.items.map((item: MediaItem) => (
                        <div key={item.id} className="group relative border rounded-lg overflow-hidden bg-slate-100 dark:bg-slate-900 aspect-square flex flex-col items-center justify-center">
                            {item.media_type === 'image' ? (
                                <img src={item.url} alt="media" className="object-cover w-full h-full" loading="lazy" />
                            ) : (
                                <div className="flex flex-col items-center text-slate-400">
                                    <Music className="w-12 h-12 mb-2" />
                                    <span className="text-xs uppercase font-bold text-slate-500">Аудио</span>
                                </div>
                            )}

                            {/* Overlay */}
                            <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col justify-end p-2 gap-2 text-white">
                                <div className="text-xs truncate">
                                    <span className="font-bold">{item.license_type}</span>
                                    <br />
                                    <span className="opacity-80">© {item.author}</span>
                                </div>
                                <div className="flex justify-between items-center mt-1">
                                    <Badge variant="secondary" className="text-[10px] h-5">{item.entity_type}</Badge>
                                    <div className="flex gap-1">
                                        <Button variant="ghost" size="icon" className="h-6 w-6 text-white hover:text-red-400"
                                            onClick={() => {
                                                if (confirm("Удалить этот элемент? Он будет удалён из сущности.")) deleteMutation.mutate(item);
                                            }}
                                        >
                                            <Trash className="w-4 h-4" />
                                        </Button>
                                        <a href={item.source_page_url} target="_blank" rel="noopener noreferrer">
                                            <Button variant="ghost" size="icon" className="h-6 w-6 text-white">
                                                <ExternalLink className="w-3 h-3" />
                                            </Button>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Pagination Controls */}
            <div className="flex items-center justify-center gap-4 mt-6">
                <Button
                    variant="outline"
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page === 1}
                >
                    Назад
                </Button>
                <span className="text-sm">Страница {page} из {data?.pages || 1}</span>
                <Button
                    variant="outline"
                    onClick={() => setPage((p) => p + 1)}
                    disabled={!data || page >= data.pages}
                >
                    Вперёд
                </Button>
            </div>
        </div>
    );
}




