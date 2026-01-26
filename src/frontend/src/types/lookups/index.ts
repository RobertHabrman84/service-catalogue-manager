export interface AllLookups {
  categories: ServiceCategory[];
  sizeOptions: SizeOption[];
  cloudProviders: CloudProvider[];
  dependencyTypes: DependencyType[];
  prerequisiteCategories: PrerequisiteCategory[];
  licenseTypes: LicenseType[];
  toolCategories: ToolCategory[];
  scopeTypes: ScopeType[];
  interactionLevels: InteractionLevel[];
  requirementLevels: RequirementLevel[];
  roles: Role[];
}

export interface ServiceCategory {
  categoryId: number;
  categoryCode: string;
  categoryName: string;
  parentCategoryId?: number;
  categoryPath: string;
  sortOrder: number;
  isActive: boolean;
}

export interface SizeOption {
  sizeOptionId: number;
  sizeCode: string;
  sizeName: string;
  sortOrder: number;
  isActive: boolean;
}

export interface CloudProvider {
  cloudProviderId: number;
  providerCode: string;
  providerName: string;
  isActive: boolean;
}

export interface DependencyType {
  dependencyTypeId: number;
  typeCode: string;
  typeName: string;
  description?: string;
}

export interface PrerequisiteCategory {
  prerequisiteCategoryId: number;
  categoryCode: string;
  categoryName: string;
}

export interface LicenseType {
  licenseTypeId: number;
  typeCode: string;
  typeName: string;
}

export interface ToolCategory {
  toolCategoryId: number;
  categoryCode: string;
  categoryName: string;
}

export interface ScopeType {
  scopeTypeId: number;
  typeCode: string;
  typeName: string;
}

export interface InteractionLevel {
  interactionLevelId: number;
  levelCode: string;
  levelName: string;
  sortOrder: number;
}

export interface RequirementLevel {
  requirementLevelId: number;
  levelCode: string;
  levelName: string;
  sortOrder: number;
}

export interface Role {
  roleId: number;
  roleCode: string;
  roleName: string;
  description?: string;
  isActive: boolean;
}
