/* eslint-disable react/no-unescaped-entities */
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Lock, Mail, Sparkles, ArrowRight } from 'lucide-react';

export default function LoginPage() {
    const router = useRouter();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);

    const handleLogin = async (e?: React.FormEvent) => {
        if (e) e.preventDefault();
        console.log('[LOGIN] handleLogin called', { email, password: '***' });
        setLoading(true);
        try {
            console.log('[LOGIN] Sending request to /api/auth/login');
            const res = await fetch('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });
            console.log('[LOGIN] Response status:', res.status);

            if (res.ok) {
                console.log('[LOGIN] Success, redirecting to dashboard');
                console.log('[LOGIN] Response headers Set-Cookie:', res.headers.get('set-cookie'));
                console.log('[LOGIN] Document cookies:', document.cookie);
                
                // Используем window.location вместо router.push для надёжного редиректа
                console.log('[LOGIN] Using window.location.href for redirect');
                window.location.href = '/dashboard';
            } else {
                const err = await res.json();
                console.log('[LOGIN] Error response:', err);
                alert(`Ошибка входа: ${err.detail || 'Неизвестная ошибка'}`);
            }
        } catch (error) {
            console.error('[LOGIN] Exception:', error);
            alert('Ошибка входа');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
            {/* Animated Background */}
            <div className="absolute inset-0 bg-gradient-to-br from-slate-50 via-blue-50/30 to-violet-50/30 dark:from-slate-950 dark:via-blue-950/30 dark:to-violet-950/30"></div>
            
            {/* Mesh Gradient Orbs */}
            <div className="absolute top-1/4 -left-20 w-96 h-96 bg-primary/20 rounded-full blur-3xl animate-pulse"></div>
            <div className="absolute bottom-1/4 -right-20 w-96 h-96 bg-accent/20 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }}></div>
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-violet-500/10 rounded-full blur-3xl"></div>

            {/* Grid Pattern */}
            <div className="absolute inset-0 bg-[linear-gradient(rgba(0,0,0,0.02)_1px,transparent_1px),linear-gradient(90deg,rgba(0,0,0,0.02)_1px,transparent_1px)] bg-[size:50px_50px] [mask-image:radial-gradient(ellipse_at_center,black_20%,transparent_70%)]"></div>

            <div className="relative z-10 w-full max-w-md px-4 fade-in-up">
                {/* Logo */}
                <div className="flex justify-center mb-8">
                    <div className="flex items-center gap-3 px-4 py-2 rounded-2xl bg-white/50 dark:bg-slate-900/50 backdrop-blur-xl border border-white/20 shadow-xl">
                        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-primary/80 shadow-lg shadow-primary/30">
                            <Sparkles className="h-5 w-5 text-white" />
                        </div>
                        <span className="font-bold text-xl gradient-text">Аудиогид</span>
                    </div>
                </div>

                <Card className="border-0 shadow-2xl shadow-black/10 bg-white/70 dark:bg-slate-900/70 backdrop-blur-xl">
                    <CardHeader className="space-y-1 text-center pb-2">
                        <CardTitle className="text-2xl font-bold tracking-tight">Добро пожаловать</CardTitle>
                        <CardDescription className="text-base">
                            Войдите в панель администратора
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="pt-4">
                        <form onSubmit={handleLogin} className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="email" className="text-sm font-medium">Эл. почта</Label>
                                <div className="relative group">
                                    <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                                    <Input
                                        id="email"
                                        type="email"
                                        placeholder="admin@audiogid.app"
                                        value={email}
                                        onChange={e => setEmail(e.target.value)}
                                        className="pl-10 h-12 bg-white/50 dark:bg-slate-800/50"
                                        required
                                        disabled={loading}
                                    />
                                </div>
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="password" className="text-sm font-medium">Пароль</Label>
                                <div className="relative group">
                                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                                    <Input
                                        id="password"
                                        type="password"
                                        placeholder="••••••••"
                                        value={password}
                                        onChange={e => setPassword(e.target.value)}
                                        className="pl-10 h-12 bg-white/50 dark:bg-slate-800/50"
                                        required
                                        disabled={loading}
                                    />
                                </div>
                            </div>
                            <Button
                                type="submit"
                                className="w-full h-12 text-base font-semibold shadow-lg shadow-primary/25 group"
                                disabled={loading || !email || !password}
                                onClick={() => console.log('[LOGIN] Button clicked', { email, password: password ? '***' : 'empty', loading, disabled: loading || !email || !password })}
                            >
                                {loading ? (
                                    <div className="flex items-center gap-2">
                                        <div className="h-4 w-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                                        Вход...
                                    </div>
                                ) : (
                                    <div className="flex items-center gap-2">
                                        Войти
                                        <ArrowRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
                                    </div>
                                )}
                            </Button>
                        </form>
                    </CardContent>
                    <CardFooter className="flex justify-center border-t border-border/50 mt-2 py-4">
                        <p className="text-xs text-muted-foreground flex items-center gap-2">
                            <Lock className="h-3 w-3" />
                            Защищённое соединение
                        </p>
                    </CardFooter>
                </Card>

                {/* Footer */}
                <p className="text-center text-xs text-muted-foreground mt-6">
                    © 2026 Аудиогид. Все права защищены.
                </p>
            </div>
        </div>
    );
}
