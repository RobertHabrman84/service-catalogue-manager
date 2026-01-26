import { apiClient, ApiResponse } from './apiClient';
import { ENDPOINTS } from './endpoints';

export interface PublishRequest {
  serviceIds: number[];
  targetBookUri: string;
  options?: PublishOptions;
}

export interface PublishOptions {
  updateExisting?: boolean;
  createNewPages?: boolean;
  includeImages?: boolean;
  templateId?: string;
}

export type PublishStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';

export interface PublishOperationResponse {
  operationId: string;
  status: PublishStatus;
  targetBookUri: string;
  createdAt: string;
  estimatedCompletionTime?: string;
}

export interface PublishStatusResponse {
  operationId: string;
  status: PublishStatus;
  progress: number;
  currentStep?: string;
  processedCount: number;
  totalCount: number;
  message?: string;
  publishedPageUris?: string[];
  completedAt?: string;
  error?: string;
  errors?: Array<{
    serviceId: number;
    serviceName: string;
    message: string;
  }>;
}

export interface SyncStatusResponse {
  lastSyncAt?: string;
  isInSync: boolean;
  pendingChanges: number;
  syncedServicesCount: number;
  targetBookUri?: string;
  details?: Array<{
    serviceId: number;
    serviceName: string;
    status: 'synced' | 'pending' | 'error';
    lastSyncAt?: string;
    pageUri?: string;
  }>;
}

export interface SyncRequest {
  serviceIds?: number[];
  forceSync?: boolean;
}

export interface UuBookKitConfig {
  baseUri: string;
  bookUri: string;
  awid: string;
  accessCode1?: string;
  accessCode2?: string;
  isConfigured: boolean;
}

export interface PublishHistoryItem {
  operationId: string;
  status: PublishStatus;
  serviceCount: number;
  targetBookUri: string;
  createdAt: string;
  completedAt?: string;
  createdBy: string;
  publishedPageUris?: string[];
  errorCount?: number;
}

export interface PublishHistoryParams {
  page?: number;
  pageSize?: number;
  status?: PublishStatus;
  fromDate?: string;
  toDate?: string;
}

export interface PublishHistoryResponse {
  items: PublishHistoryItem[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface ValidationResponse {
  isValid: boolean;
  errors: Array<{
    code: string;
    message: string;
    field?: string;
  }>;
  warnings: Array<{
    code: string;
    message: string;
  }>;
  connectionStatus: 'connected' | 'disconnected' | 'error';
}

export const uuBookKitApi = {
  /**
   * Start publish operation
   */
  async publish(request: PublishRequest): Promise<ApiResponse<PublishOperationResponse>> {
    return apiClient.post<PublishOperationResponse>(ENDPOINTS.uuBookKit.publish, request);
  },

  /**
   * Get publish operation status
   */
  async getPublishStatus(operationId: string): Promise<ApiResponse<PublishStatusResponse>> {
    return apiClient.get<PublishStatusResponse>(ENDPOINTS.uuBookKit.publishStatus(operationId));
  },

  /**
   * Start sync operation
   */
  async sync(request: SyncRequest = {}): Promise<ApiResponse<PublishOperationResponse>> {
    return apiClient.post<PublishOperationResponse>(ENDPOINTS.uuBookKit.sync, request);
  },

  /**
   * Get current sync status
   */
  async getSyncStatus(): Promise<ApiResponse<SyncStatusResponse>> {
    return apiClient.get<SyncStatusResponse>(ENDPOINTS.uuBookKit.syncStatus);
  },

  /**
   * Get publish history
   */
  async getHistory(params: PublishHistoryParams = {}): Promise<ApiResponse<PublishHistoryResponse>> {
    return apiClient.get<PublishHistoryResponse>(ENDPOINTS.uuBookKit.history, {
      params: {
        page: params.page,
        pageSize: params.pageSize,
        status: params.status,
        fromDate: params.fromDate,
        toDate: params.toDate,
      },
    });
  },

  /**
   * Get UuBookKit configuration
   */
  async getConfig(): Promise<ApiResponse<UuBookKitConfig>> {
    return apiClient.get<UuBookKitConfig>(ENDPOINTS.uuBookKit.config);
  },

  /**
   * Update UuBookKit configuration
   */
  async updateConfig(config: Partial<UuBookKitConfig>): Promise<ApiResponse<UuBookKitConfig>> {
    return apiClient.put<UuBookKitConfig>(ENDPOINTS.uuBookKit.config, config);
  },

  /**
   * Validate UuBookKit connection and configuration
   */
  async validate(): Promise<ApiResponse<ValidationResponse>> {
    return apiClient.get<ValidationResponse>(ENDPOINTS.uuBookKit.validate);
  },
};

export default uuBookKitApi;
