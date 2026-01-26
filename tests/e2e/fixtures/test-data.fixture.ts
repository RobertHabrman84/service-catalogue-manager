// =============================================================================
// SERVICE CATALOGUE MANAGER - TEST DATA FIXTURE
// =============================================================================

import { test as base } from '@playwright/test';

interface ServiceData {
  code: string;
  name: string;
  shortDescription: string;
  status: string;
  category: string;
}

interface TestDataFixture {
  testService: ServiceData;
  createUniqueService: () => ServiceData;
  services: ServiceData[];
}

export const test = base.extend<TestDataFixture>({
  testService: async ({}, use) => {
    const service: ServiceData = {
      code: 'TST-001',
      name: 'Test Service',
      shortDescription: 'A test service for E2E testing',
      status: 'Draft',
      category: 'Application',
    };
    await use(service);
  },

  createUniqueService: async ({}, use) => {
    const createService = (): ServiceData => {
      const uniqueId = Date.now().toString(36);
      return {
        code: `E2E-${uniqueId}`.substring(0, 15),
        name: `E2E Test Service ${uniqueId}`,
        shortDescription: 'Auto-generated service for E2E testing',
        status: 'Draft',
        category: 'Application',
      };
    };
    await use(createService);
  },

  services: async ({}, use) => {
    const services: ServiceData[] = [
      { code: 'APP-001', name: 'Core Application', shortDescription: 'Main app', status: 'Active', category: 'Application' },
      { code: 'INFRA-001', name: 'Infrastructure Service', shortDescription: 'Infra', status: 'Active', category: 'Infrastructure' },
      { code: 'DATA-001', name: 'Data Service', shortDescription: 'Data', status: 'Draft', category: 'Data' },
    ];
    await use(services);
  },
});

export const expect = base.expect;
