
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
    FileText,
    Sparkles
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

const COLORS = ['#6366f1', '#22d3ee', '#f59e0b', '#ef4444'];

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
        { name: 'Опубликовано', value: 45 },
        { name: 'Черновик', value: 12 },
        { name: 'Ожидает', value: 3 },
        { name: 'Проблемы', value: 2 },
    ];

    if (analyticsLoading) return (
        <div className="flex items-center justify-center p-8 h-screen">
            <div className="relative">
                <div className="h-12 w-12 rounded-full border-4 border-primary/20 border-t-primary animate-spin"></div>
                <Sparkles className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 h-5 w-5 text-primary animate-pulse" />
            </div>
        </div>
    );

    return (
        <div className="flex flex-col gap-8 p-8 fade-in">
            {/* Header with gradient background */}
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-primary/10 via-accent/5 to-primary/10 p-8 border border-primary/10">
                <div className="absolute inset-0 bg-grid-white/5 [mask-image:linear-gradient(0deg,transparent,black)]"></div>
                <div className="relative flex items-center justify-between">
                    <div className="space-y-2">
                        <h1 className="text-4xl font-bold tracking-tight gradient-text">Панель управления</h1>
                        <p className="text-muted-foreground text-lg">
                            Обзор платформы и активность в реальном времени
                        </p>
                    </div>
                    <div className="flex gap-3">
                        <Button variant="outline" onClick={() => router.push('/content/tours/new')} className="bg-background/80 backdrop-blur-sm">
                            <Plus className="mr-2 h-4 w-4" /> Новый тур
                        </Button>
                        <Button onClick={() => router.push('/content/pois/new')} className="shadow-lg shadow-primary/25">
                            <Plus className="mr-2 h-4 w-4" /> Новая точка
                        </Button>
                    </div>
                </div>
            </div>

            {/* KPI Cards with stagger animation */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4 stagger-children">
                {/* Card 1 - Users */}
                <Card className="group relative overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">Активные пользователи</CardTitle>
                        <div className="h-10 w-10 rounded-xl bg-blue-500/10 flex items-center justify-center">
                            <Users className="h-5 w-5 text-blue-500" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div className="text-3xl font-bold tracking-tight">{analytics?.kpis.dau || 0}</div>
                        <div className="flex items-center gap-2 mt-2">
                            <Badge variant="success" className="text-[10px]">
                                <ArrowUpRight className="h-3 w-3 mr-1" /> +12%
                            </Badge>
                            <span className="text-xs text-muted-foreground">за 24ч</span>
                        </div>
                    </CardContent>
                </Card>

                {/* Card 2 - Revenue */}
                <Card className="group relative overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">Доход за месяц</CardTitle>
                        <div className="h-10 w-10 rounded-xl bg-emerald-500/10 flex items-center justify-center">
                            <CreditCard className="h-5 w-5 text-emerald-500" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div className="text-3xl font-bold tracking-tight">${analytics?.kpis.revenue_30d || 0}</div>
                        <div className="flex items-center gap-2 mt-2">
                            <Badge variant="success" className="text-[10px]">
                                <ArrowUpRight className="h-3 w-3 mr-1" /> +8%
                            </Badge>
                            <span className="text-xs text-muted-foreground">за 30 дней</span>
                        </div>
                    </CardContent>
                </Card>

                {/* Card 3 - Sessions */}
                <Card className="group relative overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-br from-violet-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">Сессии (7д)</CardTitle>
                        <div className="h-10 w-10 rounded-xl bg-violet-500/10 flex items-center justify-center">
                            <Activity className="h-5 w-5 text-violet-500" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div className="text-3xl font-bold tracking-tight">{analytics?.kpis.sessions_last_7d || 0}</div>
                        <div className="flex items-center gap-2 mt-2">
                            <Badge variant="info" className="text-[10px]">Стабильно</Badge>
                            <span className="text-xs text-muted-foreground">всего сессий</span>
                        </div>
                    </CardContent>
                </Card>

                {/* Card 4 - Conversion */}
                <Card className="group relative overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-br from-amber-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">Конверсия</CardTitle>
                        <div className="h-10 w-10 rounded-xl bg-amber-500/10 flex items-center justify-center">
                            <TrendingUp className="h-5 w-5 text-amber-500" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div className="text-3xl font-bold tracking-tight">{(analytics?.kpis.conversion_rate * 100).toFixed(1)}%</div>
                        <div className="flex items-center gap-2 mt-2">
                            <Badge variant="warning" className="text-[10px]">Цель: 5%</Badge>
                            <span className="text-xs text-muted-foreground">установка → покупка</span>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
                {/* Traffic Trend Chart */}
                <Card className="col-span-4 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <div className="flex items-center justify-between">
                            <div>
                                <CardTitle>Трафик посетителей</CardTitle>
                                <CardDescription>Активность за последние 30 дней</CardDescription>
                            </div>
                            <Badge variant="outline" className="font-mono">30 дней</Badge>
                        </div>
                    </CardHeader>
                    <CardContent className="pt-6">
                        <div className="h-[300px] w-full">
                            <ResponsiveContainer width="100%" height="100%">
                                <BarChart data={analytics?.recent_trend || []}>
                                    <defs>
                                        <linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stopColor="#6366f1" stopOpacity={1}/>
                                            <stop offset="100%" stopColor="#6366f1" stopOpacity={0.6}/>
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
                                    <XAxis
                                        dataKey="date"
                                        tickFormatter={(value) => new Date(value).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' })}
                                        style={{ fontSize: '11px' }}
                                        stroke="hsl(var(--muted-foreground))"
                                        tickLine={false}
                                        axisLine={false}
                                    />
                                    <YAxis 
                                        stroke="hsl(var(--muted-foreground))"
                                        tickLine={false}
                                        axisLine={false}
                                        style={{ fontSize: '11px' }}
                                    />
                                    <Tooltip 
                                        contentStyle={{ 
                                            backgroundColor: 'hsl(var(--popover))', 
                                            border: '1px solid hsl(var(--border))',
                                            borderRadius: '12px',
                                            boxShadow: '0 10px 40px -10px rgba(0,0,0,0.2)'
                                        }}
                                    />
                                    <Bar dataKey="dau" fill="url(#barGradient)" name="Активные пользователи" radius={[6, 6, 0, 0]} />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>
                    </CardContent>
                </Card>

                {/* Content Status Pie Chart */}
                <Card className="col-span-3 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <CardTitle>Статус контента</CardTitle>
                        <CardDescription>Распределение по статусу проверки</CardDescription>
                    </CardHeader>
                    <CardContent className="pt-6">
                        <div className="h-[300px] w-full flex justify-center">
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <defs>
                                        {COLORS.map((color, index) => (
                                            <linearGradient key={index} id={`pieGradient${index}`} x1="0" y1="0" x2="1" y2="1">
                                                <stop offset="0%" stopColor={color} stopOpacity={1}/>
                                                <stop offset="100%" stopColor={color} stopOpacity={0.7}/>
                                            </linearGradient>
                                        ))}
                                    </defs>
                                    <Pie
                                        data={contentStatus}
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={70}
                                        outerRadius={100}
                                        fill="#8884d8"
                                        paddingAngle={4}
                                        dataKey="value"
                                        strokeWidth={0}
                                    >
                                        {contentStatus.map((entry, index) => (
                                            <Cell key={`cell-${index}`} fill={`url(#pieGradient${index})`} />
                                        ))}
                                    </Pie>
                                    <Tooltip 
                                        contentStyle={{ 
                                            backgroundColor: 'hsl(var(--popover))', 
                                            border: '1px solid hsl(var(--border))',
                                            borderRadius: '12px'
                                        }}
                                    />
                                    <Legend 
                                        verticalAlign="bottom"
                                        iconType="circle"
                                        iconSize={8}
                                    />
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
                {/* Recent Activity */}
                <Card className="col-span-4 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <div className="flex items-center justify-between">
                            <div>
                                <CardTitle>Последняя активность</CardTitle>
                                <CardDescription>Журнал аудита в реальном времени</CardDescription>
                            </div>
                            <div className="flex items-center gap-2">
                                <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></div>
                                <span className="text-xs text-muted-foreground">Live</span>
                            </div>
                        </div>
                    </CardHeader>
                    <CardContent className="pt-4">
                        <div className="space-y-1">
                            {activity?.map((log: any, index: number) => (
                                <div 
                                    key={log.id} 
                                    className="flex items-center gap-4 p-3 rounded-xl hover:bg-muted/50 transition-colors duration-200 group"
                                    style={{ animationDelay: `${index * 100}ms` }}
                                >
                                    <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/5 group-hover:bg-primary/10 transition-colors">
                                        <Activity className="h-4 w-4 text-primary" />
                                    </div>
                                    <div className="flex-1 grid gap-0.5">
                                        <p className="text-sm font-medium leading-none">
                                            {log.action}
                                        </p>
                                        <p className="text-xs text-muted-foreground">
                                            {log.actor_fingerprint} • {new Date(log.timestamp).toLocaleString('ru-RU')}
                                        </p>
                                    </div>
                                    <div className="font-mono text-xs text-muted-foreground bg-muted/50 px-2 py-1 rounded-md truncate max-w-[100px]">
                                        {log.target_id?.slice(0, 8)}...
                                    </div>
                                </div>
                            ))}
                            {!activity?.length && (
                                <div className="flex flex-col items-center justify-center py-8 text-muted-foreground">
                                    <Activity className="h-8 w-8 mb-2 opacity-50" />
                                    <span className="text-sm">Нет активности</span>
                                </div>
                            )}
                        </div>
                    </CardContent>
                </Card>

                {/* Top Content */}
                <Card className="col-span-3 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <CardTitle>Популярный контент</CardTitle>
                        <CardDescription>Самое просматриваемое за неделю</CardDescription>
                    </CardHeader>
                    <CardContent className="p-0">
                        <Table>
                            <TableHeader>
                                <TableRow className="hover:bg-transparent">
                                    <TableHead>Название</TableHead>
                                    <TableHead className="text-right">Просмотры</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {analytics?.top_content?.slice(0, 5).map((item: any, index: number) => (
                                    <TableRow key={item.id} className="group">
                                        <TableCell>
                                            <div className="flex items-center gap-3">
                                                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-muted/50 text-xs font-bold text-muted-foreground">
                                                    {index + 1}
                                                </div>
                                                <div>
                                                    <div className="font-medium truncate max-w-[120px] group-hover:text-primary transition-colors">{item.title}</div>
                                                    <Badge variant="secondary" className="text-[10px] uppercase mt-1">{item.type}</Badge>
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-right">
                                            <span className="font-bold text-lg">{item.views}</span>
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




