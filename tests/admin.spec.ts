
import { test, expect } from '@playwright/test';

test('admin login and dashboard access', async ({ page }) => {
    await page.goto('/login');

    // Login Flow
    await page.fill('input[type="email"]', 'admin@audiogid.app');
    await page.fill('input[type="password"]', 'password');
    await page.click('button[type="submit"]');

    // Verify Redirect
    await expect(page).toHaveURL(/\/dashboard|\/analytics/);

    // Verify Shell
    await expect(page.getByText('Audiogid Admin')).toBeVisible();
});

test('analytics page loads', async ({ page }) => {
    // Assume generic auth setup or reuse state in real world
    await page.goto('/analytics/overview');
    // Check kpis
    await expect(page.getByText('DAU')).toBeVisible();
    await expect(page.getByText('Revenue')).toBeVisible();
});
