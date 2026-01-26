import {
  ServiceCategory,
  SizeOption,
  CloudProvider,
  DependencyType,
  RequirementLevel,
  InteractionLevel,
  Role,
} from '../../types';

export const mockCategories: ServiceCategory[] = [
  {
    categoryId: 1,
    categoryCode: 'ASSESS',
    categoryName: 'Assessment',
    sortOrder: 1,
    isActive: true,
  },
  {
    categoryId: 2,
    categoryCode: 'IMPL',
    categoryName: 'Implementation',
    sortOrder: 2,
    isActive: true,
  },
  {
    categoryId: 3,
    categoryCode: 'MGMT',
    categoryName: 'Management',
    sortOrder: 3,
    isActive: true,
  },
  {
    categoryId: 4,
    categoryCode: 'SUPPORT',
    categoryName: 'Support',
    sortOrder: 4,
    isActive: true,
  },
];

export const mockSizeOptions: SizeOption[] = [
  { sizeOptionId: 1, sizeCode: 'XS', sizeName: 'Extra Small', sortOrder: 1 },
  { sizeOptionId: 2, sizeCode: 'S', sizeName: 'Small', sortOrder: 2 },
  { sizeOptionId: 3, sizeCode: 'M', sizeName: 'Medium', sortOrder: 3 },
  { sizeOptionId: 4, sizeCode: 'L', sizeName: 'Large', sortOrder: 4 },
  { sizeOptionId: 5, sizeCode: 'XL', sizeName: 'Extra Large', sortOrder: 5 },
];

export const mockCloudProviders: CloudProvider[] = [
  { cloudProviderId: 1, providerCode: 'AZURE', providerName: 'Microsoft Azure', isActive: true },
  { cloudProviderId: 2, providerCode: 'AWS', providerName: 'Amazon Web Services', isActive: true },
  { cloudProviderId: 3, providerCode: 'GCP', providerName: 'Google Cloud Platform', isActive: true },
  { cloudProviderId: 4, providerCode: 'OCI', providerName: 'Oracle Cloud', isActive: true },
];

export const mockDependencyTypes: DependencyType[] = [
  { dependencyTypeId: 1, typeCode: 'PREREQ', typeName: 'Prerequisite', description: 'Must be completed before' },
  { dependencyTypeId: 2, typeCode: 'RELATED', typeName: 'Related', description: 'Related service' },
  { dependencyTypeId: 3, typeCode: 'EXTENDS', typeName: 'Extends', description: 'Extends functionality' },
];

export const mockRequirementLevels: RequirementLevel[] = [
  { requirementLevelId: 1, levelCode: 'MUST', levelName: 'Must Have' },
  { requirementLevelId: 2, levelCode: 'SHOULD', levelName: 'Should Have' },
  { requirementLevelId: 3, levelCode: 'COULD', levelName: 'Could Have' },
  { requirementLevelId: 4, levelCode: 'WONT', levelName: "Won't Have" },
];

export const mockInteractionLevels: InteractionLevel[] = [
  { interactionLevelId: 1, levelCode: 'HIGH', levelName: 'High', description: 'Daily interaction' },
  { interactionLevelId: 2, levelCode: 'MEDIUM', levelName: 'Medium', description: 'Weekly interaction' },
  { interactionLevelId: 3, levelCode: 'LOW', levelName: 'Low', description: 'Monthly interaction' },
];

export const mockRoles: Role[] = [
  { roleId: 1, roleCode: 'PM', roleName: 'Project Manager', description: 'Project management' },
  { roleId: 2, roleCode: 'ARCH', roleName: 'Solution Architect', description: 'Architecture design' },
  { roleId: 3, roleCode: 'DEV', roleName: 'Developer', description: 'Development' },
  { roleId: 4, roleCode: 'QA', roleName: 'QA Engineer', description: 'Quality assurance' },
  { roleId: 5, roleCode: 'OPS', roleName: 'Operations', description: 'Operations' },
];

export const mockAllLookups = {
  categories: mockCategories,
  sizeOptions: mockSizeOptions,
  cloudProviders: mockCloudProviders,
  dependencyTypes: mockDependencyTypes,
  requirementLevels: mockRequirementLevels,
  scopeTypes: [],
  interactionLevels: mockInteractionLevels,
  roles: mockRoles,
  effortCategories: [],
};

export const createCategory = (overrides: Partial<ServiceCategory> = {}): ServiceCategory => ({
  categoryId: 1,
  categoryCode: 'TEST',
  categoryName: 'Test Category',
  sortOrder: 1,
  isActive: true,
  ...overrides,
});

export const createSizeOption = (overrides: Partial<SizeOption> = {}): SizeOption => ({
  sizeOptionId: 1,
  sizeCode: 'M',
  sizeName: 'Medium',
  sortOrder: 1,
  ...overrides,
});

export const createCloudProvider = (overrides: Partial<CloudProvider> = {}): CloudProvider => ({
  cloudProviderId: 1,
  providerCode: 'AZURE',
  providerName: 'Microsoft Azure',
  isActive: true,
  ...overrides,
});

export default {
  mockCategories,
  mockSizeOptions,
  mockCloudProviders,
  mockDependencyTypes,
  mockRequirementLevels,
  mockInteractionLevels,
  mockRoles,
  mockAllLookups,
  createCategory,
  createSizeOption,
  createCloudProvider,
};
