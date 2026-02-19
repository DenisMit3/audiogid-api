
'use client';

import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { Button } from "@/components/ui/button";
import PoiForm from '@/components/PoiForm';

export default function PoiCreatePage() {
    return (
        <div className="max-w-4xl mx-auto p-6 space-y-6">
            <div className="flex items-center gap-4">
                <Link href="/content/pois">
                    <Button variant="ghost" size="icon">
                        <ArrowLeft className="w-5 h-5" />
                    </Button>
                </Link>
                <h1 className="text-2xl font-bold tracking-tight">Создать новую точку</h1>
            </div>

            <PoiForm />
        </div>
    );
}




