// types/index.ts
// TypeScript type definitions for Service Catalogue Manager

// ============================================
// Base Types
// ============================================

export interface BaseEntity {
  createdAt: string;
  createdBy: string;
  updatedAt?: string;
  updatedBy?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  totalCount: number;
  pageNumber: number;
  pageSize: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}

export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
  errors?: string[];
}

// ============================================
// Lookup Types
// ============================================

export interface ServiceCategory {
  categoryId: number;
  categoryCode: string;
  categoryName: string;
  parentCategoryId?: number;
  categoryPath?: string;
  sortOrder: number;
  isActive: boolean;
}

export interface DependencyType {
  dependencyTypeId: number;
  typeCode: string;
  typeName: string;
  description?: string;
}

export interface RequirementLevel {
  requirementLevelId: number;
  levelCode: string;
  levelName: string;
}

export interface PrerequisiteCategory {
  prerequisiteCategoryId: number;
  categoryCode: string;
  categoryName: string;
}

export interface CloudProvider {
  cloudProviderId: number;
  providerCode: string;
  providerName: string;
  isActive: boolean;
}

export interface ToolCategory {
  toolCategoryId: number;
  categoryCode: string;
  categoryName: string;
}

export interface LicenseType {
  licenseTypeId: number;
  typeCode: string;
  typeName: string;
}

export interface InteractionLevel {
  interactionLevelId: number;
  levelCode: string;
  levelName: string;
  description?: string;
}

export interface SizeOption {
  sizeOptionId: number;
  sizeCode: string;
  sizeName: string;
  sortOrder: number;
}

export interface Role {
  roleId: number;
  roleCode: string;
  roleName: string;
  description?: string;
}

// ============================================
// Service Catalog Types
// ============================================

export interface UsageScenario {
  usageScenarioId?: number;
  scenarioNumber: number;
  scenarioTitle: string;
  scenarioDescription: string;
}

export interface ServiceDependency {
  serviceDependencyId?: number;
  dependencyTypeId: number;
  dependentServiceId?: number;
  dependentServiceName: string;
  requirementLevelId?: number;
  notes?: string;
  // Expanded
  dependencyType?: DependencyType;
  requirementLevel?: RequirementLevel;
}

export interface ScopeCategory {
  scopeCategoryId?: number;
  categoryName: string;
  isInScope: boolean;
  items: ScopeItem[];
}

export interface ScopeItem {
  scopeItemId?: number;
  itemDescription: string;
  sortOrder: number;
}

export interface Prerequisite {
  prerequisiteId?: number;
  prerequisiteCategoryId: number;
  prerequisiteDescription: string;
  // Expanded
  category?: PrerequisiteCategory;
}

export interface CloudProviderCapability {
  capabilityId?: number;
  cloudProviderId: number;
  capabilityType: string;
  capabilityName: string;
  notes?: string;
  // Expanded
  cloudProvider?: CloudProvider;
}

export interface ToolFramework {
  toolFrameworkId?: number;
  toolCategoryId: number;
  toolName: string;
  description?: string;
  // Expanded
  toolCategory?: ToolCategory;
}

export interface License {
  licenseId?: number;
  licenseTypeId: number;
  licenseDescription: string;
  cloudProviderId?: number;
  // Expanded
  licenseType?: LicenseType;
  cloudProvider?: CloudProvider;
}

export interface ServiceInteraction {
  serviceInteractionId?: number;
  interactionLevelId: number;
  notes?: string;
  // Expanded
  interactionLevel?: InteractionLevel;
}

export interface CustomerRequirement {
  requirementId?: number;
  requirementDescription: string;
}

export interface AccessRequirement {
  requirementId?: number;
  requirementDescription: string;
}

export interface StakeholderInvolvement {
  involvementId?: number;
  stakeholderRole: string;
  involvementDescription: string;
}

export interface InputParameter {
  inputParameterId?: number;
  parameterName: string;
  parameterDescription: string;
  requirementLevelId: number;
  dataType?: string;
  defaultValue?: string;
  // Expanded
  requirementLevel?: RequirementLevel;
}

export interface OutputCategory {
  outputCategoryId?: number;
  categoryName: string;
  items: OutputItem[];
}

export interface OutputItem {
  outputItemId?: number;
  itemDescription: string;
  sortOrder: number;
}

export interface TimelinePhase {
  phaseId?: number;
  phaseNumber: number;
  phaseName: string;
}

export interface ServiceSizeOption {
  serviceSizeOptionId?: number;
  sizeOptionId: number;
  scopeDescription: string;
  durationDisplay: string;
  effortDisplay: string;
  teamSizeDisplay: string;
  complexity?: string;
  // Expanded
  sizeOption?: SizeOption;
}

export interface SizingCriteria {
  criteriaId?: number;
  criteriaName: string;
  values: SizingCriteriaValue[];
}

export interface SizingCriteriaValue {
  valueId?: number;
  sizeOptionId: number;
  criteriaValue: string;
}

export interface EffortEstimationItem {
  itemId?: number;
  sizeOptionId: number;
  activityName: string;
  hoursEstimate: number;
  notes?: string;
}

export interface TechnicalComplexityAddition {
  additionId?: number;
  additionName: string;
  condition: string;
  hoursAdded: number;
  notes?: string;
}

export interface ResponsibleRole {
  responsibleRoleId?: number;
  roleId: number;
  isPrimaryOwner: boolean;
  responsibility: string;
  // Expanded
  role?: Role;
}

export interface TeamAllocation {
  allocationId?: number;
  sizeOptionId: number;
  roleId: number;
  fteAllocation: number;
  notes?: string;
  // Expanded
  role?: Role;
  sizeOption?: SizeOption;
}

export interface MultiCloudConsideration {
  considerationId?: number;
  considerationTitle: string;
  considerationDescription: string;
}

export interface SizingExample {
  exampleId?: number;
  sizeOptionId: number;
  exampleTitle: string;
  scenario: string;
  characteristics: string[];
  deliverables?: string;
  // Expanded
  sizeOption?: SizeOption;
}

// Main Service Catalog Item
export interface ServiceCatalogItem extends BaseEntity {
  serviceId: number;
  serviceCode: string;
  serviceName: string;
  version: string;
  categoryId: number;
  description: string;
  notes?: string;
  isActive: boolean;
  isPublished: boolean;
  publishedAt?: string;
  
  // Related entities
  category?: ServiceCategory;
  usageScenarios?: UsageScenario[];
  dependencies?: ServiceDependency[];
  inScopeCategories?: ScopeCategory[];
  outScopeCategories?: ScopeCategory[];
  prerequisites?: Prerequisite[];
  cloudProviderCapabilities?: CloudProviderCapability[];
  toolsFrameworks?: ToolFramework[];
  licenses?: License[];
  interaction?: ServiceInteraction;
  customerRequirements?: CustomerRequirement[];
  accessRequirements?: AccessRequirement[];
  stakeholderInvolvements?: StakeholderInvolvement[];
  inputs?: InputParameter[];
  outputCategories?: OutputCategory[];
  timelinePhases?: TimelinePhase[];
  sizeOptions?: ServiceSizeOption[];
  sizingCriteria?: SizingCriteria[];
  effortEstimationItems?: EffortEstimationItem[];
  technicalComplexityAdditions?: TechnicalComplexityAddition[];
  responsibleRoles?: ResponsibleRole[];
  teamAllocations?: TeamAllocation[];
  multiCloudConsiderations?: MultiCloudConsideration[];
  sizingExamples?: SizingExample[];
}

// ============================================
// Form Types
// ============================================

export interface ServiceCatalogFormData extends Omit<ServiceCatalogItem, 'serviceId' | 'createdAt' | 'createdBy' | 'updatedAt' | 'updatedBy' | 'isActive' | 'isPublished' | 'publishedAt' | 'category'> {}

// ============================================
// Filter & Search Types
// ============================================

export interface ServiceCatalogFilters {
  search?: string;
  categoryId?: number;
  isActive?: boolean;
  isPublished?: boolean;
  sizeOptionId?: number;
  cloudProviderId?: number;
  sortBy?: string;
  sortDirection?: 'asc' | 'desc';
}

// ============================================
// Export Types
// ============================================

export type ExportFormat = 'pdf' | 'markdown' | 'uubookkit';

export interface ExportOptions {
  format: ExportFormat;
  serviceIds: number[];
  includeAllSections: boolean;
  sections?: string[];
  templateId?: string;
}

export interface ExportResult {
  exportId: string;
  format: ExportFormat;
  fileName: string;
  downloadUrl: string;
  expiresAt: string;
}

// ============================================
// uuBookKit Types
// ============================================

export interface UuBookKitPublishOptions {
  serviceId: number;
  bookUri: string;
  pageCode: string;
  overwrite: boolean;
}

export interface UuBookKitSyncStatus {
  serviceId: number;
  lastSyncedAt?: string;
  syncStatus: 'synced' | 'pending' | 'failed' | 'never';
  uuBookKitPageUrl?: string;
}

// ============================================
// User & Auth Types
// ============================================

export interface User {
  id: string;
  email: string;
  displayName: string;
  roles: string[];
  avatar?: string;
}

export interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  accessToken: string | null;
  isLoading: boolean;
  error: string | null;
}

// ============================================
// Re-exports from sub-modules
// ============================================

export * from './api';
export * from './common';
export * from './lookups';
export * from './models/ServiceCatalogItem';

// ============================================
// List Item Type (for catalog views)
// ============================================

export interface ServiceCatalogListItem {
  serviceId: number;
  serviceCode: string;
  serviceName: string;
  version: string;
  categoryId: number;
  categoryName: string;
  description: string;
  isActive: boolean;
  isPublished: boolean;
  publishedAt?: string;
  createdAt: string;
  updatedAt?: string;
}
