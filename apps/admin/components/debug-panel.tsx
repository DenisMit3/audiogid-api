'use client';

import { useState, useEffect, useCallback } from 'react';
import { logger, LogEntry, LogLevel } from '@/lib/debug-logger';
import { X, Trash2, Bug, ChevronDown, ChevronUp, Copy, Filter, Eye, EyeOff } from 'lucide-react';
import { cn } from '@/lib/utils';

const COLORS: Record<LogLevel, string> = {
    info: 'bg-blue-500/10 text-blue-500 border-blue-500/20',
    warn: 'bg-amber-500/10 text-amber-500 border-amber-500/20',
    error: 'bg-red-500/10 text-red-500 border-red-500/20',
    success: 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20',
    api: 'bg-violet-500/10 text-violet-500 border-violet-500/20',
    auth: 'bg-pink-500/10 text-pink-500 border-pink-500/20',
    nav: 'bg-cyan-500/10 text-cyan-500 border-cyan-500/20'
};

const ICONS: Record<LogLevel, string> = {
    info: 'ℹ️', warn: '⚠️', error: '❌', success: '✅', api: '🔌', auth: '🔐', nav: '🧭'
};

export function DebugPanel() {
    const [logs, setLogs] = useState<LogEntry[]>([]);
    const [isOpen, setIsOpen] = useState(false);
    const [isMinimized, setIsMinimized] = useState(false);
    const [filter, setFilter] = useState<LogLevel | 'all'>('all');
    const [expandedId, setExpandedId] = useState<string | null>(null);
    const [enabled, setEnabled] = useState(true);

    useEffect(() => {
        setLogs(logger.getLogs());
        setEnabled(logger.isEnabled());
        return logger.subscribe(setLogs);
    }, []);

    const filteredLogs = filter === 'all' ? logs : logs.filter(l => l.level === filter);
    const errorCount = logs.filter(l => l.level === 'error').length;
    const warnCount = logs.filter(l => l.level === 'warn').length;

    const copyLog = useCallback((log: LogEntry) => {
        const text = `[${log.level.toUpperCase()}] ${log.timestamp.toISOString()}\n${log.message}${log.data ? '\n' + JSON.stringify(log.data, null, 2) : ''}${log.stack ? '\n\nStack:\n' + log.stack : ''}`;
        navigator.clipboard.writeText(text);
    }, []);

    const copyAll = useCallback(() => {
        const text = filteredLogs.map(l => 
            `[${l.level.toUpperCase()}] ${l.timestamp.toISOString()} - ${l.message}`
        ).join('\n');
        navigator.clipboard.writeText(text);
    }, [filteredLogs]);

    // Floating button
    if (!isOpen) {
        return (
            <button
                onClick={() => setIsOpen(true)}
                className={cn(
                    "fixed bottom-4 right-4 z-[9999] flex items-center gap-2 px-3 py-2 rounded-full shadow-lg transition-all",
                    "bg-gradient-to-r from-violet-600 to-purple-600 text-white hover:scale-105 active:scale-95",
                    errorCount > 0 && "animate-pulse"
                )}
            >
                <Bug className="h-4 w-4" />
                <span className="text-xs font-medium">Debug</span>
                {errorCount > 0 && (
                    <span className="flex items-center justify-center h-5 w-5 rounded-full bg-red-500 text-[10px] font-bold">
                        {errorCount}
                    </span>
                )}
                {warnCount > 0 && errorCount === 0 && (
                    <span className="flex items-center justify-center h-5 w-5 rounded-full bg-amber-500 text-[10px] font-bold">
                        {warnCount}
                    </span>
                )}
            </button>
        );
    }

    return (
        <div className={cn(
            "fixed bottom-4 right-4 z-[9999] flex flex-col rounded-lg shadow-2xl border border-border overflow-hidden transition-all",
            "bg-background/95 backdrop-blur-md",
            isMinimized ? "w-[300px] h-[44px]" : "w-[420px] h-[400px]"
        )}>
            {/* Header */}
            <div className="flex items-center justify-between px-3 py-2 bg-gradient-to-r from-violet-600 to-purple-600 text-white">
                <div className="flex items-center gap-2">
                    <Bug className="h-4 w-4" />
                    <span className="text-sm font-semibold">Debug Console</span>
                    <span className="text-[10px] opacity-70">({filteredLogs.length})</span>
                </div>
                <div className="flex items-center gap-1">
                    {errorCount > 0 && (
                        <span className="px-1.5 py-0.5 rounded bg-red-500/30 text-[10px]">{errorCount} err</span>
                    )}
                    {warnCount > 0 && (
                        <span className="px-1.5 py-0.5 rounded bg-amber-500/30 text-[10px]">{warnCount} warn</span>
                    )}
                    <button onClick={() => setIsMinimized(!isMinimized)} className="p-1 hover:bg-white/20 rounded">
                        {isMinimized ? <ChevronUp className="h-3.5 w-3.5" /> : <ChevronDown className="h-3.5 w-3.5" />}
                    </button>
                    <button onClick={() => setIsOpen(false)} className="p-1 hover:bg-white/20 rounded">
                        <X className="h-3.5 w-3.5" />
                    </button>
                </div>
            </div>

            {!isMinimized && (
                <>
                    {/* Toolbar */}
                    <div className="flex items-center gap-2 px-2 py-1.5 border-b border-border bg-muted/30">
                        <div className="flex items-center gap-1">
                            <Filter className="h-3 w-3 text-muted-foreground" />
                            <select 
                                value={filter} 
                                onChange={(e) => setFilter(e.target.value as LogLevel | 'all')}
                                className="text-[11px] bg-transparent border-none outline-none cursor-pointer"
                            >
                                <option value="all">Все</option>
                                <option value="error">❌ Ошибки</option>
                                <option value="warn">⚠️ Warn</option>
                                <option value="api">🔌 API</option>
                                <option value="auth">🔐 Auth</option>
                                <option value="nav">🧭 Nav</option>
                                <option value="info">ℹ️ Info</option>
                                <option value="success">✅ Success</option>
                            </select>
                        </div>
                        <div className="flex-1" />
                        <button 
                            onClick={() => setEnabled(logger.toggle())}
                            className={cn("p-1 rounded hover:bg-muted", enabled ? "text-emerald-500" : "text-muted-foreground")}
                            title={enabled ? "Логирование вкл" : "Логирование выкл"}
                        >
                            {enabled ? <Eye className="h-3.5 w-3.5" /> : <EyeOff className="h-3.5 w-3.5" />}
                        </button>
                        <button onClick={copyAll} className="p-1 rounded hover:bg-muted text-muted-foreground" title="Копировать все">
                            <Copy className="h-3.5 w-3.5" />
                        </button>
                        <button onClick={() => logger.clear()} className="p-1 rounded hover:bg-muted text-muted-foreground" title="Очистить">
                            <Trash2 className="h-3.5 w-3.5" />
                        </button>
                    </div>

                    {/* Logs */}
                    <div className="flex-1 overflow-auto p-1 space-y-1 scrollbar-hide">
                        {filteredLogs.length === 0 ? (
                            <div className="flex items-center justify-center h-full text-muted-foreground text-sm">
                                Нет логов
                            </div>
                        ) : (
                            filteredLogs.map((log) => (
                                <div 
                                    key={log.id}
                                    className={cn(
                                        "rounded border px-2 py-1.5 cursor-pointer transition-all hover:brightness-95",
                                        COLORS[log.level]
                                    )}
                                    onClick={() => setExpandedId(expandedId === log.id ? null : log.id)}
                                >
                                    <div className="flex items-start gap-2">
                                        <span className="text-xs">{ICONS[log.level]}</span>
                                        <div className="flex-1 min-w-0">
                                            <div className="flex items-center gap-2">
                                                <span className="text-[10px] opacity-60 font-mono">
                                                    {log.timestamp.toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                                                </span>
                                                <span className="text-[9px] uppercase font-bold opacity-50">{log.level}</span>
                                            </div>
                                            <p className="text-xs break-all leading-relaxed">{log.message}</p>
                                        </div>
                                        <button 
                                            onClick={(e) => { e.stopPropagation(); copyLog(log); }}
                                            className="p-0.5 rounded hover:bg-black/10 opacity-50 hover:opacity-100"
                                        >
                                            <Copy className="h-3 w-3" />
                                        </button>
                                    </div>
                                    
                                    {expandedId === log.id && (log.data || log.stack) && (
                                        <div className="mt-2 pt-2 border-t border-current/20 space-y-2">
                                            {log.data && (
                                                <pre className="text-[10px] font-mono bg-black/10 rounded p-2 overflow-auto max-h-[100px]">
                                                    {JSON.stringify(log.data, null, 2)}
                                                </pre>
                                            )}
                                            {log.stack && (
                                                <pre className="text-[10px] font-mono bg-black/10 rounded p-2 overflow-auto max-h-[100px] text-red-400">
                                                    {log.stack}
                                                </pre>
                                            )}
                                        </div>
                                    )}
                                </div>
                            ))
                        )}
                    </div>
                </>
            )}
        </div>
    );
}
