// =============================================================================
// SERVICE CATALOGUE MANAGER - E2E TEST HELPERS
// =============================================================================

import { Page, Download } from '@playwright/test';

export async function waitForDownload(page: Page, action: () => Promise<void>): Promise<Download> {
  const [download] = await Promise.all([
    page.waitForEvent('download'),
    action(),
  ]);
  return download;
}

export async function saveDownload(download: Download, path: string): Promise<void> {
  await download.saveAs(path);
}

export function generateUniqueCode(prefix: string = 'E2E'): string {
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substring(2, 6);
  return `${prefix}-${timestamp}${random}`.substring(0, 15).toUpperCase();
}

export function generateUniqueEmail(): string {
  return `test.${Date.now()}@example.com`;
}

export async function retryAction<T>(
  action: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> {
  let lastError: Error | undefined;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await action();
    } catch (error) {
      lastError = error as Error;
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError;
}

export async function clearLocalStorage(page: Page): Promise<void> {
  await page.evaluate(() => localStorage.clear());
}

export async function clearSessionStorage(page: Page): Promise<void> {
  await page.evaluate(() => sessionStorage.clear());
}

export async function mockApiResponse(
  page: Page,
  url: string,
  response: object,
  status: number = 200
): Promise<void> {
  await page.route(url, (route) => {
    route.fulfill({
      status,
      contentType: 'application/json',
      body: JSON.stringify(response),
    });
  });
}

export async function interceptApiCall(
  page: Page,
  urlPattern: string
): Promise<{ request: any; response: any }[]> {
  const calls: { request: any; response: any }[] = [];
  
  await page.route(urlPattern, async (route) => {
    const request = route.request();
    const response = await route.fetch();
    const body = await response.json().catch(() => null);
    
    calls.push({
      request: {
        url: request.url(),
        method: request.method(),
        body: request.postDataJSON(),
      },
      response: {
        status: response.status(),
        body,
      },
    });
    
    await route.fulfill({ response });
  });
  
  return calls;
}

export function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}
