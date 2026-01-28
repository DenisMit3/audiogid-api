
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
    Eye
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
        { name: 'POIs', href: '/admin/pois', icon: MapPin, perm: 'poi:read' },
        { name: 'Tours', href: '/admin/tours', icon: Route, perm: 'tour:read' },
        { name: 'Analytics', href: '/analytics/overview', icon: Activity, perm: 'analytics:read' },
        { name: 'Cohorts', href: '/analytics/cohorts', icon: Users, perm: 'analytics:read' },
        { name: 'Funnels', href: '/analytics/funnels', icon: Filter, perm: 'analytics:read' },
        { name: 'Users', href: '/users', icon: Shield, perm: 'users:manage' },
        { name: 'Audit', href: '/audit', icon: Eye, perm: 'audit:read' },
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
        <div className="hidden border-r bg-gray-100/40 lg:block dark:bg-gray-800/40 w-[240px] h-screen flex-col">
            <div className="flex h-[60px] items-center border-b px-6">
                <span className="font-bold">AudioGuide Admin</span>
            </div>
            <div className="flex-1 overflow-auto py-2">
                <nav className="grid items-start px-4 text-sm font-medium">
                    {links.map((link) => {
                        if (!hasAccess(link.perm)) return null;
                        return (
                            <a
                                key={link.href}
                                href={link.href}
                                className="flex items-center gap-3 rounded-lg px-3 py-2 text-gray-500 transition-all hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-50"
                            >
                                <link.icon className="h-4 w-4" />
                                {link.name}
                            </a>
                        )
                    })}
                </nav>
            </div>
        </div>
    )
}

export function MobileSidebar({ permissions }: { permissions: string[] }) {
    return (
        <Sheet>
            <SheetTrigger asChild>
                <Button variant="ghost" className="lg:hidden">
                    <Menu className="h-6 w-6" />
                </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-[240px] p-0">
                <Sidebar permissions={permissions} />
            </SheetContent>
        </Sheet>
    )
}

export function Topbar({ user, onLogout }: { user: any, onLogout: () => void }) {
    return (
        <header className="flex h-[60px] items-center gap-4 border-b bg-gray-100/40 px-6 dark:bg-gray-800/40">
            <div className="w-full flex-1">
                {/* Breadcrumbs or Title */}
            </div>

            {/* Theme Toggle (Stub) */}

            <DropdownMenu>
                <DropdownMenuTrigger asChild>
                    <Button variant="ghost" className="relative h-8 w-8 rounded-full">
                        <Avatar className="h-8 w-8">
                            <AvatarFallback>{user?.first_name?.[0] || 'U'}</AvatarFallback>
                        </Avatar>
                    </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                    <DropdownMenuLabel>My Account</DropdownMenuLabel>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem onClick={onLogout}>
                        <LogOut className="mr-2 h-4 w-4" /> Log out
                    </DropdownMenuItem>
                </DropdownMenuContent>
            </DropdownMenu>
        </header>
    )
}
