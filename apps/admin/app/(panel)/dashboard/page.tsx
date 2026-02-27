
'use client';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import {
    Plus,
    Activity,
    Users,
    CreditCard,
    TrendingUp,
    ArrowUpRight,
    ArrowDownRight,
    Eye,
    Route,
    MapPin
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
import { PieChart, Pie, Cell, ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip } from 'recharts';

const API_URL = '/api/proxy';

const fetchOverview = async () => {
    const res = await fetch(`${API_URL}/admin/analytics/overview`);
    if (!res.ok) throw new Error("Не удалось загрузить аналитику");
    return res.json();
};

const fetchActivity = async () => {
    const res = await fetch(`${API_URL}/admin/audit/logs?limit=5`);
    if (!res.ok) return [];
    return res.json();
};

const COLORS = ['#8b5cf6', '#06b6d4', '#f59e0b', '#ef4444'];

export default function Dashboard() {
    const router = useRouter();

    const { data: analytics, isLoading } = useQuery({
        queryKey: ['dashboard-overview'],
        queryFn: fetchOverview
    });

    const { data: activity } = useQuery({
        queryKey: ['dashboard-activity'],
        queryFn: fetchActivity,
        refetchInterval: 10000
    });

    const contentStatus = [
        { name: 'Опубликовано', value: 45 },
        { name: 'Черновик', value: 12 },
        { name: 'Ожидает', value: 3 },
        { name: 'Проблемы', value: 2 },
    ];

    if (isLoading) return (
        <div className="flex items-center justify-center h-[50vh]">
            <div className="h-8 w-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
        </div>
    );

    const kpis = [
        { 
            title: 'Пользователи', 
            value: analytics?.kpis.dau || 0, 
            change: '+12%', 
            up: true,
            icon: Users, 
            color: 'text-blue-500',
            bg: 'bg-blue-500/10'
        },
        { 
            title: 'Доход', 
            value: `$${analytics?.kpis.revenue_30d || 0}`, 
            change: '+8%', 
            up: true,
            icon: CreditCard, 
            color: 'text-emerald-500',
            bg: 'bg-emerald-500/10'
        },
        { 
            title: 'Сессии', 
            value: analytics?.kpis.sessions_last_7d || 0, 
            change: '-2%', 
            up: false,
            icon: Activity, 
            color: 'text-violet-500',
            bg: 'bg-violet-500/10'
        },
        { 
            title: 'Конверсия', 
            value: `${((analytics?.kpis?.conversion_rate ?? 0) * 100).toFixed(1)}%`, 
            change: '+0.5%', 
            up: true,
            icon: TrendingUp, 
            color: 'text-amber-500',
            bg: 'bg-amber-500/10'
        },
    ];

    return (
        <div className="p-4 space-y-4 fade-in">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-gradient">Дашборд</h1>
                    <p className="text-xs text-muted-foreground">Обзор платформы</p>
                </div>
                <div className="flex gap-2">
                    <Button size="sm" variant="outline" onClick={() => router.push('/content/tours/new')}>
                        <Plus className="h-3.5 w-3.5 mr-1" /> Тур
                    </Button>
                    <Button size="sm" onClick={() => router.push('/content/pois/new')}>
                        <Plus className="h-3.5 w-3.5 mr-1" /> Точка
                    </Button>
                </div>
            </div>

            {/* KPI Grid */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
                {kpis.map((kpi, i) => (
                    <Card key={i} className="card-stat">
                        <CardContent className="p-3">
                            <div className="flex items-center justify-between mb-2">
                                <div className={`icon-box icon-box-sm ${kpi.bg}`}>
                                    <kpi.icon className={`h-3.5 w-3.5 ${kpi.color}`} />
                                </div>
                                <Badge variant={kpi.up ? "success" : "destructive"} className="text-[10px] px-1.5">
                                    {kpi.up ? <ArrowUpRight className="h-3 w-3 mr-0.5" /> : <ArrowDownRight className="h-3 w-3 mr-0.5" />}
                                    {kpi.change}
                                </Badge>
                            </div>
                            <div className="text-2xl font-bold">{kpi.value}</div>
                            <div className="text-[11px] text-muted-foreground">{kpi.title}</div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            {/* Charts Row */}
            <div className="grid lg:grid-cols-5 gap-3">
                {/* Traffic Chart */}
                <Card className="lg:col-span-3">
                    <CardHeader className="pb-2">
                        <div className="flex items-center justify-between">
                            <CardTitle>Трафик (30д)</CardTitle>
                            <Badge variant="outline" className="text-[10px]">DAU</Badge>
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div className="h-[180px]">
                            <ResponsiveContainer width="100%" height="100%">
                                <BarChart data={analytics?.recent_trend || []}>
                                    <defs>
                                        <linearGradient id="barGrad" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stopColor="#8b5cf6" stopOpacity={1}/>
                                            <stop offset="100%" stopColor="#06b6d4" stopOpacity={0.8}/>
                                        </linearGradient>
                                    </defs>
                                    <XAxis 
                                        dataKey="date" 
                                        tickFormatter={(v) => new Date(v).getDate().toString()}
                                        tick={{ fontSize: 10 }}
                                        axisLine={false}
                                        tickLine={false}
                                    />
                                    <YAxis hide />
                                    <Tooltip 
                                        contentStyle={{ 
                                            fontSize: 12, 
                                            borderRadius: 8,
                                            border: '1px solid hsl(var(--border))'
                                        }} 
                                    />
                                    <Bar dataKey="dau" fill="url(#barGrad)" radius={[4, 4, 0, 0]} />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>
                    </CardContent>
                </Card>

                {/* Pie Chart */}
                <Card className="lg:col-span-2">
                    <CardHeader className="pb-2">
                        <CardTitle>Контент</CardTitle>
                        <CardDescription>По статусу</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="h-[180px] flex items-center">
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie
                                        data={contentStatus}
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={45}
                                        outerRadius={70}
                                        paddingAngle={3}
                                        dataKey="value"
                                    >
                                        {contentStatus.map((_, i) => (
                                            <Cell key={i} fill={COLORS[i]} />
                                        ))}
                                    </Pie>
                                    <Tooltip contentStyle={{ fontSize: 11, borderRadius: 8 }} />
                                </PieChart>
                            </ResponsiveContainer>
                            <div className="space-y-1 min-w-[80px]">
                                {contentStatus.map((item, i) => (
                                    <div key={i} className="flex items-center gap-1.5 text-[10px]">
                                        <div className="h-2 w-2 rounded-full" style={{ background: COLORS[i] }} />
                                        <span className="text-muted-foreground">{item.name}</span>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Bottom Row */}
            <div className="grid lg:grid-cols-5 gap-3">
                {/* Activity */}
                <Card className="lg:col-span-3">
                    <CardHeader className="pb-2">
                        <div className="flex items-center justify-between">
                            <CardTitle>Активность</CardTitle>
                            <div className="flex items-center gap-1">
                                <div className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                                <span className="text-[10px] text-muted-foreground">Live</span>
                            </div>
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-2">
                            {activity?.slice(0, 4).map((log: any) => (
                                <div key={log.id} className="flex items-center gap-3 p-2 rounded-md hover:bg-muted/50 transition-colors">
                                    <div className="icon-box icon-box-sm icon-box-primary">
                                        <Activity className="h-3 w-3" />
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <p className="text-sm font-medium truncate">{log.action}</p>
                                        <p className="text-[10px] text-muted-foreground">
                                            {new Date(log.timestamp).toLocaleString('ru-RU', { hour: '2-digit', minute: '2-digit' })}
                                        </p>
                                    </div>
                                    <code className="text-[10px] text-muted-foreground bg-muted px-1.5 py-0.5 rounded">
                                        {log.target_id?.slice(0, 6)}
                                    </code>
                                </div>
                            ))}
                            {!activity?.length && (
                                <p className="text-sm text-muted-foreground text-center py-4">Нет активности</p>
                            )}
                        </div>
                    </CardContent>
                </Card>

                {/* Top Content */}
                <Card className="lg:col-span-2">
                    <CardHeader className="pb-2">
                        <CardTitle>Топ контент</CardTitle>
                        <CardDescription>За неделю</CardDescription>
                    </CardHeader>
                    <CardContent className="p-0">
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>Название</TableHead>
                                    <TableHead className="text-right w-16">Views</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {analytics?.top_content?.slice(0, 4).map((item: any, i: number) => (
                                    <TableRow key={item.id}>
                                        <TableCell className="py-2">
                                            <div className="flex items-center gap-2">
                                                <span className="text-[10px] font-bold text-muted-foreground w-4">{i + 1}</span>
                                                <div>
                                                    <p className="text-sm font-medium truncate max-w-[120px]">{item.title}</p>
                                                    <Badge variant="secondary" className="text-[9px] mt-0.5">{item.type}</Badge>
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-right py-2">
                                            <span className="font-bold">{item.views}</span>
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
