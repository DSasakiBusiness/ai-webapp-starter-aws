import { test, expect } from '@playwright/test';

test.describe('Health Check', () => {
  test('should display the top page', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('h1')).toBeVisible();
  });

  test('should return ok from API health endpoint', async ({ request }) => {
    const response = await request.get(
      `${process.env.E2E_API_URL || 'http://localhost:3001'}/api/v1/health`,
    );
    expect(response.ok()).toBeTruthy();
    const body = await response.json();
    expect(body.status).toBe('ok');
  });
});
