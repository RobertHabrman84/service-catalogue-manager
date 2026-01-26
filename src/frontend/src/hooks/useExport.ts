import { useState, useCallback } from 'react';
import { useApi } from './useApi';

export type ExportFormat = 'pdf' | 'markdown';
export type ExportStatus = 'idle' | 'pending' | 'processing' | 'completed' | 'failed';

export interface ExportRequest {
  serviceIds?: number[];
  format: ExportFormat;
  includeAllServices?: boolean;
  options?: {
    includeToc?: boolean;
    includeCoverPage?: boolean;
    includeTimestamp?: boolean;
  };
}

export interface ExportResult {
  exportId: string;
  status: ExportStatus;
  downloadUrl?: string;
  fileName?: string;
  createdAt: string;
  completedAt?: string;
  error?: string;
}

export interface ExportHistoryItem {
  id: string;
  format: ExportFormat;
  status: ExportStatus;
  fileName: string;
  downloadUrl?: string;
  serviceCount: number;
  createdAt: string;
  completedAt?: string;
  expiresAt?: string;
}

export interface UseExportResult {
  isExporting: boolean;
  progress: number;
  currentExport: ExportResult | null;
  history: ExportHistoryItem[];
  error: string | null;
  exportToPdf: (request: Omit<ExportRequest, 'format'>) => Promise<ExportResult | null>;
  exportToMarkdown: (request: Omit<ExportRequest, 'format'>) => Promise<ExportResult | null>;
  exportCatalogToPdf: () => Promise<ExportResult | null>;
  exportCatalogToMarkdown: () => Promise<ExportResult | null>;
  checkStatus: (exportId: string) => Promise<ExportResult | null>;
  downloadExport: (downloadUrl: string, fileName: string) => void;
  fetchHistory: () => Promise<void>;
  clearError: () => void;
}

export const useExport = (): UseExportResult => {
  const [isExporting, setIsExporting] = useState(false);
  const [progress, setProgress] = useState(0);
  const [currentExport, setCurrentExport] = useState<ExportResult | null>(null);
  const [history, setHistory] = useState<ExportHistoryItem[]>([]);
  const [error, setError] = useState<string | null>(null);

  const exportPdfApi = useApi<ExportResult>('/export/pdf', 'POST');
  const exportMarkdownApi = useApi<ExportResult>('/export/markdown', 'POST');
  const exportCatalogPdfApi = useApi<ExportResult>('/export/catalog/pdf', 'POST');
  const exportCatalogMarkdownApi = useApi<ExportResult>('/export/catalog/markdown', 'POST');
  const statusApi = useApi<ExportResult>((id: unknown) => `/export/status/${id}`, 'GET');
  const historyApi = useApi<ExportHistoryItem[]>('/export/history', 'GET');

  const pollStatus = useCallback(async (exportId: string): Promise<ExportResult | null> => {
    const maxAttempts = 60;
    let attempts = 0;

    while (attempts < maxAttempts) {
      const result = await statusApi.execute(exportId);
      if (result) {
        setCurrentExport(result);
        setProgress(result.status === 'processing' ? Math.min(90, (attempts / maxAttempts) * 100) : 100);

        if (result.status === 'completed' || result.status === 'failed') {
          return result;
        }
      }
      await new Promise((resolve) => setTimeout(resolve, 2000));
      attempts++;
    }

    setError('Export timed out');
    return null;
  }, [statusApi]);

  const performExport = useCallback(async (
    api: typeof exportPdfApi,
    request: ExportRequest
  ): Promise<ExportResult | null> => {
    setIsExporting(true);
    setProgress(0);
    setError(null);

    const result = await api.execute(request);
    if (result) {
      setProgress(10);
      const finalResult = await pollStatus(result.exportId);
      setIsExporting(false);
      return finalResult;
    } else if (api.error) {
      setError(api.error.message);
    }

    setIsExporting(false);
    return null;
  }, [pollStatus]);

  const exportToPdf = useCallback(async (request: Omit<ExportRequest, 'format'>): Promise<ExportResult | null> => {
    return performExport(exportPdfApi, { ...request, format: 'pdf' });
  }, [performExport, exportPdfApi]);

  const exportToMarkdown = useCallback(async (request: Omit<ExportRequest, 'format'>): Promise<ExportResult | null> => {
    return performExport(exportMarkdownApi, { ...request, format: 'markdown' });
  }, [performExport, exportMarkdownApi]);

  const exportCatalogToPdf = useCallback(async (): Promise<ExportResult | null> => {
    return performExport(exportCatalogPdfApi, { format: 'pdf', includeAllServices: true });
  }, [performExport, exportCatalogPdfApi]);

  const exportCatalogToMarkdown = useCallback(async (): Promise<ExportResult | null> => {
    return performExport(exportCatalogMarkdownApi, { format: 'markdown', includeAllServices: true });
  }, [performExport, exportCatalogMarkdownApi]);

  const checkStatus = useCallback(async (exportId: string): Promise<ExportResult | null> => {
    const result = await statusApi.execute(exportId);
    if (result) {
      setCurrentExport(result);
    }
    return result;
  }, [statusApi]);

  const downloadExport = useCallback((downloadUrl: string, fileName: string) => {
    const link = document.createElement('a');
    link.href = downloadUrl;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }, []);

  const fetchHistory = useCallback(async () => {
    const result = await historyApi.execute();
    if (result) {
      setHistory(result);
    }
  }, [historyApi]);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    isExporting,
    progress,
    currentExport,
    history,
    error,
    exportToPdf,
    exportToMarkdown,
    exportCatalogToPdf,
    exportCatalogToMarkdown,
    checkStatus,
    downloadExport,
    fetchHistory,
    clearError,
  };
};

export default useExport;
