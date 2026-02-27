'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Plus, Pencil, Trash2, Gift, Search, Loader2 } from 'lucide-react';

const API_URL = '/api/proxy';

type Entitlement = {
    id: string;
    slug: string;
    scope: string;
    ref: string;
    title_ru: string;
    price_amount: number;
    price_currency: string;
    is_active: boolean;
    ref_title?: string;
};

type Grant = {
    id: string;
    device_anon_id?: string;
    user_id?: string;
    entitlement_id: string;
    entitlement_slug: string;
    entitlement_title: string;
    source: string;
    source_ref: string;
    granted_at: string;
    revoked_at?: string;
};

export default function EntitlementsPage() {
    const queryClient = useQueryClient();
    const [activeTab, setActiveTab] = useState('products');
    const [searchQuery, setSearchQuery] = useState('');
    
    // Product dialog state
    const [isProductDialogOpen, setIsProductDialogOpen] = useState(false);
    const [editingProduct, setEditingProduct] = useState<Entitlement | null>(null);
    const [productForm, setProductForm] = useState({
        slug: '',
        scope: 'city',
        ref: '',
        title_ru: '',
        price_amount: 0,
        price_currency: 'RUB',
        is_active: true
    });
    
    // Grant dialog state
    const [isGrantDialogOpen, setIsGrantDialogOpen] = useState(false);
    const [grantingProduct, setGrantingProduct] = useState<Entitlement | null>(null);
    const [grantForm, setGrantForm] = useState({
        device_anon_id: '',
        source: 'promo'
    });

    // Fetch entitlements
    const { data: entitlementsData, isLoading: loadingEntitlements } = useQuery({
        queryKey: ['entitlements', searchQuery],
        queryFn: async () => {
            const params = new URLSearchParams();
            if (searchQuery) params.set('search', searchQuery);
            const res = await fetch(`${API_URL}/admin/entitlements?${params}`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch entitlements');
            return res.json();
        }
    });

    // Fetch grants
    const { data: grantsData, isLoading: loadingGrants } = useQuery({
        queryKey: ['entitlement-grants'],
        queryFn: async () => {
            const res = await fetch(`${API_URL}/admin/entitlement-grants?active_only=true`, { credentials: 'include' });
            if (!res.ok) throw new Error('Failed to fetch grants');
            return res.json();
        }
    });

    // Create/Update entitlement
    const productMutation = useMutation({
        mutationFn: async (data: typeof productForm & { id?: string }) => {
            const url = data.id 
                ? `${API_URL}/admin/entitlements/${data.id}`
                : `${API_URL}/admin/entitlements`;
            const method = data.id ? 'PATCH' : 'POST';
            
            const res = await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify(data)
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || 'Failed to save');
            }
            return res.json();
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['entitlements'] });
            setIsProductDialogOpen(false);
            resetProductForm();
        }
    });

    // Delete entitlement
    const deleteMutation = useMutation({
        mutationFn: async (id: string) => {
            const res = await fetch(`${API_URL}/admin/entitlements/${id}`, {
                method: 'DELETE',
                credentials: 'include'
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || 'Failed to delete');
            }
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['entitlements'] });
        }
    });

    // Grant entitlement
    const grantMutation = useMutation({
        mutationFn: async ({ entitlementId, data }: { entitlementId: string; data: typeof grantForm }) => {
            const res = await fetch(`${API_URL}/admin/entitlements/${entitlementId}/grant`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify(data)
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || 'Failed to grant');
            }
            return res.json();
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['entitlement-grants'] });
            setIsGrantDialogOpen(false);
            setGrantForm({ device_anon_id: '', source: 'promo' });
        }
    });

    // Revoke grant
    const revokeMutation = useMutation({
        mutationFn: async (grantId: string) => {
            const res = await fetch(`${API_URL}/admin/entitlement-grants/${grantId}`, {
                method: 'DELETE',
                credentials: 'include'
            });
            if (!res.ok) throw new Error('Failed to revoke');
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['entitlement-grants'] });
        }
    });

    const resetProductForm = () => {
        setProductForm({
            slug: '',
            scope: 'city',
            ref: '',
            title_ru: '',
            price_amount: 0,
            price_currency: 'RUB',
            is_active: true
        });
        setEditingProduct(null);
    };

    const openEditDialog = (product: Entitlement) => {
        setEditingProduct(product);
        setProductForm({
            slug: product.slug,
            scope: product.scope,
            ref: product.ref,
            title_ru: product.title_ru,
            price_amount: product.price_amount,
            price_currency: product.price_currency,
            is_active: product.is_active
        });
        setIsProductDialogOpen(true);
    };

    const openGrantDialog = (product: Entitlement) => {
        setGrantingProduct(product);
        setIsGrantDialogOpen(true);
    };

    const entitlements: Entitlement[] = entitlementsData?.items || [];
    const grants: Grant[] = grantsData?.items || [];

    return (
        <div className="container mx-auto py-6 space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Продукты и права доступа</h1>
                    <p className="text-muted-foreground">Управление монетизацией и выдачей прав</p>
                </div>
            </div>

            <Tabs value={activeTab} onValueChange={setActiveTab}>
                <TabsList>
                    <TabsTrigger value="products">Продукты ({entitlements.length})</TabsTrigger>
                    <TabsTrigger value="grants">Выданные права ({grants.length})</TabsTrigger>
                </TabsList>

                <TabsContent value="products" className="space-y-4">
                    <div className="flex items-center gap-4">
                        <div className="relative flex-1 max-w-sm">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                            <Input
                                placeholder="Поиск по названию..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-9"
                            />
                        </div>
                        <Button onClick={() => { resetProductForm(); setIsProductDialogOpen(true); }}>
                            <Plus className="w-4 h-4 mr-2" />
                            Добавить продукт
                        </Button>
                    </div>

                    {loadingEntitlements ? (
                        <div className="flex items-center justify-center py-12">
                            <Loader2 className="w-6 h-6 animate-spin" />
                        </div>
                    ) : (
                        <div className="grid gap-4">
                            {entitlements.map((e) => (
                                <Card key={e.id}>
                                    <CardContent className="flex items-center justify-between py-4">
                                        <div className="space-y-1">
                                            <div className="flex items-center gap-2">
                                                <span className="font-medium">{e.title_ru}</span>
                                                <Badge variant={e.is_active ? "default" : "secondary"}>
                                                    {e.is_active ? 'Активен' : 'Неактивен'}
                                                </Badge>
                                                <Badge variant="outline">{e.scope}</Badge>
                                            </div>
                                            <div className="text-sm text-muted-foreground">
                                                <code className="bg-slate-100 px-1 rounded">{e.slug}</code>
                                                {e.ref_title && <span className="ml-2">→ {e.ref_title}</span>}
                                            </div>
                                            <div className="text-sm font-medium text-green-600">
                                                {e.price_amount} {e.price_currency}
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <Button variant="outline" size="sm" onClick={() => openGrantDialog(e)}>
                                                <Gift className="w-4 h-4 mr-1" />
                                                Выдать
                                            </Button>
                                            <Button variant="ghost" size="icon" onClick={() => openEditDialog(e)}>
                                                <Pencil className="w-4 h-4" />
                                            </Button>
                                            <Button 
                                                variant="ghost" 
                                                size="icon" 
                                                className="text-red-500"
                                                onClick={() => {
                                                    if (confirm('Удалить продукт?')) {
                                                        deleteMutation.mutate(e.id);
                                                    }
                                                }}
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </Button>
                                        </div>
                                    </CardContent>
                                </Card>
                            ))}
                            {entitlements.length === 0 && (
                                <div className="text-center py-12 text-muted-foreground">
                                    Нет продуктов
                                </div>
                            )}
                        </div>
                    )}
                </TabsContent>

                <TabsContent value="grants" className="space-y-4">
                    {loadingGrants ? (
                        <div className="flex items-center justify-center py-12">
                            <Loader2 className="w-6 h-6 animate-spin" />
                        </div>
                    ) : (
                        <div className="grid gap-4">
                            {grants.map((g) => (
                                <Card key={g.id}>
                                    <CardContent className="flex items-center justify-between py-4">
                                        <div className="space-y-1">
                                            <div className="flex items-center gap-2">
                                                <span className="font-medium">{g.entitlement_title}</span>
                                                <Badge variant="outline">{g.source}</Badge>
                                            </div>
                                            <div className="text-sm text-muted-foreground">
                                                {g.device_anon_id && (
                                                    <span>Device: <code className="bg-slate-100 px-1 rounded">{g.device_anon_id.slice(0, 12)}...</code></span>
                                                )}
                                                {g.user_id && (
                                                    <span>User: <code className="bg-slate-100 px-1 rounded">{g.user_id.slice(0, 8)}...</code></span>
                                                )}
                                            </div>
                                            <div className="text-xs text-muted-foreground">
                                                Выдано: {new Date(g.granted_at).toLocaleString('ru-RU')}
                                            </div>
                                        </div>
                                        <Button 
                                            variant="outline" 
                                            size="sm"
                                            className="text-red-500"
                                            onClick={() => {
                                                if (confirm('Отозвать право?')) {
                                                    revokeMutation.mutate(g.id);
                                                }
                                            }}
                                        >
                                            Отозвать
                                        </Button>
                                    </CardContent>
                                </Card>
                            ))}
                            {grants.length === 0 && (
                                <div className="text-center py-12 text-muted-foreground">
                                    Нет выданных прав
                                </div>
                            )}
                        </div>
                    )}
                </TabsContent>
            </Tabs>

            {/* Product Dialog */}
            <Dialog open={isProductDialogOpen} onOpenChange={setIsProductDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{editingProduct ? 'Редактировать продукт' : 'Новый продукт'}</DialogTitle>
                        <DialogDescription>
                            Продукт определяет что пользователь может купить
                        </DialogDescription>
                    </DialogHeader>
                    <div className="grid gap-4 py-4">
                        <div className="grid gap-2">
                            <Label>SKU (slug)</Label>
                            <Input
                                value={productForm.slug}
                                onChange={(e) => setProductForm({ ...productForm, slug: e.target.value })}
                                placeholder="kaliningrad_city_access"
                                disabled={!!editingProduct}
                            />
                            <p className="text-xs text-muted-foreground">Уникальный идентификатор для магазинов</p>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label>Тип</Label>
                                <Select
                                    value={productForm.scope}
                                    onValueChange={(v) => setProductForm({ ...productForm, scope: v })}
                                    disabled={!!editingProduct}
                                >
                                    <SelectTrigger>
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="city">Город</SelectItem>
                                        <SelectItem value="tour">Тур</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>
                            <div className="grid gap-2">
                                <Label>Ссылка (ref)</Label>
                                <Input
                                    value={productForm.ref}
                                    onChange={(e) => setProductForm({ ...productForm, ref: e.target.value })}
                                    placeholder={productForm.scope === 'city' ? 'kaliningrad' : 'uuid тура'}
                                    disabled={!!editingProduct}
                                />
                            </div>
                        </div>
                        <div className="grid gap-2">
                            <Label>Название</Label>
                            <Input
                                value={productForm.title_ru}
                                onChange={(e) => setProductForm({ ...productForm, title_ru: e.target.value })}
                                placeholder="Доступ к Калининграду"
                            />
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label>Цена</Label>
                                <Input
                                    type="number"
                                    value={productForm.price_amount}
                                    onChange={(e) => setProductForm({ ...productForm, price_amount: parseFloat(e.target.value) || 0 })}
                                />
                            </div>
                            <div className="grid gap-2">
                                <Label>Валюта</Label>
                                <Select
                                    value={productForm.price_currency}
                                    onValueChange={(v) => setProductForm({ ...productForm, price_currency: v })}
                                >
                                    <SelectTrigger>
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="RUB">RUB</SelectItem>
                                        <SelectItem value="USD">USD</SelectItem>
                                        <SelectItem value="EUR">EUR</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsProductDialogOpen(false)}>
                            Отмена
                        </Button>
                        <Button 
                            onClick={() => productMutation.mutate(editingProduct ? { ...productForm, id: editingProduct.id } : productForm)}
                            disabled={productMutation.isPending}
                        >
                            {productMutation.isPending && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                            {editingProduct ? 'Сохранить' : 'Создать'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Grant Dialog */}
            <Dialog open={isGrantDialogOpen} onOpenChange={setIsGrantDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Выдать право доступа</DialogTitle>
                        <DialogDescription>
                            {grantingProduct?.title_ru}
                        </DialogDescription>
                    </DialogHeader>
                    <div className="grid gap-4 py-4">
                        <div className="grid gap-2">
                            <Label>Device ID</Label>
                            <Input
                                value={grantForm.device_anon_id}
                                onChange={(e) => setGrantForm({ ...grantForm, device_anon_id: e.target.value })}
                                placeholder="Анонимный ID устройства"
                            />
                            <p className="text-xs text-muted-foreground">
                                Можно найти в аналитике или запросить у пользователя
                            </p>
                        </div>
                        <div className="grid gap-2">
                            <Label>Источник</Label>
                            <Select
                                value={grantForm.source}
                                onValueChange={(v) => setGrantForm({ ...grantForm, source: v })}
                            >
                                <SelectTrigger>
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="promo">Промо-код</SelectItem>
                                    <SelectItem value="manual">Ручная выдача</SelectItem>
                                    <SelectItem value="system">Системная</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsGrantDialogOpen(false)}>
                            Отмена
                        </Button>
                        <Button 
                            onClick={() => grantingProduct && grantMutation.mutate({ 
                                entitlementId: grantingProduct.id, 
                                data: grantForm 
                            })}
                            disabled={grantMutation.isPending || !grantForm.device_anon_id}
                        >
                            {grantMutation.isPending && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                            Выдать
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
