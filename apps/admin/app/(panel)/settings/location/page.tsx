'use client';

import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Loader2, Save, MapPin, Navigation, Clock, Compass } from 'lucide-react';

const API_URL = '/api/proxy';

type LocationSettings = {
    geofence_radius_m: number;
    free_walking_radius_m: number;
    poi_cooldown_minutes: number;
    off_route_threshold_m: number;
    auto_play_enabled: boolean;
    background_location_enabled: boolean;
    high_accuracy_mode: boolean;
};

const defaultSettings: LocationSettings = {
    geofence_radius_m: 30,
    free_walking_radius_m: 50,
    poi_cooldown_minutes: 15,
    off_route_threshold_m: 100,
    auto_play_enabled: true,
    background_location_enabled: true,
    high_accuracy_mode: false
};

export default function LocationSettingsPage() {
    const queryClient = useQueryClient();
    const [form, setForm] = useState<LocationSettings>(defaultSettings);
    const [hasChanges, setHasChanges] = useState(false);

    // Fetch settings
    const { data, isLoading } = useQuery({
        queryKey: ['settings-location'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/settings/location`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch settings');
            return res.json();
        }
    });

    // Update form when data loads
    useEffect(() => {
        if (data) {
            setForm(data);
            setHasChanges(false);
        }
    }, [data]);

    // Save mutation
    const saveMutation = useMutation({
        mutationFn: async (settings: LocationSettings) => {
            const res = await fetch(`${API_URL}/admin/settings/location`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify(settings)
            });
            if (!res.ok) throw new Error('Failed to save settings');
            return res.json();
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-location'] });
            setHasChanges(false);
        }
    });

    const updateField = <K extends keyof LocationSettings>(key: K, value: LocationSettings[K]) => {
        setForm(prev => ({ ...prev, [key]: value }));
        setHasChanges(true);
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-center py-12">
                <Loader2 className="w-6 h-6 animate-spin" />
            </div>
        );
    }

    return (
        <div className="container mx-auto py-6 space-y-6 max-w-2xl">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Настройки геолокации</h1>
                    <p className="text-muted-foreground">Параметры работы с местоположением в мобильном приложении</p>
                </div>
                <Button 
                    onClick={() => saveMutation.mutate(form)}
                    disabled={!hasChanges || saveMutation.isPending}
                >
                    {saveMutation.isPending ? (
                        <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                    ) : (
                        <Save className="w-4 h-4 mr-2" />
                    )}
                    Сохранить
                </Button>
            </div>

            {/* Geofencing */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <MapPin className="w-5 h-5 text-blue-500" />
                        Геозоны (Geofencing)
                    </CardTitle>
                    <CardDescription>
                        Радиусы срабатывания при приближении к точкам
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label>Радиус геозоны POI</Label>
                            <div className="flex items-center gap-2">
                                <Input
                                    type="number"
                                    value={form.geofence_radius_m}
                                    onChange={(e) => updateField('geofence_radius_m', parseInt(e.target.value) || 0)}
                                    className="w-24"
                                />
                                <span className="text-sm text-muted-foreground">метров</span>
                            </div>
                            <p className="text-xs text-muted-foreground">
                                При входе в эту зону запускается аудио
                            </p>
                        </div>
                        <div className="space-y-2">
                            <Label>Радиус свободной прогулки</Label>
                            <div className="flex items-center gap-2">
                                <Input
                                    type="number"
                                    value={form.free_walking_radius_m}
                                    onChange={(e) => updateField('free_walking_radius_m', parseInt(e.target.value) || 0)}
                                    className="w-24"
                                />
                                <span className="text-sm text-muted-foreground">метров</span>
                            </div>
                            <p className="text-xs text-muted-foreground">
                                Радиус поиска POI в режиме Free Walking
                            </p>
                        </div>
                    </div>
                </CardContent>
            </Card>

            {/* Navigation */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <Navigation className="w-5 h-5 text-green-500" />
                        Навигация
                    </CardTitle>
                    <CardDescription>
                        Параметры отслеживания маршрута
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="space-y-2">
                        <Label>Порог отклонения от маршрута</Label>
                        <div className="flex items-center gap-2">
                            <Input
                                type="number"
                                value={form.off_route_threshold_m}
                                onChange={(e) => updateField('off_route_threshold_m', parseInt(e.target.value) || 0)}
                                className="w-24"
                            />
                            <span className="text-sm text-muted-foreground">метров</span>
                        </div>
                        <p className="text-xs text-muted-foreground">
                            При отклонении больше этого значения показывается предупреждение
                        </p>
                    </div>
                </CardContent>
            </Card>

            {/* Timing */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <Clock className="w-5 h-5 text-orange-500" />
                        Тайминги
                    </CardTitle>
                    <CardDescription>
                        Временные интервалы
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="space-y-2">
                        <Label>Cooldown между POI</Label>
                        <div className="flex items-center gap-2">
                            <Input
                                type="number"
                                value={form.poi_cooldown_minutes}
                                onChange={(e) => updateField('poi_cooldown_minutes', parseInt(e.target.value) || 0)}
                                className="w-24"
                            />
                            <span className="text-sm text-muted-foreground">минут</span>
                        </div>
                        <p className="text-xs text-muted-foreground">
                            Минимальный интервал между автоматическим воспроизведением одной и той же точки
                        </p>
                    </div>
                </CardContent>
            </Card>

            {/* Behavior */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <Compass className="w-5 h-5 text-purple-500" />
                        Поведение
                    </CardTitle>
                    <CardDescription>
                        Настройки работы геолокации
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="flex items-center justify-between">
                        <div className="space-y-0.5">
                            <Label>Автовоспроизведение</Label>
                            <p className="text-xs text-muted-foreground">
                                Автоматически запускать аудио при входе в геозону
                            </p>
                        </div>
                        <Switch
                            checked={form.auto_play_enabled}
                            onCheckedChange={(v) => updateField('auto_play_enabled', v)}
                        />
                    </div>
                    
                    <div className="flex items-center justify-between">
                        <div className="space-y-0.5">
                            <Label>Фоновая геолокация</Label>
                            <p className="text-xs text-muted-foreground">
                                Отслеживать местоположение когда приложение свёрнуто
                            </p>
                        </div>
                        <Switch
                            checked={form.background_location_enabled}
                            onCheckedChange={(v) => updateField('background_location_enabled', v)}
                        />
                    </div>
                    
                    <div className="flex items-center justify-between">
                        <div className="space-y-0.5">
                            <Label>Высокая точность GPS</Label>
                            <p className="text-xs text-muted-foreground">
                                Использовать GPS вместо сети (больше расход батареи)
                            </p>
                        </div>
                        <Switch
                            checked={form.high_accuracy_mode}
                            onCheckedChange={(v) => updateField('high_accuracy_mode', v)}
                        />
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
