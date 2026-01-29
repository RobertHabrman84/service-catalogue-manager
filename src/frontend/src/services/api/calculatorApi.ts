import { apiClient } from './apiClient';

// Calculator Config types
export interface MetadataDto {
  name: string;
  id: string;
  version: string;
  category?: string;
}

export interface BaseEffortItemDto {
  hours: number;
  label: string;
  description?: string;
}

export interface PricingDto {
  margin: number;
  riskPremium: number;
  contingency: number;
  discount: number;
  hoursPerDay: number;
}

export interface RoleDto {
  id: string;
  name: string;
  dailyRate: number;
  isPrimary?: boolean;
}

export interface OptionDto {
  value: string;
  label: string;
  sizeImpact?: string;
  complexityHours?: number;
}

export interface ParameterDto {
  id: string;
  label: string;
  required: boolean;
  default?: string;
  options: OptionDto[];
}

export interface GroupDto {
  title: string;
  parameters: ParameterDto[];
}

export interface SectionDto {
  id: string;
  label: string;
  groups: GroupDto[];
}

export interface ScopeAreaDto {
  id: string;
  name: string;
  hours: number;
  description?: string;
  category?: string;
  required: boolean;
  requires?: string[];
}

export interface ComplexityFactorDto {
  id: string;
  label: string;
  hours: number;
}

export interface ScenarioDto {
  id: string;
  name: string;
  description?: string;
  values: Record<string, string>;
}

export interface PhaseDto {
  id: string;
  name: string;
  durationBySize: Record<string, string>;
}

export interface SizingCriteriaDto {
  duration?: string;
  effort?: string;
  description?: string;
}

export interface CalculatorConfigDto {
  metadata: MetadataDto;
  baseEffort: Record<string, BaseEffortItemDto>;
  pricing: PricingDto;
  roles: RoleDto[];
  teamComposition: Record<string, Record<string, number>>;
  contextMultipliers: Record<string, Record<string, number>>;
  sections: SectionDto[];
  scopeAreas: ScopeAreaDto[];
  complexityFactors: ComplexityFactorDto[];
  scenarios: ScenarioDto[];
  phases: PhaseDto[];
  sizingCriteria?: Record<string, SizingCriteriaDto>;
}

// Service Map types
export interface ServiceMapItemDto {
  id: string;
  name: string;
  shortName: string;
  layer: string;
  x: number;
  y: number;
}

export interface ServiceMapDependencyDto {
  from: string;
  to: string;
  type: string;
}

export interface ServiceMapDto {
  services: ServiceMapItemDto[];
  dependencies: ServiceMapDependencyDto[];
}

// API Functions
export const calculatorApi = {
  getCalculatorConfig: async (serviceId: string | number): Promise<CalculatorConfigDto> => {
    const response = await apiClient.get<CalculatorConfigDto>(`/services/${serviceId}/calculator-config`);
    return response.data;
  },

  getServiceMap: async (): Promise<ServiceMapDto> => {
    const response = await apiClient.get<ServiceMapDto>('/service-map');
    return response.data;
  },
};

export default calculatorApi;
