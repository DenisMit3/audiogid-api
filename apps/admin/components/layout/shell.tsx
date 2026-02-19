
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
    ChevronRight
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
    // In a real app we'd use usePathname for active state
    // and a Link component. For now using basic anchors/divs as placeholder if Link not imported.
    // Assuming Next.js Link

    // Stub links for now
    const links = [
        { name: 'Панель управления', href: '/dashboard', icon: Activity, perm: '*' },
        { name: 'Города', href: '/cities', icon: MapPin, perm: 'city:read' },
        { name: 'Точки интереса', href: '/content/pois', icon: MapPin, perm: 'poi:read' },
        { name: 'Туры', href: '/content/tours', icon: Route, perm: 'tour:read' },
        { name: 'Медиа', href: '/content/media', icon: Eye, perm: 'media:read' },
        { name: 'QR-коды', href: '/qr-codes', icon: QrCode, perm: 'poi:read' },
        { name: 'Задачи', href: '/jobs', icon: Zap, perm: 'jobs:read' },
        { name: 'Аналитика', href: '/analytics/overview', icon: Activity, perm: 'analytics:read' },
        { name: 'Пользователи', href: '/users', icon: Shield, perm: 'users:manage' },
        { name: 'Настройки', href: '/settings', icon: Settings, perm: 'settings:manage' }
    ];

    // Filter by permissions
    // If permissions includes '*', allow all? Or just check explicit.
    // User logic: admin has ['*'].
    const hasAccess = (perm: string) => {
        if (permissions.includes('*')) return true;
        // Simple prefix check or exact match
        return permissions.some(p => p === perm || (p.endsWith(':*') && perm.startsWith(p.split(':')[0])));
    };

    return (
        <div className="hidden lg:flex flex-col w-[260px] h-screen border-r border-border/50 bg-gradient-to-b from-background via-background to-muted/20">
            {/* Logo Section */}
            <div className="flex h-[70px] items-center border-b border-border/50 px-6">
                <div className="flex items-center gap-3">
                    <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-primary/80 shadow-lg shadow-primary/20">
                        <Route className="h-5 w-5 text-primary-foreground" />
                    </div>
                    <div className="flex flex-col">
                        <span className="font-bold text-lg tracking-tight gradient-text">Аудиогид</span>
                        <span className="text-[10px] text-muted-foreground font-medium uppercase tracking-wider">Админ-панель</span>
                    </div>
                </div>
            </div>
            
            {/* Navigation */}
            <div className="flex-1 overflow-auto py-4 px-3 scrollbar-hide">
                <nav className="grid gap-1">
                    {links.map((link, index) => {
                        if (!hasAccess(link.perm)) return null;
                        const isActive = typeof window !== 'undefined' && window.location.pathname === link.href;
                        return (
                            <a
                                key={link.href}
                                href={link.href}
                                className={cn(
                                    "group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200",
                                    "hover:bg-primary/5 hover:text-primary",
                                    isActive 
                                        ? "bg-primary/10 text-primary shadow-sm" 
                                        : "text-muted-foreground",
                                    "relative overflow-hidden"
                                )}
                                style={{ animationDelay: `${index * 50}ms` }}
                            >
                                {/* Active indicator */}
                                {isActive && (
                                    <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-primary rounded-r-full" />
                                )}
                                
                                <div className={cn(
                                    "flex h-8 w-8 items-center justify-center rounded-lg transition-all duration-200",
                                    isActive 
                                        ? "bg-primary/10" 
                                        : "bg-muted/50 group-hover:bg-primary/10"
                                )}>
                                    <link.icon className={cn(
                                        "h-4 w-4 transition-transform duration-200",
                                        "group-hover:scale-110"
                                    )} />
                                </div>
                                
                                <span className="flex-1">{link.name}</span>
                                
                                <ChevronRight className={cn(
                                    "h-4 w-4 opacity-0 -translate-x-2 transition-all duration-200",
                                    "group-hover:opacity-50 group-hover:translate-x-0"
                                )} />
                            </a>
                        )
                    })}
                </nav>
            </div>
            
            {/* Footer */}
            <div className="p-4 border-t border-border/50">
                <div className="rounded-xl bg-gradient-to-r from-primary/5 to-accent/5 p-3 border border-primary/10">
                    <p className="text-xs text-muted-foreground">
                        <span className="font-medium text-foreground">Версия 2.0</span>
                        <br />
                        Обновлено сегодня
                    </p>
                </div>
            </div>
        </div>
    )
}

export function MobileSidebar({ permissions }: { permissions: string[] }) {
    return (
        <Sheet>
            <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className="lg:hidden">
                    <Menu className="h-5 w-5" />
                </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-[280px] p-0 border-r-0">
                <Sidebar permissions={permissions} />
            </SheetContent>
        </Sheet>
    )
}

export function Topbar({ user, onLogout }: { user: any, onLogout: () => void }) {
    return (
        <header className="flex h-[70px] items-center gap-4 border-b border-border/50 px-6 bg-background/80 backdrop-blur-xl sticky top-0 z-50">
            <div className="w-full flex-1">
                {/* Breadcrumbs or Search could go here */}
                <div className="hidden md:flex items-center gap-2 text-sm text-muted-foreground">
                    <span className="font-medium text-foreground">Добро пожаловать</span>
                    <span>•</span>
                    <span>{new Date().toLocaleDateString('ru-RU', { weekday: 'long', day: 'numeric', month: 'long' })}</span>
                </div>
            </div>

            {/* Status Indicator */}
            <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20">
                <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                <span className="text-xs font-medium text-emerald-600 dark:text-emerald-400">Онлайн</span>
            </div>

            {/* User Menu */}
            <DropdownMenu>
                <DropdownMenuTrigger asChild>
                    <Button variant="ghost" className="relative h-10 w-10 rounded-full ring-2 ring-border hover:ring-primary/30 transition-all duration-200">
                        <Avatar className="h-10 w-10">
                            <AvatarImage src={user?.avatar_url} />
                            <AvatarFallback className="bg-gradient-to-br from-primary to-primary/80 text-primary-foreground font-semibold">
                                {user?.first_name?.[0] || 'A'}
                            </AvatarFallback>
                        </Avatar>
                    </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-56 p-2">
                    <div className="flex items-center gap-3 p-2 mb-2">
                        <Avatar className="h-10 w-10">
                            <AvatarFallback className="bg-gradient-to-br from-primary to-primary/80 text-primary-foreground">
                                {user?.first_name?.[0] || 'A'}
                            </AvatarFallback>
                        </Avatar>
                        <div className="flex flex-col">
                            <span className="font-medium text-sm">{user?.full_name || 'Администратор'}</span>
                            <span className="text-xs text-muted-foreground">{user?.email || 'admin@audiogid.app'}</span>
                        </div>
                    </div>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem className="cursor-pointer rounded-lg">
                        <Settings className="mr-2 h-4 w-4" /> Настройки
                    </DropdownMenuItem>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem onClick={onLogout} className="cursor-pointer rounded-lg text-destructive focus:text-destructive">
                        <LogOut className="mr-2 h-4 w-4" /> Выйти
                    </DropdownMenuItem>
                </DropdownMenuContent>
            </DropdownMenu>
        </header>
    )
}




