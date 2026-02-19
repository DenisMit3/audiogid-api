
import {
    Smartphone,
    MapPin,
    Route,
    LogOut,
    Moon,
    Sun,
    Menu,
    X,
    Activity,
    Users,
    Filter,
    Shield,
    Eye,
    Settings,
    QrCode,
    Zap,
    ChevronRight,
    Building2
} from "lucide-react"

import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

export function Sidebar({ permissions }: { permissions: string[] }) {
    const links = [
        { name: 'Дашборд', href: '/dashboard', icon: Activity, perm: '*' },
        { name: 'Города', href: '/cities', icon: Building2, perm: 'city:read' },
        { name: 'Точки', href: '/content/pois', icon: MapPin, perm: 'poi:read' },
        { name: 'Туры', href: '/content/tours', icon: Route, perm: 'tour:read' },
        { name: 'Медиа', href: '/content/media', icon: Eye, perm: 'media:read' },
        { name: 'QR-коды', href: '/qr-codes', icon: QrCode, perm: 'poi:read' },
        { name: 'Задачи', href: '/jobs', icon: Zap, perm: 'jobs:read' },
        { name: 'Аналитика', href: '/analytics/overview', icon: Activity, perm: 'analytics:read' },
        { name: 'Пользователи', href: '/users', icon: Users, perm: 'users:manage' },
        { name: 'Настройки', href: '/settings', icon: Settings, perm: 'settings:manage' }
    ];

    const hasAccess = (perm: string) => {
        if (permissions.includes('*')) return true;
        return permissions.some(p => p === perm || (p.endsWith(':*') && perm.startsWith(p.split(':')[0])));
    };

    return (
        <div className="hidden lg:flex flex-col w-[200px] h-screen border-r border-border bg-card">
            {/* Logo */}
            <div className="flex h-12 items-center gap-2 border-b border-border px-3">
                <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-gradient-primary">
                    <Route className="h-4 w-4 text-white" />
                </div>
                <span className="font-bold text-sm text-gradient">Аудиогид</span>
            </div>
            
            {/* Nav */}
            <nav className="flex-1 overflow-auto py-2 px-2 space-y-0.5">
                {links.map((link) => {
                    if (!hasAccess(link.perm)) return null;
                    const isActive = typeof window !== 'undefined' && window.location.pathname === link.href;
                    return (
                        <a
                            key={link.href}
                            href={link.href}
                            className={cn("sidebar-item", isActive && "active")}
                        >
                            <link.icon className="h-4 w-4" />
                            <span>{link.name}</span>
                        </a>
                    )
                })}
            </nav>
            
            {/* Footer */}
            <div className="p-2 border-t border-border">
                <div className="text-[10px] text-muted-foreground px-2">
                    v2.0 • Обновлено сегодня
                </div>
            </div>
        </div>
    )
}

export function MobileSidebar({ permissions }: { permissions: string[] }) {
    return (
        <Sheet>
            <SheetTrigger asChild>
                <Button variant="ghost" size="sm" className="lg:hidden h-8 w-8 p-0">
                    <Menu className="h-4 w-4" />
                </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-[200px] p-0">
                <Sidebar permissions={permissions} />
            </SheetContent>
        </Sheet>
    )
}

export function Topbar({ user, onLogout }: { user: any, onLogout: () => void }) {
    return (
        <header className="flex h-12 items-center gap-3 border-b border-border px-4 bg-card">
            <div className="flex-1">
                <span className="text-sm font-medium">Добро пожаловать</span>
                <span className="text-muted-foreground text-sm ml-2 hidden sm:inline">
                    {new Date().toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' })}
                </span>
            </div>

            {/* Status */}
            <div className="flex items-center gap-1.5 px-2 py-1 rounded-full bg-emerald-500/10">
                <div className="status-dot status-online" />
                <span className="text-[11px] font-medium text-emerald-600">Онлайн</span>
            </div>

            {/* User */}
            <DropdownMenu>
                <DropdownMenuTrigger asChild>
                    <Button variant="ghost" className="h-8 w-8 rounded-full p-0">
                        <Avatar className="h-8 w-8">
                            <AvatarImage src={user?.avatar_url} />
                            <AvatarFallback className="bg-gradient-primary text-white text-xs">
                                {user?.first_name?.[0] || 'A'}
                            </AvatarFallback>
                        </Avatar>
                    </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-48">
                    <div className="px-2 py-1.5">
                        <p className="text-sm font-medium">{user?.full_name || 'Админ'}</p>
                        <p className="text-xs text-muted-foreground">{user?.email}</p>
                    </div>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem className="text-sm">
                        <Settings className="mr-2 h-3.5 w-3.5" /> Настройки
                    </DropdownMenuItem>
                    <DropdownMenuItem onClick={onLogout} className="text-sm text-destructive">
                        <LogOut className="mr-2 h-3.5 w-3.5" /> Выйти
                    </DropdownMenuItem>
                </DropdownMenuContent>
            </DropdownMenu>
        </header>
    )
}
