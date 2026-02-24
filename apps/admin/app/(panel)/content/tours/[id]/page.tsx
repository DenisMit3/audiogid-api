
'use client';

import { useQuery } from '@tanstack/react-query';
import { RefreshCcw, ArrowLeft, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { Button } from "@/components/ui/button";
import TourEditor from '@/components/tour-editor';

const fetchTour = async (id: string) => {
    // #region agent log
    fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'f46abe'},body:JSON.stringify({sessionId:'f46abe',location:'tour-edit-page.tsx:fetchTour-start',message:'Fetching tour',data:{id,url:`/api/proxy/admin/tours/${id}`},timestamp:Date.now(),hypothesisId:'H1'})}).catch(()=>{});
    // #endregion
    const res = await fetch(`/api/proxy/admin/tours/${id}`);
    // #region agent log
    const resClone = res.clone();
    const resText = await resClone.text();
    fetch('http://127.0.0.1:7766/ingest/d777dd49-2097-49f1-af7b-31e83b667f8c',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'f46abe'},body:JSON.stringify({sessionId:'f46abe',location:'tour-edit-page.tsx:fetchTour-response',message:'Tour fetch response',data:{id,status:res.status,ok:res.ok,body:resText.substring(0,500)},timestamp:Date.now(),hypothesisId:'H1'})}).catch(()=>{});
    // #endregion
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

    if (isError) return (
        <div className="p-8 text-center text-red-500">
            Не удалось загрузить тур
            <Button variant="outline" onClick={() => refetch()} className="ml-4"><RefreshCcw className="w-4 h-4 mr-2" /> Повторить</Button>
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
                    <p className="text-sm text-muted-foreground">Редактор тура</p>
                </div>
            </div>

            <TourEditor tour={editorData} />
        </div>
    );
}
