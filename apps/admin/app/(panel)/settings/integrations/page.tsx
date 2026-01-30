
'use client';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CheckCircle, XCircle, RefreshCw } from "lucide-react";

export default function IntegrationsPage() {
    return (
        <div className="space-y-6 max-w-4xl">
            <div>
                <h2 className="text-2xl font-bold tracking-tight">Integrations</h2>
                <p className="text-muted-foreground">Manage external services and connections.</p>
            </div>

            <div className="grid gap-4">
                <IntegrationCard
                    name="QStash"
                    description="Background job queue and scheduling."
                    status="connected"
                />
                <IntegrationCard
                    name="OpenAI"
                    description="AI generation for TTS and content."
                    status="connected"
                />
                <IntegrationCard
                    name="AWS S3 / Vercel Blob"
                    description="Media storage and CDN."
                    status="connected"
                />
                <IntegrationCard
                    name="Apple App Store"
                    description="In-App Purchases verification."
                    status="connected"
                />
                <IntegrationCard
                    name="Google Play Console"
                    description="In-App Purchases verification."
                    status="connected"
                />
            </div>
        </div>
    );
}

function IntegrationCard({ name, description, status }: { name: string, description: string, status: 'connected' | 'disconnected' }) {
    return (
        <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <div className="space-y-1">
                    <CardTitle className="text-base font-medium">{name}</CardTitle>
                    <CardDescription>{description}</CardDescription>
                </div>
                <Badge variant={status === 'connected' ? 'default' : 'destructive'} className={status === 'connected' ? "bg-green-600" : ""}>
                    {status === 'connected' ? <CheckCircle className="w-3 h-3 mr-1" /> : <XCircle className="w-3 h-3 mr-1" />}
                    {status === 'connected' ? 'Active' : 'Disconnected'}
                </Badge>
            </CardHeader>
            <CardContent>
                <div className="flex justify-end">
                    <Button variant="ghost" size="sm">Configure</Button>
                </div>
            </CardContent>
        </Card>
    )
}
