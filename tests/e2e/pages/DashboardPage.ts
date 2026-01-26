// =============================================================================
// SERVICE CATALOGUE MANAGER - DASHBOARD PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class DashboardPage extends BasePage {
  readonly welcomeMessage: Locator;
  readonly statsCards: Locator;
  readonly totalServicesCard: Locator;
  readonly activeServicesCard: Locator;
  readonly recentServicesTable: Locator;
  readonly quickActions: Locator;
  readonly createServiceButton: Locator;
  readonly searchInput: Locator;

  constructor(page: Page) {
    super(page);
    this.welcomeMessage = page.locator('[data-testid="welcome-message"]');
    this.statsCards = page.locator('[data-testid="stats-cards"]');
    this.totalServicesCard = page.locator('[data-testid="total-services-card"]');
    this.activeServicesCard = page.locator('[data-testid="active-services-card"]');
    this.recentServicesTable = page.locator('[data-testid="recent-services-table"]');
    this.quickActions = page.locator('[data-testid="quick-actions"]');
    this.createServiceButton = page.locator('[data-testid="create-service-button"]');
    this.searchInput = page.locator('[data-testid="search-input"]');
  }

  get url(): string {
    return '/dashboard';
  }

  async getTotalServicesCount(): Promise<number> {
    const text = await this.totalServicesCard.locator('.count').textContent();
    return parseInt(text || '0', 10);
  }

  async getActiveServicesCount(): Promise<number> {
    const text = await this.activeServicesCard.locator('.count').textContent();
    return parseInt(text || '0', 10);
  }

  async clickCreateService(): Promise<void> {
    await this.createServiceButton.click();
    await this.page.waitForURL('**/services/create');
  }

  async searchServices(query: string): Promise<void> {
    await this.searchInput.fill(query);
    await this.searchInput.press('Enter');
    await this.waitForLoading();
  }

  async clickRecentService(index: number = 0): Promise<void> {
    await this.recentServicesTable.locator('tbody tr').nth(index).click();
  }

  async expectWelcomeMessage(userName: string): Promise<void> {
    await expect(this.welcomeMessage).toContainText(userName);
  }
}
