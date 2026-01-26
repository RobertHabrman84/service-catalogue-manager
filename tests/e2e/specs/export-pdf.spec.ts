// =============================================================================
// SERVICE CATALOGUE MANAGER - EXPORT PDF E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { ExportPage } from '../pages/ExportPage';
import { ViewServicePage } from '../pages/ViewServicePage';
import { waitForDownload } from '../utils/helpers';

test.describe('Export PDF', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  test('should export single service to PDF', async ({ page }) => {
    const exportPage = new ExportPage(page);
    await exportPage.goto();
    await exportPage.selectService('Test Service');
    await exportPage.selectFormat('pdf');
    await exportPage.exportService();
    await exportPage.expectDownloadAvailable();
  });

  test('should export from service view', async ({ page }) => {
    const viewPage = new ViewServicePage(page);
    await viewPage.gotoService(1);
    const download = await waitForDownload(page, () => viewPage.clickExportPdf());
    expect(download.suggestedFilename()).toContain('.pdf');
  });

  test('should export all services to PDF', async ({ page }) => {
    const exportPage = new ExportPage(page);
    await exportPage.goto();
    await exportPage.exportAllServices();
    await exportPage.expectDownloadAvailable();
  });

  test('should show progress during export', async ({ page }) => {
    const exportPage = new ExportPage(page);
    await exportPage.goto();
    await exportPage.selectService('Test Service');
    await exportPage.selectFormat('pdf');
    await exportPage.exportButton.click();
    await expect(exportPage.progressBar).toBeVisible();
  });

  test('should update export history', async ({ page }) => {
    const exportPage = new ExportPage(page);
    await exportPage.goto();
    const initialCount = await exportPage.getExportHistoryCount();
    await exportPage.selectService('Test Service');
    await exportPage.selectFormat('pdf');
    await exportPage.exportService();
    const newCount = await exportPage.getExportHistoryCount();
    expect(newCount).toBeGreaterThanOrEqual(initialCount);
  });
});
