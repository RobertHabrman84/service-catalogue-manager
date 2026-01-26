// =============================================================================
// SERVICE CATALOGUE MANAGER - AUTH FIXTURE
// =============================================================================

import { test as base, Page } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

type AuthFixture = {
  authenticatedPage: Page;
  loginPage: LoginPage;
};

export const test = base.extend<AuthFixture>({
  authenticatedPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(
      process.env.TEST_USER || 'test@example.com',
      process.env.TEST_PASSWORD || 'TestPassword123!'
    );
    await page.waitForURL('**/dashboard');
    await use(page);
  },
  
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },
});

export const expect = base.expect;

// Storage state for authenticated sessions
export const STORAGE_STATE = 'playwright/.auth/user.json';

// Setup authentication once
export async function globalSetup(page: Page): Promise<void> {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login(
    process.env.TEST_USER || 'test@example.com',
    process.env.TEST_PASSWORD || 'TestPassword123!'
  );
  await page.waitForURL('**/dashboard');
  await page.context().storageState({ path: STORAGE_STATE });
}
