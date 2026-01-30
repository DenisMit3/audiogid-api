
import Link from 'next/link';
import { Card, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Settings, Globe, LayoutGrid, Bell, CreditCard, Database, Bot } from 'lucide-react';

const SECTIONS = [
    { name: 'General', href: '/settings/general', icon: Settings, desc: 'App name, logos, contact info' },
    { name: 'Localization', href: '/settings/localization', icon: Globe, desc: 'Languages and translations' },
    { name: 'Integrations', href: '/settings/integrations', icon: LayoutGrid, desc: 'API keys and webhooks' },
    { name: 'Notifications', href: '/settings/notifications', icon: Bell, desc: 'Email and Push settings' },
    { name: 'Billing', href: '/settings/billing', icon: CreditCard, desc: 'Payment providers' },
    { name: 'AI & Automation', href: '/settings/ai', icon: Bot, desc: 'TTS and Translation', ml: true },
    { name: 'Backups', href: '/settings/backup', icon: Database, desc: 'Database snapshots' },
];

export default function SettingsPage() {
    return (
        <div className="space-y-6 p-8">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Settings</h1>
                <p className="text-muted-foreground">Manage application configuration and preferences.</p>
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


