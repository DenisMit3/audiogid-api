
'use client';

import { useQuery } from '@tanstack/react-query';
import { RefreshCcw, ArrowLeft, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { Button } from "@/components/ui/button";
import TourEditor from '@/components/tour-editor';

const API_URL = process.env.NEXT_PUBLIC_API_URL || "https://audiogid-api.vercel.app/v1";

const fetchTour = async (id: string) => {
    const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : '';
    const res = await fetch(`${API_URL}/admin/tours/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to fetch Tour");
    return res.json();
};

export default function TourEditPage({ params }: { params: { id: string } }) {
    const { data: tourData, isLoading, isError, refetch } = useQuery({
        queryKey: ['tour', params.id],
        queryFn: () => fetchTour(params.id),
    });

    if (isLoading) return (
        <div className="flex h-[50vh] flex-col items-center justify-center">
            <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            <p className="mt-4 text-sm text-muted-foreground">Loading tour details...</p>
        </div>
    );

    if (isError) return (
        <div className="p-8 text-center text-red-500">
            Failed to load Tour
            <Button variant="outline" onClick={() => refetch()} className="ml-4"><RefreshCcw className="w-4 h-4 mr-2" /> Retry</Button>
        </div>
    );

    // Flatten structure for Editor
    const editorData = {
        ...tourData.tour,
        items: tourData.items,
        sources: tourData.sources,
        media: tourData.media,
        can_publish: tourData.can_publish,
        publish_issues: tourData.publish_issues
    };

    return (
        <div className="max-w-5xl mx-auto p-6 space-y-6">
            <div className="flex items-center gap-4">
                <Link href="/content/tours">
                    <Button variant="ghost" size="icon">
                        <ArrowLeft className="w-5 h-5" />
                    </Button>
                </Link>
                <div>
                    <h1 className="text-2xl font-bold tracking-tight">{editorData.title_ru}</h1>
                    <p className="text-sm text-muted-foreground">Tour Editor</p>
                </div>
            </div>

            <TourEditor tour={editorData} />
        </div>
    );
}
