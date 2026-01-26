import { useState, useCallback, useRef, useEffect } from 'react';
import { useAuth } from './useAuth';

export interface ApiError {
  message: string;
  statusCode: number;
  errors?: Record<string, string[]>;
}

export interface ApiState<T> {
  data: T | null;
  isLoading: boolean;
  error: ApiError | null;
}

export interface UseApiOptions {
  immediate?: boolean;
  onSuccess?: (data: unknown) => void;
  onError?: (error: ApiError) => void;
}

export interface UseApiResult<T> extends ApiState<T> {
  execute: (...args: unknown[]) => Promise<T | null>;
  reset: () => void;
}

const BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';

export const useApi = <T>(
  endpoint: string | ((...args: unknown[]) => string),
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' = 'GET',
  options: UseApiOptions = {}
): UseApiResult<T> => {
  const { getAccessToken } = useAuth();
  const [state, setState] = useState<ApiState<T>>({
    data: null,
    isLoading: false,
    error: null,
  });
  const abortControllerRef = useRef<AbortController | null>(null);

  const reset = useCallback(() => {
    setState({
      data: null,
      isLoading: false,
      error: null,
    });
  }, []);

  const execute = useCallback(
    async (...args: unknown[]): Promise<T | null> => {
      // Cancel any ongoing request
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }
      abortControllerRef.current = new AbortController();

      setState((prev) => ({ ...prev, isLoading: true, error: null }));

      try {
        const token = await getAccessToken();
        const url = typeof endpoint === 'function' ? endpoint(...args) : endpoint;
        const fullUrl = url.startsWith('http') ? url : `${BASE_URL}${url}`;

        const headers: HeadersInit = {
          'Content-Type': 'application/json',
        };

        if (token) {
          headers['Authorization'] = `Bearer ${token}`;
        }

        const body = method !== 'GET' && args.length > 0 ? JSON.stringify(args[0]) : undefined;

        const response = await fetch(fullUrl, {
          method,
          headers,
          body,
          signal: abortControllerRef.current.signal,
        });

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          const apiError: ApiError = {
            message: errorData.message || `HTTP error ${response.status}`,
            statusCode: response.status,
            errors: errorData.errors,
          };
          throw apiError;
        }

        const data = await response.json();
        setState({ data, isLoading: false, error: null });
        options.onSuccess?.(data);
        return data;
      } catch (err) {
        if ((err as Error).name === 'AbortError') {
          return null;
        }

        const apiError: ApiError =
          err instanceof Error
            ? { message: err.message, statusCode: 0 }
            : (err as ApiError);

        setState({ data: null, isLoading: false, error: apiError });
        options.onError?.(apiError);
        return null;
      }
    },
    [endpoint, method, getAccessToken, options]
  );

  // Execute immediately if specified
  useEffect(() => {
    if (options.immediate && method === 'GET') {
      execute();
    }
    // Cleanup on unmount
    return () => {
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }
    };
  }, []);

  return {
    ...state,
    execute,
    reset,
  };
};

export default useApi;
