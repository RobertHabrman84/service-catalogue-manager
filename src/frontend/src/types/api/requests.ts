// API Request Types

export interface CreateServiceRequest {
  name: string;
  description: string;
  categoryId: number;
  subcategoryId?: number;
  sizeOptionId?: number;
  isActive?: boolean;
  version?: string;
  
  // Basic Info
  summary?: string;
  benefits?: string;
  limitations?: string;
  
  // Usage Scenarios
  usageScenarios?: CreateUsageScenarioRequest[];
  
  // Prerequisites
  prerequisites?: CreatePrerequisiteRequest[];
  
  // Inputs
  inputs?: CreateInputRequest[];
  
  // Outputs
  outputs?: CreateOutputRequest[];
  
  // Tools
  tools?: CreateToolRequest[];
  
  // Dependencies
  dependencies?: CreateDependencyRequest[];
  
  // Scope
  scopeCategories?: CreateScopeCategoryRequest[];
  
  // Interactions
  interactions?: CreateInteractionRequest[];
  
  // Timeline
  timelinePhases?: CreateTimelinePhaseRequest[];
  
  // Team
  responsibleRoles?: CreateResponsibleRoleRequest[];
  
  // Effort
  effortEstimations?: CreateEffortEstimationRequest[];
  
  // Licenses
  licenses?: CreateLicenseRequest[];
  
  // Multi-Cloud
  cloudSupport?: CreateCloudSupportRequest[];
  
  // Examples
  examples?: CreateExampleRequest[];
  
  // Notes
  notes?: string;
  internalNotes?: string;
}

export interface UpdateServiceRequest extends Partial<CreateServiceRequest> {
  id: number;
}

export interface CreateUsageScenarioRequest {
  title: string;
  description: string;
  order?: number;
}

export interface CreatePrerequisiteRequest {
  name: string;
  description?: string;
  requirementLevelId: number;
  order?: number;
}

export interface CreateInputRequest {
  name: string;
  description?: string;
  dataType?: string;
  isRequired: boolean;
  defaultValue?: string;
  validationRules?: string;
  order?: number;
}

export interface CreateOutputRequest {
  name: string;
  description?: string;
  dataType?: string;
  format?: string;
  order?: number;
}

export interface CreateToolRequest {
  name: string;
  description?: string;
  url?: string;
  version?: string;
  isRequired: boolean;
  order?: number;
}

export interface CreateDependencyRequest {
  dependentServiceId?: number;
  externalDependency?: string;
  dependencyTypeId: number;
  description?: string;
  isRequired: boolean;
}

export interface CreateScopeCategoryRequest {
  scopeTypeId: number;
  name: string;
  description?: string;
  isIncluded: boolean;
}

export interface CreateInteractionRequest {
  name: string;
  description?: string;
  interactionLevelId: number;
  roleId?: number;
  frequency?: string;
}

export interface CreateTimelinePhaseRequest {
  name: string;
  description?: string;
  durationDays?: number;
  durationWeeks?: number;
  order: number;
  milestones?: string[];
}

export interface CreateResponsibleRoleRequest {
  roleId: number;
  responsibility?: string;
  isRequired: boolean;
}

export interface CreateEffortEstimationRequest {
  effortCategoryId: number;
  minHours?: number;
  maxHours?: number;
  typicalHours?: number;
  notes?: string;
}

export interface CreateLicenseRequest {
  name: string;
  type?: string;
  cost?: number;
  costPeriod?: string;
  description?: string;
  url?: string;
}

export interface CreateCloudSupportRequest {
  cloudProviderId: number;
  isSupported: boolean;
  notes?: string;
  specificServices?: string[];
}

export interface CreateExampleRequest {
  title: string;
  description?: string;
  code?: string;
  language?: string;
  order?: number;
}

// Export related requests
export interface ExportServicesRequest {
  serviceIds: number[];
  format: 'pdf' | 'markdown';
  options?: ExportOptionsRequest;
}

export interface ExportOptionsRequest {
  includeUsageScenarios?: boolean;
  includeDependencies?: boolean;
  includeScope?: boolean;
  includeTimeline?: boolean;
  includeTeam?: boolean;
  includeEffort?: boolean;
  includeLicenses?: boolean;
  templateId?: string;
}

// Publish related requests
export interface PublishServicesRequest {
  serviceIds: number[];
  targetBookUri: string;
  options?: PublishOptionsRequest;
}

export interface PublishOptionsRequest {
  updateExisting?: boolean;
  createNewPages?: boolean;
  includeImages?: boolean;
  templateId?: string;
}
