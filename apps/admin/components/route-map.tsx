
'use client';

import { useEffect, useMemo, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Polyline, useMap } from 'react-leaflet';
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

type RouteItem = {
    id: string;
    order_index: number;
    poi_title?: string;
    poi_lat?: number;
    poi_lon?: number;
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

export function RouteMap({ items }: { items: RouteItem[] }) {
    // #region agent log
    fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'f46abe'},body:JSON.stringify({sessionId:'f46abe',location:'route-map.tsx:render',message:'RouteMap render start',data:{itemsCount:items?.length,isArray:Array.isArray(items)},timestamp:Date.now(),hypothesisId:'H2'})}).catch(()=>{});
    // #endregion
    const [mounted, setMounted] = useState(false);
    useEffect(() => setMounted(true), []);

    const polylinePositions = useMemo(() => {
        return items
            .filter(i => i.poi_lat && i.poi_lon)
            .map(i => [i.poi_lat!, i.poi_lon!] as [number, number]);
    }, [items]);

    const center: [number, number] = polylinePositions.length > 0 ? polylinePositions[0] : [54.71, 20.51];

    if (!mounted) {
        return <div className="h-[400px] w-full rounded-md bg-slate-100 flex items-center justify-center border">Загрузка карты...</div>;
    }

    return (
        <div className="h-[400px] w-full rounded-md overflow-hidden border">
            <MapContainer
                center={center}
                zoom={12}
                style={{ height: '100%', width: '100%' }}
            >
                <TileLayer
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                />

                {items.map((item, idx) => (
                    item.poi_lat && item.poi_lon && (
                        <Marker key={item.id} position={[item.poi_lat, item.poi_lon]}>
                            <Popup>
                                <b>{idx + 1}. {item.poi_title}</b>
                            </Popup>
                        </Marker>
                    )
                ))}

                <Polyline positions={polylinePositions} color="blue" />
                <MapBounds items={items} />
            </MapContainer>
        </div>
    );
}




