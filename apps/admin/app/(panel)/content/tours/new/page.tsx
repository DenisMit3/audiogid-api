
'use client';

import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { Button } from "@/components/ui/button";
import TourEditor from '@/components/tour-editor';

export default function TourCreatePage() {
    return (
        <div className="max-w-5xl mx-auto p-6 space-y-6">
            <div className="flex items-center gap-4">
                <Link href="/content/tours">
                    <Button variant="ghost" size="icon">
                        <ArrowLeft className="w-5 h-5" />
                    </Button>
                </Link>
                <h1 className="text-2xl font-bold tracking-tight">Create New Tour</h1>
            </div>

            <p className="text-muted-foreground mb-4">You'll be able to add route points and media after saving the basic details.</p>

            <TourEditor />
        </div>
    );
}

