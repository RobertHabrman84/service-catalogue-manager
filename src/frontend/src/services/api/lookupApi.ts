import { apiClient, ApiResponse } from './apiClient';
import { ENDPOINTS } from './endpoints';
import {
  ServiceCategory,
  ServiceSubcategory,
  SizeOption,
  CloudProvider,
  DependencyType,
  RequirementLevel,
  ScopeType,
  InteractionLevel,
  Role,
  EffortCategory,
} from '../../types/lookups';

export interface AllLookupsResponse {
  categories: ServiceCategory[];
  sizeOptions: SizeOption[];
  cloudProviders: CloudProvider[];
  dependencyTypes: DependencyType[];
  requirementLevels: RequirementLevel[];
  scopeTypes: ScopeType[];
  interactionLevels: InteractionLevel[];
  roles: Role[];
  effortCategories: EffortCategory[];
}

export const lookupApi = {
  /**
   * Get all lookup data in single request
   */
  async getAll(): Promise<ApiResponse<AllLookupsResponse>> {
    return apiClient.get<AllLookupsResponse>(ENDPOINTS.lookups.all);
  },

  /**
   * Get all categories
   */
  async getCategories(): Promise<ApiResponse<ServiceCategory[]>> {
    return apiClient.get<ServiceCategory[]>(ENDPOINTS.lookups.categories);
  },

  /**
   * Get subcategories for a category
   */
  async getSubcategories(categoryId: number): Promise<ApiResponse<ServiceSubcategory[]>> {
    return apiClient.get<ServiceSubcategory[]>(ENDPOINTS.lookups.subcategories(categoryId));
  },

  /**
   * Get all size options
   */
  async getSizeOptions(): Promise<ApiResponse<SizeOption[]>> {
    return apiClient.get<SizeOption[]>(ENDPOINTS.lookups.sizeOptions);
  },

  /**
   * Get all cloud providers
   */
  async getCloudProviders(): Promise<ApiResponse<CloudProvider[]>> {
    return apiClient.get<CloudProvider[]>(ENDPOINTS.lookups.cloudProviders);
  },

  /**
   * Get all dependency types
   */
  async getDependencyTypes(): Promise<ApiResponse<DependencyType[]>> {
    return apiClient.get<DependencyType[]>(ENDPOINTS.lookups.dependencyTypes);
  },

  /**
   * Get all requirement levels
   */
  async getRequirementLevels(): Promise<ApiResponse<RequirementLevel[]>> {
    return apiClient.get<RequirementLevel[]>(ENDPOINTS.lookups.requirementLevels);
  },

  /**
   * Get all scope types
   */
  async getScopeTypes(): Promise<ApiResponse<ScopeType[]>> {
    return apiClient.get<ScopeType[]>(ENDPOINTS.lookups.scopeTypes);
  },

  /**
   * Get all interaction levels
   */
  async getInteractionLevels(): Promise<ApiResponse<InteractionLevel[]>> {
    return apiClient.get<InteractionLevel[]>(ENDPOINTS.lookups.interactionLevels);
  },

  /**
   * Get all roles
   */
  async getRoles(): Promise<ApiResponse<Role[]>> {
    return apiClient.get<Role[]>(ENDPOINTS.lookups.roles);
  },

  /**
   * Get all effort categories
   */
  async getEffortCategories(): Promise<ApiResponse<EffortCategory[]>> {
    return apiClient.get<EffortCategory[]>(ENDPOINTS.lookups.effortCategories);
  },
};

export default lookupApi;
