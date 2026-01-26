import { apiClient, ApiResponse } from './apiClient';
import { ENDPOINTS } from './endpoints';

export type ExportFormat = 'pdf' | 'markdown';

export interface ExportRequest {
  serviceIds: number[];
  format: ExportFormat;
  options?: ExportOptions;
}

export interface ExportOptions {
  includeUsageScenarios?: boolean;
  includeDependencies?: boolean;
  includeScope?: boolean;
  includeTimeline?: boolean;
  includeTeam?: boolean;
  includeEffort?: boolean;
  includeLicenses?: boolean;
  templateId?: string;
}

export interface ExportOperationResponse {
  operationId: string;
  status: ExportStatus;
  format: ExportFormat;
  createdAt: string;
  estimatedCompletionTime?: string;
}

export type ExportStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';

export interface ExportStatusResponse {
  operationId: string;
  status: ExportStatus;
  progress: number;
  message?: string;
  downloadUrl?: string;
  fileName?: string;
  fileSize?: number;
  completedAt?: string;
  error?: string;
}

export interface ExportHistoryItem {
  operationId: string;
  format: ExportFormat;
  status: ExportStatus;
  serviceCount: number;
  fileName?: string;
  fileSize?: number;
  createdAt: string;
  completedAt?: string;
  createdBy: string;
  downloadUrl?: string;
  expiresAt?: string;
}

export interface ExportHistoryParams {
  page?: number;
  pageSize?: number;
  format?: ExportFormat;
  status?: ExportStatus;
  fromDate?: string;
  toDate?: string;
}

export interface ExportHistoryResponse {
  items: ExportHistoryItem[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export const exportApi = {
  /**
   * Start PDF export operation
   */
  async exportPdf(request: Omit<ExportRequest, 'format'>): Promise<ApiResponse<ExportOperationResponse>> {
    return apiClient.post<ExportOperationResponse>(ENDPOINTS.export.pdf, {
      ...request,
      format: 'pdf',
    });
  },

  /**
   * Get PDF export status
   */
  async getPdfStatus(operationId: string): Promise<ApiResponse<ExportStatusResponse>> {
    return apiClient.get<ExportStatusResponse>(ENDPOINTS.export.pdfStatus(operationId));
  },

  /**
   * Download PDF export
   */
  async downloadPdf(operationId: string, filename: string): Promise<void> {
    return apiClient.downloadFile(ENDPOINTS.export.pdfDownload(operationId), filename);
  },

  /**
   * Start Markdown export operation
   */
  async exportMarkdown(request: Omit<ExportRequest, 'format'>): Promise<ApiResponse<ExportOperationResponse>> {
    return apiClient.post<ExportOperationResponse>(ENDPOINTS.export.markdown, {
      ...request,
      format: 'markdown',
    });
  },

  /**
   * Get Markdown export status
   */
  async getMarkdownStatus(operationId: string): Promise<ApiResponse<ExportStatusResponse>> {
    return apiClient.get<ExportStatusResponse>(ENDPOINTS.export.markdownStatus(operationId));
  },

  /**
   * Download Markdown export
   */
  async downloadMarkdown(operationId: string, filename: string): Promise<void> {
    return apiClient.downloadFile(ENDPOINTS.export.markdownDownload(operationId), filename);
  },

  /**
   * Get export history
   */
  async getHistory(params: ExportHistoryParams = {}): Promise<ApiResponse<ExportHistoryResponse>> {
    return apiClient.get<ExportHistoryResponse>(ENDPOINTS.export.history, {
      params: {
        page: params.page,
        pageSize: params.pageSize,
        format: params.format,
        status: params.status,
        fromDate: params.fromDate,
        toDate: params.toDate,
      },
    });
  },

  /**
   * Cancel export operation
   */
  async cancel(operationId: string): Promise<ApiResponse<void>> {
    return apiClient.post<void>(ENDPOINTS.export.cancel(operationId));
  },

  /**
   * Generic export with format parameter
   */
  async export(request: ExportRequest): Promise<ApiResponse<ExportOperationResponse>> {
    if (request.format === 'pdf') {
      return this.exportPdf(request);
    }
    return this.exportMarkdown(request);
  },

  /**
   * Get export status by format
   */
  async getStatus(operationId: string, format: ExportFormat): Promise<ApiResponse<ExportStatusResponse>> {
    if (format === 'pdf') {
      return this.getPdfStatus(operationId);
    }
    return this.getMarkdownStatus(operationId);
  },
};

export default exportApi;
