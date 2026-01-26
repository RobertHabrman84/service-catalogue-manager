// =============================================================================
// SERVICE CATALOGUE MANAGER - CATALOG LIST E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { CatalogListPage } from '../pages/CatalogListPage';

test.describe('Catalog List', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  let catalogPage: CatalogListPage;

  test.beforeEach(async ({ page }) => {
    catalogPage = new CatalogListPage(page);
    await catalogPage.goto();
  });

  test('should display catalog list', async () => {
    await expect(catalogPage.pageTitle).toBeVisible();
    await expect(catalogPage.servicesTable).toBeVisible();
  });

  test('should search services', async () => {
    await catalogPage.search('test');
    await catalogPage.waitForLoading();
  });

  test('should filter by status', async () => {
    await catalogPage.filterByStatus('Active');
    await catalogPage.waitForLoading();
  });

  test('should filter by category', async () => {
    await catalogPage.filterByCategory('Application');
    await catalogPage.waitForLoading();
  });

  test('should navigate to service detail', async ({ page }) => {
    const count = await catalogPage.getServiceCount();
    if (count > 0) {
      await catalogPage.serviceRows.first().click();
      await expect(page).toHaveURL(/services\/\d+/);
    }
  });

  test('should navigate to create service', async ({ page }) => {
    await catalogPage.clickCreateService();
    await expect(page).toHaveURL(/services\/create/);
  });

  test('should paginate results', async () => {
    const count = await catalogPage.getServiceCount();
    if (count >= 10) {
      await catalogPage.goToPage(2);
      await expect(catalogPage.pagination).toBeVisible();
    }
  });

  test('should show empty state when no results', async () => {
    await catalogPage.search('nonexistent12345xyz');
    await catalogPage.expectEmptyState();
  });
});
