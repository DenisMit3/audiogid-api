'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://audiogid-api.vercel.app';
const BOT_NAME = 'Audiogidpro_bot';

export default function LoginPage() {
    const router = useRouter();

    useEffect(() => {
        // Check if valid token exists
        const token = localStorage.getItem('admin_token');
        if (token) {
            // Ideally verify token validity here
            router.push('/dashboard');
            return;
        }

        // Inject Telegram Script
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

        // Global callback
        (window as any).onTelegramAuth = async (user: any) => {
            try {
                const res = await fetch(`${API_URL}/v1/auth/login/telegram`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(user)
                });
                if (res.ok) {
                    const data = await res.json();
                    localStorage.setItem('admin_token', data.access_token);
                    // Also store user info for UI
                    localStorage.setItem('admin_user', JSON.stringify(user));
                    router.push('/dashboard');
                } else {
                    const err = await res.json();
                    alert(`Login failed: ${err.detail}`);
                }
            } catch (e) {
                alert('Login error');
                console.error(e);
            }
        };
    }, [router]);

    return (
        <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', height: '100vh', fontFamily: 'sans-serif' }}>
            <h1>AudioGuide Admin</h1>
            <div id="telegram-login-container" style={{ marginTop: '20px' }}></div>
        </div>
    );
}
