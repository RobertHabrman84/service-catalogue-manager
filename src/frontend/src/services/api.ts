// services/api.ts
// API service layer for Service Catalogue Manager

import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { msalInstance, loginRequest } from './auth';
import {
  ServiceCatalogItem,
  ServiceCatalogFormData,
  ServiceCatalogFilters,
  PaginatedResponse,
  ApiResponse,
  ServiceCategory,
  DependencyType,
  RequirementLevel,
  PrerequisiteCategory,
  CloudProvider,
  ToolCategory,
  LicenseType,
  InteractionLevel,
  SizeOption,
  Role,
  ExportOptions,
  ExportResult,
  UuBookKitPublishOptions,
  UuBookKitSyncStatus,
} from '../types';

// API Configuration
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';

// Create axios instance
const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
});

// Request interceptor for auth token
apiClient.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    try {
      const account = msalInstance.getActiveAccount();
      if (account) {
        const response = await msalInstance.acquireTokenSilent({
          ...loginRequest,
          account,
        });
        config.headers.Authorization = `Bearer ${response.accessToken}`;
      }
    } catch (error) {
      console.error('Failed to acquire token:', error);
    }

    // Add correlation ID
    config.headers['X-Correlation-Id'] = crypto.randomUUID();
    
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError<ApiResponse<unknown>>) => {
    if (error.response?.status === 401) {
      // Try to refresh token
      try {
        const account = msalInstance.getActiveAccount();
        if (account) {
          await msalInstance.acquireTokenSilent({
            ...loginRequest,
            account,
            forceRefresh: true,
          });
          // Retry the original request
          return apiClient.request(error.config!);
        }
      } catch (refreshError) {
        // Redirect to login
        msalInstance.loginRedirect(loginRequest);
      }
    }
    
    return Promise.reject(error);
  }
);

// ============================================
// Service Catalog API
// ============================================

export const serviceCatalogApi = {
  // Get all services with pagination and filters
  getServices: async (
    filters: ServiceCatalogFilters = {},
    page = 1,
    pageSize = 20
  ): Promise<PaginatedResponse<ServiceCatalogItem>> => {
    const params = new URLSearchParams();
    params.append('pageNumber', page.toString());
    params.append('pageSize', pageSize.toString());
    
    if (filters.search) params.append('search', filters.search);
    if (filters.categoryId) params.append('categoryId', filters.categoryId.toString());
    if (filters.isActive !== undefined) params.append('isActive', filters.isActive.toString());
    if (filters.isPublished !== undefined) params.append('isPublished', filters.isPublished.toString());
    if (filters.sizeOptionId) params.append('sizeOptionId', filters.sizeOptionId.toString());
    if (filters.cloudProviderId) params.append('cloudProviderId', filters.cloudProviderId.toString());
    if (filters.sortBy) params.append('sortBy', filters.sortBy);
    if (filters.sortDirection) params.append('sortDirection', filters.sortDirection);
    
    const response = await apiClient.get<PaginatedResponse<ServiceCatalogItem>>(
      `/services?${params.toString()}`
    );
    return response.data;
  },

  // Get single service by ID
  getService: async (id: number): Promise<ServiceCatalogItem> => {
    const response = await apiClient.get<ServiceCatalogItem>(`/services/${id}`);
    return response.data;
  },

  // Get service by code
  getServiceByCode: async (code: string): Promise<ServiceCatalogItem> => {
    const response = await apiClient.get<ServiceCatalogItem>(`/services/code/${code}`);
    return response.data;
  },

  // Create new service
  createService: async (data: ServiceCatalogFormData): Promise<ServiceCatalogItem> => {
    const response = await apiClient.post<ServiceCatalogItem>('/services', data);
    return response.data;
  },

  // Update service
  updateService: async (id: number, data: ServiceCatalogFormData): Promise<ServiceCatalogItem> => {
    const response = await apiClient.put<ServiceCatalogItem>(`/services/${id}`, data);
    return response.data;
  },

  // Delete service
  deleteService: async (id: number): Promise<void> => {
    await apiClient.delete(`/services/${id}`);
  },

  // Duplicate service
  duplicateService: async (id: number, newCode: string): Promise<ServiceCatalogItem> => {
    const response = await apiClient.post<ServiceCatalogItem>(`/services/${id}/duplicate`, {
      newServiceCode: newCode,
    });
    return response.data;
  },

  // Publish service
  publishService: async (id: number): Promise<void> => {
    await apiClient.post(`/services/${id}/publish`);
  },

  // Unpublish service
  unpublishService: async (id: number): Promise<void> => {
    await apiClient.post(`/services/${id}/unpublish`);
  },
};

// ============================================
// Lookup API
// ============================================

export const lookupService = {
  getServiceCategories: async (): Promise<ServiceCategory[]> => {
    const response = await apiClient.get<ServiceCategory[]>('/lookups/categories');
    return response.data;
  },

  getDependencyTypes: async (): Promise<DependencyType[]> => {
    const response = await apiClient.get<DependencyType[]>('/lookups/dependency-types');
    return response.data;
  },

  getRequirementLevels: async (): Promise<RequirementLevel[]> => {
    const response = await apiClient.get<RequirementLevel[]>('/lookups/requirement-levels');
    return response.data;
  },

  getPrerequisiteCategories: async (): Promise<PrerequisiteCategory[]> => {
    const response = await apiClient.get<PrerequisiteCategory[]>('/lookups/prerequisite-categories');
    return response.data;
  },

  getCloudProviders: async (): Promise<CloudProvider[]> => {
    const response = await apiClient.get<CloudProvider[]>('/lookups/cloud-providers');
    return response.data;
  },

  getToolCategories: async (): Promise<ToolCategory[]> => {
    const response = await apiClient.get<ToolCategory[]>('/lookups/tool-categories');
    return response.data;
  },

  getLicenseTypes: async (): Promise<LicenseType[]> => {
    const response = await apiClient.get<LicenseType[]>('/lookups/license-types');
    return response.data;
  },

  getInteractionLevels: async (): Promise<InteractionLevel[]> => {
    const response = await apiClient.get<InteractionLevel[]>('/lookups/interaction-levels');
    return response.data;
  },

  getSizeOptions: async (): Promise<SizeOption[]> => {
    const response = await apiClient.get<SizeOption[]>('/lookups/size-options');
    return response.data;
  },

  getRoles: async (): Promise<Role[]> => {
    const response = await apiClient.get<Role[]>('/lookups/roles');
    return response.data;
  },

  getServicesList: async (): Promise<Array<{ serviceId: number; serviceCode: string; serviceName: string }>> => {
    const response = await apiClient.get('/lookups/services-list');
    return response.data;
  },
};

// ============================================
// Export API
// ============================================

export const exportService = {
  exportToPdf: async (options: ExportOptions): Promise<ExportResult> => {
    const response = await apiClient.post<ExportResult>('/export/pdf', options);
    return response.data;
  },

  exportToMarkdown: async (options: ExportOptions): Promise<ExportResult> => {
    const response = await apiClient.post<ExportResult>('/export/markdown', options);
    return response.data;
  },

  getExportHistory: async (): Promise<ExportResult[]> => {
    const response = await apiClient.get<ExportResult[]>('/export/history');
    return response.data;
  },

  downloadExport: async (exportId: string): Promise<Blob> => {
    const response = await apiClient.get(`/export/download/${exportId}`, {
      responseType: 'blob',
    });
    return response.data;
  },
};

// ============================================
// uuBookKit API
// ============================================

export const uuBookKitService = {
  publish: async (options: UuBookKitPublishOptions): Promise<void> => {
    await apiClient.post('/uubookkit/publish', options);
  },

  getSyncStatus: async (serviceId: number): Promise<UuBookKitSyncStatus> => {
    const response = await apiClient.get<UuBookKitSyncStatus>(`/uubookkit/status/${serviceId}`);
    return response.data;
  },

  syncAll: async (): Promise<void> => {
    await apiClient.post('/uubookkit/sync-all');
  },
};

// ============================================
// Health API
// ============================================

export const healthService = {
  check: async (): Promise<{ status: string; version: string }> => {
    const response = await apiClient.get('/health');
    return response.data;
  },

  checkDatabase: async (): Promise<{ connected: boolean }> => {
    const response = await apiClient.get('/health/db');
    return response.data;
  },
};

export default apiClient;
