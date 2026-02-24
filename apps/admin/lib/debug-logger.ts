/**
 * 🔍 Debug Logger - Визуальное логирование для админки
 * Показывает логи прямо в интерфейсе + консоль
 */

type LogLevel = 'info' | 'warn' | 'error' | 'success' | 'api' | 'auth' | 'nav';

interface LogEntry {
    id: string;
    level: LogLevel;
    message: string;
    data?: any;
    timestamp: Date;
    stack?: string;
}

const COLORS: Record<LogLevel, string> = {
    info: '#3b82f6',
    warn: '#f59e0b', 
    error: '#ef4444',
    success: '#10b981',
    api: '#8b5cf6',
    auth: '#ec4899',
    nav: '#06b6d4'
};

const ICONS: Record<LogLevel, string> = {
    info: 'ℹ️',
    warn: '⚠️',
    error: '❌',
    success: '✅',
    api: '🔌',
    auth: '🔐',
    nav: '🧭'
};

class DebugLogger {
    private logs: LogEntry[] = [];
    private maxLogs = 500; // Увеличено для максимального логирования
    private listeners: Set<(logs: LogEntry[]) => void> = new Set();
    private enabled = true;
    private isLogging = false; // Prevent recursion

    constructor() {
        if (typeof window !== 'undefined') {
            // Принудительно включаем логирование
            this.enabled = true;
            localStorage.setItem('debug_enabled', 'true');
            this.interceptConsole();
            this.interceptFetch();
            this.interceptErrors();
            this.logNavigation();
            
            // Логируем старт
            console.log('🔍 Debug Logger initialized - максимальное логирование включено');
        }
    }

    private interceptConsole() {
        const origLog = console.log.bind(console);
        const origWarn = console.warn.bind(console);
        const origError = console.error.bind(console);
        const self = this;

        console.log = function(...args: any[]) {
            origLog(...args);
            if (!self.isLogging) {
                self.addInternal('info', args.map(a => self.stringify(a)).join(' '));
            }
        };

        console.warn = function(...args: any[]) {
            origWarn(...args);
            if (!self.isLogging) {
                self.addInternal('warn', args.map(a => self.stringify(a)).join(' '));
            }
        };

        console.error = function(...args: any[]) {
            origError(...args);
            if (!self.isLogging) {
                self.addInternal('error', args.map(a => self.stringify(a)).join(' '), undefined, new Error().stack);
            }
        };
    }

    private interceptFetch() {
        const origFetch = window.fetch;
        const self = this;
        window.fetch = async (input, init) => {
            const url = typeof input === 'string' ? input : input instanceof URL ? input.href : input.url;
            const method = init?.method || 'GET';
            const start = Date.now();

            // Логируем тело запроса для POST/PUT/PATCH
            let bodyPreview = '';
            if (init?.body && typeof init.body === 'string') {
                try {
                    const parsed = JSON.parse(init.body);
                    bodyPreview = JSON.stringify(parsed).slice(0, 200);
                } catch {
                    bodyPreview = String(init.body).slice(0, 200);
                }
            }

            self.add('api', `→ ${method} ${url}${bodyPreview ? ` | Body: ${bodyPreview}` : ''}`);

            try {
                const res = await origFetch(input, init);
                const duration = Date.now() - start;
                const status = res.status;
                
                // Клонируем response чтобы прочитать тело
                const cloned = res.clone();
                let responsePreview = '';
                try {
                    const text = await cloned.text();
                    responsePreview = text.slice(0, 300);
                } catch {}
                
                if (status >= 400) {
                    self.add('error', `← ${status} ${url} (${duration}ms)`, { 
                        status, 
                        response: responsePreview,
                        headers: Object.fromEntries(res.headers.entries())
                    });
                } else {
                    self.add('api', `← ${status} ${url} (${duration}ms)`, {
                        response: responsePreview.slice(0, 100)
                    });
                }
                
                return res;
            } catch (err: any) {
                const duration = Date.now() - start;
                self.add('error', `✗ ${method} ${url} - ${err.message} (${duration}ms)`, {
                    error: err.message,
                    name: err.name
                }, err.stack);
                throw err;
            }
        };
    }

    private interceptErrors() {
        window.addEventListener('error', (e) => {
            this.add('error', `Runtime: ${e.message}`, { 
                file: e.filename, 
                line: e.lineno, 
                col: e.colno 
            }, e.error?.stack);
        });

        window.addEventListener('unhandledrejection', (e) => {
            this.add('error', `Promise: ${e.reason?.message || e.reason}`, undefined, e.reason?.stack);
        });
    }

    private logNavigation() {
        if (typeof window !== 'undefined') {
            const origPush = history.pushState;
            const origReplace = history.replaceState;

            history.pushState = (...args) => {
                origPush.apply(history, args);
                this.add('nav', `Navigate → ${args[2]}`);
            };

            history.replaceState = (...args) => {
                origReplace.apply(history, args);
                this.add('nav', `Replace → ${args[2]}`);
            };

            window.addEventListener('popstate', () => {
                this.add('nav', `Back/Forward → ${location.pathname}`);
            });
        }
    }

    private stringify(val: any): string {
        if (val === null) return 'null';
        if (val === undefined) return 'undefined';
        if (typeof val === 'string') return val;
        if (typeof val === 'number' || typeof val === 'boolean') return String(val);
        if (val instanceof Error) return `${val.name}: ${val.message}`;
        try {
            return JSON.stringify(val, null, 2);
        } catch {
            return String(val);
        }
    }

    private addInternal(level: LogLevel, message: string, data?: any, stack?: string) {
        if (!this.enabled || this.isLogging) return;

        const entry: LogEntry = {
            id: Math.random().toString(36).slice(2, 9),
            level,
            message,
            data,
            timestamp: new Date(),
            stack
        };

        this.logs.unshift(entry);
        if (this.logs.length > this.maxLogs) {
            this.logs = this.logs.slice(0, this.maxLogs);
        }

        this.notify();
    }

    add(level: LogLevel, message: string, data?: any, stack?: string) {
        if (!this.enabled || this.isLogging) return;
        this.isLogging = true;

        const entry: LogEntry = {
            id: Math.random().toString(36).slice(2, 9),
            level,
            message,
            data,
            timestamp: new Date(),
            stack
        };

        this.logs.unshift(entry);
        if (this.logs.length > this.maxLogs) {
            this.logs = this.logs.slice(0, this.maxLogs);
        }

        this.notify();
        this.isLogging = false;
    }

    info(msg: string, data?: any) { this.add('info', msg, data); }
    warn(msg: string, data?: any) { this.add('warn', msg, data); }
    error(msg: string, data?: any, stack?: string) { this.add('error', msg, data, stack); }
    success(msg: string, data?: any) { this.add('success', msg, data); }
    api(msg: string, data?: any) { this.add('api', msg, data); }
    auth(msg: string, data?: any) { this.add('auth', msg, data); }
    nav(msg: string, data?: any) { this.add('nav', msg, data); }

    getLogs() { return this.logs; }
    
    clear() { 
        this.logs = []; 
        this.notify();
    }

    toggle(enabled?: boolean) {
        this.enabled = enabled ?? !this.enabled;
        if (typeof window !== 'undefined') {
            localStorage.setItem('debug_enabled', String(this.enabled));
        }
        return this.enabled;
    }

    isEnabled() { return this.enabled; }

    subscribe(fn: (logs: LogEntry[]) => void): () => boolean {
        this.listeners.add(fn);
        return () => this.listeners.delete(fn);
    }

    private notify() {
        this.listeners.forEach(fn => fn(this.logs));
    }
}

interface ILogger {
    add(level: LogLevel, message: string, data?: any, stack?: string): void;
    info(msg: string, data?: any): void;
    warn(msg: string, data?: any): void;
    error(msg: string, data?: any, stack?: string): void;
    success(msg: string, data?: any): void;
    api(msg: string, data?: any): void;
    auth(msg: string, data?: any): void;
    nav(msg: string, data?: any): void;
    getLogs(): LogEntry[];
    clear(): void;
    toggle(enabled?: boolean): boolean;
    isEnabled(): boolean;
    subscribe(fn: (logs: LogEntry[]) => void): () => boolean;
}

const noopLogger: ILogger = {
    add: () => {},
    info: () => {},
    warn: () => {},
    error: () => {},
    success: () => {},
    api: () => {},
    auth: () => {},
    nav: () => {},
    getLogs: () => [],
    clear: () => {},
    toggle: () => false,
    isEnabled: () => false,
    subscribe: () => () => false
};

export const logger: ILogger = typeof window !== 'undefined' ? new DebugLogger() : noopLogger;

export type { LogEntry, LogLevel };
