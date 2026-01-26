import { http, HttpResponse } from 'msw';

const API_BASE = '/api';

// Mock data
const mockServices = [
  {
    serviceId: 1,
    serviceCode: 'SVC-001',
    serviceName: 'Cloud Migration Assessment',
    version: '1.0.0',
    categoryId: 1,
    categoryName: 'Assessment',
    description: 'Comprehensive cloud readiness assessment',
    isActive: true,
    isPublished: true,
    createdAt: '2024-01-15T10:00:00Z',
    updatedAt: '2024-01-20T14:30:00Z',
  },
  {
    serviceId: 2,
    serviceCode: 'SVC-002',
    serviceName: 'DevOps Implementation',
    version: '2.0.0',
    categoryId: 2,
    categoryName: 'Implementation',
    description: 'Full DevOps pipeline setup',
    isActive: true,
    isPublished: false,
    createdAt: '2024-01-10T08:00:00Z',
    updatedAt: '2024-01-18T16:45:00Z',
  },
];

const mockCategories = [
  { categoryId: 1, categoryCode: 'ASSESS', categoryName: 'Assessment', sortOrder: 1, isActive: true },
  { categoryId: 2, categoryCode: 'IMPL', categoryName: 'Implementation', sortOrder: 2, isActive: true },
  { categoryId: 3, categoryCode: 'MGMT', categoryName: 'Management', sortOrder: 3, isActive: true },
];

const mockSizeOptions = [
  { sizeOptionId: 1, sizeCode: 'S', sizeName: 'Small', sortOrder: 1 },
  { sizeOptionId: 2, sizeCode: 'M', sizeName: 'Medium', sortOrder: 2 },
  { sizeOptionId: 3, sizeCode: 'L', sizeName: 'Large', sortOrder: 3 },
];

const mockCloudProviders = [
  { cloudProviderId: 1, providerCode: 'AZURE', providerName: 'Microsoft Azure', isActive: true },
  { cloudProviderId: 2, providerCode: 'AWS', providerName: 'Amazon Web Services', isActive: true },
  { cloudProviderId: 3, providerCode: 'GCP', providerName: 'Google Cloud Platform', isActive: true },
];

export const handlers = [
  // Services
  http.get(`${API_BASE}/services`, () => {
    return HttpResponse.json({
      items: mockServices,
      totalCount: mockServices.length,
      page: 1,
      pageSize: 20,
      totalPages: 1,
    });
  }),

  http.get(`${API_BASE}/services/:id`, ({ params }) => {
    const service = mockServices.find(s => s.serviceId === Number(params.id));
    if (!service) {
      return new HttpResponse(null, { status: 404 });
    }
    return HttpResponse.json(service);
  }),

  http.post(`${API_BASE}/services`, async ({ request }) => {
    const body = await request.json();
    const newService = {
      serviceId: mockServices.length + 1,
      ...body,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    return HttpResponse.json(newService, { status: 201 });
  }),

  http.put(`${API_BASE}/services/:id`, async ({ params, request }) => {
    const body = await request.json();
    const service = mockServices.find(s => s.serviceId === Number(params.id));
    if (!service) {
      return new HttpResponse(null, { status: 404 });
    }
    const updated = { ...service, ...body, updatedAt: new Date().toISOString() };
    return HttpResponse.json(updated);
  }),

  http.delete(`${API_BASE}/services/:id`, ({ params }) => {
    const index = mockServices.findIndex(s => s.serviceId === Number(params.id));
    if (index === -1) {
      return new HttpResponse(null, { status: 404 });
    }
    return new HttpResponse(null, { status: 204 });
  }),

  // Lookups
  http.get(`${API_BASE}/lookups/all`, () => {
    return HttpResponse.json({
      categories: mockCategories,
      sizeOptions: mockSizeOptions,
      cloudProviders: mockCloudProviders,
      dependencyTypes: [],
      requirementLevels: [],
      scopeTypes: [],
      interactionLevels: [],
      roles: [],
      effortCategories: [],
    });
  }),

  http.get(`${API_BASE}/lookups/categories`, () => {
    return HttpResponse.json(mockCategories);
  }),

  http.get(`${API_BASE}/lookups/size-options`, () => {
    return HttpResponse.json(mockSizeOptions);
  }),

  http.get(`${API_BASE}/lookups/cloud-providers`, () => {
    return HttpResponse.json(mockCloudProviders);
  }),

  // Export
  http.post(`${API_BASE}/export/pdf`, () => {
    return HttpResponse.json({
      operationId: 'export-123',
      status: 'pending',
      format: 'pdf',
      createdAt: new Date().toISOString(),
    });
  }),

  http.get(`${API_BASE}/export/pdf/status/:operationId`, () => {
    return HttpResponse.json({
      operationId: 'export-123',
      status: 'completed',
      progress: 100,
      downloadUrl: '/api/export/pdf/download/export-123',
      fileName: 'export.pdf',
    });
  }),

  // Health
  http.get(`${API_BASE}/health`, () => {
    return HttpResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    });
  }),

  http.get(`${API_BASE}/health/live`, () => {
    return HttpResponse.json({ alive: true, timestamp: new Date().toISOString() });
  }),

  http.get(`${API_BASE}/health/ready`, () => {
    return HttpResponse.json({ ready: true, timestamp: new Date().toISOString(), checks: [] });
  }),

  // Dashboard
  http.get(`${API_BASE}/dashboard/stats`, () => {
    return HttpResponse.json({
      totalServices: 25,
      activeServices: 20,
      archivedServices: 3,
      draftServices: 2,
      categoryCounts: [
        { categoryId: 1, categoryName: 'Assessment', count: 10 },
        { categoryId: 2, categoryName: 'Implementation', count: 15 },
      ],
      cloudProviderCounts: [
        { providerId: 1, providerName: 'Azure', count: 15 },
        { providerId: 2, providerName: 'AWS', count: 10 },
      ],
      recentActivity: {
        createdLast7Days: 5,
        updatedLast7Days: 12,
        publishedLast7Days: 3,
      },
    });
  }),
];

export default handlers;
