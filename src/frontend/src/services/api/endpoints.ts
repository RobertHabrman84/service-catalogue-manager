// API Endpoints Configuration
// Centralized definition of all API endpoints

export const API_VERSION = 'v1';

export const ENDPOINTS = {
  // Service Catalog endpoints
  services: {
    list: '/services',
    getById: (id: number) => `/services/${id}`,
    create: '/services',
    update: (id: number) => `/services/${id}`,
    delete: (id: number) => `/services/${id}`,
    search: '/services/search',
    duplicate: (id: number) => `/services/${id}/duplicate`,
    validate: '/services/validate',
    bulk: {
      delete: '/services/bulk/delete',
      export: '/services/bulk/export',
      archive: '/services/bulk/archive',
    },
  },

  // Lookup data endpoints
  lookups: {
    categories: '/lookups/categories',
    subcategories: (categoryId: number) => `/lookups/categories/${categoryId}/subcategories`,
    sizeOptions: '/lookups/size-options',
    cloudProviders: '/lookups/cloud-providers',
    dependencyTypes: '/lookups/dependency-types',
    requirementLevels: '/lookups/requirement-levels',
    scopeTypes: '/lookups/scope-types',
    interactionLevels: '/lookups/interaction-levels',
    roles: '/lookups/roles',
    effortCategories: '/lookups/effort-categories',
    all: '/lookups/all',
  },

  // Export endpoints
  export: {
    pdf: '/export/pdf',
    pdfStatus: (operationId: string) => `/export/pdf/status/${operationId}`,
    pdfDownload: (operationId: string) => `/export/pdf/download/${operationId}`,
    markdown: '/export/markdown',
    markdownStatus: (operationId: string) => `/export/markdown/status/${operationId}`,
    markdownDownload: (operationId: string) => `/export/markdown/download/${operationId}`,
    history: '/export/history',
    cancel: (operationId: string) => `/export/cancel/${operationId}`,
  },

  // UuBookKit endpoints
  uuBookKit: {
    publish: '/uubookkit/publish',
    publishStatus: (operationId: string) => `/uubookkit/publish/status/${operationId}`,
    sync: '/uubookkit/sync',
    syncStatus: '/uubookkit/sync/status',
    history: '/uubookkit/history',
    config: '/uubookkit/config',
    validate: '/uubookkit/validate',
  },

  // Health endpoints
  health: {
    status: '/health',
    detailed: '/health/detailed',
    ready: '/health/ready',
    live: '/health/live',
  },

  // User/Auth endpoints (if needed beyond MSAL)
  user: {
    profile: '/user/profile',
    preferences: '/user/preferences',
    updatePreferences: '/user/preferences',
  },

  // Dashboard/Statistics endpoints
  dashboard: {
    stats: '/dashboard/stats',
    recentServices: '/dashboard/recent-services',
    activityLog: '/dashboard/activity',
  },
} as const;

// Type helpers for endpoint parameters
export type ServiceEndpoint = typeof ENDPOINTS.services;
export type LookupEndpoint = typeof ENDPOINTS.lookups;
export type ExportEndpoint = typeof ENDPOINTS.export;
export type UuBookKitEndpoint = typeof ENDPOINTS.uuBookKit;
export type HealthEndpoint = typeof ENDPOINTS.health;

export default ENDPOINTS;
