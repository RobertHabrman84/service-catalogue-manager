import { AuthenticationResult } from '@azure/msal-browser';
import { authService } from './authService';
import { apiScopes } from './authConfig';

export interface TokenInfo {
  accessToken: string;
  expiresOn: Date;
  scopes: string[];
  isExpired: boolean;
  expiresInMinutes: number;
}

class TokenService {
  private tokenCache: Map<string, AuthenticationResult> = new Map();
  private refreshTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();

  /**
   * Get token for specific scopes
   */
  async getToken(scopes: string[] = apiScopes.default): Promise<string | null> {
    const cacheKey = scopes.sort().join(',');
    const cached = this.tokenCache.get(cacheKey);

    if (cached && !this.isTokenExpired(cached)) {
      return cached.accessToken;
    }

    try {
      const result = await authService.acquireTokenSilent(scopes);
      if (result) {
        this.tokenCache.set(cacheKey, result);
        this.scheduleRefresh(cacheKey, result, scopes);
        return result.accessToken;
      }
      return null;
    } catch (error) {
      console.error('Failed to acquire token:', error);
      return null;
    }
  }

  /**
   * Get token info
   */
  async getTokenInfo(scopes: string[] = apiScopes.default): Promise<TokenInfo | null> {
    const token = await this.getToken(scopes);
    if (!token) {
      return null;
    }

    const cacheKey = scopes.sort().join(',');
    const cached = this.tokenCache.get(cacheKey);

    if (!cached) {
      return null;
    }

    const expiresOn = cached.expiresOn || new Date();
    const now = new Date();
    const expiresInMs = expiresOn.getTime() - now.getTime();

    return {
      accessToken: cached.accessToken,
      expiresOn,
      scopes: cached.scopes,
      isExpired: expiresInMs <= 0,
      expiresInMinutes: Math.max(0, Math.floor(expiresInMs / 60000)),
    };
  }

  /**
   * Check if token is expired or about to expire
   */
  private isTokenExpired(result: AuthenticationResult, bufferMinutes: number = 5): boolean {
    if (!result.expiresOn) {
      return true;
    }

    const expirationTime = result.expiresOn.getTime();
    const currentTime = Date.now();
    const bufferMs = bufferMinutes * 60 * 1000;

    return currentTime >= expirationTime - bufferMs;
  }

  /**
   * Schedule token refresh before expiration
   */
  private scheduleRefresh(
    cacheKey: string,
    result: AuthenticationResult,
    scopes: string[]
  ): void {
    // Clear existing timer
    const existingTimer = this.refreshTimers.get(cacheKey);
    if (existingTimer) {
      clearTimeout(existingTimer);
    }

    if (!result.expiresOn) {
      return;
    }

    // Schedule refresh 5 minutes before expiration
    const expirationTime = result.expiresOn.getTime();
    const refreshTime = expirationTime - Date.now() - 5 * 60 * 1000;

    if (refreshTime > 0) {
      const timer = setTimeout(async () => {
        try {
          const newResult = await authService.acquireTokenSilent(scopes);
          if (newResult) {
            this.tokenCache.set(cacheKey, newResult);
            this.scheduleRefresh(cacheKey, newResult, scopes);
          }
        } catch (error) {
          console.warn('Token refresh failed:', error);
          this.tokenCache.delete(cacheKey);
        }
      }, refreshTime);

      this.refreshTimers.set(cacheKey, timer);
    }
  }

  /**
   * Force refresh token
   */
  async refreshToken(scopes: string[] = apiScopes.default): Promise<string | null> {
    const cacheKey = scopes.sort().join(',');
    this.tokenCache.delete(cacheKey);
    return this.getToken(scopes);
  }

  /**
   * Clear all cached tokens
   */
  clearCache(): void {
    this.tokenCache.clear();
    this.refreshTimers.forEach(timer => clearTimeout(timer));
    this.refreshTimers.clear();
  }

  /**
   * Get authorization header
   */
  async getAuthHeader(scopes: string[] = apiScopes.default): Promise<Record<string, string>> {
    const token = await this.getToken(scopes);
    if (token) {
      return { Authorization: `Bearer ${token}` };
    }
    return {};
  }

  /**
   * Decode JWT token (for debugging)
   */
  decodeToken(token: string): Record<string, unknown> | null {
    try {
      const parts = token.split('.');
      if (parts.length !== 3) {
        return null;
      }

      const payload = parts[1];
      const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
      return JSON.parse(decoded);
    } catch (error) {
      console.error('Failed to decode token:', error);
      return null;
    }
  }
}

export const tokenService = new TokenService();
export default tokenService;
