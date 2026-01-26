// API Response Types

export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
  errors?: ApiError[];
}

export interface ApiError {
  code: string;
  message: string;
  field?: string;
  details?: Record<string, unknown>;
}

export interface PaginatedResponse<T> {
  items: T[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}

export interface ServiceListResponse {
  items: ServiceListItemResponse[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface ServiceListItemResponse {
  id: number;
  name: string;
  description: string;
  categoryId: number;
  categoryName: string;
  subcategoryId?: number;
  subcategoryName?: string;
  sizeOptionId?: number;
  sizeOptionName?: string;
  isActive: boolean;
  version?: string;
  createdAt: string;
  updatedAt: string;
  createdBy: string;
  updatedBy: string;
}

export interface ServiceDetailResponse {
  id: number;
  name: string;
  description: string;
  summary?: string;
  benefits?: string;
  limitations?: string;
  categoryId: number;
  categoryName: string;
  subcategoryId?: number;
  subcategoryName?: string;
  sizeOptionId?: number;
  sizeOptionName?: string;
  isActive: boolean;
  version?: string;
  notes?: string;
  internalNotes?: string;
  
  usageScenarios: UsageScenarioResponse[];
  prerequisites: PrerequisiteResponse[];
  inputs: InputResponse[];
  outputs: OutputResponse[];
  tools: ToolResponse[];
  dependencies: DependencyResponse[];
  scopeCategories: ScopeCategoryResponse[];
  interactions: InteractionResponse[];
  timelinePhases: TimelinePhaseResponse[];
  responsibleRoles: ResponsibleRoleResponse[];
  effortEstimations: EffortEstimationResponse[];
  licenses: LicenseResponse[];
  cloudSupport: CloudSupportResponse[];
  examples: ExampleResponse[];
  
  createdAt: string;
  updatedAt: string;
  createdBy: string;
  updatedBy: string;
}

export interface UsageScenarioResponse {
  id: number;
  title: string;
  description: string;
  order: number;
}

export interface PrerequisiteResponse {
  id: number;
  name: string;
  description?: string;
  requirementLevelId: number;
  requirementLevelName: string;
  order: number;
}

export interface InputResponse {
  id: number;
  name: string;
  description?: string;
  dataType?: string;
  isRequired: boolean;
  defaultValue?: string;
  validationRules?: string;
  order: number;
}

export interface OutputResponse {
  id: number;
  name: string;
  description?: string;
  dataType?: string;
  format?: string;
  order: number;
}

export interface ToolResponse {
  id: number;
  name: string;
  description?: string;
  url?: string;
  version?: string;
  isRequired: boolean;
  order: number;
}

export interface DependencyResponse {
  id: number;
  dependentServiceId?: number;
  dependentServiceName?: string;
  externalDependency?: string;
  dependencyTypeId: number;
  dependencyTypeName: string;
  description?: string;
  isRequired: boolean;
}

export interface ScopeCategoryResponse {
  id: number;
  scopeTypeId: number;
  scopeTypeName: string;
  name: string;
  description?: string;
  isIncluded: boolean;
}

export interface InteractionResponse {
  id: number;
  name: string;
  description?: string;
  interactionLevelId: number;
  interactionLevelName: string;
  roleId?: number;
  roleName?: string;
  frequency?: string;
}

export interface TimelinePhaseResponse {
  id: number;
  name: string;
  description?: string;
  durationDays?: number;
  durationWeeks?: number;
  order: number;
  milestones: string[];
}

export interface ResponsibleRoleResponse {
  id: number;
  roleId: number;
  roleName: string;
  responsibility?: string;
  isRequired: boolean;
}

export interface EffortEstimationResponse {
  id: number;
  effortCategoryId: number;
  effortCategoryName: string;
  minHours?: number;
  maxHours?: number;
  typicalHours?: number;
  notes?: string;
}

export interface LicenseResponse {
  id: number;
  name: string;
  type?: string;
  cost?: number;
  costPeriod?: string;
  description?: string;
  url?: string;
}

export interface CloudSupportResponse {
  id: number;
  cloudProviderId: number;
  cloudProviderName: string;
  isSupported: boolean;
  notes?: string;
  specificServices: string[];
}

export interface ExampleResponse {
  id: number;
  title: string;
  description?: string;
  code?: string;
  language?: string;
  order: number;
}

// Export operation responses
export interface ExportOperationResponse {
  operationId: string;
  status: ExportStatusType;
  format: 'pdf' | 'markdown';
  createdAt: string;
  estimatedCompletionTime?: string;
}

export type ExportStatusType = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';

export interface ExportStatusResponse {
  operationId: string;
  status: ExportStatusType;
  progress: number;
  message?: string;
  downloadUrl?: string;
  fileName?: string;
  fileSize?: number;
  completedAt?: string;
  error?: string;
}

// Publish operation responses
export interface PublishOperationResponse {
  operationId: string;
  status: PublishStatusType;
  targetBookUri: string;
  createdAt: string;
  estimatedCompletionTime?: string;
}

export type PublishStatusType = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';

export interface PublishStatusResponse {
  operationId: string;
  status: PublishStatusType;
  progress: number;
  currentStep?: string;
  processedCount: number;
  totalCount: number;
  message?: string;
  publishedPageUris?: string[];
  completedAt?: string;
  error?: string;
}

// Validation responses
export interface ValidationResponse {
  isValid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

export interface ValidationWarning {
  field: string;
  message: string;
}
