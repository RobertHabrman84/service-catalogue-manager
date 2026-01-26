import { Configuration, LogLevel, PopupRequest, RedirectRequest } from '@azure/msal-browser';

// MSAL configuration
export const msalConfig: Configuration = {
  auth: {
    clientId: import.meta.env.VITE_AZURE_AD_CLIENT_ID || '',
    authority: `https://login.microsoftonline.com/${import.meta.env.VITE_AZURE_AD_TENANT_ID || 'common'}`,
    redirectUri: import.meta.env.VITE_AZURE_AD_REDIRECT_URI || window.location.origin,
    postLogoutRedirectUri: import.meta.env.VITE_AZURE_AD_POST_LOGOUT_URI || window.location.origin,
    navigateToLoginRequestUrl: true,
  },
  cache: {
    cacheLocation: 'sessionStorage',
    storeAuthStateInCookie: false,
  },
  system: {
    loggerOptions: {
      loggerCallback: (level: LogLevel, message: string, containsPii: boolean) => {
        if (containsPii) {
          return;
        }
        switch (level) {
          case LogLevel.Error:
            console.error(message);
            break;
          case LogLevel.Warning:
            console.warn(message);
            break;
          case LogLevel.Info:
            console.info(message);
            break;
          case LogLevel.Verbose:
            console.debug(message);
            break;
          default:
            break;
        }
      },
      logLevel: import.meta.env.DEV ? LogLevel.Warning : LogLevel.Error,
      piiLoggingEnabled: false,
    },
    allowNativeBroker: false,
  },
};

// Scopes for API access
export const apiScopes = {
  default: [`api://${import.meta.env.VITE_AZURE_AD_CLIENT_ID}/access_as_user`],
  read: [`api://${import.meta.env.VITE_AZURE_AD_CLIENT_ID}/Services.Read`],
  write: [`api://${import.meta.env.VITE_AZURE_AD_CLIENT_ID}/Services.Write`],
  admin: [`api://${import.meta.env.VITE_AZURE_AD_CLIENT_ID}/Services.Admin`],
};

// Login request configuration
export const loginRequest: PopupRequest = {
  scopes: ['openid', 'profile', 'email', ...apiScopes.default],
};

// Silent token request
export const silentRequest: RedirectRequest = {
  scopes: apiScopes.default,
};

// Graph API scopes (if needed)
export const graphScopes = {
  user: ['User.Read'],
  profile: ['User.Read', 'User.ReadBasic.All'],
};

// App roles
export const APP_ROLES = {
  ADMIN: 'ServiceCatalog.Admin',
  EDITOR: 'ServiceCatalog.Editor',
  VIEWER: 'ServiceCatalog.Viewer',
} as const;

export type AppRole = typeof APP_ROLES[keyof typeof APP_ROLES];

// Permission helpers
export const hasRole = (roles: string[], requiredRole: AppRole): boolean => {
  return roles.includes(requiredRole);
};

export const hasAnyRole = (roles: string[], requiredRoles: AppRole[]): boolean => {
  return requiredRoles.some(role => roles.includes(role));
};

export const hasAllRoles = (roles: string[], requiredRoles: AppRole[]): boolean => {
  return requiredRoles.every(role => roles.includes(role));
};

export const canEdit = (roles: string[]): boolean => {
  return hasAnyRole(roles, [APP_ROLES.ADMIN, APP_ROLES.EDITOR]);
};

export const canAdmin = (roles: string[]): boolean => {
  return hasRole(roles, APP_ROLES.ADMIN);
};

export default msalConfig;
