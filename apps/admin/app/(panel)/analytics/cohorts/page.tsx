
"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import useSWR from "swr"
import { format } from "date-fns"

const fetcher = (url: string) => fetch(url).then(r => r.json())

export default function CohortsPage() {
    const { data: retentionData, mutate } = useSWR('/api/proxy/admin/analytics/retention', fetcher);

    // retentionData: [{ cohort_date, day_n, percentage, retained_count }]

    // Transform to Heatmap structure
    // Rows: Date, Cols: Day 0, 1, 3, 7, 14, 30

    const pivotData = () => {
        if (!retentionData) return [];

        const map: Record<string, Record<string, number>> = {};

        retentionData.forEach((row: any) => {
            const date = row.cohort_date.split('T')[0];
            if (!map[date]) map[date] = {};
            map[date][row.day_n] = row.percentage;
        });

        // Convert to array sorted by date desc
        return Object.entries(map).sort((a, b) => b[0].localeCompare(a[0])).map(([date, days]) => ({
            date,
            days
        }));
    };

    const rows = pivotData();
    const cols = [0, 1, 3, 7, 14, 30];

    const triggerRecalc = async () => {
        await fetch('/api/proxy/admin/analytics/trigger-cohorts', { method: 'POST' });
        mutate();
    }

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Retention Cohorts</h1>
                <Button onClick={triggerRecalc}>Recalculate</Button>
            </div>

            <Card>
                <CardHeader><CardTitle>Retention Matrix (Last 60 Days)</CardTitle></CardHeader>
                <CardContent>
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm text-left">
                            <thead>
                                <tr className="border-b">
                                    <th className="p-2 font-medium">Cohort</th>
                                    {cols.map(day => <th key={day} className="p-2 font-medium">Day {day}</th>)}
                                </tr>
                            </thead>
                            <tbody>
                                {rows.map((row) => (
                                    <tr key={row.date} className="border-b hover:bg-muted/50">
                                        <td className="p-2 font-medium">{format(new Date(row.date), 'MMM d, yyyy')}</td>
                                        {cols.map(day => {
                                            const val = row.days[day];
                                            let bg = 'bg-transparent';
                                            if (val > 0) bg = 'bg-red-50 text-red-900';
                                            if (val > 10) bg = 'bg-red-100 text-red-900';
                                            if (val > 25) bg = 'bg-red-200 text-red-900';
                                            if (val > 50) bg = 'bg-red-300 text-red-900'; // Hot

                                            // Ideally use HSL 
                                            // const alpha = val / 100;
                                            // style={{ backgroundColor: `rgba(255, 0, 0, ${alpha})` }}

                                            return (
                                                <td key={day} className="p-2">
                                                    <div
                                                        className={`w-12 h-8 flex items-center justify-center rounded ${val === undefined ? 'text-gray-300' : ''}`}
                                                        style={val !== undefined ? { backgroundColor: `rgba(59, 130, 246, ${val / 100})`, color: val > 50 ? 'white' : 'black' } : {}}
                                                    >
                                                        {val !== undefined ? val.toFixed(1) + '%' : '-'}
                                                    </div>
                                                </td>
                                            )
                                        })}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                        {rows.length === 0 && <div className="p-4 text-center text-muted-foreground">No data available. Try recalculating.</div>}
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}


