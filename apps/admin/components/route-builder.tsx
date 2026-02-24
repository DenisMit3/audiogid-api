
'use client';

import { useState, useMemo } from 'react';
import {
    DndContext,
    closestCenter,
    KeyboardSensor,
    PointerSensor,
    useSensor,
    useSensors,
} from '@dnd-kit/core';
import {
    arrayMove,
    SortableContext,
    sortableKeyboardCoordinates,
    verticalListSortingStrategy,
    useSortable
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { GripVertical, Trash, MapPin, Plus, Clock, FileText, Edit2, Navigation, Play, Mic } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from "@/components/ui/dialog";
import {
    Command,
    CommandGroup,
    CommandInput,
    CommandItem,
} from "@/components/ui/command";
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from "@/components/ui/popover";
import { useQuery } from '@tanstack/react-query';
import dynamic from 'next/dynamic';

const RouteMap = dynamic(() => import('./route-map').then(mod => mod.RouteMap), {
    ssr: false,
    loading: () => <div className="h-full w-full flex items-center justify-center bg-slate-100 font-mono text-xs">Загрузка карты...</div>
});

// --- Haversine distance calculation ---
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // Distance in km
}

function formatDistance(km: number): string {
    if (km < 1) {
        return `${Math.round(km * 1000)} м`;
    }
    return `${km.toFixed(1)} км`;
}

function estimateWalkingTime(km: number): number {
    // Average walking speed ~5 km/h
    return Math.round(km / 5 * 60); // minutes
}

// --- Distance indicator between items ---
function DistanceIndicator({ fromItem, toItem }: { fromItem: TourItem, toItem: TourItem }) {
    if (!fromItem.poi_lat || !fromItem.poi_lon || !toItem.poi_lat || !toItem.poi_lon) {
        return null;
    }
    
    const distance = calculateDistance(fromItem.poi_lat, fromItem.poi_lon, toItem.poi_lat, toItem.poi_lon);
    const walkTime = estimateWalkingTime(distance);
    
    return (
        <div className="flex items-center justify-center py-1 text-xs text-slate-400">
            <div className="flex items-center gap-2 bg-slate-100 px-3 py-1 rounded-full">
                <Navigation className="w-3 h-3" />
                <span>{formatDistance(distance)}</span>
                <span className="text-slate-300">•</span>
                <Clock className="w-3 h-3" />
                <span>~{walkTime} мин</span>
            </div>
        </div>
    );
}

// --- Sortable Item Component ---
function SortableItem({ item, onRemove, onEdit }: { item: TourItem, onRemove: (id: string) => void, onEdit: (item: TourItem) => void }) {
    const {
        attributes,
        listeners,
        setNodeRef,
        transform,
        transition,
        isDragging
    } = useSortable({ id: item.id });

    const style = {
        transform: CSS.Transform.toString(transform),
        transition,
        zIndex: isDragging ? 50 : 'auto',
        opacity: isDragging ? 0.3 : 1
    };

    return (
        <div
            ref={setNodeRef}
            style={style}
            className="flex items-center gap-3 p-3 bg-white border rounded-md shadow-sm group hover:border-blue-400 transition-colors"
        >
            <div {...attributes} {...listeners} className="cursor-grab text-slate-400 hover:text-slate-600 self-stretch flex items-center bg-slate-50 -ml-3 pl-3 rounded-l-md pr-2 border-r">
                <GripVertical className="w-5 h-5" />
            </div>

            <div className="flex-1 min-w-0">
                <div className="font-medium text-sm flex items-center gap-2">
                    <span className="w-6 h-6 rounded-full bg-indigo-500 text-white flex items-center justify-center text-xs font-bold flex-shrink-0">
                        {item.order_index + 1}
                    </span>
                    <span className="truncate">{item.poi_title || "Неизвестная точка"}</span>
                </div>

                <div className="flex gap-4 mt-1 text-xs text-muted-foreground">
                    {item.duration_seconds && item.duration_seconds > 0 && (
                        <div className="flex items-center gap-1">
                            <Clock className="w-3 h-3" />
                            {Math.floor(item.duration_seconds / 60)} мин
                        </div>
                    )}
                    {item.transition_text_ru && (
                        <div className="flex items-center gap-1">
                            <FileText className="w-3 h-3" />
                            <span>Заметка</span>
                        </div>
                    )}
                    {item.transition_audio_url && (
                        <div className="flex items-center gap-1 text-purple-500">
                            <Mic className="w-3 h-3" />
                            <span>Аудио</span>
                        </div>
                    )}
                    {(!item.duration_seconds && !item.transition_text_ru && !item.transition_audio_url) && (
                        <span className="italic opacity-50">Детали не добавлены</span>
                    )}
                </div>
            </div>

            <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                <Button variant="ghost" size="sm" onClick={() => onEdit(item)}>
                    <Edit2 className="w-4 h-4 text-slate-500" />
                </Button>
                <Button variant="ghost" size="sm" onClick={() => onRemove(item.id)} className="text-red-500 hover:text-red-700 hover:bg-red-50">
                    <Trash className="w-4 h-4" />
                </Button>
            </div>
        </div>
    );
}

// --- Main Component ---

type TourItem = {
    id: string;
    poi_id: string;
    order_index: number;
    poi_title?: string;
    poi_lat?: number;
    poi_lon?: number;
    transition_text_ru?: string;
    transition_audio_url?: string;
    duration_seconds?: number;
};

type Props = {
    items: TourItem[];
    citySlug?: string;
    onReorder: (items: TourItem[]) => void;
    onAddItem: (poiId: string, poiTitle: string) => void;
    onRemoveItem: (id: string) => void;
    onUpdateItem: (itemId: string, data: { transition_text_ru?: string, duration_seconds?: number, transition_audio_url?: string }) => void;
};

const API_URL = '/api/proxy';

export function RouteBuilder({ items, citySlug, onReorder, onAddItem, onRemoveItem, onUpdateItem }: Props) {
    const sensors = useSensors(
        useSensor(PointerSensor),
        useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
    );

    const [openCombobox, setOpenCombobox] = useState(false);
    const [editingItem, setEditingItem] = useState<TourItem | null>(null);
    const [editForm, setEditForm] = useState({ text: '', duration: 0, audioUrl: '' });
    const [selectedItemId, setSelectedItemId] = useState<string | undefined>();

    // Calculate total route stats
    const routeStats = useMemo(() => {
        let totalDistance = 0;
        let totalWalkTime = 0;
        const sortedItems = [...items].sort((a, b) => a.order_index - b.order_index);
        
        for (let i = 0; i < sortedItems.length - 1; i++) {
            const from = sortedItems[i];
            const to = sortedItems[i + 1];
            if (from.poi_lat && from.poi_lon && to.poi_lat && to.poi_lon) {
                const dist = calculateDistance(from.poi_lat, from.poi_lon, to.poi_lat, to.poi_lon);
                totalDistance += dist;
                totalWalkTime += estimateWalkingTime(dist);
            }
        }
        
        const totalStayTime = items.reduce((acc, i) => acc + (i.duration_seconds || 0), 0);
        
        return {
            distance: totalDistance,
            walkTime: totalWalkTime,
            stayTime: Math.round(totalStayTime / 60),
            totalTime: totalWalkTime + Math.round(totalStayTime / 60)
        };
    }, [items]);

    // Fetch POIs for autocomplete
    const { data: poiOptions } = useQuery({
        queryKey: ['pois_search', citySlug],
        queryFn: async () => {
            const cityFilter = citySlug ? `&city_slug=${citySlug}` : '';
            const res = await fetch(`${API_URL}/admin/pois?page=1&per_page=100${cityFilter}`, {
                headers: { Authorization: `Bearer ${localStorage.getItem('admin_token')}` }
            });
            if (!res.ok) return { items: [] };
            return res.json();
        }
    });

    const handleDragEnd = (event: any) => {
        const { active, over } = event;
        if (active.id !== over?.id) {
            const oldIndex = items.findIndex(i => i.id === active.id);
            const newIndex = items.findIndex(i => i.id === over.id);
            const newItems = arrayMove(items, oldIndex, newIndex);
            const reindexed = newItems.map((item, idx) => ({ ...item, order_index: idx }));
            onReorder(reindexed);
        }
    };

    const handleEditClick = (item: TourItem) => {
        setEditingItem(item);
        setEditForm({
            text: item.transition_text_ru || '',
            duration: item.duration_seconds || 0,
            audioUrl: item.transition_audio_url || ''
        });
        setSelectedItemId(item.id);
    };

    const saveEdit = () => {
        if (!editingItem) return;
        onUpdateItem(editingItem.id, {
            transition_text_ru: editForm.text,
            duration_seconds: editForm.duration,
            transition_audio_url: editForm.audioUrl || undefined
        });
        setEditingItem(null);
        setSelectedItemId(undefined);
    };

    const sortedItems = useMemo(() => 
        [...items].sort((a, b) => a.order_index - b.order_index), 
        [items]
    );

    return (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[600px]">
            {/* Left Column: List */}
            <div className="flex flex-col h-full space-y-4">
                <div className="flex justify-between items-center bg-slate-50 p-3 rounded-lg border">
                    <div>
                        <h3 className="font-semibold text-sm">Точки маршрута</h3>
                        <p className="text-xs text-muted-foreground">
                            {items.length} остановок • {formatDistance(routeStats.distance)} • ~{routeStats.totalTime} мин всего
                        </p>
                    </div>

                    <Popover open={openCombobox} onOpenChange={setOpenCombobox}>
                        <PopoverTrigger asChild>
                            <Button variant="outline" size="sm">
                                <Plus className="w-4 h-4 mr-2" /> Добавить
                            </Button>
                        </PopoverTrigger>
                        <PopoverContent className="p-0 w-[300px]" align="end">
                            <Command>
                                <CommandInput placeholder="Поиск точек..." />
                                <CommandGroup className="max-h-[200px] overflow-auto">
                                    {!poiOptions?.items?.length && <div className="p-2 text-xs text-center">Точки не найдены</div>}
                                    {poiOptions?.items?.map((poi: any) => (
                                        <CommandItem
                                            key={poi.id}
                                            value={poi.title_ru}
                                            onSelect={() => {
                                                onAddItem(poi.id, poi.title_ru);
                                                setOpenCombobox(false);
                                            }}
                                        >
                                            <MapPin className="mr-2 h-4 w-4 opacity-50" />
                                            {poi.title_ru}
                                        </CommandItem>
                                    ))}
                                </CommandGroup>
                            </Command>
                        </PopoverContent>
                    </Popover>
                </div>

                <div className="flex-1 overflow-y-auto bg-slate-50/50 rounded-lg p-2 border border-dashed border-slate-200">
                    <DndContext
                        sensors={sensors}
                        collisionDetection={closestCenter}
                        onDragEnd={handleDragEnd}
                    >
                        <SortableContext
                            items={sortedItems.map(i => i.id)}
                            strategy={verticalListSortingStrategy}
                        >
                            {sortedItems.length === 0 && (
                                <div className="h-full flex flex-col items-center justify-center text-slate-400">
                                    <MapPin className="w-8 h-8 mb-2 opacity-50" />
                                    <span className="text-sm">Маршрут пуст</span>
                                    <span className="text-xs mt-1">Добавьте точки или найдите на карте</span>
                                </div>
                            )}
                            {sortedItems.map((item, idx) => (
                                <div key={item.id}>
                                    <SortableItem item={item} onRemove={onRemoveItem} onEdit={handleEditClick} />
                                    {idx < sortedItems.length - 1 && (
                                        <DistanceIndicator fromItem={item} toItem={sortedItems[idx + 1]} />
                                    )}
                                </div>
                            ))}
                        </SortableContext>
                    </DndContext>
                </div>

                {/* Route Summary */}
                {items.length > 1 && (
                    <div className="bg-indigo-50 border border-indigo-200 rounded-lg p-3">
                        <div className="text-xs font-medium text-indigo-700 mb-1">Итого по маршруту</div>
                        <div className="flex gap-4 text-sm text-indigo-600">
                            <div className="flex items-center gap-1">
                                <Navigation className="w-4 h-4" />
                                {formatDistance(routeStats.distance)}
                            </div>
                            <div className="flex items-center gap-1">
                                <Clock className="w-4 h-4" />
                                {routeStats.walkTime} мин пешком
                            </div>
                            <div className="flex items-center gap-1">
                                <MapPin className="w-4 h-4" />
                                {routeStats.stayTime} мин осмотр
                            </div>
                        </div>
                    </div>
                )}
            </div>

            {/* Right Column: Map */}
            <div className="h-full">
                <RouteMap 
                    items={sortedItems} 
                    onRemoveItem={onRemoveItem}
                    selectedItemId={selectedItemId}
                />
            </div>

            {/* Edit Modal */}
            <Dialog open={!!editingItem} onOpenChange={(o) => { if (!o) { setEditingItem(null); setSelectedItemId(undefined); } }}>
                <DialogContent className="max-w-lg">
                    <DialogHeader>
                        <DialogTitle>
                            Редактировать: {editingItem?.poi_title}
                        </DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="grid gap-2">
                            <Label>Рекомендуемая длительность осмотра</Label>
                            <div className="flex gap-2 items-center">
                                <Input
                                    type="number"
                                    value={editForm.duration}
                                    onChange={e => setEditForm({ ...editForm, duration: parseInt(e.target.value) || 0 })}
                                    className="w-32"
                                />
                                <span className="text-sm text-muted-foreground">секунд ({Math.floor(editForm.duration / 60)} мин)</span>
                            </div>
                        </div>
                        
                        <div className="grid gap-2">
                            <Label>Заметка перехода к следующей точке</Label>
                            <Textarea
                                value={editForm.text}
                                onChange={e => setEditForm({ ...editForm, text: e.target.value })}
                                placeholder="Пройдите 50м прямо, поверните налево у фонтана..."
                                rows={3}
                            />
                        </div>

                        <div className="grid gap-2">
                            <Label className="flex items-center gap-2">
                                <Mic className="w-4 h-4 text-purple-500" />
                                Аудио перехода (URL)
                            </Label>
                            <Input
                                value={editForm.audioUrl}
                                onChange={e => setEditForm({ ...editForm, audioUrl: e.target.value })}
                                placeholder="https://storage.example.com/audio/transition.mp3"
                            />
                            {editForm.audioUrl && (
                                <div className="flex items-center gap-2 p-2 bg-purple-50 rounded-md">
                                    <Button variant="ghost" size="sm" className="text-purple-600">
                                        <Play className="w-4 h-4 mr-1" /> Прослушать
                                    </Button>
                                    <audio src={editForm.audioUrl} controls className="h-8 flex-1" />
                                </div>
                            )}
                            <p className="text-xs text-muted-foreground">
                                Аудио-инструкция для перехода к следующей точке маршрута
                            </p>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => { setEditingItem(null); setSelectedItemId(undefined); }}>Отмена</Button>
                        <Button onClick={saveEdit}>Сохранить</Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
