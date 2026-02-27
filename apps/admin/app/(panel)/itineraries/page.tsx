'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Search, Loader2, MapPin, Calendar, User, Smartphone, Eye, Route } from 'lucide-react';

const API_URL = '/api/proxy';

type Itinerary = {
    id: string;
    user_id?: string;
    device_anon_id?: string;
    title: string;
    city_slug: string;
    city_name?: string;
    created_at: string;
    updated_at: string;
    items_count: number;
};

type ItineraryItem = {
    id: string;
    poi_id: string;
    poi_title?: string;
    poi_lat?: number;
    poi_lon?: number;
    order_index: number;
};

type ItineraryDetail = Itinerary & {
    items: ItineraryItem[];
};

type Stats = {
    total_itineraries: number;
    total_items: number;
    by_city: Record<string, number>;
    recent_count: number;
};

export default function ItinerariesPage() {
    const [searchQuery, setSearchQuery] = useState('');
    const [filterCity, setFilterCity] = useState<string>('');
    const [selectedItinerary, setSelectedItinerary] = useState<string | null>(null);

    // Fetch cities
    const { data: citiesData } = useQuery({
        queryKey: ['cities'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/cities`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch cities');
            return res.json();
        }
    });

    // Fetch stats
    const { data: statsData } = useQuery({
        queryKey: ['itineraries-stats'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/itineraries/stats`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch stats');
            return res.json();
        }
    });

    // Fetch itineraries
    const { data: itinerariesData, isLoading } = useQuery({
        queryKey: ['itineraries', filterCity, searchQuery],
        queryFn: async () => {
            const params = new URLSearchParams();
            if (filterCity) params.set('city_slug', filterCity);
            if (searchQuery) params.set('search', searchQuery);
            const res = await fetch(`${API_URL}/admin/itineraries?${params}`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch itineraries');
            return res.json();
        }
    });

    // Fetch itinerary detail
    const { data: detailData, isLoading: loadingDetail } = useQuery({
        queryKey: ['itinerary', selectedItinerary],
        queryFn: async () => {
            if (!selectedItinerary) return null;
            const res = await fetch(`${API_URL}/admin/itineraries/${selectedItinerary}`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch itinerary');
            return res.json();
        },
        enabled: !!selectedItinerary
    });

    const itineraries: Itinerary[] = itinerariesData?.items || [];
    const cities = citiesData?.items || [];
    const stats: Stats | null = statsData || null;
    const detail: ItineraryDetail | null = detailData || null;

    const formatDate = (dateStr: string) => {
        return new Date(dateStr).toLocaleString('ru-RU', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    return (
        <div className="container mx-auto py-6 space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Пользовательские маршруты</h1>
                    <p className="text-muted-foreground">Маршруты, созданные пользователями в мобильном приложении</p>
                </div>
            </div>

            {/* Stats */}
            {stats && (
                <div className="grid grid-cols-4 gap-4">
                    <Card>
                        <CardContent className="pt-6">
                            <div className="text-2xl font-bold">{stats.total_itineraries}</div>
                            <p className="text-xs text-muted-foreground">Всего маршрутов</p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="pt-6">
                            <div className="text-2xl font-bold">{stats.total_items}</div>
                            <p className="text-xs text-muted-foreground">Всего точек</p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="pt-6">
                            <div className="text-2xl font-bold">{stats.recent_count}</div>
                            <p className="text-xs text-muted-foreground">За последние 7 дней</p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="pt-6">
                            <div className="text-2xl font-bold">
                                {stats.total_itineraries > 0 
                                    ? (stats.total_items / stats.total_itineraries).toFixed(1) 
                                    : 0}
                            </div>
                            <p className="text-xs text-muted-foreground">Среднее точек на маршрут</p>
                        </CardContent>
                    </Card>
                </div>
            )}

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
                    Найдено: {itinerariesData?.total || 0}
                </div>
            </div>

            {/* List */}
            {isLoading ? (
                <div className="flex items-center justify-center py-12">
                    <Loader2 className="w-6 h-6 animate-spin" />
                </div>
            ) : (
                <div className="grid gap-3">
                    {itineraries.map((it) => (
                        <Card key={it.id} className="hover:border-blue-300 transition-colors">
                            <CardContent className="flex items-center justify-between py-4">
                                <div className="space-y-1">
                                    <div className="flex items-center gap-2">
                                        <Route className="w-4 h-4 text-blue-500" />
                                        <span className="font-medium">{it.title}</span>
                                        <Badge variant="outline">{it.city_name || it.city_slug}</Badge>
                                        <Badge variant="secondary">{it.items_count} точек</Badge>
                                    </div>
                                    <div className="flex items-center gap-4 text-sm text-muted-foreground">
                                        {it.device_anon_id && (
                                            <span className="flex items-center gap-1">
                                                <Smartphone className="w-3 h-3" />
                                                {it.device_anon_id.slice(0, 8)}...
                                            </span>
                                        )}
                                        {it.user_id && (
                                            <span className="flex items-center gap-1">
                                                <User className="w-3 h-3" />
                                                {it.user_id.slice(0, 8)}...
                                            </span>
                                        )}
                                        <span className="flex items-center gap-1">
                                            <Calendar className="w-3 h-3" />
                                            {formatDate(it.created_at)}
                                        </span>
                                    </div>
                                </div>
                                <Button 
                                    variant="outline" 
                                    size="sm"
                                    onClick={() => setSelectedItinerary(it.id)}
                                >
                                    <Eye className="w-4 h-4 mr-1" />
                                    Просмотр
                                </Button>
                            </CardContent>
                        </Card>
                    ))}
                    {itineraries.length === 0 && (
                        <div className="text-center py-12 text-muted-foreground">
                            Нет маршрутов
                        </div>
                    )}
                </div>
            )}

            {/* Detail Dialog */}
            <Dialog open={!!selectedItinerary} onOpenChange={(o) => !o && setSelectedItinerary(null)}>
                <DialogContent className="max-w-2xl">
                    <DialogHeader>
                        <DialogTitle className="flex items-center gap-2">
                            <Route className="w-5 h-5 text-blue-500" />
                            {detail?.title || 'Загрузка...'}
                        </DialogTitle>
                    </DialogHeader>
                    
                    {loadingDetail ? (
                        <div className="flex items-center justify-center py-8">
                            <Loader2 className="w-6 h-6 animate-spin" />
                        </div>
                    ) : detail ? (
                        <div className="space-y-4">
                            {/* Info */}
                            <div className="grid grid-cols-2 gap-4 text-sm">
                                <div>
                                    <span className="text-muted-foreground">Город:</span>
                                    <span className="ml-2 font-medium">{detail.city_name || detail.city_slug}</span>
                                </div>
                                <div>
                                    <span className="text-muted-foreground">Создан:</span>
                                    <span className="ml-2">{formatDate(detail.created_at)}</span>
                                </div>
                                {detail.device_anon_id && (
                                    <div>
                                        <span className="text-muted-foreground">Device:</span>
                                        <code className="ml-2 bg-slate-100 px-1 rounded text-xs">{detail.device_anon_id}</code>
                                    </div>
                                )}
                                {detail.user_id && (
                                    <div>
                                        <span className="text-muted-foreground">User:</span>
                                        <code className="ml-2 bg-slate-100 px-1 rounded text-xs">{detail.user_id}</code>
                                    </div>
                                )}
                            </div>

                            {/* Items */}
                            <div>
                                <h4 className="font-medium mb-2">Точки маршрута ({detail.items.length})</h4>
                                <div className="space-y-2 max-h-[300px] overflow-y-auto">
                                    {detail.items.map((item, idx) => (
                                        <div 
                                            key={item.id} 
                                            className="flex items-center gap-3 p-2 bg-slate-50 rounded-lg"
                                        >
                                            <span className="w-6 h-6 rounded-full bg-blue-500 text-white flex items-center justify-center text-xs font-bold">
                                                {idx + 1}
                                            </span>
                                            <div className="flex-1">
                                                <div className="font-medium text-sm">{item.poi_title || 'Неизвестная точка'}</div>
                                                {item.poi_lat && item.poi_lon && (
                                                    <div className="text-xs text-muted-foreground flex items-center gap-1">
                                                        <MapPin className="w-3 h-3" />
                                                        {item.poi_lat.toFixed(5)}, {item.poi_lon.toFixed(5)}
                                                    </div>
                                                )}
                                            </div>
                                            {item.poi_lat && item.poi_lon && (
                                                <Button
                                                    variant="ghost"
                                                    size="sm"
                                                    onClick={() => window.open(
                                                        `https://www.openstreetmap.org/?mlat=${item.poi_lat}&mlon=${item.poi_lon}#map=18/${item.poi_lat}/${item.poi_lon}`,
                                                        '_blank'
                                                    )}
                                                >
                                                    <MapPin className="w-4 h-4" />
                                                </Button>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    ) : null}
                </DialogContent>
            </Dialog>
        </div>
    );
}
