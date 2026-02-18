'use client';

import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import dynamic from 'next/dynamic';

const API_URL = '/api/proxy';

const HeatmapMap = dynamic(() => import('@/components/analytics/heatmap-map'), {
    ssr: false,
    loading: () => <div className="h-full w-full flex items-center justify-center bg-slate-100">Loading Map Engine...</div>
});

const fetchHeatmap = async (days: number) => {
    if (!API_URL) return { points: [], max: 1 };
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/analytics/heatmap?days=${days}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to fetch heatmap data");
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
                <h1 className="text-2xl font-bold tracking-tight">Activity Heatmap</h1>
                <Select value={days} onValueChange={setDays}>
                    <SelectTrigger className="w-[180px]">
                        <SelectValue placeholder="Period" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="7">Last 7 Days</SelectItem>
                        <SelectItem value="30">Last 30 Days</SelectItem>
                        <SelectItem value="90">Last 3 Months</SelectItem>
                        <SelectItem value="365">Last Year</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            <Card className="flex-1 flex flex-col overflow-hidden">
                <div className="flex-1 relative">
                    <HeatmapMap points={points} max={max} />

                    {/* Legend */}
                    <div className="absolute bottom-4 right-4 bg-white/90 p-4 rounded-lg shadow-lg z-[1000] text-xs">
                        <div className="font-semibold mb-2">Interaction Density</div>
                        <div className="flex items-center gap-2">
                            <div className="w-20 h-4 rounded bg-gradient-to-r from-blue-600 via-green-500 to-red-600"></div>
                        </div>
                        <div className="flex justify-between mt-1 text-slate-500">
                            <span>Low</span>
                            <span>High</span>
                        </div>
                    </div>
                </div>
            </Card>
        </div>
    );
}
