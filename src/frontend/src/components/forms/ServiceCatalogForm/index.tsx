// ServiceCatalogForm/index.tsx
// Main form orchestrator for Service Catalog Item creation/editing

import React, { useState, useCallback, useEffect } from 'react';
import { useForm, FormProvider } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { ServiceCatalogFormData, ServiceCatalogItem } from '../../../types';
import { Button, Card, Alert } from '../../common';
import { FormNavigation } from './FormNavigation';
import { BasicInfoSection } from './BasicInfoSection';
import { UsageScenariosSection } from './UsageScenariosSection';
import { DependenciesSection } from './DependenciesSection';
import { ScopeSection } from './ScopeSection';
import { PrerequisitesSection } from './PrerequisitesSection';
import { ToolsSection } from './ToolsSection';
import { LicensesSection } from './LicensesSection';
import { InteractionSection } from './InteractionSection';
import { InputsSection } from './InputsSection';
import { OutputsSection } from './OutputsSection';
import { TimelineSection } from './TimelineSection';
import { SizingSection } from './SizingSection';
import { EffortSection } from './EffortSection';
import { TeamSection } from './TeamSection';
import { MultiCloudSection } from './MultiCloudSection';
import { ExamplesSection } from './ExamplesSection';
import { NotesSection } from './NotesSection';

// Form sections configuration
export const FORM_SECTIONS = [
  { id: 'basic-info', title: 'Basic Information', component: BasicInfoSection, required: true },
  { id: 'usage-scenarios', title: 'Usage Scenarios', component: UsageScenariosSection, required: true },
  { id: 'dependencies', title: 'Dependencies', component: DependenciesSection, required: false },
  { id: 'scope', title: 'Scope', component: ScopeSection, required: true },
  { id: 'prerequisites', title: 'Prerequisites', component: PrerequisitesSection, required: false },
  { id: 'tools', title: 'Tools & Frameworks', component: ToolsSection, required: false },
  { id: 'licenses', title: 'Licenses', component: LicensesSection, required: false },
  { id: 'interaction', title: 'Interaction Requirements', component: InteractionSection, required: true },
  { id: 'inputs', title: 'Inputs (Parameters)', component: InputsSection, required: false },
  { id: 'outputs', title: 'Outputs (Deliverables)', component: OutputsSection, required: true },
  { id: 'timeline', title: 'Timeline & Phases', component: TimelineSection, required: false },
  { id: 'sizing', title: 'Sizing Options', component: SizingSection, required: true },
  { id: 'effort', title: 'Effort Estimation', component: EffortSection, required: false },
  { id: 'team', title: 'Team Allocation', component: TeamSection, required: false },
  { id: 'multi-cloud', title: 'Multi-Cloud Considerations', component: MultiCloudSection, required: false },
  { id: 'examples', title: 'Sizing Examples', component: ExamplesSection, required: false },
  { id: 'notes', title: 'Additional Notes', component: NotesSection, required: false },
] as const;

// Validation schema
const serviceCatalogSchema = z.object({
  serviceCode: z.string().min(1, 'Service code is required').max(50),
  serviceName: z.string().min(1, 'Service name is required').max(200),
  version: z.string().default('v1.0'),
  categoryId: z.number().min(1, 'Category is required'),
  description: z.string().min(10, 'Description must be at least 10 characters'),
  notes: z.string().optional(),
  usageScenarios: z.array(z.object({
    scenarioNumber: z.number(),
    scenarioTitle: z.string().min(1),
    scenarioDescription: z.string().min(1),
  })).min(1, 'At least one usage scenario is required'),
  dependencies: z.array(z.object({
    dependencyTypeId: z.number(),
    dependentServiceName: z.string(),
    requirementLevelId: z.number().optional(),
    notes: z.string().optional(),
  })).optional(),
  inScopeCategories: z.array(z.object({
    categoryName: z.string(),
    items: z.array(z.string()),
  })).optional(),
  outScopeCategories: z.array(z.object({
    categoryName: z.string(),
    items: z.array(z.string()),
  })).optional(),
  prerequisites: z.array(z.object({
    prerequisiteCategoryId: z.number(),
    prerequisiteDescription: z.string(),
  })).optional(),
  cloudProviderCapabilities: z.array(z.object({
    cloudProviderId: z.number(),
    capabilityType: z.string(),
    capabilityName: z.string(),
  })).optional(),
  toolsFrameworks: z.array(z.object({
    toolCategoryId: z.number(),
    toolName: z.string(),
    description: z.string().optional(),
  })).optional(),
  licenses: z.array(z.object({
    licenseTypeId: z.number(),
    licenseDescription: z.string(),
    cloudProviderId: z.number().optional(),
  })).optional(),
  interaction: z.object({
    interactionLevelId: z.number(),
    notes: z.string().optional(),
  }).optional(),
  customerRequirements: z.array(z.object({
    requirementDescription: z.string(),
  })).optional(),
  accessRequirements: z.array(z.object({
    requirementDescription: z.string(),
  })).optional(),
  stakeholderInvolvements: z.array(z.object({
    stakeholderRole: z.string(),
    involvementDescription: z.string(),
  })).optional(),
  inputs: z.array(z.object({
    parameterName: z.string(),
    parameterDescription: z.string(),
    requirementLevelId: z.number(),
    dataType: z.string().optional(),
    defaultValue: z.string().optional(),
  })).optional(),
  outputCategories: z.array(z.object({
    categoryName: z.string(),
    items: z.array(z.string()),
  })).optional(),
  timelinePhases: z.array(z.object({
    phaseNumber: z.number(),
    phaseName: z.string(),
  })).optional(),
  sizeOptions: z.array(z.object({
    sizeOptionId: z.number(),
    scopeDescription: z.string(),
    durationDisplay: z.string(),
    effortDisplay: z.string(),
    teamSizeDisplay: z.string(),
    complexity: z.string().optional(),
  })).min(1, 'At least one size option is required'),
  sizingCriteria: z.array(z.object({
    criteriaName: z.string(),
    values: z.array(z.object({
      sizeOptionId: z.number(),
      criteriaValue: z.string(),
    })),
  })).optional(),
  effortEstimationItems: z.array(z.object({
    sizeOptionId: z.number(),
    activityName: z.string(),
    hoursEstimate: z.number(),
    notes: z.string().optional(),
  })).optional(),
  technicalComplexityAdditions: z.array(z.object({
    additionName: z.string(),
    condition: z.string(),
    hoursAdded: z.number(),
    notes: z.string().optional(),
  })).optional(),
  responsibleRoles: z.array(z.object({
    roleId: z.number(),
    isPrimaryOwner: z.boolean(),
    responsibility: z.string(),
  })).optional(),
  teamAllocations: z.array(z.object({
    sizeOptionId: z.number(),
    roleId: z.number(),
    fteAllocation: z.number(),
    notes: z.string().optional(),
  })).optional(),
  multiCloudConsiderations: z.array(z.object({
    considerationTitle: z.string(),
    considerationDescription: z.string(),
  })).optional(),
  sizingExamples: z.array(z.object({
    sizeOptionId: z.number(),
    exampleTitle: z.string(),
    scenario: z.string(),
    characteristics: z.array(z.string()),
    deliverables: z.string().optional(),
  })).optional(),
});

type ServiceCatalogFormSchema = z.infer<typeof serviceCatalogSchema>;

interface ServiceCatalogFormProps {
  initialData?: ServiceCatalogItem;
  onSubmit: (data: ServiceCatalogFormData) => Promise<void>;
  onCancel: () => void;
  isLoading?: boolean;
  mode: 'create' | 'edit';
}

export const ServiceCatalogForm: React.FC<ServiceCatalogFormProps> = ({
  initialData,
  onSubmit,
  onCancel,
  isLoading = false,
  mode,
}) => {
  const [currentSection, setCurrentSection] = useState(0);
  const [completedSections, setCompletedSections] = useState<Set<number>>(new Set());
  const [submitError, setSubmitError] = useState<string | null>(null);

  const methods = useForm<ServiceCatalogFormSchema>({
    resolver: zodResolver(serviceCatalogSchema),
    defaultValues: initialData ? mapServiceToFormData(initialData) : getDefaultFormValues(),
    mode: 'onChange',
  });

  const { handleSubmit, formState: { errors, isDirty, isValid }, trigger, watch } = methods;

  // Watch for changes to mark sections as completed
  const formValues = watch();

  useEffect(() => {
    // Auto-save to localStorage for recovery
    if (isDirty) {
      localStorage.setItem('serviceCatalogFormDraft', JSON.stringify(formValues));
    }
  }, [formValues, isDirty]);

  const handleSectionChange = useCallback(async (newSection: number) => {
    // Validate current section before moving
    const currentSectionConfig = FORM_SECTIONS[currentSection];
    const isValid = await trigger(getSectionFields(currentSectionConfig.id));
    
    if (isValid) {
      setCompletedSections(prev => new Set([...prev, currentSection]));
    }
    
    setCurrentSection(newSection);
  }, [currentSection, trigger]);

  const handleNext = useCallback(async () => {
    if (currentSection < FORM_SECTIONS.length - 1) {
      await handleSectionChange(currentSection + 1);
    }
  }, [currentSection, handleSectionChange]);

  const handlePrevious = useCallback(() => {
    if (currentSection > 0) {
      setCurrentSection(currentSection - 1);
    }
  }, [currentSection]);

  const onFormSubmit = async (data: ServiceCatalogFormSchema) => {
    try {
      setSubmitError(null);
      await onSubmit(data as ServiceCatalogFormData);
      localStorage.removeItem('serviceCatalogFormDraft');
    } catch (error) {
      setSubmitError(error instanceof Error ? error.message : 'An error occurred while saving');
    }
  };

  const CurrentSectionComponent = FORM_SECTIONS[currentSection].component;

  return (
    <FormProvider {...methods}>
      <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-6">
        {/* Progress Header */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-gray-900">
              {mode === 'create' ? 'Create New Service' : 'Edit Service'}
            </h2>
            <span className="text-sm text-gray-500">
              Section {currentSection + 1} of {FORM_SECTIONS.length}
            </span>
          </div>
          
          {/* Progress Bar */}
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all duration-300"
              style={{ width: `${((currentSection + 1) / FORM_SECTIONS.length) * 100}%` }}
            />
          </div>
        </div>

        {/* Navigation Sidebar + Content */}
        <div className="flex gap-6">
          {/* Sidebar Navigation */}
          <div className="w-64 flex-shrink-0">
            <FormNavigation
              sections={FORM_SECTIONS}
              currentSection={currentSection}
              completedSections={completedSections}
              onSectionChange={handleSectionChange}
              errors={errors}
            />
          </div>

          {/* Form Content */}
          <div className="flex-1">
            <Card className="p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                {FORM_SECTIONS[currentSection].title}
                {FORM_SECTIONS[currentSection].required && (
                  <span className="text-red-500 ml-1">*</span>
                )}
              </h3>

              {submitError && (
                <Alert variant="error\" className="mb-4">
                  {submitError}
                </Alert>
              )}

              {/* Dynamic Section Component */}
              <CurrentSectionComponent />

              {/* Navigation Buttons */}
              <div className="flex items-center justify-between mt-8 pt-6 border-t border-gray-200">
                <div className="flex gap-3">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handlePrevious}
                    disabled={currentSection === 0}
                  >
                    ← Previous
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={onCancel}
                  >
                    Cancel
                  </Button>
                </div>

                <div className="flex gap-3">
                  {currentSection < FORM_SECTIONS.length - 1 ? (
                    <Button
                      type="button"
                      variant="primary"
                      onClick={handleNext}
                    >
                      Next →
                    </Button>
                  ) : (
                    <Button
                      type="submit"
                      variant="primary"
                      disabled={isLoading || !isValid}
                      isLoading={isLoading}
                    >
                      {mode === 'create' ? 'Create Service' : 'Save Changes'}
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          </div>
        </div>
      </form>
    </FormProvider>
  );
};

// Helper functions
function getDefaultFormValues(): Partial<ServiceCatalogFormSchema> {
  return {
    serviceCode: '',
    serviceName: '',
    version: 'v1.0',
    categoryId: 0,
    description: '',
    notes: '',
    usageScenarios: [{ scenarioNumber: 1, scenarioTitle: '', scenarioDescription: '' }],
    dependencies: [],
    inScopeCategories: [{ categoryName: '', items: [''] }],
    outScopeCategories: [{ categoryName: '', items: [''] }],
    prerequisites: [],
    cloudProviderCapabilities: [],
    toolsFrameworks: [],
    licenses: [],
    interaction: { interactionLevelId: 0, notes: '' },
    customerRequirements: [],
    accessRequirements: [],
    stakeholderInvolvements: [],
    inputs: [],
    outputCategories: [{ categoryName: '', items: [''] }],
    timelinePhases: [],
    sizeOptions: [],
    sizingCriteria: [],
    effortEstimationItems: [],
    technicalComplexityAdditions: [],
    responsibleRoles: [],
    teamAllocations: [],
    multiCloudConsiderations: [],
    sizingExamples: [],
  };
}

function mapServiceToFormData(service: ServiceCatalogItem): Partial<ServiceCatalogFormSchema> {
  return {
    serviceCode: service.serviceCode,
    serviceName: service.serviceName,
    version: service.version,
    categoryId: service.categoryId,
    description: service.description,
    notes: service.notes || '',
    usageScenarios: service.usageScenarios || [],
    dependencies: service.dependencies || [],
    // ... map all other fields
  };
}

function getSectionFields(sectionId: string): string[] {
  const fieldMap: Record<string, string[]> = {
    'basic-info': ['serviceCode', 'serviceName', 'version', 'categoryId', 'description'],
    'usage-scenarios': ['usageScenarios'],
    'dependencies': ['dependencies'],
    'scope': ['inScopeCategories', 'outScopeCategories'],
    'prerequisites': ['prerequisites'],
    'tools': ['cloudProviderCapabilities', 'toolsFrameworks'],
    'licenses': ['licenses'],
    'interaction': ['interaction', 'customerRequirements', 'accessRequirements', 'stakeholderInvolvements'],
    'inputs': ['inputs'],
    'outputs': ['outputCategories'],
    'timeline': ['timelinePhases'],
    'sizing': ['sizeOptions', 'sizingCriteria'],
    'effort': ['effortEstimationItems', 'technicalComplexityAdditions'],
    'team': ['responsibleRoles', 'teamAllocations'],
    'multi-cloud': ['multiCloudConsiderations'],
    'examples': ['sizingExamples'],
    'notes': ['notes'],
  };
  return fieldMap[sectionId] || [];
}

export default ServiceCatalogForm;
