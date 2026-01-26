import { 
  AccountInfo, 
  AuthenticationResult, 
  InteractionRequiredAuthError,
  PopupRequest,
  SilentRequest,
} from '@azure/msal-browser';
import { msalInstance } from './msalInstance';
import { loginRequest, apiScopes, APP_ROLES, AppRole } from './authConfig';

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  username: string;
  roles: AppRole[];
  tenantId: string;
}

export interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  user: AuthUser | null;
  error: string | null;
}

class AuthService {
  private cachedUser: AuthUser | null = null;

  /**
   * Get current account
   */
  getAccount(): AccountInfo | null {
    const accounts = msalInstance.getAllAccounts();
    return accounts.length > 0 ? accounts[0] : null;
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated(): boolean {
    return this.getAccount() !== null;
  }

  /**
   * Get current user info
   */
  getUser(): AuthUser | null {
    if (this.cachedUser) {
      return this.cachedUser;
    }

    const account = this.getAccount();
    if (!account) {
      return null;
    }

    this.cachedUser = this.mapAccountToUser(account);
    return this.cachedUser;
  }

  /**
   * Alias for getUser() for backward compatibility
   */
  getCurrentUser(): AuthUser | null {
    return this.getUser();
  }

  /**
   * Logout - alias for logoutPopup
   */
  async logout(): Promise<void> {
    return this.logoutPopup();
  }

  /**
   * Map MSAL account to AuthUser
   */
  private mapAccountToUser(account: AccountInfo): AuthUser {
    const idTokenClaims = account.idTokenClaims as Record<string, unknown> | undefined;
    const roles = (idTokenClaims?.roles as string[] | undefined) || [];

    return {
      id: account.localAccountId,
      email: account.username,
      name: account.name || account.username,
      username: account.username,
      roles: roles as AppRole[],
      tenantId: account.tenantId,
    };
  }

  /**
   * Login with popup
   */
  async loginPopup(request?: PopupRequest): Promise<AuthUser> {
    try {
      const response = await msalInstance.loginPopup(request || loginRequest);
      this.cachedUser = this.mapAccountToUser(response.account);
      return this.cachedUser;
    } catch (error) {
      console.error('Login popup failed:', error);
      throw error;
    }
  }

  /**
   * Login with redirect
   */
  async loginRedirect(request?: PopupRequest): Promise<void> {
    try {
      await msalInstance.loginRedirect(request || loginRequest);
    } catch (error) {
      console.error('Login redirect failed:', error);
      throw error;
    }
  }

  /**
   * Logout with popup
   */
  async logoutPopup(): Promise<void> {
    try {
      this.cachedUser = null;
      await msalInstance.logoutPopup({
        mainWindowRedirectUri: '/',
      });
    } catch (error) {
      console.error('Logout popup failed:', error);
      throw error;
    }
  }

  /**
   * Logout with redirect
   */
  async logoutRedirect(): Promise<void> {
    try {
      this.cachedUser = null;
      await msalInstance.logoutRedirect();
    } catch (error) {
      console.error('Logout redirect failed:', error);
      throw error;
    }
  }

  /**
   * Acquire token silently
   */
  async acquireTokenSilent(scopes?: string[]): Promise<AuthenticationResult | null> {
    const account = this.getAccount();
    if (!account) {
      return null;
    }

    const request: SilentRequest = {
      account,
      scopes: scopes || apiScopes.default,
    };

    try {
      return await msalInstance.acquireTokenSilent(request);
    } catch (error) {
      if (error instanceof InteractionRequiredAuthError) {
        // Fallback to popup
        return this.acquireTokenPopup(scopes);
      }
      throw error;
    }
  }

  /**
   * Acquire token with popup
   */
  async acquireTokenPopup(scopes?: string[]): Promise<AuthenticationResult> {
    const request: PopupRequest = {
      scopes: scopes || apiScopes.default,
    };

    return msalInstance.acquireTokenPopup(request);
  }

  /**
   * Get access token
   */
  async getAccessToken(scopes?: string[]): Promise<string | null> {
    try {
      const response = await this.acquireTokenSilent(scopes);
      return response?.accessToken || null;
    } catch (error) {
      console.error('Failed to get access token:', error);
      return null;
    }
  }

  /**
   * Check if user has a specific role
   */
  hasRole(role: AppRole): boolean {
    const user = this.getUser();
    return user?.roles.includes(role) || false;
  }

  /**
   * Check if user has any of the specified roles
   */
  hasAnyRole(roles: AppRole[]): boolean {
    const user = this.getUser();
    return roles.some(role => user?.roles.includes(role));
  }

  /**
   * Check if user can edit services
   */
  canEdit(): boolean {
    return this.hasAnyRole([APP_ROLES.ADMIN, APP_ROLES.EDITOR]);
  }

  /**
   * Check if user is admin
   */
  isAdmin(): boolean {
    return this.hasRole(APP_ROLES.ADMIN);
  }

  /**
   * Handle redirect callback
   */
  async handleRedirectPromise(): Promise<AuthenticationResult | null> {
    try {
      const response = await msalInstance.handleRedirectPromise();
      if (response?.account) {
        this.cachedUser = this.mapAccountToUser(response.account);
      }
      return response;
    } catch (error) {
      console.error('Handle redirect failed:', error);
      throw error;
    }
  }

  /**
   * Clear cached user
   */
  clearCache(): void {
    this.cachedUser = null;
  }
}

export const authService = new AuthService();
export default authService;
