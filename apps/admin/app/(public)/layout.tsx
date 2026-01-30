import Link from 'next/link';
import { Button } from "@/components/ui/button";

export default function PublicLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <div className="min-h-screen bg-white">
            <header className="border-b">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
                    <div className="flex items-center">
                        <Link href="/" className="text-xl font-bold text-slate-900">
                            Audiogid
                        </Link>
                    </div>
                    <nav className="flex gap-4">
                        <Link href="/privacy" className="text-sm font-medium text-slate-600 hover:text-slate-900">
                            Privacy
                        </Link>
                        <Link href="/terms" className="text-sm font-medium text-slate-600 hover:text-slate-900">
                            Terms
                        </Link>
                    </nav>
                </div>
            </header>
            <main>
                {children}
            </main>
            <footer className="bg-slate-50 border-t mt-12">
                <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8 text-center text-sm text-slate-500">
                    &copy; {new Date().getFullYear()} Audiogid. All rights reserved.
                </div>
            </footer>
        </div>
    );
}




