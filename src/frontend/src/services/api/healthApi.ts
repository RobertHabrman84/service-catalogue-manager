import { apiClient, ApiResponse } from './apiClient';
import { ENDPOINTS } from './endpoints';

export interface HealthStatus {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  version?: string;
  uptime?: number;
}

export interface DetailedHealthStatus extends HealthStatus {
  checks: HealthCheck[];
  totalDuration: number;
}

export interface HealthCheck {
  name: string;
  status: 'healthy' | 'degraded' | 'unhealthy';
  duration: number;
  description?: string;
  data?: Record<string, unknown>;
  error?: string;
}

export interface ReadinessStatus {
  ready: boolean;
  timestamp: string;
  checks: Array<{
    name: string;
    ready: boolean;
    message?: string;
  }>;
}

export interface LivenessStatus {
  alive: boolean;
  timestamp: string;
}

export const healthApi = {
  /**
   * Get basic health status
   */
  async getStatus(): Promise<ApiResponse<HealthStatus>> {
    return apiClient.get<HealthStatus>(ENDPOINTS.health.status, { skipAuth: true });
  },

  /**
   * Get detailed health status with all checks
   */
  async getDetailedStatus(): Promise<ApiResponse<DetailedHealthStatus>> {
    return apiClient.get<DetailedHealthStatus>(ENDPOINTS.health.detailed, { skipAuth: true });
  },

  /**
   * Get readiness status (for k8s readiness probe)
   */
  async getReadiness(): Promise<ApiResponse<ReadinessStatus>> {
    return apiClient.get<ReadinessStatus>(ENDPOINTS.health.ready, { skipAuth: true });
  },

  /**
   * Get liveness status (for k8s liveness probe)
   */
  async getLiveness(): Promise<ApiResponse<LivenessStatus>> {
    return apiClient.get<LivenessStatus>(ENDPOINTS.health.live, { skipAuth: true });
  },

  /**
   * Check if API is available
   */
  async ping(): Promise<boolean> {
    try {
      const response = await this.getLiveness();
      return response.data.alive;
    } catch {
      return false;
    }
  },
};

export default healthApi;
