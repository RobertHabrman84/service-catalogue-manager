// Auth Bypass Utility for Development
// Automatically injects mock user when VITE_SKIP_AUTH=true

export const getAuthBypassUser = () => {
  const skipAuth = import.meta.env.VITE_SKIP_AUTH === 'true' || 
                   import.meta.env.VITE_DEV_MODE === 'true';
  
  if (skipAuth) {
    return {
      homeAccountId: 'dev-user-1',
      localAccountId: 'dev-user-1',
      username: 'dev@example.com',
      name: 'Development User',
      environment: 'dev',
      tenantId: 'dev-tenant',
      idTokenClaims: {
        name: 'Development User',
        preferred_username: 'dev@example.com',
        roles: ['Admin', 'Developer']
      }
    };
  }
  return null;
};

export const shouldSkipAuth = () => {
  return import.meta.env.VITE_SKIP_AUTH === 'true' || 
         import.meta.env.VITE_DEV_MODE === 'true';
};

// Wrapper pro useMsal hook
export const useMsalWrapper = (originalUseMsal: any) => {
  const result = originalUseMsal();
  const skipAuth = shouldSkipAuth();
  
  if (skipAuth) {
    return {
      ...result,
      accounts: [getAuthBypassUser()],
      inProgress: 'none',
      instance: {
        ...result.instance,
        getAllAccounts: () => [getAuthBypassUser()],
        getActiveAccount: () => getAuthBypassUser()
      }
    };
  }
  
  return result;
};
