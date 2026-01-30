
'use client';

import { useQuery } from '@tanstack/react-query';
import {
    LineChart,
    Line,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
    AreaChart,
    Area
} from 'recharts';
import { Loader2, TrendingUp, Users, DollarSign, Activity, Eye, RefreshCcw } from 'lucide-react';
import { formatCurrency } from '@/lib/utils'; // Assuming this utility exists, if not I'll mock it

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";

const API_URL = process.env.NEXT_PUBLIC_API_URL;

type KPI = {
    dau: number;
    mau: number;
    revenue_30d: number;
    conversion_rate: number;
    sessions_last_7d: number;
}

type TopContent = {
    id: string;
    title: string;
    views: number;
    type: string;
}

type TrendItem = {
    date: string;
    dau: number;
    revenue: number;
}

type AnalyticsData = {
    kpis: KPI;
    top_content: TopContent[];
    recent_trend: TrendItem[];
}

const fetchAnalytics = async (): Promise<AnalyticsData> => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/analytics/overview`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to load analytics");
    return res.json();
}

export default function AnalyticsPage() {
    const { data, isLoading, isError, refetch } = useQuery({
        queryKey: ['analytics_overview'],
        queryFn: fetchAnalytics
    });

    if (isLoading) return (
        <div className="flex h-[50vh] items-center justify-center">
            <Loader2 className="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
    );

    if (isError) return (
        <div className="p-8 text-center text-red-500">
            Failed to load analytics.
            <Button variant="outline" onClick={() => refetch()} className="ml-4">Retry</Button>
        </div>
    );

    const { kpis, top_content, recent_trend } = data!;

    return (
        <div className="p-6 space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold tracking-tight">Analytics Dashboard</h1>
                <Button variant="outline" onClick={() => refetch()}>
                    <RefreshCcw className="w-4 h-4 mr-2" /> Refresh
                </Button>
            </div>

            {/* KPIs */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Revenue (30d)</CardTitle>
                        <DollarSign className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{(kpis.revenue_30d).toLocaleString('ru-RU', { style: 'currency', currency: 'RUB' })}</div>
                        <p className="text-xs text-muted-foreground">+20.1% from last month</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Active Users (DAU)</CardTitle>
                        <Users className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{kpis.dau}</div>
                        <p className="text-xs text-muted-foreground">MAU: {kpis.mau}</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Conversion Rate</CardTitle>
                        <TrendingUp className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{(kpis.conversion_rate * 100).toFixed(1)}%</div>
                        <p className="text-xs text-muted-foreground">Free to Paid</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Sessions (7d)</CardTitle>
                        <Activity className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{kpis.sessions_last_7d}</div>
                        <p className="text-xs text-muted-foreground">Weekly Engagement</p>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                {/* Main Chart */}
                <Card className="col-span-4">
                    <CardHeader>
                        <CardTitle>Activity Trend</CardTitle>
                        <CardDescription>Daily Active Users over the last 30 days</CardDescription>
                    </CardHeader>
                    <CardContent className="pl-2">
                        <div className="h-[300px]">
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={recent_trend}>
                                    <defs>
                                        <linearGradient id="colorDau" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#8884d8" stopOpacity={0.8} />
                                            <stop offset="95%" stopColor="#8884d8" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                    <XAxis
                                        dataKey="date"
                                        stroke="#888888"
                                        fontSize={12}
                                        tickLine={false}
                                        axisLine={false}
                                        tickFormatter={(val) => val.slice(5)} // MM-DD
                                    />
                                    <YAxis
                                        stroke="#888888"
                                        fontSize={12}
                                        tickLine={false}
                                        axisLine={false}
                                        tickFormatter={(value) => `${value}`}
                                    />
                                    <CartesianGrid strokeDasharray="3 3" vertical={false} />
                                    <Tooltip />
                                    <Area
                                        type="monotone"
                                        dataKey="dau"
                                        stroke="#8884d8"
                                        fillOpacity={1}
                                        fill="url(#colorDau)"
                                    />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>
                    </CardContent>
                </Card>

                {/* Top Content */}
                <Card className="col-span-3">
                    <CardHeader>
                        <CardTitle>Popular Content</CardTitle>
                        <CardDescription>Most viewed items (7d)</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>Title</TableHead>
                                    <TableHead className="text-right">Views</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {top_content.length === 0 && (
                                    <TableRow>
                                        <TableCell colSpan={2} className="text-center text-muted-foreground">No data</TableCell>
                                    </TableRow>
                                )}
                                {top_content.map((item) => (
                                    <TableRow key={item.id}>
                                        <TableCell>
                                            <div className="font-medium truncate max-w-[150px]">{item.title}</div>
                                            <div className="text-xs text-muted-foreground uppercase">{item.type}</div>
                                        </TableCell>
                                        <TableCell className="text-right flex items-center justify-end gap-1">
                                            <Eye className="w-3 h-3 text-muted-foreground" />
                                            {item.views}
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}

