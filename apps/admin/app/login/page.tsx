'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Lock } from 'lucide-react';

const BOT_NAME = 'Audiogidpro_bot';

export default function LoginPage() {
    const router = useRouter();
    const [secret, setSecret] = useState('');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        // Init Telegram Widget
        if (!document.getElementById('tg-script')) {
            const script = document.createElement('script');
            script.id = 'tg-script';
            script.src = "https://telegram.org/js/telegram-widget.js?22";
            script.setAttribute('data-telegram-login', BOT_NAME);
            script.setAttribute('data-size', "large");
            script.setAttribute('data-onauth', "onTelegramAuth(user)");
            script.setAttribute('data-request-access', "write");
            script.async = true;

            const container = document.getElementById('telegram-login-container');
            if (container) container.appendChild(script);
        }

        (window as any).onTelegramAuth = async (user: any) => {
            setLoading(true);
            try {
                const res = await fetch('/api/auth/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(user)
                });
                if (res.ok) {
                    router.push('/dashboard');
                    router.refresh();
                } else {
                    const err = await res.json();
                    alert(`Login failed: ${err.detail}`);
                }
            } catch (e) {
                alert('Login error');
                console.error(e);
            } finally {
                setLoading(false);
            }
        };
    }, [router]);

    const handleDevLogin = async () => {
        setLoading(true);
        try {
            const res = await fetch('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ secret })
            });
            if (res.ok) {
                router.push('/dashboard');
                router.refresh();
            } else {
                alert('Invalid Secret');
            }
        } catch (e) {
            alert('Error during dev login');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50/50 dark:bg-gray-950 px-4">
            <Card className="w-full max-w-md shadow-lg border-gray-200/50 dark:border-gray-800/50">
                <CardHeader className="space-y-1 text-center">
                    <CardTitle className="text-3xl font-bold tracking-tight">AudioGuide Admin</CardTitle>
                    <CardDescription>
                        Authentication required for administrative access
                    </CardDescription>
                </CardHeader>
                <CardContent className="flex flex-col items-center py-6">
                    <div id="telegram-login-container" className="mb-8 scale-110 transition-transform hover:scale-115"></div>

                    <div className="w-full h-px bg-gradient-to-r from-transparent via-gray-200 dark:via-gray-800 to-transparent my-4"></div>

                    <div className="w-full space-y-4">
                        <div className="text-center">
                            <span className="text-xs font-medium text-muted-foreground uppercase tracking-widest">Emergency Access</span>
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="secret" className="sr-only">Admin Secret</Label>
                            <div className="relative">
                                <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                <Input
                                    id="secret"
                                    type="password"
                                    placeholder="Enter your secret key..."
                                    value={secret}
                                    onChange={e => setSecret(e.target.value)}
                                    className="pl-9"
                                    onKeyDown={e => e.key === 'Enter' && handleDevLogin()}
                                    disabled={loading}
                                />
                            </div>
                        </div>
                        <Button
                            onClick={handleDevLogin}
                            className="w-full font-semibold"
                            disabled={loading || !secret}
                        >
                            {loading ? 'Entering...' : 'Access Panel'}
                        </Button>
                    </div>
                </CardContent>
                <CardFooter className="flex justify-center border-t border-gray-100 dark:border-gray-900 mt-2 py-4">
                    <p className="text-xs text-muted-foreground">
                        Secure administrative environment
                    </p>
                </CardFooter>
            </Card>
        </div>
    );
}
