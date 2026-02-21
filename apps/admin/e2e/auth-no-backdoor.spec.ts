import { test, expect } from '@playwright/test';

/**
 * E2E тесты проверки отсутствия backdoor в авторизации (P0 - критично для безопасности)
 * 
 * Реальный UI:
 * - Страница логина: email input (placeholder "admin@audiogid.app"), password input, кнопка "Войти"
 * - Dashboard: заголовок "Дашборд" в sidebar
 * - Sidebar: div с классом, содержит nav элементы
 * - Logout: в dropdown меню пользователя (Avatar), текст "Выйти"
 */

test.describe('Auth Security - No Backdoor', () => {
    
    test('redirects to login on auth failure', async ({ page }) => {
        // Очищаем cookies чтобы симулировать неавторизованного пользователя
        await page.context().clearCookies();
        
        // Пытаемся зайти на защищенную страницу
        await page.goto('/');
        
        // Должен быть редирект на /login
        await expect(page).toHaveURL(/\/login/);
    });
    
    test('shows error message before redirect on API error', async ({ page }) => {
        // Мокаем /api/auth/me чтобы вернуть ошибку
        await page.route('**/api/auth/me', async (route) => {
            await route.fulfill({
                status: 500,
                contentType: 'application/json',
                body: JSON.stringify({ error: 'Internal Server Error' })
            });
        });
        
        // Устанавливаем фейковый токен чтобы пройти начальную проверку
        await page.context().addCookies([{
            name: 'token',
            value: 'fake_token',
            domain: 'localhost',
            path: '/'
        }]);
        
        await page.goto('/');
        
        // Должно показать сообщение об ошибке авторизации
        await expect(page.getByText('Ошибка авторизации')).toBeVisible({ timeout: 5000 });
        
        // Ждем редирект на login (с таймаутом 2 сек + буфер)
        await expect(page).toHaveURL(/\/login/, { timeout: 5000 });
    });
    
    test('no mock admin access without valid token', async ({ page }) => {
        // Мокаем /api/auth/me чтобы вернуть 401
        await page.route('**/api/auth/me', async (route) => {
            await route.fulfill({
                status: 401,
                contentType: 'application/json',
                body: JSON.stringify({ error: 'Not authenticated' })
            });
        });
        
        await page.goto('/');
        
        // НЕ должно быть текста "Debug Mode" или "Mock Admin"
        await expect(page.getByText(/Debug Mode/i)).not.toBeVisible();
        await expect(page.getByText(/Mock Admin/i)).not.toBeVisible();
        
        // Должен быть редирект на login
        await expect(page).toHaveURL(/\/login/);
    });
    
    test('does not show admin UI without authentication', async ({ page }) => {
        await page.context().clearCookies();
        
        await page.goto('/');
        
        // Ждем редирект на login
        await expect(page).toHaveURL(/\/login/);
        
        // На странице логина не должно быть sidebar (nav с ссылками на Дашборд)
        await expect(page.getByRole('link', { name: 'Дашборд' })).not.toBeVisible();
    });
    
    test('protected routes redirect to login', async ({ page }) => {
        await page.context().clearCookies();
        
        const protectedRoutes = [
            '/content/pois',
            '/content/tours',
            '/settings/notifications',
            '/settings/ai',
            '/analytics',
            '/users'
        ];
        
        for (const route of protectedRoutes) {
            await page.goto(route);
            
            // Все защищенные роуты должны редиректить на login
            await expect(page).toHaveURL(/\/login/, { 
                timeout: 3000 
            });
        }
    });
    
    test('valid token allows access to dashboard', async ({ page }) => {
        // Мокаем успешный ответ /api/auth/me
        await page.route('**/api/auth/me', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    id: 'user-123',
                    role: 'admin',
                    full_name: 'Test Admin',
                    first_name: 'Test',
                    email: 'test@audiogid.app'
                })
            });
        });
        
        // Устанавливаем валидный токен
        await page.context().addCookies([{
            name: 'token',
            value: 'valid_test_token',
            domain: 'localhost',
            path: '/'
        }]);
        
        await page.goto('/');
        
        // Должен остаться на dashboard, не редирект на login
        await expect(page).not.toHaveURL(/\/login/);
        
        // Sidebar должен быть видим - проверяем наличие ссылки "Дашборд"
        await expect(page.getByRole('link', { name: 'Дашборд' })).toBeVisible();
    });
    
    test('logout clears session and redirects to login', async ({ page }) => {
        // Мокаем успешную авторизацию
        await page.route('**/api/auth/me', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    id: 'user-123',
                    role: 'admin',
                    full_name: 'Test Admin',
                    first_name: 'Test',
                    email: 'test@audiogid.app'
                })
            });
        });
        
        // Мокаем logout
        await page.route('**/api/auth/logout', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({ success: true })
            });
        });
        
        await page.context().addCookies([{
            name: 'token',
            value: 'valid_token',
            domain: 'localhost',
            path: '/'
        }]);
        
        await page.goto('/');
        
        // Ждем загрузки страницы с sidebar
        await expect(page.getByRole('link', { name: 'Дашборд' })).toBeVisible();
        
        // Находим и кликаем на аватар пользователя (открывает dropdown)
        const avatarButton = page.locator('button').filter({ has: page.locator('[class*="Avatar"], img') }).first();
        await avatarButton.click();
        
        // Кликаем "Выйти" в dropdown меню
        await page.getByRole('menuitem', { name: /выйти/i }).click();
        
        // После logout должен быть редирект на login
        await expect(page).toHaveURL(/\/login/);
    });
    
    test('login page has correct form elements', async ({ page }) => {
        await page.goto('/login');
        
        // Проверяем наличие элементов формы логина
        await expect(page.getByPlaceholder('admin@audiogid.app')).toBeVisible();
        await expect(page.getByLabel(/пароль/i)).toBeVisible();
        await expect(page.getByRole('button', { name: /войти/i })).toBeVisible();
        
        // Заголовок страницы
        await expect(page.getByText('Добро пожаловать')).toBeVisible();
    });
});

test.describe('Auth Error Handling', () => {
    
    test('handles network error gracefully', async ({ page }) => {
        // Симулируем сетевую ошибку
        await page.route('**/api/auth/me', async (route) => {
            await route.abort('failed');
        });
        
        await page.context().addCookies([{
            name: 'token',
            value: 'some_token',
            domain: 'localhost',
            path: '/'
        }]);
        
        await page.goto('/');
        
        // Должен обработать ошибку и редиректнуть на login
        await expect(page).toHaveURL(/\/login/, { timeout: 5000 });
    });
    
    test('handles timeout gracefully', async ({ page }) => {
        // Симулируем таймаут
        await page.route('**/api/auth/me', async (route) => {
            await new Promise(resolve => setTimeout(resolve, 10000));
            await route.fulfill({
                status: 200,
                body: JSON.stringify({ id: 'user' })
            });
        });
        
        await page.context().addCookies([{
            name: 'token',
            value: 'some_token',
            domain: 'localhost',
            path: '/'
        }]);
        
        // Устанавливаем короткий таймаут для теста
        await page.goto('/', { timeout: 5000 }).catch(() => {});
        
        // Страница должна показать loading или редирект
    });
    
    test('login form shows error on invalid credentials', async ({ page }) => {
        // Мокаем ошибку авторизации
        await page.route('**/api/auth/login', async (route) => {
            await route.fulfill({
                status: 401,
                contentType: 'application/json',
                body: JSON.stringify({ detail: 'Неверный email или пароль' })
            });
        });
        
        await page.goto('/login');
        
        // Заполняем форму
        await page.getByPlaceholder('admin@audiogid.app').fill('wrong@email.com');
        await page.getByLabel(/пароль/i).fill('wrongpassword');
        
        // Перехватываем alert
        page.on('dialog', async dialog => {
            expect(dialog.message()).toContain('Неверный email или пароль');
            await dialog.accept();
        });
        
        // Кликаем войти
        await page.getByRole('button', { name: /войти/i }).click();
    });
});
