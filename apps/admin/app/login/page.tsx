/* eslint-disable react/no-unescaped-entities */
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Lock, Mail } from 'lucide-react';

export default function LoginPage() {
    const router = useRouter();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);

    const handleLogin = async (e?: React.FormEvent) => {
        if (e) e.preventDefault();
        setLoading(true);
        try {
            const res = await fetch('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });

            if (res.ok) {
                router.push('/dashboard');
                router.refresh();
            } else {
                const err = await res.json();
                alert(`Ошибка входа: ${err.detail || 'Неизвестная ошибка'}`);
            }
        } catch (error) {
            console.error(error);
            alert('Ошибка входа');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50/50 dark:bg-gray-950 px-4">
            <Card className="w-full max-w-md shadow-lg border-gray-200/50 dark:border-gray-800/50">
                <CardHeader className="space-y-1 text-center">
                    <CardTitle className="text-3xl font-bold tracking-tight">Аудиогид Админ</CardTitle>
                    <CardDescription>
                        Введите данные для входа в панель
                    </CardDescription>
                </CardHeader>
                <CardContent className="flex flex-col items-center py-6">
                    <form onSubmit={handleLogin} className="w-full space-y-4">
                        <div className="space-y-2">
                            <Label htmlFor="email" className="sr-only">Эл. почта</Label>
                            <div className="relative">
                                <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                <Input
                                    id="email"
                                    type="email"
                                    placeholder="name@example.com"
                                    value={email}
                                    onChange={e => setEmail(e.target.value)}
                                    className="pl-9"
                                    required
                                    disabled={loading}
                                />
                            </div>
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="password" className="sr-only">Пароль</Label>
                            <div className="relative">
                                <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                <Input
                                    id="password"
                                    type="password"
                                    placeholder="Пароль"
                                    value={password}
                                    onChange={e => setPassword(e.target.value)}
                                    className="pl-9"
                                    required
                                    disabled={loading}
                                />
                            </div>
                        </div>
                        <Button
                            type="submit"
                            className="w-full font-semibold"
                            disabled={loading || !email || !password}
                        >
                            {loading ? 'Вход...' : 'Войти'}
                        </Button>
                    </form>
                </CardContent>
                <CardFooter className="flex justify-center border-t border-gray-100 dark:border-gray-900 mt-2 py-4">
                    <p className="text-xs text-muted-foreground">
                        Защищённая административная среда
                    </p>
                </CardFooter>
            </Card>
        </div>
    );
}
