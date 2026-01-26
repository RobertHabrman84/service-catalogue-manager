import { useCallback, useEffect, useState } from 'react';
import { useApi } from './useApi';
import { ServiceCatalogItem, ServiceCatalogFullDto, CreateServiceRequest, UpdateServiceRequest } from '../types';

export interface UseServiceResult {
  service: ServiceCatalogFullDto | null;
  isLoading: boolean;
  error: string | null;
  fetchService: (id: number) => Promise<void>;
  fetchServiceByCode: (code: string) => Promise<void>;
  createService: (data: CreateServiceRequest) => Promise<ServiceCatalogItem | null>;
  updateService: (id: number, data: UpdateServiceRequest) => Promise<ServiceCatalogItem | null>;
  deleteService: (id: number) => Promise<boolean>;
  reset: () => void;
}

export const useService = (initialId?: number): UseServiceResult => {
  const [service, setService] = useState<ServiceCatalogFullDto | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const getApi = useApi<ServiceCatalogFullDto>((id: unknown) => `/services/${id}/full`, 'GET');
  const getByCodeApi = useApi<ServiceCatalogFullDto>((code: unknown) => `/services/code/${code}/full`, 'GET');
  const createApi = useApi<ServiceCatalogItem>('/services', 'POST');
  const updateApi = useApi<ServiceCatalogItem>((id: unknown) => `/services/${id}`, 'PUT');
  const deleteApi = useApi<void>((id: unknown) => `/services/${id}`, 'DELETE');

  const fetchService = useCallback(async (id: number) => {
    setIsLoading(true);
    setError(null);
    const result = await getApi.execute(id);
    if (result) {
      setService(result);
    } else if (getApi.error) {
      setError(getApi.error.message);
    }
    setIsLoading(false);
  }, [getApi]);

  const fetchServiceByCode = useCallback(async (code: string) => {
    setIsLoading(true);
    setError(null);
    const result = await getByCodeApi.execute(code);
    if (result) {
      setService(result);
    } else if (getByCodeApi.error) {
      setError(getByCodeApi.error.message);
    }
    setIsLoading(false);
  }, [getByCodeApi]);

  const createService = useCallback(async (data: CreateServiceRequest): Promise<ServiceCatalogItem | null> => {
    setIsLoading(true);
    setError(null);
    const result = await createApi.execute(data);
    if (createApi.error) {
      setError(createApi.error.message);
    }
    setIsLoading(false);
    return result;
  }, [createApi]);

  const updateService = useCallback(async (id: number, data: UpdateServiceRequest): Promise<ServiceCatalogItem | null> => {
    setIsLoading(true);
    setError(null);
    const result = await updateApi.execute(id, data);
    if (updateApi.error) {
      setError(updateApi.error.message);
    }
    setIsLoading(false);
    return result;
  }, [updateApi]);

  const deleteService = useCallback(async (id: number): Promise<boolean> => {
    setIsLoading(true);
    setError(null);
    await deleteApi.execute(id);
    const success = !deleteApi.error;
    if (!success) {
      setError(deleteApi.error?.message || 'Delete failed');
    }
    setIsLoading(false);
    return success;
  }, [deleteApi]);

  const reset = useCallback(() => {
    setService(null);
    setError(null);
    setIsLoading(false);
  }, []);

  useEffect(() => {
    if (initialId) {
      fetchService(initialId);
    }
  }, [initialId]);

  return {
    service,
    isLoading,
    error,
    fetchService,
    fetchServiceByCode,
    createService,
    updateService,
    deleteService,
    reset,
  };
};

export default useService;
