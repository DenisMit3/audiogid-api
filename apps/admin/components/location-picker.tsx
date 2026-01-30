
'use client';

import { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Search } from 'lucide-react';

// Fix Leaflet Icon
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

function LocationMarker({ position, onChange }: { position: L.LatLngExpression | null, onChange: (lat: number, lon: number) => void }) {
    const map = useMapEvents({
        click(e) {
            onChange(e.latlng.lat, e.latlng.lng);
        },
    });

    useEffect(() => {
        if (position) {
            map.flyTo(position as L.LatLngTuple, map.getZoom());
        }
    }, [position, map]);

    return position === null ? null : (
        <Marker position={position}></Marker>
    );
}

export function LocationPicker({ lat, lon, onChange }: { lat?: number, lon?: number, onChange: (lat: number, lon: number) => void }) {
    const [search, setSearch] = useState('');
    const [position, setPosition] = useState<[number, number] | null>(lat && lon ? [lat, lon] : null);

    const handleSearch = async () => {
        if (!search) return;
        try {
            const res = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(search)}`);
            const data = await res.json();
            if (data && data.length > 0) {
                const { lat, lon } = data[0];
                const newLat = parseFloat(lat);
                const newLon = parseFloat(lon);
                setPosition([newLat, newLon]);
                onChange(newLat, newLon);
            }
        } catch (e) {
            console.error(e);
        }
    };

    return (
        <div className="space-y-4">
            <div className="flex gap-2">
                <Input
                    placeholder="Search address (e.g. Red Square)"
                    value={search}
                    onChange={e => setSearch(e.target.value)}
                    onKeyDown={e => e.key === 'Enter' && handleSearch()}
                />
                <Button type="button" variant="secondary" onClick={handleSearch}>
                    <Search className="w-4 h-4 mr-2" /> Find
                </Button>
            </div>

            <div className="h-[400px] w-full rounded-md overflow-hidden border">
                <MapContainer
                    center={position || [54.71, 20.51]} // Kaliningrad default
                    zoom={13}
                    style={{ height: '100%', width: '100%' }}
                >
                    <TileLayer
                        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    />
                    <LocationMarker position={position} onChange={(lat, lng) => {
                        setPosition([lat, lng]);
                        onChange(lat, lng);
                    }} />
                </MapContainer>
            </div>
            <div className="grid grid-cols-2 gap-4 text-xs text-muted-foreground">
                <div>Lat: {position?.[0].toFixed(6) || '-'}</div>
                <div>Lon: {position?.[1].toFixed(6) || '-'}</div>
            </div>
        </div>
    );
}


