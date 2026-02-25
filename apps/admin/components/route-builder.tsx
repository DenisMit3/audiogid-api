
'use client';

import { useState, useMemo, useCallback } from 'react';
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
import { GripVertical, Trash, MapPin, Plus, Clock, FileText, Edit2, Navigation, Mic, MousePointer2, Search, Maximize2, Minimize2, Eye, EyeOff } from 'lucide-react';
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
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import dynamic from 'next/dynamic';
import { AudioUploadField } from './audio-upload-field';

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
function SortableItem({ item, onRemove, onEdit, onTogglePublish, isPublishing }: { 
    item: TourItem, 
    onRemove: (id: string) => void, 
    onEdit: (item: TourItem) => void,
    onTogglePublish?: (item: TourItem) => void,
    isPublishing?: boolean
}) {
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

    const isPoiPublished = !!item.poi_published_at;

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
                    {!isPoiPublished && (
                        <span className="text-xs bg-orange-100 text-orange-600 px-1.5 py-0.5 rounded">черновик</span>
                    )}
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
                        <div className="flex items-center gap-1 text-green-600 bg-green-50 px-2 py-0.5 rounded-full font-medium">
                            <Mic className="w-3 h-3" />
                            <span>Аудио ✓</span>
                        </div>
                    )}
                    {!item.transition_audio_url && (
                        <div className="flex items-center gap-1 text-orange-500 bg-orange-50 px-2 py-0.5 rounded-full text-xs">
                            <Mic className="w-3 h-3" />
                            <span>Нет аудио</span>
                        </div>
                    )}
                    {(!item.duration_seconds && !item.transition_text_ru) && (
                        <span className="italic opacity-50">Детали не добавлены</span>
                    )}
                </div>
            </div>

            <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                {/* POI Publish toggle */}
                {onTogglePublish && (
                    <Button 
                        variant="ghost" 
                        size="sm" 
                        onClick={() => onTogglePublish(item)}
                        disabled={isPublishing}
                        title={isPoiPublished ? 'Снять POI с публикации' : 'Опубликовать POI'}
                    >
                        {isPoiPublished ? (
                            <Eye className="w-4 h-4 text-green-600" />
                        ) : (
                            <EyeOff className="w-4 h-4 text-orange-500" />
                        )}
                    </Button>
                )}
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
    poi_published_at?: string;
    transition_text_ru?: string;
    transition_audio_url?: string;
    duration_seconds?: number;
};

type Props = {
    items: TourItem[];
    citySlug?: string;
    tourId?: string;
    onReorder: (items: TourItem[]) => void;
    onAddItem: (poiId: string, poiTitle: string) => void;
    onRemoveItem: (id: string) => void;
    onUpdateItem: (itemId: string, data: { transition_text_ru?: string, duration_seconds?: number, transition_audio_url?: string }) => void;
    onAddNewPoi?: (lat: number, lon: number, title: string) => Promise<string | null>;
    onPoiPublishChange?: () => void;
};

const API_URL = '/api/proxy';

export function RouteBuilder({ items, citySlug, tourId, onReorder, onAddItem, onRemoveItem, onUpdateItem, onAddNewPoi, onPoiPublishChange }: Props) {
    const sensors = useSensors(
        useSensor(PointerSensor),
        useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
    );

    const [openCombobox, setOpenCombobox] = useState(false);
    const [editingItem, setEditingItem] = useState<TourItem | null>(null);
    const [editForm, setEditForm] = useState({ text: '', duration: 0, audioUrl: '' });
    const [selectedItemId, setSelectedItemId] = useState<string | undefined>();
    const [isAddMode, setIsAddMode] = useState(false);
    const [isMapExpanded, setIsMapExpanded] = useState(false);
    const [newPointDialog, setNewPointDialog] = useState<{ lat: number, lon: number } | null>(null);
    const [newPointTitle, setNewPointTitle] = useState('');
    const queryClient = useQueryClient();

    // POI Publish/Unpublish mutation
    const togglePoiPublishMutation = useMutation({
        mutationFn: async ({ poiId, action }: { poiId: string, action: 'publish' | 'unpublish' }) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/pois/${poiId}/${action}`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${token}` }
            });
            if (!res.ok) {
                const data = await res.json().catch(() => ({}));
                
                // Извлекаем сообщение об ошибке
                let errorMsg = '';
                if (typeof data.detail === 'string') {
                    errorMsg = data.detail;
                } else if (Array.isArray(data.detail)) {
                    // Pydantic validation errors
                    errorMsg = data.detail.map((e: any) => e.msg || e.message || String(e)).join(', ');
                } else if (typeof data.message === 'string') {
                    errorMsg = data.message;
                } else if (data.detail?.msg) {
                    errorMsg = data.detail.msg;
                }
                
                // Формируем понятное сообщение на русском
                if (errorMsg.includes('Description too short')) {
                    errorMsg = 'Описание POI слишком короткое (минимум 10 символов)';
                } else if (errorMsg.includes('Missing coordinates')) {
                    errorMsg = 'У POI не заданы координаты';
                } else if (errorMsg.includes('Field required')) {
                    errorMsg = 'Не все обязательные поля POI заполнены';
                } else if (!errorMsg) {
                    errorMsg = `Не удалось ${action === 'publish' ? 'опубликовать' : 'снять с публикации'} POI`;
                }
                throw new Error(errorMsg);
            }
            return res.json();
        },
        onSuccess: () => {
            // Обновляем данные тура чтобы получить новый статус POI
            if (tourId) {
                queryClient.invalidateQueries({ queryKey: ['tour', tourId] });
            }
            onPoiPublishChange?.();
        },
        onError: (error: Error) => {
            alert(error.message || 'Произошла ошибка');
        }
    });

    const handleTogglePoiPublish = useCallback((item: TourItem) => {
        if (!item.poi_id) return;
        const action = item.poi_published_at ? 'unpublish' : 'publish';
        togglePoiPublishMutation.mutate({ poiId: item.poi_id, action });
    }, [togglePoiPublishMutation]);

    // Create new POI mutation
    const createPoiMutation = useMutation({
        mutationFn: async ({ lat, lon, title }: { lat: number, lon: number, title: string }) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/pois`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                    'x-admin-token': 'temp-admin-key-2026'
                },
                body: JSON.stringify({
                    title_ru: title,
                    city_slug: citySlug || 'kaliningrad_city'
                })
            });
            if (!res.ok) {
                const errorText = await res.text();
                console.error('POI creation error:', errorText);
                throw new Error('Не удалось создать точку');
            }
            return res.json();
        },
        onSuccess: (data) => {
            queryClient.invalidateQueries({ queryKey: ['pois_search'] });
            onAddItem(data.id, data.title_ru);
            setNewPointDialog(null);
            setNewPointTitle('');
            setIsAddMode(false);
        }
    });

    // Handle map click in add mode
    const handleMapClick = useCallback((lat: number, lon: number) => {
        if (isAddMode) {
            setNewPointDialog({ lat, lon });
        }
    }, [isAddMode]);

    // Save new point
    const handleSaveNewPoint = () => {
        if (!newPointDialog || !newPointTitle.trim()) return;
        createPoiMutation.mutate({
            lat: newPointDialog.lat,
            lon: newPointDialog.lon,
            title: newPointTitle.trim()
        });
    };

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
        <div className={`grid gap-6 ${isMapExpanded ? 'grid-cols-1' : 'grid-cols-1 lg:grid-cols-2'}`} style={{ height: isMapExpanded ? '80vh' : '700px' }}>
            {/* Left Column: List - hidden when map expanded */}
            {!isMapExpanded && (
            <div className="flex flex-col h-full space-y-4">
                <div className="flex justify-between items-center bg-slate-50 p-3 rounded-lg border">
                    <div>
                        <h3 className="font-semibold text-sm">Точки маршрута</h3>
                        <p className="text-xs text-muted-foreground">
                            {items.length} остановок • {formatDistance(routeStats.distance)} • ~{routeStats.totalTime} мин всего
                        </p>
                    </div>

                    <div className="flex gap-2">
                        <Button 
                            variant={isAddMode ? "default" : "outline"} 
                            size="sm"
                            onClick={() => setIsAddMode(!isAddMode)}
                            className={isAddMode ? "bg-blue-500 hover:bg-blue-600" : ""}
                        >
                            <MousePointer2 className="w-4 h-4 mr-2" />
                            {isAddMode ? "Отмена" : "Добавить на карте"}
                        </Button>
                        <Popover open={openCombobox} onOpenChange={setOpenCombobox}>
                            <PopoverTrigger asChild>
                                <Button variant="outline" size="sm">
                                    <Plus className="w-4 h-4 mr-2" /> Из списка
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
                                <div className="h-full flex flex-col items-center justify-center text-slate-400 py-8">
                                    <MapPin className="w-12 h-12 mb-3 opacity-50" />
                                    <span className="text-sm font-medium">Маршрут пуст</span>
                                    <span className="text-xs mt-1 text-center max-w-[200px]">
                                        Нажмите "Добавить на карте" и кликните на карту, или выберите точку из списка
                                    </span>
                                </div>
                            )}
                            {sortedItems.map((item, idx) => (
                                <div key={item.id}>
                                    <SortableItem 
                                        item={item} 
                                        onRemove={onRemoveItem} 
                                        onEdit={handleEditClick}
                                        onTogglePublish={handleTogglePoiPublish}
                                        isPublishing={togglePoiPublishMutation.isPending}
                                    />
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
            )}

            {/* Right Column: Map */}
            <div className="h-full flex flex-col">
                {/* Map toolbar */}
                <div className="flex justify-between items-center mb-2">
                    <div className="text-sm text-slate-500">
                        {isAddMode && (
                            <span className="text-blue-600 font-medium flex items-center gap-1">
                                <MousePointer2 className="w-4 h-4" />
                                Кликните на карту для добавления точки
                            </span>
                        )}
                    </div>
                    <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setIsMapExpanded(!isMapExpanded)}
                    >
                        {isMapExpanded ? (
                            <><Minimize2 className="w-4 h-4 mr-1" /> Свернуть</>
                        ) : (
                            <><Maximize2 className="w-4 h-4 mr-1" /> Развернуть</>
                        )}
                    </Button>
                </div>
                <div className="flex-1 min-h-[500px]">
                    <RouteMap 
                        items={sortedItems} 
                        onRemoveItem={onRemoveItem}
                        onMapClick={handleMapClick}
                        selectedItemId={selectedItemId}
                        isAddMode={isAddMode}
                    />
                </div>
            </div>

            {/* Edit Modal */}
            <Dialog open={!!editingItem} onOpenChange={(o) => { if (!o) { setEditingItem(null); setSelectedItemId(undefined); } }}>
                <DialogContent className="max-w-md p-0 gap-0 overflow-hidden max-h-[90vh] flex flex-col">
                    {/* Header */}
                    <div className="px-5 py-4 border-b bg-slate-50 shrink-0">
                        <DialogTitle className="text-base font-semibold text-slate-800">
                            {editingItem?.poi_title}
                        </DialogTitle>
                        <p className="text-xs text-slate-500 mt-0.5">Настройки точки маршрута</p>
                    </div>
                    
                    {/* Content */}
                    <div className="px-5 py-4 space-y-4 overflow-y-auto flex-1">
                        {/* Длительность */}
                        <div>
                            <Label className="text-xs font-medium text-slate-600 mb-1.5 block">
                                Время осмотра
                            </Label>
                            <div className="flex items-center gap-2">
                                <Input
                                    type="number"
                                    value={editForm.duration}
                                    onChange={e => setEditForm({ ...editForm, duration: parseInt(e.target.value) || 0 })}
                                    className="w-24 h-9"
                                />
                                <span className="text-sm text-slate-500">сек</span>
                                <span className="text-xs text-slate-400">({Math.floor(editForm.duration / 60)} мин)</span>
                            </div>
                        </div>
                        
                        {/* Заметка */}
                        <div>
                            <Label className="text-xs font-medium text-slate-600 mb-1.5 block">
                                Инструкция перехода
                            </Label>
                            <Textarea
                                value={editForm.text}
                                onChange={e => setEditForm({ ...editForm, text: e.target.value })}
                                placeholder="Пройдите 50м прямо, поверните налево..."
                                rows={2}
                                className="resize-none text-sm"
                            />
                        </div>

                        {/* Аудио */}
                        <div>
                            <Label className="text-xs font-medium text-slate-600 mb-1.5 flex items-center gap-1.5">
                                <Mic className="w-3.5 h-3.5 text-purple-500" />
                                Аудио перехода
                            </Label>
                            <AudioUploadField
                                value={editForm.audioUrl}
                                onChange={(url) => setEditForm({ ...editForm, audioUrl: url || '' })}
                                entityType="tour"
                                entityId={editingItem?.id}
                            />
                        </div>
                    </div>
                    
                    {/* Footer */}
                    <div className="px-5 py-3 border-t bg-slate-50 flex justify-end gap-2 shrink-0">
                        <Button variant="ghost" size="sm" onClick={() => { setEditingItem(null); setSelectedItemId(undefined); }}>
                            Отмена
                        </Button>
                        <Button size="sm" onClick={saveEdit}>
                            Сохранить
                        </Button>
                    </div>
                </DialogContent>
            </Dialog>

            {/* New Point Dialog */}
            <Dialog open={!!newPointDialog} onOpenChange={(o) => { if (!o) { setNewPointDialog(null); setNewPointTitle(''); } }}>
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle>Новая точка маршрута</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="bg-slate-50 p-3 rounded-lg text-sm">
                            <div className="flex items-center gap-2 text-slate-600">
                                <MapPin className="w-4 h-4" />
                                <span>Координаты:</span>
                            </div>
                            <div className="mt-1 font-mono text-xs">
                                {newPointDialog?.lat.toFixed(6)}, {newPointDialog?.lon.toFixed(6)}
                            </div>
                        </div>
                        
                        <div className="grid gap-2">
                            <Label>Название точки *</Label>
                            <Input
                                value={newPointTitle}
                                onChange={e => setNewPointTitle(e.target.value)}
                                placeholder="Например: Кафедральный собор"
                                autoFocus
                            />
                            <p className="text-xs text-muted-foreground">
                                Будет создана новая достопримечательность и добавлена в маршрут
                            </p>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => { setNewPointDialog(null); setNewPointTitle(''); }}>
                            Отмена
                        </Button>
                        <Button 
                            onClick={handleSaveNewPoint} 
                            disabled={!newPointTitle.trim() || createPoiMutation.isPending}
                        >
                            {createPoiMutation.isPending ? 'Создание...' : 'Создать и добавить'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
