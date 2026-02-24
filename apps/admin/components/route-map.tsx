
'use client';

import { useEffect, useMemo, useState, useCallback } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Polyline, useMap, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { Trash2, Plus, Search } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

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

// Создание нумерованной иконки маркера
function createNumberedIcon(number: number, isActive: boolean = false) {
    const color = isActive ? '#3b82f6' : '#6366f1';
    return L.divIcon({
        className: 'custom-numbered-marker',
        html: `<div style="
            background-color: ${color};
            color: white;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 14px;
            border: 3px solid white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.3);
        ">${number}</div>`,
        iconSize: [28, 28],
        iconAnchor: [14, 14],
        popupAnchor: [0, -14]
    });
}

type RouteItem = {
    id: string;
    order_index: number;
    poi_id?: string;
    poi_title?: string;
    poi_lat?: number;
    poi_lon?: number;
};

type Props = {
    items: RouteItem[];
    onRemoveItem?: (id: string) => void;
    onMapClick?: (lat: number, lon: number) => void;
    onMarkerDrag?: (itemId: string, lat: number, lon: number) => void;
    selectedItemId?: string;
    isAddMode?: boolean;
};

// Component to handle auto-zoom
function MapBounds({ items }: { items: RouteItem[] }) {
    const map = useMap();

    useEffect(() => {
        if (items.length === 0) return;

        const bounds = L.latLngBounds([]);
        let valid = false;
        items.forEach(i => {
            if (i.poi_lat && i.poi_lon) {
                bounds.extend([i.poi_lat, i.poi_lon]);
                valid = true;
            }
        });

        if (valid) {
            map.fitBounds(bounds, { padding: [50, 50] });
        }
    }, [items, map]);

    return null;
}

// Component to handle map click events
function MapClickHandler({ onMapClick, isAddMode }: { onMapClick?: (lat: number, lon: number) => void, isAddMode?: boolean }) {
    useMapEvents({
        click: (e) => {
            if (isAddMode && onMapClick) {
                onMapClick(e.latlng.lat, e.latlng.lng);
            }
        }
    });
    return null;
}

// Draggable marker component
function DraggableMarker({ 
    item, 
    index, 
    onRemove, 
    onDrag,
    isSelected 
}: { 
    item: RouteItem; 
    index: number; 
    onRemove?: (id: string) => void;
    onDrag?: (itemId: string, lat: number, lon: number) => void;
    isSelected?: boolean;
}) {
    const [position, setPosition] = useState<[number, number]>([item.poi_lat!, item.poi_lon!]);

    useEffect(() => {
        if (item.poi_lat && item.poi_lon) {
            setPosition([item.poi_lat, item.poi_lon]);
        }
    }, [item.poi_lat, item.poi_lon]);

    const eventHandlers = useMemo(() => ({
        dragend: (e: L.DragEndEvent) => {
            const marker = e.target;
            const pos = marker.getLatLng();
            setPosition([pos.lat, pos.lng]);
            if (onDrag) {
                onDrag(item.id, pos.lat, pos.lng);
            }
        }
    }), [item.id, onDrag]);

    if (!item.poi_lat || !item.poi_lon) return null;

    return (
        <Marker 
            position={position} 
            icon={createNumberedIcon(index + 1, isSelected)}
            draggable={!!onDrag}
            eventHandlers={eventHandlers}
        >
            <Popup>
                <div className="min-w-[150px]">
                    <div className="font-bold text-sm mb-2">{index + 1}. {item.poi_title || 'Точка маршрута'}</div>
                    <div className="text-xs text-gray-500 mb-2">
                        {position[0].toFixed(5)}, {position[1].toFixed(5)}
                    </div>
                    {onRemove && (
                        <Button 
                            variant="destructive" 
                            size="sm" 
                            className="w-full"
                            onClick={() => onRemove(item.id)}
                        >
                            <Trash2 className="w-3 h-3 mr-1" /> Удалить
                        </Button>
                    )}
                </div>
            </Popup>
        </Marker>
    );
}

// Address search component
function AddressSearch({ onSelect }: { onSelect: (lat: number, lon: number, name: string) => void }) {
    const [query, setQuery] = useState('');
    const [results, setResults] = useState<any[]>([]);
    const [isSearching, setIsSearching] = useState(false);
    const map = useMap();

    const handleSearch = useCallback(async () => {
        if (!query.trim()) return;
        
        setIsSearching(true);
        try {
            const res = await fetch(
                `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=5&accept-language=ru`
            );
            const data = await res.json();
            setResults(data);
        } catch (err) {
            console.error('Search error:', err);
        } finally {
            setIsSearching(false);
        }
    }, [query]);

    const handleSelect = (result: any) => {
        const lat = parseFloat(result.lat);
        const lon = parseFloat(result.lon);
        map.flyTo([lat, lon], 16);
        onSelect(lat, lon, result.display_name);
        setResults([]);
        setQuery('');
    };

    return (
        <div className="absolute top-2 left-2 z-[1000] w-72">
            <div className="flex gap-1">
                <Input
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="Поиск адреса..."
                    className="bg-white shadow-md text-sm"
                    onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                />
                <Button 
                    size="icon" 
                    variant="secondary" 
                    onClick={handleSearch}
                    disabled={isSearching}
                    className="shadow-md"
                >
                    <Search className="w-4 h-4" />
                </Button>
            </div>
            {results.length > 0 && (
                <div className="mt-1 bg-white rounded-md shadow-lg border max-h-48 overflow-y-auto">
                    {results.map((r, i) => (
                        <div 
                            key={i}
                            className="p-2 text-xs hover:bg-slate-100 cursor-pointer border-b last:border-b-0"
                            onClick={() => handleSelect(r)}
                        >
                            {r.display_name}
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}

export function RouteMap({ 
    items, 
    onRemoveItem, 
    onMapClick, 
    onMarkerDrag,
    selectedItemId,
    isAddMode = false
}: Props) {
    const [mounted, setMounted] = useState(false);
    
    useEffect(() => {
        setMounted(true);
    }, []);

    const polylinePositions = useMemo(() => {
        return items
            .filter(i => i.poi_lat && i.poi_lon)
            .sort((a, b) => a.order_index - b.order_index)
            .map(i => [i.poi_lat!, i.poi_lon!] as [number, number]);
    }, [items]);

    // Центр карты - Калининград по умолчанию
    const center: [number, number] = polylinePositions.length > 0 ? polylinePositions[0] : [54.71, 20.51];

    if (!mounted) {
        return <div className="h-full w-full rounded-md bg-slate-100 flex items-center justify-center border">Загрузка карты...</div>;
    }

    return (
        <div className={`h-full w-full rounded-md overflow-hidden border relative ${isAddMode ? 'ring-2 ring-blue-500' : ''}`}>
            {isAddMode && (
                <div className="absolute top-2 right-2 z-[1000] bg-blue-500 text-white px-3 py-1 rounded-full text-xs font-medium flex items-center gap-1 shadow-lg">
                    <Plus className="w-3 h-3" /> Кликните на карту для добавления точки
                </div>
            )}
            <MapContainer
                center={center}
                zoom={12}
                style={{ height: '100%', width: '100%' }}
            >
                <TileLayer
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                />

                <AddressSearch onSelect={(lat, lon, name) => {
                    if (onMapClick) {
                        onMapClick(lat, lon);
                    }
                }} />

                {items
                    .filter(item => item.poi_lat && item.poi_lon)
                    .sort((a, b) => a.order_index - b.order_index)
                    .map((item, idx) => (
                        <DraggableMarker
                            key={item.id}
                            item={item}
                            index={idx}
                            onRemove={onRemoveItem}
                            onDrag={onMarkerDrag}
                            isSelected={item.id === selectedItemId}
                        />
                    ))
                }

                {polylinePositions.length > 1 && (
                    <Polyline 
                        positions={polylinePositions} 
                        color="#6366f1" 
                        weight={4}
                        opacity={0.8}
                        dashArray="10, 10"
                    />
                )}
                
                <MapBounds items={items} />
                <MapClickHandler onMapClick={onMapClick} isAddMode={isAddMode} />
            </MapContainer>
        </div>
    );
}
