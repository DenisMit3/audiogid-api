'use client';

import { useEffect } from 'react';
import { logger } from '@/lib/debug-logger';

/**
 * Хук для логирования в компонентах
 */
export function useLogger(componentName: string) {
    useEffect(() => {
        logger.info(`[${componentName}] Mounted`);
        return () => logger.info(`[${componentName}] Unmounted`);
    }, [componentName]);

    return {
        info: (msg: string, data?: any) => logger.info(`[${componentName}] ${msg}`, data),
        warn: (msg: string, data?: any) => logger.warn(`[${componentName}] ${msg}`, data),
        error: (msg: string, data?: any, stack?: string) => logger.error(`[${componentName}] ${msg}`, data, stack),
        success: (msg: string, data?: any) => logger.success(`[${componentName}] ${msg}`, data),
        api: (msg: string, data?: any) => logger.api(`[${componentName}] ${msg}`, data),
        auth: (msg: string, data?: any) => logger.auth(`[${componentName}] ${msg}`, data),
    };
}

/**
 * Хук для отслеживания состояния запросов
 */
export function useApiLogger() {
    const logRequest = (method: string, url: string, body?: any) => {
        logger.api(`→ ${method} ${url}`, body ? { body } : undefined);
    };

    const logResponse = (method: string, url: string, status: number, data?: any, duration?: number) => {
        const msg = `← ${status} ${method} ${url}${duration ? ` (${duration}ms)` : ''}`;
        if (status >= 400) {
            logger.error(msg, data);
        } else {
            logger.api(msg, data);
        }
    };

    const logError = (method: string, url: string, error: any) => {
        logger.error(`✗ ${method} ${url}`, { message: error.message }, error.stack);
    };

    return { logRequest, logResponse, logError };
}

/**
 * Обертка для fetch с автоматическим логированием
 */
export async function fetchWithLog<T = any>(
    url: string, 
    options?: RequestInit
): Promise<{ data: T | null; error: string | null; status: number }> {
    const method = options?.method || 'GET';
    const start = Date.now();

    logger.api(`→ ${method} ${url}`);

    try {
        const res = await fetch(url, options);
        const duration = Date.now() - start;
        
        let data: T | null = null;
        try {
            data = await res.json();
        } catch {
            // не JSON
        }

        if (res.ok) {
            logger.api(`← ${res.status} ${url} (${duration}ms)`);
            return { data, error: null, status: res.status };
        } else {
            const errorMsg = (data as any)?.error || (data as any)?.message || `HTTP ${res.status}`;
            logger.error(`← ${res.status} ${url} (${duration}ms)`, data);
            return { data: null, error: errorMsg, status: res.status };
        }
    } catch (err: any) {
        const duration = Date.now() - start;
        logger.error(`✗ ${method} ${url} (${duration}ms)`, { message: err.message }, err.stack);
        return { data: null, error: err.message, status: 0 };
    }
}
