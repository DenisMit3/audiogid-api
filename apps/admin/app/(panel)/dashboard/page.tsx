
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import {
    Plus,
    MapPin,
    Activity,
    Eye,
    ArrowUpRight,
    Users,
    CreditCard,
    TrendingUp,
    FileText
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow
} from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip, BarChart, Bar, XAxis, YAxis, CartesianGrid } from 'recharts';

const API_URL = process.env.NEXT_PUBLIC_API_URL;
if (!API_URL) throw new Error("NEXT_PUBLIC_API_URL is required");

const fetchOverview = async () => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/analytics/overview`, {
        headers: { 'Authorization': `Bearer ${token}` }
    });
    if (!res.ok) throw new Error("Failed to fetch analytics");
    return res.json();
};

const fetchActivity = async () => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/audit/logs?limit=5`, {
        headers: { 'Authorization': `Bearer ${token}` }
    });
    if (!res.ok) return [];
    return res.json();
};

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

export default function Dashboard() {
    const router = useRouter();

    const { data: analytics, isLoading: analyticsLoading } = useQuery({
        queryKey: ['dashboard-overview'],
        queryFn: fetchOverview
    });

    const { data: activity } = useQuery({
        queryKey: ['dashboard-activity'],
        queryFn: fetchActivity,
        refetchInterval: 10000 // Poll every 10s for "real-time" feel
    });

    // Mock Content Status Data (could be fetched)
    const contentStatus = [
        { name: 'Published', value: 45 },
        { name: 'Draft', value: 12 },
        { name: 'Pending', value: 3 },
        { name: 'Issues', value: 2 },
    ];

    if (analyticsLoading) return (
        <div className="flex items-center justify-center p-8 h-screen">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        </div>
    );

    return (
        <div className="flex flex-col gap-6 p-8">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
                    <p className="text-muted-foreground">
                        Platform overview and real-time activity.
                    </p>
                </div>
                <div className="flex gap-2">
                    <Button variant="outline" onClick={() => router.push('/content/tours/new')}>
                        <Plus className="mr-2 h-4 w-4" /> New Tour
                    </Button>
                    <Button onClick={() => router.push('/content/pois/new')}>
                        <Plus className="mr-2 h-4 w-4" /> New POI
                    </Button>
                </div>
            </div>

            {/* KPI Cards */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Daily Active Users</CardTitle>
                        <Users className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{analytics?.kpis.dau || 0}</div>
                        <p className="text-xs text-muted-foreground">Active last 24h</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Monthly Revenue</CardTitle>
                        <CreditCard className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">${analytics?.kpis.revenue_30d || 0}</div>
                        <p className="text-xs text-muted-foreground">Last 30 days</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Sessions (7d)</CardTitle>
                        <Activity className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{analytics?.kpis.sessions_last_7d || 0}</div>
                        <p className="text-xs text-muted-foreground">Total sessions</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Conversion Rate</CardTitle>
                        <TrendingUp className="h-4 w-4 text-green-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{(analytics?.kpis.conversion_rate * 100).toFixed(1)}%</div>
                        <p className="text-xs text-muted-foreground">Install to Purchase</p>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                {/* Traffic Trend Chart */}
                <Card className="col-span-4">
                    <CardHeader>
                        <CardTitle>Visitor Traffic (30 Days)</CardTitle>
                    </CardHeader>
                    <CardContent className="pl-2">
                        <div className="h-[300px] w-full">
                            <ResponsiveContainer width="100%" height="100%">
                                <BarChart data={analytics?.recent_trend || []}>
                                    <CartesianGrid strokeDasharray="3 3" />
                                    <XAxis
                                        dataKey="date"
                                        tickFormatter={(value) => new Date(value).toLocaleDateString(undefined, { day: 'numeric', month: 'short' })}
                                        style={{ fontSize: '12px' }}
                                    />
                                    <YAxis />
                                    <Tooltip />
                                    <Bar dataKey="dau" fill="#3b82f6" name="Active Users" radius={[4, 4, 0, 0]} />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>
                    </CardContent>
                </Card>

                {/* Content Status Pie Chart */}
                <Card className="col-span-3">
                    <CardHeader>
                        <CardTitle>Content Status</CardTitle>
                        <CardDescription>Breakdown by verify state</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="h-[300px] w-full flex justify-center">
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie
                                        data={contentStatus}
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={60}
                                        outerRadius={80}
                                        fill="#8884d8"
                                        paddingAngle={5}
                                        dataKey="value"
                                    >
                                        {contentStatus.map((entry, index) => (
                                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                        ))}
                                    </Pie>
                                    <Tooltip />
                                    <Legend />
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                {/* recent Activity */}
                <Card className="col-span-4">
                    <CardHeader>
                        <CardTitle>Recent Activity</CardTitle>
                        <CardDescription>Real-time audit log stream</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {activity?.map((log: any) => (
                                <div key={log.id} className="flex items-center gap-4 border-b pb-4 last:border-0 last:pb-0">
                                    <div className="flex h-9 w-9 items-center justify-center rounded-full border bg-muted">
                                        <Activity className="h-4 w-4" />
                                    </div>
                                    <div className="grid gap-1">
                                        <p className="text-sm font-medium leading-none">
                                            {log.action}
                                        </p>
                                        <p className="text-xs text-muted-foreground">
                                            {log.actor_fingerprint} • {new Date(log.timestamp).toLocaleString()}
                                        </p>
                                    </div>
                                    <div className="ml-auto font-mono text-xs text-muted-foreground truncate max-w-[100px]">
                                        {log.target_id}
                                    </div>
                                </div>
                            ))}
                            {!activity?.length && <div className="text-sm text-muted-foreground">No recent activity.</div>}
                        </div>
                    </CardContent>
                </Card>

                {/* Top Content */}
                <Card className="col-span-3">
                    <CardHeader>
                        <CardTitle>Top Content</CardTitle>
                        <CardDescription>Most viewed this week</CardDescription>
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
                                {analytics?.top_content?.slice(0, 5).map((item: any) => (
                                    <TableRow key={item.id}>
                                        <TableCell>
                                            <div className="font-medium truncate max-w-[150px]">{item.title}</div>
                                            <Badge variant="secondary" className="text-[10px] uppercase">{item.type}</Badge>
                                        </TableCell>
                                        <TableCell className="text-right font-bold">{item.views}</TableCell>
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


