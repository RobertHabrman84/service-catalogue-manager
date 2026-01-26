// =============================================================================
// SERVICE CATALOGUE MANAGER - EDIT SERVICE PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class EditServicePage extends BasePage {
  readonly pageTitle: Locator;
  readonly serviceCodeInput: Locator;
  readonly serviceNameInput: Locator;
  readonly versionInput: Locator;
  readonly shortDescriptionInput: Locator;
  readonly statusSelect: Locator;
  readonly categorySelect: Locator;
  readonly saveButton: Locator;
  readonly cancelButton: Locator;
  readonly deleteButton: Locator;
  readonly formNavigation: Locator;
  readonly confirmDialog: Locator;

  constructor(page: Page) {
    super(page);
    this.pageTitle = page.locator('[data-testid="page-title"]');
    this.serviceCodeInput = page.locator('[data-testid="service-code-input"]');
    this.serviceNameInput = page.locator('[data-testid="service-name-input"]');
    this.versionInput = page.locator('[data-testid="version-input"]');
    this.shortDescriptionInput = page.locator('[data-testid="short-description-input"]');
    this.statusSelect = page.locator('[data-testid="status-select"]');
    this.categorySelect = page.locator('[data-testid="category-select"]');
    this.saveButton = page.locator('[data-testid="save-button"]');
    this.cancelButton = page.locator('[data-testid="cancel-button"]');
    this.deleteButton = page.locator('[data-testid="delete-button"]');
    this.formNavigation = page.locator('[data-testid="form-navigation"]');
    this.confirmDialog = page.locator('[data-testid="confirm-dialog"]');
  }

  get url(): string {
    return '/services/:id/edit';
  }

  async gotoService(serviceId: number): Promise<void> {
    await this.page.goto(`/services/${serviceId}/edit`);
    await this.waitForPageLoad();
  }

  async updateName(name: string): Promise<void> {
    await this.serviceNameInput.clear();
    await this.serviceNameInput.fill(name);
  }

  async updateVersion(version: string): Promise<void> {
    await this.versionInput.clear();
    await this.versionInput.fill(version);
  }

  async save(): Promise<void> {
    await this.saveButton.click();
    await this.waitForLoading();
  }

  async deleteService(): Promise<void> {
    await this.deleteButton.click();
    await this.confirmDialog.getByRole('button', { name: 'Confirm' }).click();
    await this.waitForLoading();
  }

  async expectSaveSuccess(): Promise<void> {
    await this.expectNotification('Service updated successfully', 'success');
  }

  async expectDeleteSuccess(): Promise<void> {
    await this.expectNotification('Service deleted successfully', 'success');
    await this.page.waitForURL('**/catalog');
  }
}
