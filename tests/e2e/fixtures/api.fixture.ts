// =============================================================================
// SERVICE CATALOGUE MANAGER - API FIXTURE
// =============================================================================

import { test as base, APIRequestContext, request } from '@playwright/test';

interface ApiFixture {
  apiContext: APIRequestContext;
  createTestService: (data?: Partial<ServiceRequest>) => Promise<ServiceResponse>;
  deleteTestService: (id: number) => Promise<void>;
  getService: (id: number) => Promise<ServiceResponse>;
}

interface ServiceRequest {
  serviceCode: string;
  serviceName: string;
  shortDescription: string;
  statusId: number;
  categoryId: number;
}

interface ServiceResponse {
  id: number;
  serviceCode: string;
  serviceName: string;
}

const API_URL = process.env.API_URL || 'http://localhost:7071/api';

export const test = base.extend<ApiFixture>({
  apiContext: async ({}, use) => {
    const context = await request.newContext({
      baseURL: API_URL,
      extraHTTPHeaders: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.API_TOKEN || ''}`,
      },
    });
    await use(context);
    await context.dispose();
  },

  createTestService: async ({ apiContext }, use) => {
    const createdIds: number[] = [];
    
    const create = async (data?: Partial<ServiceRequest>): Promise<ServiceResponse> => {
      const uniqueId = Date.now().toString(36);
      const payload: ServiceRequest = {
        serviceCode: `API-${uniqueId}`.substring(0, 15),
        serviceName: `API Test Service ${uniqueId}`,
        shortDescription: 'Created via API fixture',
        statusId: 1,
        categoryId: 1,
        ...data,
      };
      
      const response = await apiContext.post('/services', { data: payload });
      const service = await response.json();
      createdIds.push(service.id);
      return service;
    };
    
    await use(create);
    
    // Cleanup
    for (const id of createdIds) {
      await apiContext.delete(`/services/${id}`).catch(() => {});
    }
  },

  deleteTestService: async ({ apiContext }, use) => {
    const deleteService = async (id: number): Promise<void> => {
      await apiContext.delete(`/services/${id}`);
    };
    await use(deleteService);
  },

  getService: async ({ apiContext }, use) => {
    const get = async (id: number): Promise<ServiceResponse> => {
      const response = await apiContext.get(`/services/${id}`);
      return response.json();
    };
    await use(get);
  },
});

export const expect = base.expect;
