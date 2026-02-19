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
    private maxLogs = 100;
    private listeners: Set<(logs: LogEntry[]) => void> = new Set();
    private enabled = true;

    constructor() {
        if (typeof window !== 'undefined') {
            this.enabled = localStorage.getItem('debug_enabled') !== 'false';
            this.interceptConsole();
            this.interceptFetch();
            this.interceptErrors();
            this.logNavigation();
        }
    }

    private interceptConsole() {
        const origLog = console.log;
        const origWarn = console.warn;
        const origError = console.error;

        console.log = (...args) => {
            origLog.apply(console, args);
            this.add('info', args.map(a => this.stringify(a)).join(' '));
        };

        console.warn = (...args) => {
            origWarn.apply(console, args);
            this.add('warn', args.map(a => this.stringify(a)).join(' '));
        };

        console.error = (...args) => {
            origError.apply(console, args);
            this.add('error', args.map(a => this.stringify(a)).join(' '), undefined, new Error().stack);
        };
    }

    private interceptFetch() {
        const origFetch = window.fetch;
        window.fetch = async (input, init) => {
            const url = typeof input === 'string' ? input : input instanceof URL ? input.href : input.url;
            const method = init?.method || 'GET';
            const start = Date.now();

            this.add('api', `→ ${method} ${url}`);

            try {
                const res = await origFetch(input, init);
                const duration = Date.now() - start;
                const status = res.status;
                
                if (status >= 400) {
                    this.add('error', `← ${status} ${url} (${duration}ms)`);
                } else {
                    this.add('api', `← ${status} ${url} (${duration}ms)`);
                }
                
                return res;
            } catch (err: any) {
                const duration = Date.now() - start;
                this.add('error', `✗ ${method} ${url} - ${err.message} (${duration}ms)`, undefined, err.stack);
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

    add(level: LogLevel, message: string, data?: any, stack?: string) {
        if (!this.enabled) return;

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

        // Styled console output
        const style = `color: ${COLORS[level]}; font-weight: bold;`;
        console.log(`%c${ICONS[level]} [${level.toUpperCase()}]`, style, message);

        this.notify();
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

    subscribe(fn: (logs: LogEntry[]) => void) {
        this.listeners.add(fn);
        return () => this.listeners.delete(fn);
    }

    private notify() {
        this.listeners.forEach(fn => fn(this.logs));
    }
}

export const logger: Pick<DebugLogger, 'add' | 'info' | 'warn' | 'error' | 'success' | 'api' | 'auth' | 'nav' | 'getLogs' | 'clear' | 'toggle' | 'isEnabled' | 'subscribe'> = typeof window !== 'undefined' ? new DebugLogger() : {
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
    subscribe: () => () => {}
};

export type { LogEntry, LogLevel };
