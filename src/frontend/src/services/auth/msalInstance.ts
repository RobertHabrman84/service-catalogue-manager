import { PublicClientApplication, LogLevel } from '@azure/msal-browser';
import type { Configuration, PopupRequest } from '@azure/msal-browser';

// ========================================
// 🔥 DEV MODE BYPASS - Vypne MSAL v dev módu
// ========================================

const isDevelopment = import.meta.env.MODE === 'development';
const skipAuth = import.meta.env.VITE_SKIP_AUTH === 'true' || 
                 import.meta.env.VITE_DEV_MODE === 'true';

// MSAL Configuration
const msalConfig: Configuration = (isDevelopment && skipAuth) ? {
  auth: {
    clientId: 'dev-bypass-client-id',
    authority: 'https://login.microsoftonline.com/common',
    redirectUri: window.location.origin,
  },
  cache: {
    cacheLocation: 'sessionStorage',
    storeAuthStateInCookie: false,
  },
  system: {
    loggerOptions: {
      logLevel: LogLevel.Warning,
      loggerCallback: () => {}, // Suppress all logs
    },
  },
} : {
  auth: {
    clientId: import.meta.env.VITE_AZURE_AD_CLIENT_ID || '',
    authority: `https://login.microsoftonline.com/${import.meta.env.VITE_AZURE_AD_TENANT_ID || 'common'}`,
    redirectUri: import.meta.env.VITE_AZURE_AD_REDIRECT_URI || window.location.origin,
  },
  cache: {
    cacheLocation: 'sessionStorage',
    storeAuthStateInCookie: false,
  },
  system: {
    loggerOptions: {
      logLevel: LogLevel.Info,
      loggerCallback: (level: LogLevel, message: string, containsPii: boolean) => {
        if (containsPii) return;
        
        switch (level) {
          case LogLevel.Error:
            console.error(message);
            break;
          case LogLevel.Info:
            console.info(message);
            break;
          case LogLevel.Verbose:
            console.debug(message);
            break;
          case LogLevel.Warning:
            console.warn(message);
            break;
        }
      },
    },
  },
};

// Login Request Configuration
export const loginRequest: PopupRequest = {
  scopes: ['User.Read'],
};

// API Request Configuration
export const apiRequest = {
  scopes: ['api://your-api-client-id/access_as_user'],
};

// Graph API Request Configuration
export const graphConfig = {
  graphMeEndpoint: 'https://graph.microsoft.com/v1.0/me',
};

// Log bypass status
if (isDevelopment && skipAuth) {
  console.log('🔥 MSAL INSTANCE: Bypassed - using mock config');
} else {
  console.log('🔒 MSAL INSTANCE: Active - using real Azure AD');
}

// Create MSAL instance
export const msalInstance = new PublicClientApplication(msalConfig);

// Initialize MSAL only if not in bypass mode
if (isDevelopment && skipAuth) {
  console.log('✅ MSAL Instance created but will NOT be initialized (dev bypass)');
} else {
  msalInstance.initialize().catch((error) => {
    console.error('Failed to initialize MSAL:', error);
  });
}
