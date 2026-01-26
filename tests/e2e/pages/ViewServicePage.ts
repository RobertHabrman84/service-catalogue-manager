// =============================================================================
// SERVICE CATALOGUE MANAGER - VIEW SERVICE PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class ViewServicePage extends BasePage {
  readonly pageTitle: Locator;
  readonly serviceCode: Locator;
  readonly serviceName: Locator;
  readonly statusBadge: Locator;
  readonly categoryBadge: Locator;
  readonly description: Locator;
  readonly editButton: Locator;
  readonly exportPdfButton: Locator;
  readonly exportMarkdownButton: Locator;
  readonly publishButton: Locator;
  readonly tabs: Locator;
  readonly usageScenariosSection: Locator;
  readonly dependenciesSection: Locator;

  constructor(page: Page) {
    super(page);
    this.pageTitle = page.locator('[data-testid="page-title"]');
    this.serviceCode = page.locator('[data-testid="service-code"]');
    this.serviceName = page.locator('[data-testid="service-name"]');
    this.statusBadge = page.locator('[data-testid="status-badge"]');
    this.categoryBadge = page.locator('[data-testid="category-badge"]');
    this.description = page.locator('[data-testid="description"]');
    this.editButton = page.locator('[data-testid="edit-button"]');
    this.exportPdfButton = page.locator('[data-testid="export-pdf-button"]');
    this.exportMarkdownButton = page.locator('[data-testid="export-markdown-button"]');
    this.publishButton = page.locator('[data-testid="publish-button"]');
    this.tabs = page.locator('[data-testid="service-tabs"]');
    this.usageScenariosSection = page.locator('[data-testid="usage-scenarios"]');
    this.dependenciesSection = page.locator('[data-testid="dependencies"]');
  }

  get url(): string {
    return '/services/:id';
  }

  async gotoService(serviceId: number): Promise<void> {
    await this.page.goto(`/services/${serviceId}`);
    await this.waitForPageLoad();
  }

  async clickEdit(): Promise<void> {
    await this.editButton.click();
    await this.page.waitForURL('**/edit');
  }

  async clickExportPdf(): Promise<void> {
    await this.exportPdfButton.click();
  }

  async clickExportMarkdown(): Promise<void> {
    await this.exportMarkdownButton.click();
  }

  async clickPublish(): Promise<void> {
    await this.publishButton.click();
  }

  async selectTab(tabName: string): Promise<void> {
    await this.tabs.getByRole('tab', { name: tabName }).click();
  }

  async expectServiceDetails(code: string, name: string): Promise<void> {
    await expect(this.serviceCode).toHaveText(code);
    await expect(this.serviceName).toHaveText(name);
  }

  async expectStatus(status: string): Promise<void> {
    await expect(this.statusBadge).toHaveText(status);
  }
}
