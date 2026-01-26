// =============================================================================
// SERVICE CATALOGUE MANAGER - CREATE SERVICE PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class CreateServicePage extends BasePage {
  readonly pageTitle: Locator;
  readonly serviceCodeInput: Locator;
  readonly serviceNameInput: Locator;
  readonly shortDescriptionInput: Locator;
  readonly longDescriptionInput: Locator;
  readonly statusSelect: Locator;
  readonly categorySelect: Locator;
  readonly ownerEmailInput: Locator;
  readonly saveButton: Locator;
  readonly cancelButton: Locator;
  readonly formNavigation: Locator;
  readonly validationErrors: Locator;

  constructor(page: Page) {
    super(page);
    this.pageTitle = page.locator('[data-testid="page-title"]');
    this.serviceCodeInput = page.locator('[data-testid="service-code-input"]');
    this.serviceNameInput = page.locator('[data-testid="service-name-input"]');
    this.shortDescriptionInput = page.locator('[data-testid="short-description-input"]');
    this.longDescriptionInput = page.locator('[data-testid="long-description-input"]');
    this.statusSelect = page.locator('[data-testid="status-select"]');
    this.categorySelect = page.locator('[data-testid="category-select"]');
    this.ownerEmailInput = page.locator('[data-testid="owner-email-input"]');
    this.saveButton = page.locator('[data-testid="save-button"]');
    this.cancelButton = page.locator('[data-testid="cancel-button"]');
    this.formNavigation = page.locator('[data-testid="form-navigation"]');
    this.validationErrors = page.locator('[data-testid="validation-error"]');
  }

  get url(): string {
    return '/services/create';
  }

  async fillBasicInfo(data: {
    code: string;
    name: string;
    shortDescription?: string;
    status?: string;
    category?: string;
  }): Promise<void> {
    await this.serviceCodeInput.fill(data.code);
    await this.serviceNameInput.fill(data.name);
    if (data.shortDescription) {
      await this.shortDescriptionInput.fill(data.shortDescription);
    }
    if (data.status) {
      await this.statusSelect.selectOption(data.status);
    }
    if (data.category) {
      await this.categorySelect.selectOption(data.category);
    }
  }

  async navigateToSection(sectionName: string): Promise<void> {
    await this.formNavigation.getByRole('button', { name: sectionName }).click();
  }

  async save(): Promise<void> {
    await this.saveButton.click();
    await this.waitForLoading();
  }

  async cancel(): Promise<void> {
    await this.cancelButton.click();
  }

  async expectValidationError(field: string, message: string): Promise<void> {
    const fieldError = this.page.locator(`[data-testid="${field}-error"]`);
    await expect(fieldError).toContainText(message);
  }

  async expectSaveSuccess(): Promise<void> {
    await this.expectNotification('Service created successfully', 'success');
  }
}
