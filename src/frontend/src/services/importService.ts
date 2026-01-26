import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:7071/api';

export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

export interface ImportResult {
  success: boolean;
  serviceId?: number;
  serviceCode?: string;
  message?: string;
  errors?: ValidationError[];
}

export interface BulkImportResult {
  totalCount: number;
  successCount: number;
  failCount: number;
  results: ImportResult[];
}

export interface HealthStatus {
  status: string;
  service: string;
  timestamp: string;
}

class ImportService {
  private axiosInstance;

  constructor() {
    this.axiosInstance = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  /**
   * Check API health
   */
  async checkHealth(): Promise<HealthStatus> {
    const response = await this.axiosInstance.get<HealthStatus>('/services/import/health');
    return response.data;
  }

  /**
   * Validate import without actually importing
   */
  async validateImport(serviceData: any): Promise<{ isValid: boolean; errors?: ValidationError[] }> {
    try {
      const response = await this.axiosInstance.post('/services/import/validate', serviceData);
      return { isValid: response.data.isValid, errors: response.data.errors };
    } catch (error: any) {
      if (error.response?.status === 400) {
        return {
          isValid: false,
          errors: error.response.data.errors || [{ field: 'General', message: error.response.data.message, code: 'VALIDATION_ERROR' }],
        };
      }
      throw error;
    }
  }

  /**
   * Import single service
   */
  async importService(serviceData: any): Promise<ImportResult> {
    try {
      const response = await this.axiosInstance.post<ImportResult>('/services/import', serviceData);
      return response.data;
    } catch (error: any) {
      if (error.response?.status === 400) {
        return {
          success: false,
          message: error.response.data.message,
          errors: error.response.data.errors,
        };
      }
      throw error;
    }
  }

  /**
   * Import multiple services
   */
  async bulkImportServices(servicesData: any[]): Promise<BulkImportResult> {
    const response = await this.axiosInstance.post<BulkImportResult>('/services/import/bulk', servicesData);
    return response.data;
  }

  /**
   * Parse JSON file
   */
  async parseJsonFile(file: File): Promise<any> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = (e) => {
        try {
          const json = JSON.parse(e.target?.result as string);
          resolve(json);
        } catch (error) {
          reject(new Error('Invalid JSON file'));
        }
      };
      reader.onerror = () => reject(new Error('Failed to read file'));
      reader.readAsText(file);
    });
  }
}

export default new ImportService();
