
"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import useSWR from "swr"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LabelList } from 'recharts'
import { Plus } from "lucide-react"

const fetcher = (url: string) => fetch(url).then(r => r.json())

export default function FunnelsPage() {
    const { data: funnels } = useSWR('/api/proxy/admin/analytics/funnels', fetcher);

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Funnels</h1>
                {/* Create logic could be a modal, for now just list */}
                <Button>
                    <Plus className="mr-2 h-4 w-4" /> New Funnel
                </Button>
            </div>

            <div className="grid gap-6">
                {funnels && funnels.map((funnel: any) => (
                    <FunnelSection key={funnel.id} funnel={funnel} />
                ))}
                {funnels && funnels.length === 0 && (
                    <div className="text-center text-muted-foreground">No funnels found. Create one to metrics.</div>
                )}
                {!funnels && <div>Loading funnels...</div>}
            </div>

            <div className="bg-muted/50 p-4 rounded-lg">
                <h3 className="font-semibold mb-2">Debug Tools</h3>
                <DebugTrigger />
            </div>
        </div>
    )
}

function FunnelSection({ funnel }: { funnel: any }) {
    const { data: conversions, mutate } = useSWR(`/api/proxy/admin/analytics/funnels/${funnel.id}/conversions`, fetcher);

    // conversions: [{ step, order, count, conversion_rate }]

    return (
        <Card>
            <CardHeader>
                <CardTitle>{funnel.name}</CardTitle>
            </CardHeader>
            <CardContent>
                <div className="h-[300px] w-full">
                    {conversions ? (
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={conversions} layout="vertical" margin={{ left: 50, right: 50 }}>
                                <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                                <XAxis type="number" hide />
                                <YAxis dataKey="step" type="category" width={150} tick={{ fontSize: 12 }} />
                                <Tooltip cursor={{ fill: 'transparent' }} />
                                <Bar dataKey="count" fill="#3b82f6" radius={[0, 4, 4, 0]} barSize={32}>
                                    <LabelList dataKey="count" position="right" />
                                    <LabelList dataKey="conversion_rate" position="insideLeft" formatter={(val: number) => val > 0 ? `${val.toFixed(1)}%` : ''} fill="white" style={{ fontSize: 10 }} />
                                </Bar>
                            </BarChart>
                        </ResponsiveContainer>
                    ) : (
                        <div>Loading stats...</div>
                    )}
                </div>
            </CardContent>
        </Card>
    )
}

function DebugTrigger() {
    const trigger = async () => {
        await fetch('/api/proxy/admin/analytics/trigger-funnels', { method: 'POST' });
        alert('Triggered!');
        // Ideally invalidate SWR
    }

    const createDefault = async () => {
        // Create an "Onboarding" funnel
        await fetch('/api/proxy/admin/analytics/funnels', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                name: "Onboarding Flow",
                steps: [
                    { order_index: 0, event_type: "app_open", step_name: "App Open" },
                    { order_index: 1, event_type: "tour_started", step_name: "Started Tour" },
                    { order_index: 2, event_type: "purchase_completed", step_name: "Purchased" }
                ]
            })
        });
        window.location.reload();
    }

    return (
        <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={trigger}>Run Calc Job</Button>
            <Button variant="outline" size="sm" onClick={createDefault}>Create Default Funnel</Button>
        </div>
    )
}

