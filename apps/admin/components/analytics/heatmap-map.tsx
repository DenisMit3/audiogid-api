'use client';

import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Fix Leaflet Icon
if (typeof window !== 'undefined') {
    // @ts-ignore
    delete L.Icon.Default.prototype._getIconUrl;
    L.Icon.Default.mergeOptions({
        iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
        iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
    });
}

function HeatmapLayer({ points, max }: { points: number[][], max: number }) {
    const getColor = (value: number) => {
        const intense = value / (max || 1);
        const hue = (1 - intense) * 240;
        return `hsl(${hue}, 100%, 50%)`;
    };

    return (
        <>
            {points.map((p, idx) => (
                <CircleMarker
                    key={idx}
                    center={[p[0], p[1]]}
                    radius={20}
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

export default function HeatmapMap({ points, max }: { points: number[][], max: number }) {
    return (
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
    );
}
