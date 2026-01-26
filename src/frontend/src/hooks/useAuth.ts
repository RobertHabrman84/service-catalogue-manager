import { useCallback, useEffect, useState } from 'react';
import { useMsal, useAccount, useIsAuthenticated } from '@azure/msal-react';
import { InteractionStatus, AccountInfo } from '@azure/msal-browser';
import { loginRequest } from '../services/auth/authConfig';

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  roles: string[];
}

export interface UseAuthResult {
  user: AuthUser | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: Error | null;
  login: () => Promise<void>;
  logout: () => Promise<void>;
  getAccessToken: () => Promise<string | null>;
}

export const useAuth = (): UseAuthResult => {
  const { instance, accounts, inProgress } = useMsal();
  const account = useAccount(accounts[0] || null);
  const isAuthenticated = useIsAuthenticated();
  const [user, setUser] = useState<AuthUser | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const isLoading = inProgress !== InteractionStatus.None;

  useEffect(() => {
    if (account) {
      setUser({
        id: account.localAccountId || account.homeAccountId,
        email: account.username,
        name: account.name || account.username,
        roles: (account.idTokenClaims?.roles as string[]) || [],
      });
    } else {
      setUser(null);
    }
  }, [account]);

  const login = useCallback(async () => {
    try {
      setError(null);
      await instance.loginPopup(loginRequest);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Login failed'));
      throw err;
    }
  }, [instance]);

  const logout = useCallback(async () => {
    try {
      setError(null);
      await instance.logoutPopup({
        postLogoutRedirectUri: window.location.origin,
      });
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Logout failed'));
      throw err;
    }
  }, [instance]);

  const getAccessToken = useCallback(async (): Promise<string | null> => {
    if (!account) return null;

    try {
      const response = await instance.acquireTokenSilent({
        ...loginRequest,
        account: account as AccountInfo,
      });
      return response.accessToken;
    } catch (err) {
      // If silent token acquisition fails, try interactive
      try {
        const response = await instance.acquireTokenPopup(loginRequest);
        return response.accessToken;
      } catch (popupErr) {
        setError(popupErr instanceof Error ? popupErr : new Error('Token acquisition failed'));
        return null;
      }
    }
  }, [instance, account]);

  return {
    user,
    isAuthenticated,
    isLoading,
    error,
    login,
    logout,
    getAccessToken,
  };
};

export default useAuth;
