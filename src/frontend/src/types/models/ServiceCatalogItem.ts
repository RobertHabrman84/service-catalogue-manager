export interface ServiceCatalogItem {
  serviceId: number;
  serviceCode: string;
  serviceName: string;
  version: string;
  categoryId: number;
  categoryPath?: string;
  description: string;
  notes?: string;
  isActive: boolean;
  createdDate: string;
  createdBy?: string;
  modifiedDate: string;
  modifiedBy?: string;
}

export interface ServiceCatalogListItem {
  serviceId: number;
  serviceCode: string;
  serviceName: string;
  version: string;
  categoryPath: string;
  description: string;
  isActive: boolean;
  modifiedDate: string;
}

export interface ServiceCatalogFull extends ServiceCatalogItem {
  usageScenarios: UsageScenario[];
  dependencies: Dependency[];
  scopeCategories: ScopeCategory[];
  prerequisites: Prerequisite[];
  cloudCapabilities: CloudCapability[];
  tools: Tool[];
  licenses: License[];
  interaction?: Interaction;
  inputs: Input[];
  outputCategories: OutputCategory[];
  timelinePhases: TimelinePhase[];
  sizeOptions: SizeOption[];
  sizingCriteria: SizingCriteria[];
  effortEstimations: EffortEstimation[];
  complexityAdditions: ComplexityAddition[];
  scopeDependencies: ScopeDependencyItem[];
  sizingExamples: SizingExample[];
  responsibleRoles: ResponsibleRole[];
  teamAllocations: TeamAllocation[];
  multiCloudConsiderations: MultiCloudConsideration[];
}

export interface UsageScenario {
  scenarioId?: number;
  scenarioNumber: number;
  scenarioTitle: string;
  scenarioDescription: string;
  sortOrder: number;
}

export interface Dependency {
  dependencyId?: number;
  dependencyTypeId: number;
  dependencyTypeName?: string;
  dependentServiceId?: number;
  dependentServiceName?: string;
  requirementLevelId?: number;
  requirementLevelName?: string;
  notes?: string;
  sortOrder: number;
}

export interface ScopeCategory {
  scopeCategoryId?: number;
  scopeTypeId: number;
  scopeTypeName?: string;
  categoryNumber?: string;
  categoryName: string;
  items: ScopeItem[];
  sortOrder: number;
}

export interface ScopeItem {
  scopeItemId?: number;
  itemDescription: string;
  sortOrder: number;
}

export interface Prerequisite {
  prerequisiteId?: number;
  prerequisiteCategoryId: number;
  prerequisiteCategoryName?: string;
  prerequisiteDescription: string;
  sortOrder: number;
}

export interface CloudCapability {
  capabilityId?: number;
  cloudProviderId: number;
  cloudProviderName?: string;
  capabilityName: string;
  capabilityDescription?: string;
  sortOrder: number;
}

export interface Tool {
  toolId?: number;
  toolCategoryId: number;
  toolCategoryName?: string;
  toolName: string;
  toolDescription?: string;
  sortOrder: number;
}

export interface License {
  licenseId?: number;
  licenseTypeId: number;
  licenseTypeName?: string;
  licenseName: string;
  licenseDescription?: string;
  sortOrder: number;
}

export interface Interaction {
  interactionId?: number;
  interactionLevelId: number;
  interactionLevelName?: string;
  customerRequirements: CustomerRequirement[];
  accessRequirements: AccessRequirement[];
  stakeholderInvolvements: StakeholderInvolvement[];
}

export interface CustomerRequirement {
  requirementId?: number;
  requirementDescription: string;
  sortOrder: number;
}

export interface AccessRequirement {
  accessId?: number;
  accessDescription: string;
  sortOrder: number;
}

export interface StakeholderInvolvement {
  involvementId?: number;
  roleId: number;
  roleName?: string;
  involvementDescription?: string;
  sortOrder: number;
}

export interface Input {
  inputId?: number;
  parameterName: string;
  parameterDescription?: string;
  requirementLevelId: number;
  requirementLevelName?: string;
  sortOrder: number;
}

export interface OutputCategory {
  outputCategoryId?: number;
  categoryName: string;
  items: OutputItem[];
  sortOrder: number;
}

export interface OutputItem {
  outputItemId?: number;
  itemDescription: string;
  sortOrder: number;
}

export interface TimelinePhase {
  phaseId?: number;
  phaseName: string;
  phaseDescription?: string;
  durationsBySize?: PhaseDuration[];
  sortOrder: number;
}

export interface PhaseDuration {
  phaseDurationId?: number;
  sizeOptionId: number;
  sizeCode?: string;
  duration: string;
}

export interface SizeOption {
  serviceSizeOptionId?: number;
  sizeOptionId: number;
  sizeCode?: string;
  sizeName?: string;
  scopeDescription?: string;
  durationDisplay?: string;
  effortDisplay?: string;
  teamSizeDisplay?: string;
  complexity?: string;
}

export interface SizingCriteria {
  criteriaId?: number;
  criteriaName: string;
  values: SizingCriteriaValue[];
  sortOrder: number;
}

export interface SizingCriteriaValue {
  criteriaValueId?: number;
  sizeOptionId: number;
  sizeCode?: string;
  value: string;
}

export interface EffortEstimation {
  estimationId?: number;
  areaName: string;
  baseHours?: string;
  notes?: string;
  sortOrder: number;
}

export interface ComplexityAddition {
  additionId?: number;
  additionName: string;
  condition?: string;
  additionalHours?: string;
  sortOrder: number;
}

export interface ScopeDependencyItem {
  scopeDependencyId?: number;
  areaName: string;
  requiresDescription?: string;
  sortOrder: number;
}

export interface SizingExample {
  exampleId?: number;
  sizeOptionId: number;
  sizeCode?: string;
  exampleName: string;
  exampleDescription?: string;
  characteristics: ExampleCharacteristic[];
  sortOrder: number;
}

export interface ExampleCharacteristic {
  characteristicId?: number;
  characteristicDescription: string;
  sortOrder: number;
}

export interface ResponsibleRole {
  responsibleRoleId?: number;
  roleId: number;
  roleName?: string;
  isPrimary: boolean;
  responsibilityDescription?: string;
  sortOrder: number;
}

export interface TeamAllocation {
  allocationId?: number;
  roleId: number;
  roleName?: string;
  sizeOptionId: number;
  sizeCode?: string;
  allocationPercentage?: number;
  allocationDescription?: string;
}

export interface MultiCloudConsideration {
  considerationId?: number;
  considerationTitle: string;
  considerationDescription: string;
  sortOrder: number;
}
