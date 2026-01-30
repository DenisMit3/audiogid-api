
'use client';

import { useState, useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { MapContainer, TileLayer, CircleMarker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Fix Leaflet Icon
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

const API_URL = process.env.NEXT_PUBLIC_API_URL;

const fetchHeatmap = async (days: number) => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/analytics/heatmap?days=${days}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to fetch heatmap data");
    return res.json();
};

function HeatmapLayer({ points, max }: { points: number[][], max: number }) {
    const getColor = (value: number) => {
        const intense = value / (max || 1);
        // Returns color from Blue (low) to Red (high)
        // Hue: 240 (blue) -> 0 (red)
        const hue = (1 - intense) * 240;
        return `hsl(${hue}, 100%, 50%)`;
    };

    return (
        <>
            {points.map((p, idx) => (
                <CircleMarker
                    key={idx}
                    center={[p[0], p[1]]}
                    radius={20} // Fixed radius for now, could be dynamic
                    fillColor={getColor(p[2])}
                    color={getColor(p[2])}
                    fillOpacity={0.6}
                    stroke={false}
                >
                    <Popup>
                        Intensity: {p[2]} / {max}
                    </Popup>
                </CircleMarker>
            ))}
        </>
    );
}

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
                    <MapContainer
                        center={[54.71, 20.51]} // Kaliningrad
                        zoom={12}
                        style={{ height: '100%', width: '100%' }}
                    >
                        <TileLayer
                            url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
                        />
                        <HeatmapLayer points={points} max={max} />
                    </MapContainer>

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


