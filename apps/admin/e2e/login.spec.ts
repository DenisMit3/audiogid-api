import { test, expect } from '@playwright/test';

test('has admin title', async ({ page }) => {
    await page.goto('/login');
    // Check the Card Title
    await expect(page.getByText('AudioGuide Admin')).toBeVisible();
});

test('shows secret input', async ({ page }) => {
    await page.goto('/login');
    await expect(page.getByPlaceholder('Enter your secret key...')).toBeVisible();
});
