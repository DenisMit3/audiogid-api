
'use client';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default function BillingSettingsPage() {
    return (
        <div className="space-y-6 max-w-5xl">
            <div>
                <h2 className="text-2xl font-bold tracking-tight">Биллинг и тарифы</h2>
                <p className="text-muted-foreground">Настройка покупок в приложении и уровней подписки.</p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Конфигурация продуктов</CardTitle>
                    <CardDescription>Привязка к ID из App Store / Play Store</CardDescription>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>ID продукта</TableHead>
                                <TableHead>Название</TableHead>
                                <TableHead>Тип</TableHead>
                                <TableHead>Цена (USD)</TableHead>
                                <TableHead>Статус</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            <TableRow>
                                <TableCell className="font-mono">com.audiogid.full_access_1m</TableCell>
                                <TableCell>Полный доступ (месяц)</TableCell>
                                <TableCell>Подписка</TableCell>
                                <TableCell>$9.99</TableCell>
                                <TableCell><Badge>Активен</Badge></TableCell>
                            </TableRow>
                            <TableRow>
                                <TableCell className="font-mono">com.audiogid.city_kaliningrad</TableCell>
                                <TableCell>Пакет Калининград</TableCell>
                                <TableCell>Разовая покупка</TableCell>
                                <TableCell>$4.99</TableCell>
                                <TableCell><Badge>Активен</Badge></TableCell>
                            </TableRow>
                        </TableBody>
                    </Table>
                    <div className="pt-4 flex justify-end">
                        <Button variant="outline">Синхронизировать из магазинов</Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}




