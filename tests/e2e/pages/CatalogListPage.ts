// =============================================================================
// SERVICE CATALOGUE MANAGER - CATALOG LIST PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class CatalogListPage extends BasePage {
  readonly pageTitle: Locator;
  readonly searchInput: Locator;
  readonly filterDropdown: Locator;
  readonly servicesTable: Locator;
  readonly serviceRows: Locator;
  readonly pagination: Locator;
  readonly createButton: Locator;
  readonly emptyState: Locator;
  readonly statusFilter: Locator;
  readonly categoryFilter: Locator;

  constructor(page: Page) {
    super(page);
    this.pageTitle = page.locator('[data-testid="page-title"]');
    this.searchInput = page.locator('[data-testid="search-input"]');
    this.filterDropdown = page.locator('[data-testid="filter-dropdown"]');
    this.servicesTable = page.locator('[data-testid="services-table"]');
    this.serviceRows = page.locator('[data-testid="service-row"]');
    this.pagination = page.locator('[data-testid="pagination"]');
    this.createButton = page.locator('[data-testid="create-service-button"]');
    this.emptyState = page.locator('[data-testid="empty-state"]');
    this.statusFilter = page.locator('[data-testid="status-filter"]');
    this.categoryFilter = page.locator('[data-testid="category-filter"]');
  }

  get url(): string {
    return '/catalog';
  }

  async search(query: string): Promise<void> {
    await this.searchInput.fill(query);
    await this.searchInput.press('Enter');
    await this.waitForLoading();
  }

  async filterByStatus(status: string): Promise<void> {
    await this.statusFilter.click();
    await this.page.getByRole('option', { name: status }).click();
    await this.waitForLoading();
  }

  async filterByCategory(category: string): Promise<void> {
    await this.categoryFilter.click();
    await this.page.getByRole('option', { name: category }).click();
    await this.waitForLoading();
  }

  async getServiceCount(): Promise<number> {
    return this.serviceRows.count();
  }

  async clickService(code: string): Promise<void> {
    await this.serviceRows.filter({ hasText: code }).click();
    await this.waitForPageLoad();
  }

  async clickCreateService(): Promise<void> {
    await this.createButton.click();
    await this.page.waitForURL('**/services/create');
  }

  async goToPage(pageNumber: number): Promise<void> {
    await this.pagination.getByRole('button', { name: String(pageNumber) }).click();
    await this.waitForLoading();
  }

  async expectServiceInList(serviceCode: string): Promise<void> {
    await expect(this.serviceRows.filter({ hasText: serviceCode })).toBeVisible();
  }

  async expectEmptyState(): Promise<void> {
    await expect(this.emptyState).toBeVisible();
  }
}
