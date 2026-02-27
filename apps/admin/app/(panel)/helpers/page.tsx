'use client';

import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Plus, Pencil, Trash2, Search, Loader2, MapPin } from 'lucide-react';

const API_URL = '/api/proxy';

type Helper = {
    id: string;
    city_slug: string;
    type: string;
    lat: number;
    lon: number;
    name_ru?: string;
    name_en?: string;
    osm_id?: string;
    address?: string;
    opening_hours?: string;
};

type HelperType = {
    value: string;
    label: string;
};

const HELPER_TYPES: HelperType[] = [
    { value: 'toilet', label: '🚻 Туалет' },
    { value: 'cafe', label: '☕ Кафе' },
    { value: 'drinking_water', label: '💧 Питьевая вода' },
    { value: 'atm', label: '💳 Банкомат' },
    { value: 'pharmacy', label: '💊 Аптека' },
    { value: 'bench', label: '🪑 Скамейка' },
    { value: 'viewpoint', label: '👁️ Смотровая' },
    { value: 'other', label: '📍 Другое' }
];

const getTypeLabel = (type: string) => {
    return HELPER_TYPES.find(t => t.value === type)?.label || type;
};

export default function HelpersPage() {
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState('');
    const [filterCity, setFilterCity] = useState<string>('');
    const [filterType, setFilterType] = useState<string>('');
    
    // Dialog state
    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [editingHelper, setEditingHelper] = useState<Helper | null>(null);
    const [form, setForm] = useState({
        city_slug: '',
        type: 'toilet',
        lat: 0,
        lon: 0,
        name_ru: '',
        address: ''
    });

    // Fetch cities for filter
    const { data: citiesData } = useQuery({
        queryKey: ['cities'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/cities`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch cities');
            return res.json();
        }
    });

    // Fetch helpers
    const { data: helpersData, isLoading } = useQuery({
        queryKey: ['helpers', filterCity, filterType, searchQuery],
        queryFn: async () => {
            const params = new URLSearchParams();
            if (filterCity) params.set('city_slug', filterCity);
            if (filterType) params.set('type', filterType);
            if (searchQuery) params.set('search', searchQuery);
            const res = await fetch(`${API_URL}/admin/helpers?${params}`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch helpers');
            return res.json();
        }
    });

    // Fetch stats
    const { data: statsData } = useQuery({
        queryKey: ['helpers-stats', filterCity],
        queryFn: async () => {
            const params = new URLSearchParams();
            if (filterCity) params.set('city_slug', filterCity);
            const res = await fetch(`${API_URL}/admin/helpers/stats?${params}`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch stats');
            return res.json();
        }
    });

    // Create/Update helper
    const mutation = useMutation({
        mutationFn: async (data: typeof form & { id?: string }) => {
            const url = data.id 
                ? `${API_URL}/admin/helpers/${data.id}`
                : `${API_URL}/admin/helpers`;
            const method = data.id ? 'PATCH' : 'POST';
            
            const res = await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify(data)
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || 'Failed to save');
            }
            return res.json();
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['helpers'] });
            queryClient.invalidateQueries({ queryKey: ['helpers-stats'] });
            setIsDialogOpen(false);
            resetForm();
        }
    });

    // Delete helper
    const deleteMutation = useMutation({
        mutationFn: async (id: string) => {
            const res = await fetch(`${API_URL}/admin/helpers/${id}`, {
                method: 'DELETE',
                credentials: 'include'
            });
            if (!res.ok) throw new Error('Failed to delete');
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['helpers'] });
            queryClient.invalidateQueries({ queryKey: ['helpers-stats'] });
        }
    });

    const resetForm = () => {
        setForm({
            city_slug: filterCity || '',
            type: 'toilet',
            lat: 0,
            lon: 0,
            name_ru: '',
            address: ''
        });
        setEditingHelper(null);
    };

    const openEditDialog = (helper: Helper) => {
        setEditingHelper(helper);
        setForm({
            city_slug: helper.city_slug,
            type: helper.type,
            lat: helper.lat,
            lon: helper.lon,
            name_ru: helper.name_ru || '',
            address: helper.address || ''
        });
        setIsDialogOpen(true);
    };

    const openCreateDialog = () => {
        resetForm();
        if (filterCity) {
            setForm(f => ({ ...f, city_slug: filterCity }));
        }
        setIsDialogOpen(true);
    };

    const helpers: Helper[] = helpersData?.items || [];
    const cities = citiesData?.items || [];
    const stats = statsData?.by_type || {};

    return (
        <div className="container mx-auto py-6 space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Вспомогательные точки</h1>
                    <p className="text-muted-foreground">Туалеты, кафе, питьевая вода и другие полезные места</p>
                </div>
                <Button onClick={openCreateDialog}>
                    <Plus className="w-4 h-4 mr-2" />
                    Добавить точку
                </Button>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-4 md:grid-cols-8 gap-2">
                {HELPER_TYPES.map(t => (
                    <Card 
                        key={t.value} 
                        className={`cursor-pointer transition-colors ${filterType === t.value ? 'ring-2 ring-primary' : ''}`}
                        onClick={() => setFilterType(filterType === t.value ? '' : t.value)}
                    >
                        <CardContent className="p-3 text-center">
                            <div className="text-2xl">{t.label.split(' ')[0]}</div>
                            <div className="text-sm font-medium">{stats[t.value] || 0}</div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            {/* Filters */}
            <div className="flex items-center gap-4">
                <Select value={filterCity} onValueChange={setFilterCity}>
                    <SelectTrigger className="w-[200px]">
                        <SelectValue placeholder="Все города" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="">Все города</SelectItem>
                        {cities.map((c: any) => (
                            <SelectItem key={c.slug} value={c.slug}>{c.name_ru}</SelectItem>
                        ))}
                    </SelectContent>
                </Select>
                
                <div className="relative flex-1 max-w-sm">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                    <Input
                        placeholder="Поиск по названию..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="pl-9"
                    />
                </div>
                
                <div className="text-sm text-muted-foreground">
                    Всего: {helpersData?.total || 0}
                </div>
            </div>

            {/* List */}
            {isLoading ? (
                <div className="flex items-center justify-center py-12">
                    <Loader2 className="w-6 h-6 animate-spin" />
                </div>
            ) : (
                <div className="grid gap-3">
                    {helpers.map((h) => (
                        <Card key={h.id}>
                            <CardContent className="flex items-center justify-between py-3">
                                <div className="flex items-center gap-4">
                                    <div className="text-2xl">{getTypeLabel(h.type).split(' ')[0]}</div>
                                    <div>
                                        <div className="flex items-center gap-2">
                                            <span className="font-medium">{h.name_ru || 'Без названия'}</span>
                                            <Badge variant="outline">{h.city_slug}</Badge>
                                        </div>
                                        <div className="text-sm text-muted-foreground flex items-center gap-2">
                                            <MapPin className="w-3 h-3" />
                                            <span>{h.lat.toFixed(5)}, {h.lon.toFixed(5)}</span>
                                            {h.address && <span className="ml-2">• {h.address}</span>}
                                        </div>
                                    </div>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Button 
                                        variant="outline" 
                                        size="sm"
                                        onClick={() => window.open(`https://www.openstreetmap.org/?mlat=${h.lat}&mlon=${h.lon}#map=18/${h.lat}/${h.lon}`, '_blank')}
                                    >
                                        <MapPin className="w-4 h-4" />
                                    </Button>
                                    <Button variant="ghost" size="icon" onClick={() => openEditDialog(h)}>
                                        <Pencil className="w-4 h-4" />
                                    </Button>
                                    <Button 
                                        variant="ghost" 
                                        size="icon" 
                                        className="text-red-500"
                                        onClick={() => {
                                            if (confirm('Удалить точку?')) {
                                                deleteMutation.mutate(h.id);
                                            }
                                        }}
                                    >
                                        <Trash2 className="w-4 h-4" />
                                    </Button>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                    {helpers.length === 0 && (
                        <div className="text-center py-12 text-muted-foreground">
                            Нет точек
                        </div>
                    )}
                </div>
            )}

            {/* Dialog */}
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{editingHelper ? 'Редактировать точку' : 'Новая точка'}</DialogTitle>
                        <DialogDescription>
                            Вспомогательная точка для туристов
                        </DialogDescription>
                    </DialogHeader>
                    <div className="grid gap-4 py-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label>Город</Label>
                                <Select
                                    value={form.city_slug}
                                    onValueChange={(v) => setForm({ ...form, city_slug: v })}
                                    disabled={!!editingHelper}
                                >
                                    <SelectTrigger>
                                        <SelectValue placeholder="Выберите город" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        {cities.map((c: any) => (
                                            <SelectItem key={c.slug} value={c.slug}>{c.name_ru}</SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>
                            <div className="grid gap-2">
                                <Label>Тип</Label>
                                <Select
                                    value={form.type}
                                    onValueChange={(v) => setForm({ ...form, type: v })}
                                >
                                    <SelectTrigger>
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        {HELPER_TYPES.map(t => (
                                            <SelectItem key={t.value} value={t.value}>{t.label}</SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>
                        </div>
                        <div className="grid gap-2">
                            <Label>Название</Label>
                            <Input
                                value={form.name_ru}
                                onChange={(e) => setForm({ ...form, name_ru: e.target.value })}
                                placeholder="Общественный туалет у вокзала"
                            />
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label>Широта (lat)</Label>
                                <Input
                                    type="number"
                                    step="0.00001"
                                    value={form.lat}
                                    onChange={(e) => setForm({ ...form, lat: parseFloat(e.target.value) || 0 })}
                                    placeholder="54.71234"
                                />
                            </div>
                            <div className="grid gap-2">
                                <Label>Долгота (lon)</Label>
                                <Input
                                    type="number"
                                    step="0.00001"
                                    value={form.lon}
                                    onChange={(e) => setForm({ ...form, lon: parseFloat(e.target.value) || 0 })}
                                    placeholder="20.51234"
                                />
                            </div>
                        </div>
                        <div className="grid gap-2">
                            <Label>Адрес</Label>
                            <Input
                                value={form.address}
                                onChange={(e) => setForm({ ...form, address: e.target.value })}
                                placeholder="ул. Ленина, 1"
                            />
                        </div>
                        <p className="text-xs text-muted-foreground">
                            Координаты можно скопировать из OpenStreetMap или Google Maps
                        </p>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
                            Отмена
                        </Button>
                        <Button 
                            onClick={() => mutation.mutate(editingHelper ? { ...form, id: editingHelper.id } : form)}
                            disabled={mutation.isPending || !form.city_slug || !form.lat || !form.lon}
                        >
                            {mutation.isPending && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                            {editingHelper ? 'Сохранить' : 'Создать'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
