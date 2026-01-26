// Services barrel export

// Re-export from api folder (new modular API)
export * from './api/index';

// Re-export auth services
export * from './auth';

// Re-export legacy api.ts services for backward compatibility
export { 
  serviceCatalogApi,
  lookupService,
  exportService,
  uuBookKitService,
  healthService,
} from './api.ts';
