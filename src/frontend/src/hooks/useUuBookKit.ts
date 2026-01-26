import { useState, useCallback } from 'react';
import { useApi } from './useApi';

export type PublishStatus = 'idle' | 'pending' | 'publishing' | 'completed' | 'failed';
export type SyncStatus = 'synced' | 'pending' | 'out_of_sync' | 'error';

export interface PublishRequest {
  serviceId: number;
  targetBookCode: string;
  createNewPage?: boolean;
  updateExisting?: boolean;
}

export interface PublishResult {
  publishId: string;
  status: PublishStatus;
  pageCode?: string;
  pageUrl?: string;
  publishedAt?: string;
  error?: string;
}

export interface SyncStatusResult {
  serviceId: number;
  serviceCode: string;
  localVersion: string;
  publishedVersion?: string;
  status: SyncStatus;
  lastSyncedAt?: string;
  pageUrl?: string;
}

export interface PublishHistoryItem {
  id: string;
  serviceId: number;
  serviceCode: string;
  serviceName: string;
  status: PublishStatus;
  pageCode?: string;
  pageUrl?: string;
  publishedAt: string;
  publishedBy: string;
}

export interface UseUuBookKitResult {
  isPublishing: boolean;
  progress: number;
  currentPublish: PublishResult | null;
  syncStatuses: SyncStatusResult[];
  publishHistory: PublishHistoryItem[];
  error: string | null;
  publishPage: (request: PublishRequest) => Promise<PublishResult | null>;
  updatePage: (serviceId: number) => Promise<PublishResult | null>;
  createPage: (serviceId: number, targetBookCode: string) => Promise<PublishResult | null>;
  checkPublishStatus: (publishId: string) => Promise<PublishResult | null>;
  getSyncStatus: (serviceId: number) => Promise<SyncStatusResult | null>;
  getAllSyncStatuses: () => Promise<void>;
  syncCatalog: () => Promise<boolean>;
  fetchPublishHistory: (serviceId?: number) => Promise<void>;
  clearError: () => void;
}

export const useUuBookKit = (): UseUuBookKitResult => {
  const [isPublishing, setIsPublishing] = useState(false);
  const [progress, setProgress] = useState(0);
  const [currentPublish, setCurrentPublish] = useState<PublishResult | null>(null);
  const [syncStatuses, setSyncStatuses] = useState<SyncStatusResult[]>([]);
  const [publishHistory, setPublishHistory] = useState<PublishHistoryItem[]>([]);
  const [error, setError] = useState<string | null>(null);

  const publishApi = useApi<PublishResult>('/uubookkit/publish', 'POST');
  const updateApi = useApi<PublishResult>((id: unknown) => `/uubookkit/update/${id}`, 'POST');
  const createApi = useApi<PublishResult>('/uubookkit/create', 'POST');
  const statusApi = useApi<PublishResult>((id: unknown) => `/uubookkit/status/${id}`, 'GET');
  const syncStatusApi = useApi<SyncStatusResult>((id: unknown) => `/uubookkit/sync-status/${id}`, 'GET');
  const allSyncStatusApi = useApi<SyncStatusResult[]>('/uubookkit/sync-status', 'GET');
  const syncCatalogApi = useApi<void>('/uubookkit/sync-catalog', 'POST');
  const historyApi = useApi<PublishHistoryItem[]>((id?: unknown) => 
    id ? `/uubookkit/history/${id}` : '/uubookkit/history', 'GET'
  );

  const pollStatus = useCallback(async (publishId: string): Promise<PublishResult | null> => {
    const maxAttempts = 60;
    let attempts = 0;

    while (attempts < maxAttempts) {
      const result = await statusApi.execute(publishId);
      if (result) {
        setCurrentPublish(result);
        setProgress(result.status === 'publishing' ? Math.min(90, (attempts / maxAttempts) * 100) : 100);

        if (result.status === 'completed' || result.status === 'failed') {
          return result;
        }
      }
      await new Promise((resolve) => setTimeout(resolve, 2000));
      attempts++;
    }

    setError('Publish timed out');
    return null;
  }, [statusApi]);

  const publishPage = useCallback(async (request: PublishRequest): Promise<PublishResult | null> => {
    setIsPublishing(true);
    setProgress(0);
    setError(null);

    const result = await publishApi.execute(request);
    if (result) {
      setProgress(10);
      const finalResult = await pollStatus(result.publishId);
      setIsPublishing(false);
      return finalResult;
    } else if (publishApi.error) {
      setError(publishApi.error.message);
    }

    setIsPublishing(false);
    return null;
  }, [publishApi, pollStatus]);

  const updatePage = useCallback(async (serviceId: number): Promise<PublishResult | null> => {
    setIsPublishing(true);
    setProgress(0);
    setError(null);

    const result = await updateApi.execute(serviceId);
    if (result) {
      setProgress(10);
      const finalResult = await pollStatus(result.publishId);
      setIsPublishing(false);
      return finalResult;
    } else if (updateApi.error) {
      setError(updateApi.error.message);
    }

    setIsPublishing(false);
    return null;
  }, [updateApi, pollStatus]);

  const createPage = useCallback(async (serviceId: number, targetBookCode: string): Promise<PublishResult | null> => {
    return publishPage({ serviceId, targetBookCode, createNewPage: true });
  }, [publishPage]);

  const checkPublishStatus = useCallback(async (publishId: string): Promise<PublishResult | null> => {
    const result = await statusApi.execute(publishId);
    if (result) {
      setCurrentPublish(result);
    }
    return result;
  }, [statusApi]);

  const getSyncStatus = useCallback(async (serviceId: number): Promise<SyncStatusResult | null> => {
    const result = await syncStatusApi.execute(serviceId);
    return result;
  }, [syncStatusApi]);

  const getAllSyncStatuses = useCallback(async () => {
    const result = await allSyncStatusApi.execute();
    if (result) {
      setSyncStatuses(result);
    }
  }, [allSyncStatusApi]);

  const syncCatalog = useCallback(async (): Promise<boolean> => {
    setIsPublishing(true);
    setError(null);

    await syncCatalogApi.execute();
    const success = !syncCatalogApi.error;
    
    if (!success) {
      setError(syncCatalogApi.error?.message || 'Sync failed');
    } else {
      await getAllSyncStatuses();
    }

    setIsPublishing(false);
    return success;
  }, [syncCatalogApi, getAllSyncStatuses]);

  const fetchPublishHistory = useCallback(async (serviceId?: number) => {
    const result = await historyApi.execute(serviceId);
    if (result) {
      setPublishHistory(result);
    }
  }, [historyApi]);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    isPublishing,
    progress,
    currentPublish,
    syncStatuses,
    publishHistory,
    error,
    publishPage,
    updatePage,
    createPage,
    checkPublishStatus,
    getSyncStatus,
    getAllSyncStatuses,
    syncCatalog,
    fetchPublishHistory,
    clearError,
  };
};

export default useUuBookKit;
