
"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
import { AlertCircle, CheckCircle } from "lucide-react"

interface PublishCheckModalProps {
    entityId: string
    entityType: 'poi' | 'tour'
}

export function PublishCheckModal({ entityId, entityType }: PublishCheckModalProps) {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState<{ can_publish: boolean, issues: string[] } | null>(null);

    const check = async () => {
        setLoading(true);
        try {
            // endpoint: /admin/{pois|tours}/{id}/publish_check
            // Proxy path: /api/proxy/admin/{pois|tours}/{id}/publish_check
            const endpoint = entityType === 'poi' ? 'pois' : 'tours';
            const res = await fetch(`/api/proxy/admin/${endpoint}/${entityId}/publish_check`);
            if (res.ok) {
                const data = await res.json();
                setResult(data);
            } else {
                setResult({ can_publish: false, issues: ["Failed to fetch check status"] });
            }
        } catch (e) {
            setResult({ can_publish: false, issues: ["Network error"] });
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={(v) => {
            setOpen(v);
            if (v) check();
        }}>
            <DialogTrigger asChild>
                <Button variant="secondary" type="button">Check Publish</Button>
            </DialogTrigger>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>Publish Check</DialogTitle>
                    <DialogDescription>Validating content requirements...</DialogDescription>
                </DialogHeader>

                <div className="py-4">
                    {loading && <div className="text-center">Checking...</div>}
                    {!loading && result && (
                        <div className="space-y-4">
                            {result.can_publish ? (
                                <div className="flex items-center gap-2 text-green-600 bg-green-50 p-4 rounded-md">
                                    <CheckCircle className="h-5 w-5" />
                                    <span className="font-semibold">Ready to Publish</span>
                                </div>
                            ) : (
                                <div className="space-y-2">
                                    <div className="flex items-center gap-2 text-red-600 font-semibold">
                                        <AlertCircle className="h-5 w-5" />
                                        <span>Issues Found ({result.issues.length})</span>
                                    </div>
                                    <ul className="list-disc pl-5 space-y-1 text-sm text-gray-700">
                                        {result.issues.map((issue, idx) => (
                                            <li key={idx}>{issue}</li>
                                        ))}
                                    </ul>
                                </div>
                            )}
                        </div>
                    )}
                </div>
            </DialogContent>
        </Dialog>
    )
}
