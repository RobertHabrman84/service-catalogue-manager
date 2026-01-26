// =============================================================================
// SERVICE CATALOGUE MANAGER - EDIT SERVICE E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { EditServicePage } from '../pages/EditServicePage';
import { test as apiTest } from '../fixtures/api.fixture';

test.describe('Edit Service', () => {
  test.use({ storageState: 'playwright/.auth/user.json' });

  test('should display edit form with existing data', async ({ page }) => {
    const editPage = new EditServicePage(page);
    await editPage.gotoService(1);
    await expect(editPage.serviceCodeInput).toBeDisabled();
    await expect(editPage.serviceNameInput).toHaveValue(/.+/);
  });

  test('should update service name', async ({ page }) => {
    const editPage = new EditServicePage(page);
    await editPage.gotoService(1);
    const newName = `Updated Service ${Date.now()}`;
    await editPage.updateName(newName);
    await editPage.save();
    await editPage.expectSaveSuccess();
  });

  test('should update service version', async ({ page }) => {
    const editPage = new EditServicePage(page);
    await editPage.gotoService(1);
    await editPage.updateVersion('2.0.0');
    await editPage.save();
    await editPage.expectSaveSuccess();
  });

  test('should delete service', async ({ page }) => {
    const editPage = new EditServicePage(page);
    await editPage.gotoService(1);
    await editPage.deleteService();
    await editPage.expectDeleteSuccess();
  });

  test('should cancel edit and return', async ({ page }) => {
    const editPage = new EditServicePage(page);
    await editPage.gotoService(1);
    await editPage.cancelButton.click();
    await expect(page).toHaveURL(/services\/1$/);
  });
});
