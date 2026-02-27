'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Loader2, Star, Trash2, MessageSquare } from 'lucide-react';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";

const API_URL = '/api/proxy';

type Rating = {
    id: string;
    tour_id: string;
    tour_title: string | null;
    device_anon_id: string;
    user_id: string | null;
    rating: number;
    comment: string | null;
    created_at: string;
};

type RatingStats = {
    tour_id: string;
    tour_title: string;
    avg_rating: number;
    total_reviews: number;
    rating_distribution: Record<number, number>;
};

export default function RatingsPage() {
    const queryClient = useQueryClient();
    const [filterTour, setFilterTour] = useState<string>('all');
    const [filterRating, setFilterRating] = useState<string>('all');
    const [selectedRating, setSelectedRating] = useState<Rating | null>(null);

    // Fetch ratings
    const { data: ratingsData, isLoading } = useQuery({
        queryKey: ['ratings', filterTour, filterRating],
        queryFn: async () => {
            const params = new URLSearchParams();
            if (filterTour && filterTour !== 'all') params.set('tour_id', filterTour);
            if (filterRating && filterRating !== 'all') params.set('rating', filterRating);
            const res = await fetch(`${API_URL}/admin/ratings?${params}`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch ratings');
            return res.json();
        }
    });

    // Fetch stats
    const { data: statsData } = useQuery({
        queryKey: ['ratings-stats'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/ratings/stats`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch stats');
            return res.json();
        }
    });

    // Delete rating
    const deleteMutation = useMutation({
        mutationFn: async (id: string) => {
            const res = await fetch(`${API_URL}/admin/ratings/${id}`, {
                method: 'DELETE',
                credentials: 'include'
            });
            if (!res.ok) throw new Error('Failed to delete');
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['ratings'] });
            queryClient.invalidateQueries({ queryKey: ['ratings-stats'] });
        }
    });

    const ratings: Rating[] = ratingsData?.items || [];
    const stats: RatingStats[] = statsData?.items || [];
    const overallAvg = statsData?.overall_avg || 0;
    const totalReviews = statsData?.total_reviews || 0;

    const renderStars = (rating: number) => {
        return (
            <div className="flex items-center gap-0.5">
                {[1, 2, 3, 4, 5].map((star) => (
                    <Star
                        key={star}
                        className={`w-4 h-4 ${star <= rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'}`}
                    />
                ))}
            </div>
        );
    };

    return (
        <div className="container mx-auto py-6 space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Отзывы о турах</h1>
                    <p className="text-muted-foreground">Управление оценками и комментариями пользователей</p>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="pt-6">
                        <div className="text-2xl font-bold">{totalReviews}</div>
                        <p className="text-sm text-muted-foreground">Всего отзывов</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-2">
                            <span className="text-2xl font-bold">{overallAvg.toFixed(1)}</span>
                            <Star className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                        </div>
                        <p className="text-sm text-muted-foreground">Средняя оценка</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="text-2xl font-bold">{stats.length}</div>
                        <p className="text-sm text-muted-foreground">Туров с отзывами</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="text-2xl font-bold">
                            {stats.filter(s => s.avg_rating >= 4).length}
                        </div>
                        <p className="text-sm text-muted-foreground">Туров с рейтингом 4+</p>
                    </CardContent>
                </Card>
            </div>

            {/* Stats by Tour */}
            {stats.length > 0 && (
                <Card>
                    <CardHeader>
                        <CardTitle>Рейтинг по турам</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3">
                            {stats.slice(0, 5).map((stat) => (
                                <div key={stat.tour_id} className="flex items-center justify-between">
                                    <div className="flex-1">
                                        <div className="font-medium">{stat.tour_title}</div>
                                        <div className="text-sm text-muted-foreground">
                                            {stat.total_reviews} отзывов
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        {renderStars(Math.round(stat.avg_rating))}
                                        <span className="font-medium">{stat.avg_rating.toFixed(1)}</span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            )}

            {/* Filters */}
            <div className="flex items-center gap-4">
                <Select value={filterTour} onValueChange={setFilterTour}>
                    <SelectTrigger className="w-[250px]">
                        <SelectValue placeholder="Все туры" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="all">Все туры</SelectItem>
                        {stats.map((stat) => (
                            <SelectItem key={stat.tour_id} value={stat.tour_id}>
                                {stat.tour_title}
                            </SelectItem>
                        ))}
                    </SelectContent>
                </Select>

                <Select value={filterRating} onValueChange={setFilterRating}>
                    <SelectTrigger className="w-[150px]">
                        <SelectValue placeholder="Все оценки" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="all">Все оценки</SelectItem>
                        <SelectItem value="5">5 звёзд</SelectItem>
                        <SelectItem value="4">4 звезды</SelectItem>
                        <SelectItem value="3">3 звезды</SelectItem>
                        <SelectItem value="2">2 звезды</SelectItem>
                        <SelectItem value="1">1 звезда</SelectItem>
                    </SelectContent>
                </Select>

                <div className="text-sm text-muted-foreground">
                    Найдено: {ratingsData?.total || 0}
                </div>
            </div>

            {/* Ratings Table */}
            <Card>
                <CardContent className="pt-6">
                    {isLoading ? (
                        <div className="flex items-center justify-center py-12">
                            <Loader2 className="w-6 h-6 animate-spin" />
                        </div>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>Тур</TableHead>
                                    <TableHead>Оценка</TableHead>
                                    <TableHead>Комментарий</TableHead>
                                    <TableHead>Дата</TableHead>
                                    <TableHead className="text-right">Действия</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {ratings.map((rating) => (
                                    <TableRow key={rating.id}>
                                        <TableCell>
                                            <div className="font-medium">{rating.tour_title || 'Неизвестный тур'}</div>
                                            <div className="text-xs text-muted-foreground">
                                                {rating.device_anon_id.slice(0, 8)}...
                                            </div>
                                        </TableCell>
                                        <TableCell>{renderStars(rating.rating)}</TableCell>
                                        <TableCell>
                                            {rating.comment ? (
                                                <Button
                                                    variant="ghost"
                                                    size="sm"
                                                    onClick={() => setSelectedRating(rating)}
                                                >
                                                    <MessageSquare className="w-4 h-4 mr-1" />
                                                    Читать
                                                </Button>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </TableCell>
                                        <TableCell>
                                            {new Date(rating.created_at).toLocaleDateString('ru-RU')}
                                        </TableCell>
                                        <TableCell className="text-right">
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                className="text-red-500"
                                                onClick={() => {
                                                    if (confirm('Удалить отзыв?')) {
                                                        deleteMutation.mutate(rating.id);
                                                    }
                                                }}
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </Button>
                                        </TableCell>
                                    </TableRow>
                                ))}
                                {ratings.length === 0 && (
                                    <TableRow>
                                        <TableCell colSpan={5} className="text-center py-12 text-muted-foreground">
                                            Нет отзывов
                                        </TableCell>
                                    </TableRow>
                                )}
                            </TableBody>
                        </Table>
                    )}
                </CardContent>
            </Card>

            {/* Comment Dialog */}
            <Dialog open={!!selectedRating} onOpenChange={(open) => !open && setSelectedRating(null)}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Комментарий к отзыву</DialogTitle>
                        <DialogDescription>
                            {selectedRating?.tour_title} - {renderStars(selectedRating?.rating || 0)}
                        </DialogDescription>
                    </DialogHeader>
                    <div className="py-4">
                        <p className="text-sm">{selectedRating?.comment}</p>
                    </div>
                    <div className="text-xs text-muted-foreground">
                        {selectedRating && new Date(selectedRating.created_at).toLocaleString('ru-RU')}
                    </div>
                </DialogContent>
            </Dialog>
        </div>
    );
}
