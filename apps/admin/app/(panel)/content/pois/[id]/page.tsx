
'use client';

import { useQuery } from '@tanstack/react-query';
import { RefreshCcw, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { Button } from "@/components/ui/button";
import PoiForm from '@/components/PoiForm';

const API_URL = process.env.NEXT_PUBLIC_API_URL;
if (!API_URL) throw new Error("NEXT_PUBLIC_API_URL is required");

const fetchPoi = async (id: string) => {
    const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';
    const res = await fetch(`${API_URL}/admin/pois/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to fetch POI");
    return res.json(); // Returns { poi: {..}, sources: [], media: [] } -> PoiForm expects { ...poi, sources, media }
};

export default function PoiEditPage({ params }: { params: { id: string } }) {
    const { data, isLoading, isError, refetch } = useQuery({
        queryKey: ['poi', params.id],
        queryFn: () => fetchPoi(params.id),
    });

    if (isLoading) return <div className="p-8 text-center">Loading POI details...</div>;
    if (isError) return (
        <div className="p-8 text-center text-red-500">
            Failed to load POI
            <Button variant="outline" onClick={() => refetch()} className="ml-4"><RefreshCcw className="w-4 h-4 mr-2" /> Retry</Button>
        </div>
    );

    // Merge structure for PoiForm
    // API returns { poi: Object, sources: Array, media: Array }
    // PoiForm expects { ...poiFields, sources: [], media: [] }
    const poiData = {
        ...data.poi,
        sources: data.sources,
        media: data.media
    };

    return (
        <div className="max-w-4xl mx-auto p-6 space-y-6">
            <div className="flex items-center gap-4">
                <Link href="/content/pois">
                    <Button variant="ghost" size="icon">
                        <ArrowLeft className="w-5 h-5" />
                    </Button>
                </Link>
                <h1 className="text-2xl font-bold tracking-tight">Edit Point of Interest</h1>
            </div>

            <PoiForm poi={poiData} />
        </div>
    );
}
