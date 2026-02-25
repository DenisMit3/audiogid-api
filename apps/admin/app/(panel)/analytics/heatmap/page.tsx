'use client';

import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import dynamic from 'next/dynamic';

const API_URL = '/api/proxy';

const HeatmapMap = dynamic(() => import('@/components/analytics/heatmap-map'), {
    ssr: false,
    loading: () => <div className="h-full w-full flex items-center justify-center bg-slate-100">Загрузка карты...</div>
});

const fetchHeatmap = async (days: number) => {
    if (!API_URL) return { points: [], max: 1 };
    const res = await fetch(`${API_URL}/admin/analytics/heatmap?days=${days}`, {
        credentials: 'include'
    });
    if (!res.ok) throw new Error("Не удалось загрузить данные тепловой карты");
    return res.json();
};

export default function HeatmapPage() {
    const [days, setDays] = useState('30');

    const { data } = useQuery({
        queryKey: ['heatmap', days],
        queryFn: () => fetchHeatmap(parseInt(days)),
    });

    const points = data?.points || [];
    const max = data?.max || 1;

    return (
        <div className="space-y-6 h-[calc(100vh-100px)] flex flex-col">
            <div className="flex justify-between items-center shrink-0">
                <h1 className="text-2xl font-bold tracking-tight">Тепловая карта активности</h1>
                <Select value={days} onValueChange={setDays}>
                    <SelectTrigger className="w-[180px]">
                        <SelectValue placeholder="Период" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="7">Последние 7 дней</SelectItem>
                        <SelectItem value="30">Последние 30 дней</SelectItem>
                        <SelectItem value="90">Последние 3 месяца</SelectItem>
                        <SelectItem value="365">Последний год</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            <Card className="flex-1 flex flex-col overflow-hidden">
                <div className="flex-1 relative">
                    <HeatmapMap points={points} max={max} />

                    {/* Legend */}
                    <div className="absolute bottom-4 right-4 bg-white/90 p-4 rounded-lg shadow-lg z-[1000] text-xs">
                        <div className="font-semibold mb-2">Плотность взаимодействий</div>
                        <div className="flex items-center gap-2">
                            <div className="w-20 h-4 rounded bg-gradient-to-r from-blue-600 via-green-500 to-red-600"></div>
                        </div>
                        <div className="flex justify-between mt-1 text-slate-500">
                            <span>Низкая</span>
                            <span>Высокая</span>
                        </div>
                    </div>
                </div>
            </Card>
        </div>
    );
}
