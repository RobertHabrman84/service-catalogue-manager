// =============================================================================
// SERVICE CATALOGUE MANAGER - BASE PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';

export abstract class BasePage {
  readonly page: Page;
  readonly header: Locator;
  readonly sidebar: Locator;
  readonly mainContent: Locator;
  readonly loadingSpinner: Locator;
  readonly notification: Locator;

  constructor(page: Page) {
    this.page = page;
    this.header = page.locator('[data-testid="header"]');
    this.sidebar = page.locator('[data-testid="sidebar"]');
    this.mainContent = page.locator('[data-testid="main-content"]');
    this.loadingSpinner = page.locator('[data-testid="loading-spinner"]');
    this.notification = page.locator('[data-testid="notification"]');
  }

  abstract get url(): string;

  async goto(): Promise<void> {
    await this.page.goto(this.url);
    await this.waitForPageLoad();
  }

  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
    await this.loadingSpinner.waitFor({ state: 'hidden', timeout: 30000 }).catch(() => {});
  }

  async waitForLoading(): Promise<void> {
    await this.loadingSpinner.waitFor({ state: 'visible' }).catch(() => {});
    await this.loadingSpinner.waitFor({ state: 'hidden', timeout: 30000 });
  }

  async getNotificationText(): Promise<string> {
    await this.notification.waitFor({ state: 'visible' });
    return this.notification.textContent() || '';
  }

  async expectNotification(text: string, type?: 'success' | 'error' | 'warning'): Promise<void> {
    await expect(this.notification).toContainText(text);
    if (type) {
      await expect(this.notification).toHaveAttribute('data-type', type);
    }
  }

  async dismissNotification(): Promise<void> {
    await this.notification.locator('[data-testid="close-button"]').click();
    await this.notification.waitFor({ state: 'hidden' });
  }

  async navigateTo(menuItem: string): Promise<void> {
    await this.sidebar.getByRole('link', { name: menuItem }).click();
    await this.waitForPageLoad();
  }

  async isLoggedIn(): Promise<boolean> {
    return this.header.locator('[data-testid="user-menu"]').isVisible();
  }

  async logout(): Promise<void> {
    await this.header.locator('[data-testid="user-menu"]').click();
    await this.page.getByRole('menuitem', { name: 'Logout' }).click();
    await this.page.waitForURL('**/login');
  }

  async takeScreenshot(name: string): Promise<void> {
    await this.page.screenshot({ path: `screenshots/${name}.png`, fullPage: true });
  }
}
