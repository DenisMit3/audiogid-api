import { test, expect } from '@playwright/test';

/**
 * E2E тесты PoiForm - opening_hours и external_links
 * 
 * Реальный UI:
 * - Часы работы: 7 input полей с placeholder "09:00-18:00" (текстовый формат, без checkbox)
 * - Внешние ссылки: input с placeholder "https://example.com", кнопка Plus для добавления, кнопка ✕ для удаления
 * - Кнопка сохранения: "Обновить информацию" (edit) или "Создать точку" (create)
 */

test.describe('PoiForm - Opening Hours & External Links', () => {
    
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
    
    test.describe('Opening Hours', () => {
        
        test('displays opening hours fields', async ({ page }) => {
            // Мокаем получение POI
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: null,
                        external_links: []
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Проверяем наличие секции часов работы
            await expect(page.getByText('Часы работы')).toBeVisible();
            
            // Должны быть поля для дней недели (7 input с placeholder "09:00-18:00")
            const hoursInputs = page.locator('input[placeholder="09:00-18:00"]');
            await expect(hoursInputs).toHaveCount(7);
            
            // Проверяем метки дней
            const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
            for (const day of days) {
                await expect(page.getByText(day, { exact: true })).toBeVisible();
            }
        });
        
        test('saves opening hours for each day', async ({ page }) => {
            let savedData: any = null;
            
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                if (route.request().method() === 'GET') {
                    await route.fulfill({
                        status: 200,
                        contentType: 'application/json',
                        body: JSON.stringify({
                            id: 'poi-123',
                            title_ru: 'Тестовая точка',
                            title_en: 'Test POI',
                            city_slug: 'moscow',
                            is_active: true,
                            opening_hours: null,
                            external_links: []
                        })
                    });
                } else if (route.request().method() === 'PUT' || route.request().method() === 'PATCH') {
                    savedData = JSON.parse(route.request().postData() || '{}');
                    await route.fulfill({
                        status: 200,
                        contentType: 'application/json',
                        body: JSON.stringify({ ...savedData, id: 'poi-123' })
                    });
                }
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Заполняем часы для понедельника (первый input с placeholder "09:00-18:00")
            const hoursInputs = page.locator('input[placeholder="09:00-18:00"]');
            await hoursInputs.first().fill('09:00-18:00');
            
            // Сохраняем (кнопка "Обновить информацию" для существующего POI)
            const saveButton = page.getByRole('button', { name: /Обновить информацию/i });
            await saveButton.click();
            
            // Ждем сохранения
            await page.waitForTimeout(1000);
            
            // Проверяем что opening_hours отправлены
            expect(savedData?.opening_hours).toBeDefined();
            expect(savedData?.opening_hours?.mon).toBe('09:00-18:00');
        });
        
        test('displays existing opening hours', async ({ page }) => {
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: {
                            mon: '09:00-18:00',
                            tue: '09:00-18:00',
                            wed: '09:00-18:00',
                            thu: '09:00-18:00',
                            fri: '09:00-17:00',
                            sat: '10:00-15:00',
                            sun: 'выходной'
                        },
                        external_links: []
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Проверяем что часы отображаются в полях
            const hoursInputs = page.locator('input[placeholder="09:00-18:00"]');
            await expect(hoursInputs.first()).toHaveValue('09:00-18:00');
        });
        
        test('marks day as closed with text', async ({ page }) => {
            let savedData: any = null;
            
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                if (route.request().method() === 'GET') {
                    await route.fulfill({
                        status: 200,
                        contentType: 'application/json',
                        body: JSON.stringify({
                            id: 'poi-123',
                            title_ru: 'Тестовая точка',
                            title_en: 'Test POI',
                            city_slug: 'moscow',
                            is_active: true,
                            opening_hours: null,
                            external_links: []
                        })
                    });
                } else if (route.request().method() === 'PATCH') {
                    savedData = JSON.parse(route.request().postData() || '{}');
                    await route.fulfill({
                        status: 200,
                        contentType: 'application/json',
                        body: JSON.stringify({ ...savedData, id: 'poi-123' })
                    });
                }
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Вводим "выходной" для воскресенья (последний input)
            const hoursInputs = page.locator('input[placeholder="09:00-18:00"]');
            await hoursInputs.last().fill('выходной');
            
            // Сохраняем
            const saveButton = page.getByRole('button', { name: /Обновить информацию/i });
            await saveButton.click();
            
            await page.waitForTimeout(1000);
            
            // Проверяем что воскресенье = "выходной"
            expect(savedData?.opening_hours?.sun).toBe('выходной');
        });
    });
    
    test.describe('External Links', () => {
        
        test('displays external links section', async ({ page }) => {
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: null,
                        external_links: []
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Проверяем наличие секции внешних ссылок
            await expect(page.getByText('Внешние ссылки')).toBeVisible();
            
            // Проверяем наличие input для добавления ссылки
            await expect(page.locator('input[placeholder="https://example.com"]')).toBeVisible();
        });
        
        test('adds external link', async ({ page }) => {
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: null,
                        external_links: []
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Вводим URL в поле
            const linkInput = page.locator('input[placeholder="https://example.com"]');
            await linkInput.fill('https://example.com');
            
            // Нажимаем кнопку добавления (Plus icon)
            const addButton = page.locator('button:has(svg.lucide-plus)');
            await addButton.click();
            
            // Проверяем что ссылка добавлена (появился readonly input с этим значением)
            await expect(page.locator('input[value="https://example.com"][readonly]')).toBeVisible();
        });
        
        test('adds external link by pressing Enter', async ({ page }) => {
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: null,
                        external_links: []
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Вводим URL и нажимаем Enter
            const linkInput = page.locator('input[placeholder="https://example.com"]');
            await linkInput.fill('https://test-site.com');
            await linkInput.press('Enter');
            
            // Проверяем что ссылка добавлена
            await expect(page.locator('input[value="https://test-site.com"][readonly]')).toBeVisible();
        });
        
        test('removes external link', async ({ page }) => {
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: null,
                        external_links: ['https://existing-link.com']
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Проверяем что ссылка отображается
            await expect(page.locator('input[value="https://existing-link.com"]')).toBeVisible();
            
            // Находим кнопку удаления (✕)
            const removeButton = page.getByRole('button', { name: '✕' });
            await removeButton.click();
            
            // Ссылка должна исчезнуть
            await expect(page.locator('input[value="https://existing-link.com"]')).not.toBeVisible();
        });
        
        test('does not add invalid URL', async ({ page }) => {
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: null,
                        external_links: []
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Вводим невалидный URL (без http)
            const linkInput = page.locator('input[placeholder="https://example.com"]');
            await linkInput.fill('not-a-valid-url');
            
            // Нажимаем кнопку добавления
            const addButton = page.locator('button:has(svg.lucide-plus)');
            await addButton.click();
            
            // Ссылка НЕ должна добавиться (проверяем что нет readonly input с этим значением)
            await expect(page.locator('input[value="not-a-valid-url"][readonly]')).not.toBeVisible();
        });
        
        test('displays multiple external links', async ({ page }) => {
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify({
                        id: 'poi-123',
                        title_ru: 'Тестовая точка',
                        title_en: 'Test POI',
                        city_slug: 'moscow',
                        is_active: true,
                        opening_hours: null,
                        external_links: [
                            'https://website.com',
                            'https://tripadvisor.com/place',
                            'https://maps.google.com/place'
                        ]
                    })
                });
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Все ссылки должны отображаться
            await expect(page.locator('input[value="https://website.com"]')).toBeVisible();
            await expect(page.locator('input[value="https://tripadvisor.com/place"]')).toBeVisible();
            await expect(page.locator('input[value="https://maps.google.com/place"]')).toBeVisible();
            
            // Должно быть 3 кнопки удаления
            const removeButtons = page.getByRole('button', { name: '✕' });
            await expect(removeButtons).toHaveCount(3);
        });
    });
    
    test.describe('Form Submission', () => {
        
        test('saves POI with opening hours and external links', async ({ page }) => {
            let savedData: any = null;
            
            await page.route('**/api/proxy/admin/pois/*', async (route) => {
                if (route.request().method() === 'GET') {
                    await route.fulfill({
                        status: 200,
                        contentType: 'application/json',
                        body: JSON.stringify({
                            id: 'poi-123',
                            title_ru: 'Тестовая точка',
                            title_en: 'Test POI',
                            city_slug: 'moscow',
                            is_active: true,
                            opening_hours: {
                                mon: '09:00-18:00'
                            },
                            external_links: ['https://example.com']
                        })
                    });
                } else if (route.request().method() === 'PUT' || route.request().method() === 'PATCH') {
                    savedData = JSON.parse(route.request().postData() || '{}');
                    await route.fulfill({
                        status: 200,
                        contentType: 'application/json',
                        body: JSON.stringify({ ...savedData, id: 'poi-123' })
                    });
                }
            });
            
            await page.goto('/content/pois/poi-123');
            
            // Сохраняем форму
            const saveButton = page.getByRole('button', { name: /Обновить информацию/i });
            await saveButton.click();
            
            // Ждем сохранения
            await page.waitForTimeout(1000);
            
            // Проверяем что данные отправлены
            expect(savedData).toBeDefined();
            expect(savedData).toHaveProperty('opening_hours');
            expect(savedData).toHaveProperty('external_links');
        });
        
        test('create mode shows "Создать точку" button', async ({ page }) => {
            // Мокаем страницу создания новой точки
            await page.route('**/api/proxy/admin/pois', async (route) => {
                if (route.request().method() === 'POST') {
                    await route.fulfill({
                        status: 200,
                        contentType: 'application/json',
                        body: JSON.stringify({ id: 'new-poi-123' })
                    });
                }
            });
            
            await page.goto('/content/pois/new');
            
            // В режиме создания кнопка должна быть "Создать точку"
            await expect(page.getByRole('button', { name: /Создать точку/i })).toBeVisible();
        });
    });
});
