
'use client';

import { useQuery } from '@tanstack/react-query';
import { RefreshCcw, ArrowLeft, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { Button } from "@/components/ui/button";
import TourEditor from '@/components/tour-editor';

const fetchTour = async (id: string) => {
    const res = await fetch(`/api/proxy/admin/tours/${id}`);
    if (!res.ok) throw new Error("Не удалось загрузить тур");
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
            <p className="mt-4 text-sm text-muted-foreground">Загрузка данных тура...</p>
        </div>
    );

    if (isError || !tourData?.tour) return (
        <div className="p-8 text-center text-red-500">
            {isError ? 'Не удалось загрузить тур' : 'Данные тура не найдены'}
            <Button variant="outline" onClick={() => refetch()} className="ml-4"><RefreshCcw className="w-4 h-4 mr-2" /> Повторить</Button>
        </div>
    );

    // Flatten structure for Editor
    const editorData = {
        ...tourData.tour,
        items: tourData.items || [],
        sources: tourData.sources || [],
        media: tourData.media || [],
        can_publish: tourData.can_publish ?? false,
        publish_issues: tourData.publish_issues || [],
        unpublished_poi_ids: tourData.unpublished_poi_ids || []
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
                    <p className="text-sm text-muted-foreground">Редактор тура</p>
                </div>
            </div>

            <TourEditor tour={editorData} />
        </div>
    );
}
