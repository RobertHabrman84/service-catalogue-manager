// API Services barrel export
export { apiClient, type ApiResponse, type ApiError, type RequestConfig } from './apiClient';
export { ENDPOINTS, API_VERSION } from './endpoints';

export { 
  serviceApi, 
  serviceApi as serviceCatalogApi, // Alias for backward compatibility
  type ServiceListParams, 
  type ServiceListResponse,
  type ServiceSearchParams,
  type BulkDeleteRequest,
  type BulkDeleteResponse,
  type ValidationResult,
} from './serviceApi';

export { 
  lookupApi,
  lookupApi as lookupService, // Alias for backward compatibility
  type AllLookupsResponse 
} from './lookupApi';

export { 
  exportApi,
  exportApi as exportService, // Alias for backward compatibility
  type ExportFormat,
  type ExportRequest,
  type ExportOptions,
  type ExportOperationResponse,
  type ExportStatus,
  type ExportStatusResponse,
  type ExportHistoryItem,
  type ExportHistoryParams,
  type ExportHistoryResponse,
} from './exportApi';

export { 
  uuBookKitApi,
  uuBookKitApi as uuBookKitService, // Alias for backward compatibility
  type PublishRequest,
  type PublishOptions,
  type PublishStatus,
  type PublishOperationResponse,
  type PublishStatusResponse,
  type SyncStatusResponse,
  type SyncRequest,
  type UuBookKitConfig,
  type PublishHistoryItem,
  type PublishHistoryParams,
  type PublishHistoryResponse,
  type ValidationResponse,
} from './uuBookKitApi';

export { 
  healthApi,
  type HealthStatus,
  type DetailedHealthStatus,
  type HealthCheck,
  type ReadinessStatus,
  type LivenessStatus,
} from './healthApi';

export { 
  dashboardApi,
  type DashboardStats,
  type ActivityLogItem,
  type ActivityLogParams,
  type ActivityLogResponse,
} from './dashboardApi';
