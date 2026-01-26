// =============================================================================
// SERVICE CATALOGUE MANAGER - E2E TEST CONSTANTS
// =============================================================================

export const URLS = {
  BASE: process.env.BASE_URL || 'http://localhost:5173',
  API: process.env.API_URL || 'http://localhost:7071/api',
  LOGIN: '/login',
  DASHBOARD: '/dashboard',
  CATALOG: '/catalog',
  CREATE_SERVICE: '/services/create',
  EXPORT: '/export',
  SETTINGS: '/settings',
};

export const TIMEOUTS = {
  SHORT: 5000,
  MEDIUM: 15000,
  LONG: 30000,
  EXPORT: 60000,
};

export const TEST_USERS = {
  ADMIN: {
    email: process.env.TEST_ADMIN_EMAIL || 'admin@example.com',
    password: process.env.TEST_ADMIN_PASSWORD || 'AdminPassword123!',
  },
  USER: {
    email: process.env.TEST_USER_EMAIL || 'user@example.com',
    password: process.env.TEST_USER_PASSWORD || 'UserPassword123!',
  },
  VIEWER: {
    email: process.env.TEST_VIEWER_EMAIL || 'viewer@example.com',
    password: process.env.TEST_VIEWER_PASSWORD || 'ViewerPassword123!',
  },
};

export const SERVICE_STATUSES = {
  DRAFT: 'Draft',
  ACTIVE: 'Active',
  DEPRECATED: 'Deprecated',
  ARCHIVED: 'Archived',
};

export const SERVICE_CATEGORIES = {
  APPLICATION: 'Application',
  INFRASTRUCTURE: 'Infrastructure',
  DATA: 'Data',
  SECURITY: 'Security',
  INTEGRATION: 'Integration',
};

export const VALIDATION_MESSAGES = {
  REQUIRED: 'This field is required',
  INVALID_EMAIL: 'Please enter a valid email address',
  CODE_TOO_SHORT: 'Service code must be at least 3 characters',
  CODE_TOO_LONG: 'Service code must not exceed 50 characters',
  DUPLICATE_CODE: 'A service with this code already exists',
};

export const API_ENDPOINTS = {
  SERVICES: '/services',
  LOOKUPS: '/lookups',
  EXPORT: '/export',
  HEALTH: '/health',
};

export const SELECTORS = {
  LOADING: '[data-testid="loading-spinner"]',
  NOTIFICATION: '[data-testid="notification"]',
  ERROR: '[data-testid="error-message"]',
};
