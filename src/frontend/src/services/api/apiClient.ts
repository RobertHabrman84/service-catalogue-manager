import { msalInstance } from '../auth/msalInstance';
import { loginRequest } from '../auth/authConfig';

export interface ApiResponse<T> {
  data: T;
  status: number;
  statusText: string;
  headers: Headers;
}

export interface ApiError {
  message: string;
  status?: number;
  statusText?: string;
  code?: string;
  details?: Record<string, unknown>;
}

export interface RequestConfig {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  headers?: Record<string, string>;
  body?: unknown;
  params?: Record<string, string | number | boolean | undefined>;
  timeout?: number;
  signal?: AbortSignal;
  skipAuth?: boolean;
}

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';
const DEFAULT_TIMEOUT = 30000;

class ApiClient {
  private baseUrl: string;
  private defaultHeaders: Record<string, string>;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
    this.defaultHeaders = {
      'Content-Type': 'application/json',
    };
  }

  private async getAuthToken(): Promise<string | null> {
    try {
      const accounts = msalInstance.getAllAccounts();
      if (accounts.length === 0) {
        return null;
      }

      const response = await msalInstance.acquireTokenSilent({
        ...loginRequest,
        account: accounts[0],
      });

      return response.accessToken;
    } catch (error) {
      console.warn('Failed to acquire token silently:', error);
      return null;
    }
  }

  private buildUrl(endpoint: string, params?: Record<string, string | number | boolean | undefined>): string {
    const url = new URL(`${this.baseUrl}${endpoint}`, window.location.origin);

    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          url.searchParams.append(key, String(value));
        }
      });
    }

    return url.toString();
  }

  private async handleResponse<T>(response: Response): Promise<ApiResponse<T>> {
    const contentType = response.headers.get('content-type');
    
    let data: T;
    
    // Handle different content types properly
    if (contentType?.includes('application/json')) {
      data = await response.json();
    } else if (contentType?.includes('application/octet-stream') || 
               contentType?.includes('application/pdf') ||
               contentType?.includes('image/')) {
      // For binary content, return as Blob (caller should expect Blob type)
      data = (await response.blob()) as T;
    } else {
      // For text content, return as string (caller should expect string type)
      data = (await response.text()) as T;
    }

    if (!response.ok) {
      const error: ApiError = {
        message: typeof data === 'object' && data !== null && 'message' in data 
          ? String((data as Record<string, unknown>).message)
          : `HTTP ${response.status}: ${response.statusText}`,
        status: response.status,
        statusText: response.statusText,
        details: typeof data === 'object' && data !== null ? data as Record<string, unknown> : undefined,
      };
      throw error;
    }

    return {
      data,
      status: response.status,
      statusText: response.statusText,
      headers: response.headers,
    };
  }

  async request<T>(endpoint: string, config: RequestConfig = {}): Promise<ApiResponse<T>> {
    const {
      method = 'GET',
      headers = {},
      body,
      params,
      timeout = DEFAULT_TIMEOUT,
      signal,
      skipAuth = false,
    } = config;

    const url = this.buildUrl(endpoint, params);

    const requestHeaders: Record<string, string> = {
      ...this.defaultHeaders,
      ...headers,
    };

    if (!skipAuth) {
      const token = await this.getAuthToken();
      if (token) {
        requestHeaders['Authorization'] = `Bearer ${token}`;
      }
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(url, {
        method,
        headers: requestHeaders,
        body: body ? JSON.stringify(body) : undefined,
        signal: signal || controller.signal,
      });

      clearTimeout(timeoutId);
      return this.handleResponse<T>(response);
    } catch (error) {
      clearTimeout(timeoutId);

      // Handle all error types properly
      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          const timeoutError: ApiError = { 
            message: 'Request timeout', 
            code: 'TIMEOUT',
            status: 408
          };
          throw timeoutError;
        }
        const networkError: ApiError = { 
          message: error.message, 
          code: 'NETWORK_ERROR',
          status: 0
        };
        throw networkError;
      }
      
      // Handle non-Error exceptions
      if (typeof error === 'string') {
        const stringError: ApiError = { 
          message: error, 
          code: 'UNKNOWN_ERROR' 
        };
        throw stringError;
      }
      
      // Handle ApiError objects thrown from handleResponse
      if (error && typeof error === 'object' && 'message' in error) {
        throw error as ApiError;
      }

      // Last resort: wrap unknown errors
      const unknownError: ApiError = { 
        message: 'An unknown error occurred', 
        code: 'UNKNOWN_ERROR',
        details: { originalError: error }
      };
      throw unknownError;
    }
  }

  async get<T>(endpoint: string, config: Omit<RequestConfig, 'method' | 'body'> = {}): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { ...config, method: 'GET' });
  }

  async post<T>(endpoint: string, body?: unknown, config: Omit<RequestConfig, 'method' | 'body'> = {}): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { ...config, method: 'POST', body });
  }

  async put<T>(endpoint: string, body?: unknown, config: Omit<RequestConfig, 'method' | 'body'> = {}): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { ...config, method: 'PUT', body });
  }

  async patch<T>(endpoint: string, body?: unknown, config: Omit<RequestConfig, 'method' | 'body'> = {}): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { ...config, method: 'PATCH', body });
  }

  async delete<T>(endpoint: string, config: Omit<RequestConfig, 'method' | 'body'> = {}): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { ...config, method: 'DELETE' });
  }

  async downloadFile(endpoint: string, filename: string, config: Omit<RequestConfig, 'method' | 'body'> = {}): Promise<void> {
    const response = await this.get<Blob>(endpoint, config);
    
    const url = window.URL.createObjectURL(response.data);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  }
}

export const apiClient = new ApiClient();
export default apiClient;
