import { test, expect } from '@playwright/test';

test('has admin title', async ({ page }) => {
    await page.goto('/login');
    // Проверяем заголовок страницы входа
    await expect(page.getByText('Добро пожаловать')).toBeVisible();
});

test('shows login form inputs', async ({ page }) => {
    await page.goto('/login');
    // Проверяем наличие полей email и password
    await expect(page.getByPlaceholder('admin@audiogid.app')).toBeVisible();
    await expect(page.getByPlaceholder('••••••••')).toBeVisible();
});
