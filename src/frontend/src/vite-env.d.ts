/// <reference types="vite/client" />

interface ImportMetaEnv {
  // API Configuration
  readonly VITE_API_BASE_URL: string;
  readonly VITE_API_TIMEOUT: string;

  // Azure AD Authentication
  readonly VITE_AZURE_AD_CLIENT_ID: string;
  readonly VITE_AZURE_AD_TENANT_ID: string;
  readonly VITE_AZURE_AD_REDIRECT_URI: string;
  readonly VITE_AZURE_AD_POST_LOGOUT_URI: string;
  readonly VITE_AZURE_AD_SCOPE: string;

  // Feature Flags
  readonly VITE_FEATURE_EXPORT_PDF: string;
  readonly VITE_FEATURE_EXPORT_MARKDOWN: string;
  readonly VITE_FEATURE_UUBOOKKIT: string;
  readonly VITE_FEATURE_DARK_MODE: string;

  // Application Settings
  readonly VITE_APP_NAME: string;
  readonly VITE_APP_VERSION: string;

  // Logging
  readonly VITE_LOG_LEVEL: string;
  readonly VITE_ENABLE_ANALYTICS: string;

  // UuBookKit Integration
  readonly VITE_UUBOOKKIT_BASE_URL: string;
  readonly VITE_UUBOOKKIT_BOOK_URI: string;

  // Development
  readonly DEV: boolean;
  readonly PROD: boolean;
  readonly MODE: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

// Global type augmentations
declare global {
  interface Window {
    __REDUX_DEVTOOLS_EXTENSION__?: () => unknown;
  }
}

export {};
