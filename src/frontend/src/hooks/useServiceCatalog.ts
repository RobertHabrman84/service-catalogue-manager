// hooks/useServiceCatalog.ts
// React Query hooks for Service Catalog operations

import { useQuery, useMutation, useQueryClient, UseQueryOptions } from '@tanstack/react-query';
import { serviceCatalogApi, lookupService, exportService, uuBookKitService } from '../services/api';
import {
  ServiceCatalogItem,
  ServiceCatalogFormData,
  ServiceCatalogFilters,
  PaginatedResponse,
  ExportOptions,
  ExportResult,
  UuBookKitPublishOptions,
} from '../types';
import { useNotification } from '../components/common';

// Query keys
export const queryKeys = {
  services: {
    all: ['services'] as const,
    lists: () => [...queryKeys.services.all, 'list'] as const,
    list: (filters: ServiceCatalogFilters, page: number, pageSize: number) =>
      [...queryKeys.services.lists(), { filters, page, pageSize }] as const,
    details: () => [...queryKeys.services.all, 'detail'] as const,
    detail: (id: number) => [...queryKeys.services.details(), id] as const,
    byCode: (code: string) => [...queryKeys.services.all, 'code', code] as const,
  },
  lookups: {
    all: ['lookups'] as const,
    categories: () => [...queryKeys.lookups.all, 'categories'] as const,
    dependencyTypes: () => [...queryKeys.lookups.all, 'dependencyTypes'] as const,
    requirementLevels: () => [...queryKeys.lookups.all, 'requirementLevels'] as const,
    prerequisiteCategories: () => [...queryKeys.lookups.all, 'prerequisiteCategories'] as const,
    cloudProviders: () => [...queryKeys.lookups.all, 'cloudProviders'] as const,
    toolCategories: () => [...queryKeys.lookups.all, 'toolCategories'] as const,
    licenseTypes: () => [...queryKeys.lookups.all, 'licenseTypes'] as const,
    interactionLevels: () => [...queryKeys.lookups.all, 'interactionLevels'] as const,
    sizeOptions: () => [...queryKeys.lookups.all, 'sizeOptions'] as const,
    roles: () => [...queryKeys.lookups.all, 'roles'] as const,
    servicesList: () => [...queryKeys.lookups.all, 'servicesList'] as const,
  },
  exports: {
    all: ['exports'] as const,
    history: () => [...queryKeys.exports.all, 'history'] as const,
  },
};

// ============================================
// Service Catalog Hooks
// ============================================

export const useServices = (
  filters: ServiceCatalogFilters = {},
  page = 1,
  pageSize = 20,
  options?: UseQueryOptions<PaginatedResponse<ServiceCatalogItem>>
) => {
  return useQuery({
    queryKey: queryKeys.services.list(filters, page, pageSize),
    queryFn: () => serviceCatalogApi.getServices(filters, page, pageSize),
    staleTime: 5 * 60 * 1000, // 5 minutes
    ...options,
  });
};

export const useService = (
  id: number,
  options?: UseQueryOptions<ServiceCatalogItem>
) => {
  return useQuery({
    queryKey: queryKeys.services.detail(id),
    queryFn: () => serviceCatalogApi.getService(id),
    enabled: !!id,
    staleTime: 5 * 60 * 1000,
    ...options,
  });
};

export const useServiceByCode = (
  code: string,
  options?: UseQueryOptions<ServiceCatalogItem>
) => {
  return useQuery({
    queryKey: queryKeys.services.byCode(code),
    queryFn: () => serviceCatalogApi.getServiceByCode(code),
    enabled: !!code,
    staleTime: 5 * 60 * 1000,
    ...options,
  });
};

export const useCreateService = () => {
  const queryClient = useQueryClient();
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: (data: ServiceCatalogFormData) => serviceCatalogApi.createService(data),
    onSuccess: (newService) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.services.lists() });
      queryClient.setQueryData(queryKeys.services.detail(newService.serviceId), newService);
      success('Service created', `Service "${newService.serviceName}" has been created successfully.`);
    },
    onError: (err: Error) => {
      error('Failed to create service', err.message);
    },
  });
};

export const useUpdateService = () => {
  const queryClient = useQueryClient();
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: ServiceCatalogFormData }) =>
      serviceCatalogApi.updateService(id, data),
    onSuccess: (updatedService) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.services.lists() });
      queryClient.setQueryData(queryKeys.services.detail(updatedService.serviceId), updatedService);
      success('Service updated', `Service "${updatedService.serviceName}" has been updated.`);
    },
    onError: (err: Error) => {
      error('Failed to update service', err.message);
    },
  });
};

export const useDeleteService = () => {
  const queryClient = useQueryClient();
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: (id: number) => serviceCatalogApi.deleteService(id),
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.services.lists() });
      queryClient.removeQueries({ queryKey: queryKeys.services.detail(id) });
      success('Service deleted', 'The service has been deleted successfully.');
    },
    onError: (err: Error) => {
      error('Failed to delete service', err.message);
    },
  });
};

export const useDuplicateService = () => {
  const queryClient = useQueryClient();
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: ({ id, newCode }: { id: number; newCode: string }) =>
      serviceCatalogApi.duplicateService(id, newCode),
    onSuccess: (newService) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.services.lists() });
      success('Service duplicated', `Service has been duplicated as "${newService.serviceCode}".`);
    },
    onError: (err: Error) => {
      error('Failed to duplicate service', err.message);
    },
  });
};

export const usePublishService = () => {
  const queryClient = useQueryClient();
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: (id: number) => serviceCatalogApi.publishService(id),
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.services.detail(id) });
      queryClient.invalidateQueries({ queryKey: queryKeys.services.lists() });
      success('Service published', 'The service is now published and visible.');
    },
    onError: (err: Error) => {
      error('Failed to publish service', err.message);
    },
  });
};

// ============================================
// Lookup Hooks
// ============================================

export const useServiceCategories = () => {
  return useQuery({
    queryKey: queryKeys.lookups.categories(),
    queryFn: () => lookupService.getServiceCategories(),
    staleTime: 30 * 60 * 1000, // 30 minutes
  });
};

export const useDependencyTypes = () => {
  return useQuery({
    queryKey: queryKeys.lookups.dependencyTypes(),
    queryFn: () => lookupService.getDependencyTypes(),
    staleTime: 30 * 60 * 1000,
  });
};

export const useRequirementLevels = () => {
  return useQuery({
    queryKey: queryKeys.lookups.requirementLevels(),
    queryFn: () => lookupService.getRequirementLevels(),
    staleTime: 30 * 60 * 1000,
  });
};

export const useCloudProviders = () => {
  return useQuery({
    queryKey: queryKeys.lookups.cloudProviders(),
    queryFn: () => lookupService.getCloudProviders(),
    staleTime: 30 * 60 * 1000,
  });
};

export const useSizeOptions = () => {
  return useQuery({
    queryKey: queryKeys.lookups.sizeOptions(),
    queryFn: () => lookupService.getSizeOptions(),
    staleTime: 30 * 60 * 1000,
  });
};

export const useRoles = () => {
  return useQuery({
    queryKey: queryKeys.lookups.roles(),
    queryFn: () => lookupService.getRoles(),
    staleTime: 30 * 60 * 1000,
  });
};

// Prefetch all lookups
export const usePrefetchLookups = () => {
  const queryClient = useQueryClient();

  return () => {
    queryClient.prefetchQuery({
      queryKey: queryKeys.lookups.categories(),
      queryFn: () => lookupService.getServiceCategories(),
    });
    queryClient.prefetchQuery({
      queryKey: queryKeys.lookups.sizeOptions(),
      queryFn: () => lookupService.getSizeOptions(),
    });
    queryClient.prefetchQuery({
      queryKey: queryKeys.lookups.roles(),
      queryFn: () => lookupService.getRoles(),
    });
  };
};

// ============================================
// Export Hooks
// ============================================

export const useExportToPdf = () => {
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: (options: ExportOptions) => exportService.exportToPdf(options),
    onSuccess: (result) => {
      success('Export complete', `PDF export "${result.fileName}" is ready for download.`);
    },
    onError: (err: Error) => {
      error('Export failed', err.message);
    },
  });
};

export const useExportToMarkdown = () => {
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: (options: ExportOptions) => exportService.exportToMarkdown(options),
    onSuccess: (result) => {
      success('Export complete', `Markdown export "${result.fileName}" is ready.`);
    },
    onError: (err: Error) => {
      error('Export failed', err.message);
    },
  });
};

export const useExportHistory = () => {
  return useQuery({
    queryKey: queryKeys.exports.history(),
    queryFn: () => exportService.getExportHistory(),
    staleTime: 60 * 1000, // 1 minute
  });
};

// ============================================
// uuBookKit Hooks
// ============================================

export const usePublishToUuBookKit = () => {
  const { success, error } = useNotification();

  return useMutation({
    mutationFn: (options: UuBookKitPublishOptions) => uuBookKitService.publish(options),
    onSuccess: () => {
      success('Published to uuBookKit', 'The service has been published successfully.');
    },
    onError: (err: Error) => {
      error('Publish failed', err.message);
    },
  });
};

export const useUuBookKitSyncStatus = (serviceId: number) => {
  return useQuery({
    queryKey: ['uubookkit', 'status', serviceId],
    queryFn: () => uuBookKitService.getSyncStatus(serviceId),
    enabled: !!serviceId,
  });
};
