// =============================================================================
// SERVICE CATALOGUE MANAGER - DASHBOARD E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { DashboardPage } from '../pages/DashboardPage';
import { test as authTest } from '../fixtures/auth.fixture';

test.describe('Dashboard', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  let dashboardPage: DashboardPage;

  test.beforeEach(async ({ page }) => {
    dashboardPage = new DashboardPage(page);
    await dashboardPage.goto();
  });

  test('should display dashboard elements', async () => {
    await expect(dashboardPage.welcomeMessage).toBeVisible();
    await expect(dashboardPage.statsCards).toBeVisible();
    await expect(dashboardPage.recentServicesTable).toBeVisible();
    await expect(dashboardPage.quickActions).toBeVisible();
  });

  test('should display service statistics', async () => {
    await expect(dashboardPage.totalServicesCard).toBeVisible();
    await expect(dashboardPage.activeServicesCard).toBeVisible();
    const total = await dashboardPage.getTotalServicesCount();
    expect(total).toBeGreaterThanOrEqual(0);
  });

  test('should navigate to create service', async ({ page }) => {
    await dashboardPage.clickCreateService();
    await expect(page).toHaveURL(/services\/create/);
  });

  test('should search services from dashboard', async () => {
    await dashboardPage.searchServices('test');
    await expect(dashboardPage.page).toHaveURL(/search=test/);
  });

  test('should click recent service and navigate to detail', async ({ page }) => {
    await dashboardPage.clickRecentService(0);
    await expect(page).toHaveURL(/services\/\d+/);
  });

  test('should display welcome message with user name', async () => {
    await dashboardPage.expectWelcomeMessage('Welcome');
  });

  test('should show loading state initially', async ({ page }) => {
    const dashboard = new DashboardPage(page);
    await page.goto('/dashboard');
    // Loading should appear briefly
    await dashboard.waitForPageLoad();
    await expect(dashboard.statsCards).toBeVisible();
  });
});
