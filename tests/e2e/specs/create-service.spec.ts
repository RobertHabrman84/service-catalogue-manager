// =============================================================================
// SERVICE CATALOGUE MANAGER - CREATE SERVICE E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { CreateServicePage } from '../pages/CreateServicePage';
import { generateUniqueCode } from '../utils/helpers';

test.describe('Create Service', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  let createPage: CreateServicePage;

  test.beforeEach(async ({ page }) => {
    createPage = new CreateServicePage(page);
    await createPage.goto();
  });

  test('should display create service form', async () => {
    await expect(createPage.pageTitle).toContainText('Create Service');
    await expect(createPage.serviceCodeInput).toBeVisible();
    await expect(createPage.serviceNameInput).toBeVisible();
    await expect(createPage.saveButton).toBeVisible();
  });

  test('should create service with valid data', async ({ page }) => {
    const code = generateUniqueCode('E2E');
    await createPage.fillBasicInfo({
      code,
      name: `E2E Test Service ${Date.now()}`,
      shortDescription: 'Created by E2E test',
      status: 'Draft',
      category: 'Application',
    });
    await createPage.save();
    await createPage.expectSaveSuccess();
    await expect(page).toHaveURL(/services\/\d+/);
  });

  test('should show validation error for empty code', async () => {
    await createPage.serviceNameInput.fill('Test Service');
    await createPage.save();
    await createPage.expectValidationError('service-code', 'required');
  });

  test('should show validation error for empty name', async () => {
    await createPage.serviceCodeInput.fill('TST-001');
    await createPage.save();
    await createPage.expectValidationError('service-name', 'required');
  });

  test('should cancel and return to catalog', async ({ page }) => {
    await createPage.cancel();
    await expect(page).toHaveURL(/catalog/);
  });

  test('should navigate between form sections', async () => {
    await createPage.navigateToSection('Usage Scenarios');
    await expect(createPage.page.locator('[data-testid="usage-scenarios-section"]')).toBeVisible();
  });
});
