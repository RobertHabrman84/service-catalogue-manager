// =============================================================================
// SERVICE CATALOGUE MANAGER - EXPORT PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class ExportPage extends BasePage {
  readonly pageTitle: Locator;
  readonly serviceSelect: Locator;
  readonly formatSelect: Locator;
  readonly exportButton: Locator;
  readonly exportAllButton: Locator;
  readonly downloadLink: Locator;
  readonly exportHistory: Locator;
  readonly progressBar: Locator;

  constructor(page: Page) {
    super(page);
    this.pageTitle = page.locator('[data-testid="page-title"]');
    this.serviceSelect = page.locator('[data-testid="service-select"]');
    this.formatSelect = page.locator('[data-testid="format-select"]');
    this.exportButton = page.locator('[data-testid="export-button"]');
    this.exportAllButton = page.locator('[data-testid="export-all-button"]');
    this.downloadLink = page.locator('[data-testid="download-link"]');
    this.exportHistory = page.locator('[data-testid="export-history"]');
    this.progressBar = page.locator('[data-testid="progress-bar"]');
  }

  get url(): string {
    return '/export';
  }

  async selectService(serviceName: string): Promise<void> {
    await this.serviceSelect.click();
    await this.page.getByRole('option', { name: serviceName }).click();
  }

  async selectFormat(format: 'pdf' | 'markdown'): Promise<void> {
    await this.formatSelect.selectOption(format);
  }

  async exportService(): Promise<void> {
    await this.exportButton.click();
    await this.progressBar.waitFor({ state: 'visible' });
    await this.progressBar.waitFor({ state: 'hidden', timeout: 60000 });
  }

  async exportAllServices(): Promise<void> {
    await this.exportAllButton.click();
    await this.progressBar.waitFor({ state: 'visible' });
    await this.progressBar.waitFor({ state: 'hidden', timeout: 120000 });
  }

  async expectDownloadAvailable(): Promise<void> {
    await expect(this.downloadLink).toBeVisible();
  }

  async getExportHistoryCount(): Promise<number> {
    return this.exportHistory.locator('tr').count();
  }
}
