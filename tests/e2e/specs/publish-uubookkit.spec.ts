// =============================================================================
// SERVICE CATALOGUE MANAGER - PUBLISH UUBOOKKIT E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { ViewServicePage } from '../pages/ViewServicePage';

test.describe('Publish to UuBookKit', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  test('should publish service to UuBookKit', async ({ page }) => {
    const viewPage = new ViewServicePage(page);
    await viewPage.gotoService(1);
    await viewPage.clickPublish();
    await viewPage.expectNotification('Publishing started', 'success');
  });

  test('should show publish status', async ({ page }) => {
    const viewPage = new ViewServicePage(page);
    await viewPage.gotoService(1);
    await expect(viewPage.publishButton).toBeVisible();
  });

  test('should handle publish error gracefully', async ({ page }) => {
    // Mock API error
    await page.route('**/uubookkit/publish/**', route => 
      route.fulfill({ status: 500, body: JSON.stringify({ error: 'Publish failed' }) })
    );
    const viewPage = new ViewServicePage(page);
    await viewPage.gotoService(1);
    await viewPage.clickPublish();
    await viewPage.expectNotification('Publish failed', 'error');
  });
});
