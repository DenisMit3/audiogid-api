
import Link from 'next/link';
import { Card, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Settings, Globe, LayoutGrid, Bell, CreditCard, Database, Bot } from 'lucide-react';

const SECTIONS = [
    { name: 'Основные', href: '/settings/general', icon: Settings, desc: 'Название, логотипы, контакты' },
    { name: 'Локализация', href: '/settings/localization', icon: Globe, desc: 'Языки и переводы' },
    { name: 'Интеграции', href: '/settings/integrations', icon: LayoutGrid, desc: 'API-ключи и вебхуки' },
    { name: 'Уведомления', href: '/settings/notifications', icon: Bell, desc: 'Настройки Email и Push' },
    { name: 'Биллинг', href: '/settings/billing', icon: CreditCard, desc: 'Платёжные провайдеры' },
    { name: 'ИИ и автоматизация', href: '/settings/ai', icon: Bot, desc: 'Озвучка и перевод', ml: true },
    { name: 'Резервные копии', href: '/settings/backup', icon: Database, desc: 'Снимки базы данных' },
];

export default function SettingsPage() {
    return (
        <div className="space-y-6 p-8">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Настройки</h1>
                <p className="text-muted-foreground">Управление конфигурацией и настройками приложения.</p>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                {SECTIONS.map((section) => (
                    <Link key={section.href} href={section.href}>
                        <Card className="hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer h-full">
                            <CardHeader>
                                <div className="flex items-center gap-2">
                                    <section.icon className="h-5 w-5 text-primary" />
                                    <CardTitle className="text-lg">{section.name}</CardTitle>
                                </div>
                                <CardDescription>{section.desc}</CardDescription>
                            </CardHeader>
                        </Card>
                    </Link>
                ))}
            </div>
        </div>
    );
}




