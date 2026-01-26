import { apiClient, ApiResponse } from './apiClient';
import { ENDPOINTS } from './endpoints';
import { ServiceCatalogListItem } from '../../types';

export interface DashboardStats {
  totalServices: number;
  activeServices: number;
  archivedServices: number;
  draftServices: number;
  categoryCounts: Array<{
    categoryId: number;
    categoryName: string;
    count: number;
  }>;
  cloudProviderCounts: Array<{
    providerId: number;
    providerName: string;
    count: number;
  }>;
  recentActivity: {
    createdLast7Days: number;
    updatedLast7Days: number;
    publishedLast7Days: number;
  };
}

export interface ActivityLogItem {
  id: string;
  action: 'created' | 'updated' | 'deleted' | 'published' | 'exported' | 'archived';
  entityType: 'service' | 'export' | 'publish';
  entityId: number | string;
  entityName: string;
  userId: string;
  userName: string;
  timestamp: string;
  details?: Record<string, unknown>;
}

export interface ActivityLogParams {
  page?: number;
  pageSize?: number;
  action?: string;
  entityType?: string;
  userId?: string;
  fromDate?: string;
  toDate?: string;
}

export interface ActivityLogResponse {
  items: ActivityLogItem[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export const dashboardApi = {
  /**
   * Get dashboard statistics
   */
  async getStats(): Promise<ApiResponse<DashboardStats>> {
    return apiClient.get<DashboardStats>(ENDPOINTS.dashboard.stats);
  },

  /**
   * Get recently modified services
   */
  async getRecentServices(limit: number = 10): Promise<ApiResponse<ServiceCatalogListItem[]>> {
    return apiClient.get<ServiceCatalogListItem[]>(ENDPOINTS.dashboard.recentServices, {
      params: { limit },
    });
  },

  /**
   * Get activity log
   */
  async getActivityLog(params: ActivityLogParams = {}): Promise<ApiResponse<ActivityLogResponse>> {
    return apiClient.get<ActivityLogResponse>(ENDPOINTS.dashboard.activityLog, {
      params: {
        page: params.page,
        pageSize: params.pageSize,
        action: params.action,
        entityType: params.entityType,
        userId: params.userId,
        fromDate: params.fromDate,
        toDate: params.toDate,
      },
    });
  },
};

export default dashboardApi;
