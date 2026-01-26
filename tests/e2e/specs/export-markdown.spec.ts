// =============================================================================
// SERVICE CATALOGUE MANAGER - EXPORT MARKDOWN E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { ExportPage } from '../pages/ExportPage';
import { ViewServicePage } from '../pages/ViewServicePage';
import { waitForDownload } from '../utils/helpers';

test.describe('Export Markdown', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  test('should export single service to Markdown', async ({ page }) => {
    const exportPage = new ExportPage(page);
    await exportPage.goto();
    await exportPage.selectService('Test Service');
    await exportPage.selectFormat('markdown');
    await exportPage.exportService();
    await exportPage.expectDownloadAvailable();
  });

  test('should export from service view', async ({ page }) => {
    const viewPage = new ViewServicePage(page);
    await viewPage.gotoService(1);
    const download = await waitForDownload(page, () => viewPage.clickExportMarkdown());
    expect(download.suggestedFilename()).toContain('.md');
  });

  test('should download markdown file', async ({ page }) => {
    const exportPage = new ExportPage(page);
    await exportPage.goto();
    await exportPage.selectService('Test Service');
    await exportPage.selectFormat('markdown');
    const download = await waitForDownload(page, () => exportPage.exportService());
    expect(download.suggestedFilename()).toMatch(/\.md$/);
  });
});
