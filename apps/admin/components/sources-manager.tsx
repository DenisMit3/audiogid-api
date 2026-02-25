'use client';

import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Trash, Globe } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
    DialogFooter
} from "@/components/ui/dialog";

type Source = {
    id: string;
    name: string;
    url?: string;
};

type Props = {
    poiId: string;
    sources: Source[];
    entityType: 'poi' | 'tour';
};

const API_URL = '/api/proxy';
// throw removed for build

export function SourcesManager({ poiId, sources: initialSources, entityType }: Props) {
    const [sources, setSources] = useState<Source[]>(initialSources || []);
    const [newName, setNewName] = useState('');
    const [newUrl, setNewUrl] = useState('');
    const queryClient = useQueryClient();

    const addMutation = useMutation({
        mutationFn: async () => {
            const endpoint = entityType === 'poi'
                ? `${API_URL}/admin/pois/${poiId}/sources`
                : `${API_URL}/admin/tours/${poiId}/sources`;

            const res = await fetch(endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({ name: newName, url: newUrl })
            });
            if (!res.ok) throw new Error('Не удалось добавить источник');
            return res.json();
        },
        onSuccess: (data: any) => {
            setSources([...sources, { id: data.id, name: newName, url: newUrl }]);
            setNewName('');
            setNewUrl('');
            queryClient.invalidateQueries({ queryKey: [entityType + 's', poiId] });
        },
        onError: () => alert("Не удалось добавить источник")
    });

    const deleteMutation = useMutation({
        mutationFn: async (sourceId: string) => {
            const endpoint = entityType === 'poi'
                ? `${API_URL}/admin/pois/${poiId}/sources/${sourceId}`
                : `${API_URL}/admin/tours/${poiId}/sources/${sourceId}`;

            const res = await fetch(endpoint, {
                method: 'DELETE',
                credentials: 'include'
            });
            if (!res.ok) throw new Error('Не удалось удалить источник');
            return sourceId;
        },
        onSuccess: (id: string) => {
            setSources(sources.filter(s => s.id !== id));
            queryClient.invalidateQueries({ queryKey: [entityType + 's', poiId] });
        }
    });

    return (
        <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0">
                <CardTitle className="text-lg">Источники контента</CardTitle>
                {entityType === 'poi' && <ImportWikipediaButton poiId={poiId} />}
            </CardHeader>
            <CardContent className="space-y-4">
                <div className="space-y-2">
                    {sources.map((s) => (
                        <div key={s.id} className="flex items-center justify-between p-2 border rounded-md bg-slate-50">
                            <div className="flex items-center gap-3 overflow-hidden">
                                <Globe className="w-4 h-4 text-muted-foreground flex-shrink-0" />
                                <div className="truncate">
                                    <div className="font-medium text-sm">{s.name}</div>
                                    {s.url && <a href={s.url} target="_blank" className="text-xs text-blue-500 hover:underline">{s.url}</a>}
                                </div>
                            </div>
                            <Button variant="ghost" size="sm" onClick={() => deleteMutation.mutate(s.id)} disabled={deleteMutation.isPending}>
                                <Trash className="w-4 h-4 text-red-500" />
                            </Button>
                        </div>
                    ))}
                    {sources.length === 0 && <div className="text-sm text-muted-foreground text-center py-4">Источники не привязаны</div>}
                </div>

                <div className="flex gap-2 items-end pt-2 border-t">
                    <div className="grid w-full gap-1.5 flex-1">
                        <Label htmlFor="source-name" className="text-xs">Название источника</Label>
                        <Input
                            id="source-name"
                            placeholder="напр. Википедия"
                            value={newName}
                            onChange={e => setNewName(e.target.value)}
                            className="h-8"
                        />
                    </div>
                    <div className="grid w-full gap-1.5 flex-[2]">
                        <Label htmlFor="source-url" className="text-xs">URL</Label>
                        <Input
                            id="source-url"
                            placeholder="https://..."
                            value={newUrl}
                            onChange={e => setNewUrl(e.target.value)}
                            className="h-8"
                        />
                    </div>
                    <Button
                        size="sm"
                        onClick={() => addMutation.mutate()}
                        disabled={!newName || addMutation.isPending}
                        className="mb-[1px]"
                    >
                        <Plus className="w-4 h-4" />
                    </Button>
                </div>
            </CardContent>
        </Card>
    );
}

function ImportWikipediaButton({ poiId }: { poiId: string }) {
    const [open, setOpen] = useState(false);
    const [query, setQuery] = useState('');
    const queryClient = useQueryClient();

    const mutation = useMutation({
        mutationFn: async () => {
            const res = await fetch(`${API_URL}/admin/pois/${poiId}/import-wikipedia`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({ query: query, lang: 'ru' })
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || "Не удалось импортировать");
            }
            return res.json();
        },
        onSuccess: (data: any) => {
            setOpen(false);
            alert(`Импорт успешен!\nОбновлено: ${data.changes.join(', ')}`);
            queryClient.invalidateQueries({ queryKey: ['poi', poiId] });
            // FORCE REFETCH of the page logic if needed, but invalidating 'poi' should trigger page refetch
        },
        onError: (err) => {
            alert(`Ошибка: ${err.message}`);
        }
    });

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button variant="outline" size="sm" className="gap-2">
                    <Globe className="w-4 h-4" /> Импорт из Wiki
                </Button>
            </DialogTrigger>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>Импорт из Википедии</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-4">
                    <div className="grid gap-2">
                        <Label>Поисковый запрос или URL</Label>
                        <Input
                            placeholder="напр. 'Кафедральный собор Калининграда'"
                            value={query}
                            onChange={(e) => setQuery(e.target.value)}
                        />
                        <p className="text-xs text-muted-foreground">
                            Загружает описание, изображение, координаты и ссылку. Перезаписывает существующие данные.
                        </p>
                    </div>
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={() => setOpen(false)}>Отмена</Button>
                    <Button onClick={() => mutation.mutate()} disabled={!query || mutation.isPending}>
                        {mutation.isPending ? 'Импорт...' : 'Найти и импортировать'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}




