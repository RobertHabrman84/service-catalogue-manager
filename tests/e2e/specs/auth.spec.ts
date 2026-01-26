// =============================================================================
// SERVICE CATALOGUE MANAGER - AUTH E2E TESTS
// =============================================================================

import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { TEST_USERS, URLS } from '../utils/constants';

test.describe('Authentication', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('should display login page', async () => {
    await expect(loginPage.emailInput).toBeVisible();
    await expect(loginPage.passwordInput).toBeVisible();
    await expect(loginPage.loginButton).toBeVisible();
  });

  test('should login with valid credentials', async ({ page }) => {
    await loginPage.login(TEST_USERS.USER.email, TEST_USERS.USER.password);
    await expect(page).toHaveURL(/dashboard/);
  });

  test('should show error with invalid credentials', async () => {
    await loginPage.login('invalid@example.com', 'wrongpassword');
    await loginPage.expectLoginError('Invalid email or password');
  });

  test('should show error with empty email', async () => {
    await loginPage.passwordInput.fill('password');
    await loginPage.loginButton.click();
    await loginPage.expectValidationError('email', 'required');
  });

  test('should show error with empty password', async () => {
    await loginPage.emailInput.fill('test@example.com');
    await loginPage.loginButton.click();
    await loginPage.expectValidationError('password', 'required');
  });

  test('should redirect to dashboard after login', async ({ page }) => {
    await loginPage.login(TEST_USERS.USER.email, TEST_USERS.USER.password);
    await page.waitForURL('**/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
  });

  test('should logout successfully', async ({ page }) => {
    await loginPage.login(TEST_USERS.USER.email, TEST_USERS.USER.password);
    await page.waitForURL('**/dashboard');
    await loginPage.logout();
    await expect(page).toHaveURL(/login/);
  });

  test('should persist session with remember me', async ({ page }) => {
    await loginPage.toggleRememberMe();
    await loginPage.login(TEST_USERS.USER.email, TEST_USERS.USER.password);
    await page.waitForURL('**/dashboard');
    // Verify session token is stored
    const cookies = await page.context().cookies();
    expect(cookies.some(c => c.name.includes('session'))).toBeTruthy();
  });
});
