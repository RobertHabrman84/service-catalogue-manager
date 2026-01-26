// =============================================================================
// SERVICE CATALOGUE MANAGER - VIEW SERVICE E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { ViewServicePage } from '../pages/ViewServicePage';

test.describe('View Service', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  let viewPage: ViewServicePage;

  test.beforeEach(async ({ page }) => {
    viewPage = new ViewServicePage(page);
    await viewPage.gotoService(1);
  });

  test('should display service details', async () => {
    await expect(viewPage.serviceCode).toBeVisible();
    await expect(viewPage.serviceName).toBeVisible();
    await expect(viewPage.statusBadge).toBeVisible();
  });

  test('should navigate to edit page', async ({ page }) => {
    await viewPage.clickEdit();
    await expect(page).toHaveURL(/edit$/);
  });

  test('should export to PDF', async () => {
    await viewPage.clickExportPdf();
    await viewPage.expectNotification('Export started', 'success');
  });

  test('should export to Markdown', async () => {
    await viewPage.clickExportMarkdown();
    await viewPage.expectNotification('Export started', 'success');
  });

  test('should switch tabs', async () => {
    await viewPage.selectTab('Dependencies');
    await expect(viewPage.dependenciesSection).toBeVisible();
  });

  test('should show usage scenarios', async () => {
    await viewPage.selectTab('Usage Scenarios');
    await expect(viewPage.usageScenariosSection).toBeVisible();
  });
});
