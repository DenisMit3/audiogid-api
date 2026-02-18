
'use client';

import { useState } from 'react';
import {
    DndContext,
    closestCenter,
    KeyboardSensor,
    PointerSensor,
    useSensor,
    useSensors,
    DragOverlay,
} from '@dnd-kit/core';
import {
    arrayMove,
    SortableContext,
    sortableKeyboardCoordinates,
    verticalListSortingStrategy,
    useSortable
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { GripVertical, Trash, MapPin, Plus, Clock, FileText, Edit2 } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
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
    CommandDialog,
    CommandEmpty,
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
    loading: () => <div className="h-full w-full flex items-center justify-center bg-slate-100 font-mono text-xs">Loading Map Engine...</div>
});

// --- Sortable Item Component ---

function SortableItem({ item, onRemove, onEdit }: { item: any, onRemove: (id: string) => void, onEdit: (item: any) => void }) {
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
            className="flex items-center gap-3 p-3 bg-white border rounded-md shadow-sm mb-2 group hover:border-blue-400 transition-colors"
        >
            <div {...attributes} {...listeners} className="cursor-grab text-slate-400 hover:text-slate-600 self-stretch flex items-center bg-slate-50 -ml-3 pl-3 rounded-l-md pr-2 border-r">
                <GripVertical className="w-5 h-5" />
            </div>

            <div className="flex-1 min-w-0">
                <div className="font-medium text-sm flex items-center gap-2">
                    <span className="w-6 h-6 rounded-full bg-slate-100 flex items-center justify-center text-xs font-bold text-slate-600 flex-shrink-0">
                        {item.order_index + 1}
                    </span>
                    <span className="truncate">{item.poi_title || "Unknown POI"}</span>
                </div>

                {item.id === 'placeholder' ? (
                    <div className="text-xs text-red-500 mt-1">Unsaved Item</div>
                ) : (
                    <div className="flex gap-4 mt-1 text-xs text-muted-foreground">
                        {item.duration_seconds > 0 && (
                            <div className="flex items-center gap-1">
                                <Clock className="w-3 h-3" />
                                {Math.floor(item.duration_seconds / 60)} min
                            </div>
                        )}
                        {item.transition_text_ru && (
                            <div className="flex items-center gap-1">
                                <FileText className="w-3 h-3" />
                                <span>Has transition note</span>
                            </div>
                        )}
                        {(!item.duration_seconds && !item.transition_text_ru) && (
                            <span className="italic opacity-50">No details added</span>
                        )}
                    </div>
                )}
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
    duration_seconds?: number;
};

type Props = {
    items: TourItem[];
    onReorder: (items: TourItem[]) => void;
    onAddItem: (poiId: string, poiTitle: string) => void;
    onRemoveItem: (id: string) => void;
    onUpdateItem: (itemId: string, data: { transition_text_ru?: string, duration_seconds?: number }) => void;
};

const API_URL = '/api/proxy';
// throw removed for build

export function RouteBuilder({ items, onReorder, onAddItem, onRemoveItem, onUpdateItem }: Props) {
    const sensors = useSensors(
        useSensor(PointerSensor),
        useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
    );

    const [openCombobox, setOpenCombobox] = useState(false);
    const [editingItem, setEditingItem] = useState<TourItem | null>(null);
    const [editForm, setEditForm] = useState({ text: '', duration: 0 });

    // Fetch POIs for autocomplete
    const { data: poiOptions } = useQuery({
        queryKey: ['pois_search'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/pois?page=1&per_page=100`, {
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
            duration: item.duration_seconds || 0
        });
    };

    const saveEdit = () => {
        if (!editingItem) return;
        onUpdateItem(editingItem.id, {
            transition_text_ru: editForm.text,
            duration_seconds: editForm.duration
        });
        setEditingItem(null);
    };

    return (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[600px]">
            {/* Left Column: List */}
            <div className="flex flex-col h-full space-y-4">
                <div className="flex justify-between items-center bg-slate-50 p-3 rounded-lg border">
                    <div>
                        <h3 className="font-semibold text-sm">Route Points</h3>
                        <p className="text-xs text-muted-foreground">{items.length} stops • {Math.round(items.reduce((acc, i) => acc + (i.duration_seconds || 0), 0) / 60)} min stay</p>
                    </div>

                    <Popover open={openCombobox} onOpenChange={setOpenCombobox}>
                        <PopoverTrigger asChild>
                            <Button variant="outline" size="sm">
                                <Plus className="w-4 h-4 mr-2" /> Add
                            </Button>
                        </PopoverTrigger>
                        <PopoverContent className="p-0 w-[300px]" align="end">
                            <Command>
                                <CommandInput placeholder="Search POIs..." />
                                <CommandGroup className="max-h-[200px] overflow-auto">
                                    {!poiOptions?.items?.length && <div className="p-2 text-xs text-center">No POIs found</div>}
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
                            items={items.map(i => i.id)}
                            strategy={verticalListSortingStrategy}
                        >
                            {items.length === 0 && (
                                <div className="h-full flex flex-col items-center justify-center text-slate-400">
                                    <MapPin className="w-8 h-8 mb-2 opacity-50" />
                                    <span className="text-sm">Route is empty</span>
                                </div>
                            )}
                            {items.map((item) => (
                                <SortableItem key={item.id} item={item} onRemove={onRemoveItem} onEdit={handleEditClick} />
                            ))}
                        </SortableContext>
                    </DndContext>
                </div>
            </div>

            {/* Right Column: Map */}
            <div className="h-full">
                <RouteMap items={items} />
            </div>

            {/* Edit Modal */}
            <Dialog open={!!editingItem} onOpenChange={(o) => !o && setEditingItem(null)}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Edit Stop Details</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="grid gap-2">
                            <Label>Recommended Duration (sec)</Label>
                            <Input
                                type="number"
                                value={editForm.duration}
                                onChange={e => setEditForm({ ...editForm, duration: parseInt(e.target.value) || 0 })}
                            />
                            <p className="text-xs text-muted-foreground">{Math.floor(editForm.duration / 60)} minutes</p>
                        </div>
                        <div className="grid gap-2">
                            <Label>Transition Note (Next Step Guide)</Label>
                            <Textarea
                                value={editForm.text}
                                onChange={e => setEditForm({ ...editForm, text: e.target.value })}
                                placeholder="Walk 50m straight, turn left..."
                            />
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setEditingItem(null)}>Cancel</Button>
                        <Button onClick={saveEdit}>Save Changes</Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}




