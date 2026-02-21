'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Sidebar, Topbar, MobileSidebar } from '@/components/layout/shell';
import { ROLE_PERMISSIONS, Role } from '@/lib/permissions';

export default function PanelLayout({ children }: { children: React.ReactNode }) {
    const router = useRouter();
    const [user, setUser] = useState<any>(null);
    const [permissions, setPermissions] = useState<string[]>([]);
    const [mounted, setMounted] = useState(false);
    const [authError, setAuthError] = useState<string | null>(null);

    useEffect(() => {
        setMounted(true);
        
        fetch('/api/auth/me')
            .then(res => {
                if (res.ok) return res.json();
                if (res.status === 401) {
                    throw new Error("NOT_AUTHENTICATED");
                }
                throw new Error("AUTH_ERROR");
            })
            .then(u => {
                setUser(u);
                const role = (u.role || 'viewer') as Role;
                const perms: string[] = [...(ROLE_PERMISSIONS[role] || [])];
                if (role === 'admin') perms.push('*');
                setPermissions(perms);
                setAuthError(null);
            })
            .catch((err) => {
                console.error("Auth error:", err.message);
                if (err.message === "NOT_AUTHENTICATED") {
                    // Редирект на логин
                    router.push('/login');
                } else {
                    // Показываем ошибку, но не даем доступ
                    setAuthError("Ошибка авторизации. Попробуйте войти заново.");
                    setTimeout(() => router.push('/login'), 2000);
                }
            });

    }, [router]);

    const handleLogout = async () => {
        await fetch('/api/auth/logout', { method: 'POST' });
        router.push('/login');
        router.refresh();
    };

    if (!mounted) return null;

    // Показываем ошибку авторизации
    if (authError) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-100">
                <div className="bg-white p-8 rounded-lg shadow-md text-center">
                    <div className="text-red-500 mb-4">
                        <svg className="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                    </div>
                    <p className="text-gray-700">{authError}</p>
                    <p className="text-sm text-gray-500 mt-2">Перенаправление на страницу входа...</p>
                </div>
            </div>
        );
    }

    // Показываем загрузку пока нет пользователя
    if (!user) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-100">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
            </div>
        );
    }

    return (
        <div className="grid min-h-screen w-full lg:grid-cols-[240px_1fr]">
            <Sidebar permissions={permissions} />
            <div className="flex flex-col">
                <header className="flex h-14 lg:h-[60px] items-center gap-4 border-b bg-gray-100/40 px-6 dark:bg-gray-800/40 lg:hidden">
                    <MobileSidebar permissions={permissions} />
                    <div className="w-full flex-1">
                        <span className="font-semibold">Аудиогид</span>
                    </div>
                </header>
                <div className="hidden lg:block">
                    <Topbar user={user} onLogout={handleLogout} />
                </div>

                <main className="flex flex-1 flex-col gap-4 p-4 lg:gap-6 lg:p-6">
                    {children}
                </main>
            </div>
        </div>
    );
}




