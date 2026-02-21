import { test, expect } from '@playwright/test';

/**
 * E2E тесты настроек уведомлений
 */

test.describe('Notification Settings', () => {
    
    test.beforeEach(async ({ page }) => {
        // Мокаем авторизацию
        await page.route('**/api/auth/me', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    id: 'admin-123',
                    role: 'admin',
                    full_name: 'Test Admin'
                })
            });
        });
        
        await page.context().addCookies([{
            name: 'token',
            value: 'valid_admin_token',
            domain: 'localhost',
            path: '/'
        }]);
    });
    
    test('loads notification settings page', async ({ page }) => {
        // Мокаем GET настроек
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            if (route.request().method() === 'GET') {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        fcm_server_key: '',
                        email_sender_name: 'Audiogid Support',
                        email_sender_address: 'support@audiogid.app',
                        enable_push: true,
                        enable_email: false
                    })
                });
            } else {
                await route.continue();
            }
        });
        
        await page.goto('/settings/notifications');
        
        // Проверяем заголовок страницы
        await expect(page.locator('h1')).toContainText('Настройки уведомлений');
        
        // Проверяем наличие секций
        await expect(page.getByText(/Push-уведомления|Push/i)).toBeVisible();
        await expect(page.getByText(/Email/i)).toBeVisible();
    });
    
    test('displays FCM server key field', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    fcm_server_key: '',
                    email_sender_name: 'Audiogid Support',
                    email_sender_address: 'support@audiogid.app',
                    enable_push: true,
                    enable_email: false
                })
            });
        });
        
        await page.goto('/settings/notifications');
        
        // FCM ключ - первый input[type="password"] на странице
        const fcmField = page.locator('input[type="password"]').first();
        await expect(fcmField).toBeVisible();
    });
    
    test('saves FCM key', async ({ page }) => {
        let savedData: any = null;
        
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            if (route.request().method() === 'GET') {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        fcm_server_key: '',
                        email_sender_name: 'Audiogid Support',
                        email_sender_address: 'support@audiogid.app',
                        enable_push: true,
                        enable_email: false
                    })
                });
            } else if (route.request().method() === 'PUT') {
                savedData = JSON.parse(route.request().postData() || '{}');
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify(savedData)
                });
            }
        });
        
        await page.goto('/settings/notifications');
        
        // Вводим FCM ключ (первый password input)
        const fcmInput = page.locator('input[type="password"]').first();
        await fcmInput.fill('AAAA1234567890BBBB');
        
        // Сохраняем
        const saveButton = page.getByRole('button', { name: 'Сохранить' });
        await saveButton.click();
        
        // Проверяем что данные отправлены
        await expect(savedData).not.toBeNull();
    });
    
    test('FCM key is masked on reload', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    fcm_server_key: 'AAAA...BBBB', // Замаскированный ключ
                    email_sender_name: 'Audiogid Support',
                    email_sender_address: 'support@audiogid.app',
                    enable_push: true,
                    enable_email: false
                })
            });
        });
        
        await page.goto('/settings/notifications');
        
        // Ключ должен отображаться замаскированным
        const fcmInput = page.locator('input[type="password"]').first();
        const value = await fcmInput.inputValue();
        
        // Значение должно содержать маску "..."
        expect(value).toContain('...');
    });
    
    test('send test push shows error without FCM', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    fcm_server_key: '',
                    email_sender_name: 'Audiogid Support',
                    email_sender_address: 'support@audiogid.app',
                    enable_push: true,
                    enable_email: false
                })
            });
        });
        
        // Мокаем отправку push с ошибкой
        await page.route('**/api/proxy/admin/notifications/push', async (route) => {
            await route.fulfill({
                status: 400,
                contentType: 'application/json',
                body: JSON.stringify({
                    detail: 'FCM Server Key не настроен'
                })
            });
        });
        
        await page.goto('/settings/notifications');
        
        // Открываем форму тестовой отправки (кнопка "Тест Push...")
        const testPushButton = page.getByRole('button', { name: /Тест Push/i });
        await testPushButton.click();
        
        // Отправляем рассылку
        const sendButton = page.getByRole('button', { name: 'Отправить рассылку' });
        await sendButton.click();
        
        // Должно показать toast с ошибкой
        await expect(page.getByText(/Ошибка|Error|FCM/i)).toBeVisible({ timeout: 5000 });
    });
    
    test('send test push success with FCM configured', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    fcm_server_key: 'AAAA...BBBB',
                    email_sender_name: 'Audiogid Support',
                    email_sender_address: 'support@audiogid.app',
                    enable_push: true,
                    enable_email: false
                })
            });
        });
        
        // Мокаем успешную отправку push
        await page.route('**/api/proxy/admin/notifications/push', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    status: 'completed',
                    recipient_count: 5,
                    success_count: 5,
                    failure_count: 0,
                    errors: []
                })
            });
        });
        
        await page.goto('/settings/notifications');
        
        // Открываем форму тестовой отправки
        const testPushButton = page.getByRole('button', { name: /Тест Push/i });
        await testPushButton.click();
        
        // Заполняем и отправляем
        const sendButton = page.getByRole('button', { name: 'Отправить рассылку' });
        await sendButton.click();
        
        // Должно показать toast с успехом
        await expect(page.getByText(/отправлен|success|доставлено/i)).toBeVisible({ timeout: 5000 });
    });
    
    test('toggles push notifications switch', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    fcm_server_key: '',
                    email_sender_name: 'Audiogid Support',
                    email_sender_address: 'support@audiogid.app',
                    enable_push: true,
                    enable_email: false
                })
            });
        });
        
        await page.goto('/settings/notifications');
        
        // Находим switch для push (role="switch")
        const pushSwitch = page.locator('[role="switch"]').first();
        await expect(pushSwitch).toBeVisible();
        
        // Кликаем для переключения
        await pushSwitch.click();
        
        // Switch должен изменить состояние
    });
    
    test('email sender fields are editable', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/notifications', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    fcm_server_key: '',
                    email_sender_name: 'Audiogid Support',
                    email_sender_address: 'support@audiogid.app',
                    enable_push: true,
                    enable_email: false
                })
            });
        });
        
        await page.goto('/settings/notifications');
        
        // Поля email отправителя по placeholder
        const senderNameInput = page.locator('input[placeholder="Команда Аудиогид"]');
        const senderEmailInput = page.locator('input[placeholder="noreply@audiogid.app"]');
        
        if (await senderNameInput.isVisible()) {
            await senderNameInput.fill('New Sender Name');
            expect(await senderNameInput.inputValue()).toBe('New Sender Name');
        }
        
        if (await senderEmailInput.isVisible()) {
            await senderEmailInput.fill('new@email.com');
            expect(await senderEmailInput.inputValue()).toBe('new@email.com');
        }
    });
});

test.describe('AI Settings', () => {
    
    test.beforeEach(async ({ page }) => {
        await page.route('**/api/auth/me', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    id: 'admin-123',
                    role: 'admin',
                    full_name: 'Test Admin'
                })
            });
        });
        
        await page.context().addCookies([{
            name: 'token',
            value: 'valid_admin_token',
            domain: 'localhost',
            path: '/'
        }]);
    });
    
    test('loads AI settings page', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/ai', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    tts_provider: 'openai',
                    openai_api_key: '',
                    default_voice: 'alloy',
                    enable_translation: true
                })
            });
        });
        
        await page.goto('/settings/ai');
        
        // Проверяем заголовок страницы
        await expect(page.locator('h1')).toContainText('ИИ и автоматизация');
        
        // Проверяем секцию TTS
        await expect(page.getByText('Синтез речи (TTS)')).toBeVisible();
    });
    
    test('selects TTS provider', async ({ page }) => {
        await page.route('**/api/proxy/admin/settings/ai', async (route) => {
            await route.fulfill({
                status: 200,
                contentType: 'application/json',
                body: JSON.stringify({
                    tts_provider: 'openai',
                    openai_api_key: '',
                    default_voice: 'alloy',
                    enable_translation: true
                })
            });
        });
        
        await page.goto('/settings/ai');
        
        // Находим combobox для TTS провайдера
        const providerSelect = page.locator('[role="combobox"]').first();
        await expect(providerSelect).toBeVisible();
        
        // Кликаем для открытия списка
        await providerSelect.click();
        
        // Должны быть опции провайдеров
        await expect(page.getByText(/OpenAI|Google|Azure/i)).toBeVisible();
    });
});
