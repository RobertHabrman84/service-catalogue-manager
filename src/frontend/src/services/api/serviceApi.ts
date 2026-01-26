import { apiClient, ApiResponse } from './apiClient';
import { ENDPOINTS } from './endpoints';
import {
  ServiceCatalogItem,
  ServiceCatalogListItem,
  CreateServiceRequest,
  UpdateServiceRequest,
} from '../../types';

export interface ServiceListParams {
  page?: number;
  pageSize?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  categoryId?: number;
  subcategoryId?: number;
  search?: string;
  isActive?: boolean;
}

export interface ServiceListResponse {
  items: ServiceCatalogListItem[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface ServiceSearchParams {
  query: string;
  categoryIds?: number[];
  cloudProviderIds?: number[];
  limit?: number;
}

export interface BulkDeleteRequest {
  serviceIds: number[];
}

export interface BulkDeleteResponse {
  deletedCount: number;
  failedIds: number[];
  errors: Array<{ id: number; message: string }>;
}

export interface ValidationResult {
  isValid: boolean;
  errors: Array<{
    field: string;
    message: string;
    code: string;
  }>;
  warnings: Array<{
    field: string;
    message: string;
  }>;
}

export const serviceApi = {
  /**
   * Get paginated list of services
   */
  async getList(params: ServiceListParams = {}): Promise<ApiResponse<ServiceListResponse>> {
    return apiClient.get<ServiceListResponse>(ENDPOINTS.services.list, {
      params: {
        page: params.page,
        pageSize: params.pageSize,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
        categoryId: params.categoryId,
        subcategoryId: params.subcategoryId,
        search: params.search,
        isActive: params.isActive,
      },
    });
  },

  /**
   * Get single service by ID
   */
  async getById(id: number): Promise<ApiResponse<ServiceCatalogItem>> {
    return apiClient.get<ServiceCatalogItem>(ENDPOINTS.services.getById(id));
  },

  /**
   * Create new service
   */
  async create(data: CreateServiceRequest): Promise<ApiResponse<ServiceCatalogItem>> {
    return apiClient.post<ServiceCatalogItem>(ENDPOINTS.services.create, data);
  },

  /**
   * Update existing service
   */
  async update(id: number, data: UpdateServiceRequest): Promise<ApiResponse<ServiceCatalogItem>> {
    return apiClient.put<ServiceCatalogItem>(ENDPOINTS.services.update(id), data);
  },

  /**
   * Delete service by ID
   */
  async delete(id: number): Promise<ApiResponse<void>> {
    return apiClient.delete<void>(ENDPOINTS.services.delete(id));
  },

  /**
   * Search services
   */
  async search(params: ServiceSearchParams): Promise<ApiResponse<ServiceCatalogListItem[]>> {
    return apiClient.post<ServiceCatalogListItem[]>(ENDPOINTS.services.search, params);
  },

  /**
   * Duplicate service
   */
  async duplicate(id: number): Promise<ApiResponse<ServiceCatalogItem>> {
    return apiClient.post<ServiceCatalogItem>(ENDPOINTS.services.duplicate(id));
  },

  /**
   * Validate service data
   */
  async validate(data: Partial<CreateServiceRequest>): Promise<ApiResponse<ValidationResult>> {
    return apiClient.post<ValidationResult>(ENDPOINTS.services.validate, data);
  },

  /**
   * Bulk delete services
   */
  async bulkDelete(serviceIds: number[]): Promise<ApiResponse<BulkDeleteResponse>> {
    return apiClient.post<BulkDeleteResponse>(ENDPOINTS.services.bulk.delete, { serviceIds });
  },

  /**
   * Bulk archive services
   */
  async bulkArchive(serviceIds: number[]): Promise<ApiResponse<{ archivedCount: number }>> {
    return apiClient.post<{ archivedCount: number }>(ENDPOINTS.services.bulk.archive, { serviceIds });
  },
};

export default serviceApi;
