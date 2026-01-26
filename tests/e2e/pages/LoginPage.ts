// =============================================================================
// SERVICE CATALOGUE MANAGER - LOGIN PAGE OBJECT
// =============================================================================

import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class LoginPage extends BasePage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly microsoftLoginButton: Locator;
  readonly errorMessage: Locator;
  readonly rememberMeCheckbox: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.locator('[data-testid="email-input"]');
    this.passwordInput = page.locator('[data-testid="password-input"]');
    this.loginButton = page.locator('[data-testid="login-button"]');
    this.microsoftLoginButton = page.locator('[data-testid="microsoft-login-button"]');
    this.errorMessage = page.locator('[data-testid="error-message"]');
    this.rememberMeCheckbox = page.locator('[data-testid="remember-me"]');
  }

  get url(): string {
    return '/login';
  }

  async login(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
    await this.waitForPageLoad();
  }

  async loginWithMicrosoft(): Promise<void> {
    await this.microsoftLoginButton.click();
  }

  async expectLoginError(message: string): Promise<void> {
    await expect(this.errorMessage).toBeVisible();
    await expect(this.errorMessage).toContainText(message);
  }

  async expectLoginSuccess(): Promise<void> {
    await this.page.waitForURL('**/dashboard');
  }

  async toggleRememberMe(): Promise<void> {
    await this.rememberMeCheckbox.click();
  }
}
