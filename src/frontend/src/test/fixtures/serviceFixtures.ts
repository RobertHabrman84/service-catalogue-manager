import { ServiceCatalogItem, ServiceCatalogListItem } from '../../types';

export const createServiceListItem = (overrides: Partial<ServiceCatalogListItem> = {}): ServiceCatalogListItem => ({
  serviceId: 1,
  serviceCode: 'SVC-001',
  serviceName: 'Test Service',
  version: '1.0.0',
  categoryId: 1,
  categoryName: 'Assessment',
  description: 'Test service description',
  isActive: true,
  isPublished: false,
  createdAt: '2024-01-01T00:00:00Z',
  updatedAt: '2024-01-01T00:00:00Z',
  ...overrides,
});

export const createServiceCatalogItem = (overrides: Partial<ServiceCatalogItem> = {}): ServiceCatalogItem => ({
  serviceId: 1,
  serviceCode: 'SVC-001',
  serviceName: 'Test Service',
  version: '1.0.0',
  categoryId: 1,
  description: 'Test service description',
  notes: '',
  isActive: true,
  isPublished: false,
  createdAt: '2024-01-01T00:00:00Z',
  createdBy: 'test@example.com',
  updatedAt: '2024-01-01T00:00:00Z',
  updatedBy: 'test@example.com',
  category: {
    categoryId: 1,
    categoryCode: 'ASSESS',
    categoryName: 'Assessment',
    sortOrder: 1,
    isActive: true,
  },
  usageScenarios: [],
  dependencies: [],
  inScopeCategories: [],
  outScopeCategories: [],
  prerequisites: [],
  cloudProviderCapabilities: [],
  toolsFrameworks: [],
  licenses: [],
  customerRequirements: [],
  accessRequirements: [],
  stakeholderInvolvements: [],
  inputs: [],
  outputCategories: [],
  timelinePhases: [],
  sizeOptions: [],
  sizingCriteria: [],
  effortEstimationItems: [],
  technicalComplexityAdditions: [],
  responsibleRoles: [],
  teamAllocations: [],
  multiCloudConsiderations: [],
  sizingExamples: [],
  ...overrides,
});

export const createServiceList = (count: number): ServiceCatalogListItem[] => {
  return Array.from({ length: count }, (_, index) =>
    createServiceListItem({
      serviceId: index + 1,
      serviceCode: `SVC-${String(index + 1).padStart(3, '0')}`,
      serviceName: `Test Service ${index + 1}`,
    })
  );
};

export const mockUsageScenario = {
  usageScenarioId: 1,
  scenarioNumber: 1,
  scenarioTitle: 'Standard Migration',
  scenarioDescription: 'Standard cloud migration scenario',
};

export const mockDependency = {
  serviceDependencyId: 1,
  dependencyTypeId: 1,
  dependentServiceName: 'Base Infrastructure',
  notes: 'Required for all services',
};

export const mockPrerequisite = {
  prerequisiteId: 1,
  prerequisiteCategoryId: 1,
  prerequisiteDescription: 'Active Azure subscription',
};

export const mockInput = {
  inputParameterId: 1,
  parameterName: 'Project Name',
  parameterDescription: 'Name of the project',
  requirementLevelId: 1,
  dataType: 'string',
};

export const mockTimelinePhase = {
  phaseId: 1,
  phaseNumber: 1,
  phaseName: 'Discovery',
};

export const mockResponsibleRole = {
  responsibleRoleId: 1,
  roleId: 1,
  isPrimaryOwner: true,
  responsibility: 'Overall project delivery',
};

export default {
  createServiceListItem,
  createServiceCatalogItem,
  createServiceList,
  mockUsageScenario,
  mockDependency,
  mockPrerequisite,
  mockInput,
  mockTimelinePhase,
  mockResponsibleRole,
};
