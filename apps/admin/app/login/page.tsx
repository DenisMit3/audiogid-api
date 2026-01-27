'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://audiogid-api.vercel.app';
const BOT_NAME = 'Audiogidpro_bot';

export default function LoginPage() {
    const router = useRouter();
    const [secret, setSecret] = useState('');

    useEffect(() => {
        const token = localStorage.getItem('admin_token');
        if (token) {
            router.push('/dashboard');
            return;
        }

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
            try {
                const res = await fetch(`${API_URL}/v1/auth/login/telegram`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(user)
                });
                if (res.ok) {
                    const data = await res.json();
                    localStorage.setItem('admin_token', data.access_token);
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

    const handleDevLogin = async () => {
        try {
            const res = await fetch(`${API_URL}/v1/auth/login/dev-admin`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ secret })
            });
            if (res.ok) {
                const data = await res.json();
                localStorage.setItem('admin_token', data.access_token);
                router.push('/dashboard');
            } else {
                alert('Invalid Secret');
            }
        } catch (e) { alert('Error during dev login'); }
    };

    return (
        <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', height: '100vh', fontFamily: 'sans-serif' }}>
            <h1>AudioGuide Admin</h1>
            <div id="telegram-login-container" style={{ marginTop: '20px' }}></div>

            <div style={{ marginTop: 50, borderTop: '1px solid #eee', paddingTop: 20, textAlign: 'center' }}>
                <p style={{ fontSize: 12, color: '#999', marginBottom: 5 }}>Emergency Access</p>
                <input
                    type="password"
                    placeholder="Admin Secret"
                    value={secret}
                    onChange={e => setSecret(e.target.value)}
                    style={{ padding: 5, border: '1px solid #ccc' }}
                />
                <button onClick={handleDevLogin} style={{ marginLeft: 5, padding: '5px 10px', cursor: 'pointer' }}>Enter</button>
            </div>
        </div>
    );
}
