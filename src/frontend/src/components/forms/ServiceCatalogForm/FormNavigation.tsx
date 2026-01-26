// ServiceCatalogForm/FormNavigation.tsx
// Sidebar navigation for form sections

import React from 'react';
import { FieldErrors } from 'react-hook-form';
import { CheckCircleIcon, ExclamationCircleIcon } from '@heroicons/react/24/solid';
import clsx from 'clsx';

interface FormSection {
  id: string;
  title: string;
  required: boolean;
}

interface FormNavigationProps {
  sections: readonly FormSection[];
  currentSection: number;
  completedSections: Set<number>;
  onSectionChange: (index: number) => void;
  errors: FieldErrors;
}

export const FormNavigation: React.FC<FormNavigationProps> = ({
  sections,
  currentSection,
  completedSections,
  onSectionChange,
  errors,
}) => {
  const getSectionStatus = (index: number, section: FormSection) => {
    if (completedSections.has(index)) {
      return 'completed';
    }
    if (hasSectionErrors(section.id, errors)) {
      return 'error';
    }
    if (index === currentSection) {
      return 'current';
    }
    return 'pending';
  };

  return (
    <nav className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 sticky top-4">
      <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-4">
        Form Sections
      </h3>
      <ul className="space-y-1">
        {sections.map((section, index) => {
          const status = getSectionStatus(index, section);
          
          return (
            <li key={section.id}>
              <button
                type="button"
                onClick={() => onSectionChange(index)}
                className={clsx(
                  'w-full flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors',
                  {
                    'bg-blue-50 text-blue-700 border-l-4 border-blue-600': status === 'current',
                    'text-green-700 hover:bg-green-50': status === 'completed',
                    'text-red-700 hover:bg-red-50': status === 'error',
                    'text-gray-600 hover:bg-gray-50': status === 'pending',
                  }
                )}
              >
                {/* Status Icon */}
                <span className="flex-shrink-0">
                  {status === 'completed' && (
                    <CheckCircleIcon className="w-5 h-5 text-green-500" />
                  )}
                  {status === 'error' && (
                    <ExclamationCircleIcon className="w-5 h-5 text-red-500" />
                  )}
                  {status === 'current' && (
                    <span className="w-5 h-5 rounded-full bg-blue-600 flex items-center justify-center text-white text-xs">
                      {index + 1}
                    </span>
                  )}
                  {status === 'pending' && (
                    <span className="w-5 h-5 rounded-full border-2 border-gray-300 flex items-center justify-center text-gray-400 text-xs">
                      {index + 1}
                    </span>
                  )}
                </span>

                {/* Section Title */}
                <span className="flex-1 text-left truncate">
                  {section.title}
                </span>

                {/* Required Indicator */}
                {section.required && (
                  <span className="text-red-500 text-xs">*</span>
                )}
              </button>
            </li>
          );
        })}
      </ul>

      {/* Legend */}
      <div className="mt-6 pt-4 border-t border-gray-200">
        <p className="text-xs text-gray-500 mb-2">Legend:</p>
        <div className="space-y-1 text-xs">
          <div className="flex items-center gap-2">
            <CheckCircleIcon className="w-4 h-4 text-green-500" />
            <span className="text-gray-600">Completed</span>
          </div>
          <div className="flex items-center gap-2">
            <ExclamationCircleIcon className="w-4 h-4 text-red-500" />
            <span className="text-gray-600">Has errors</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-red-500">*</span>
            <span className="text-gray-600">Required</span>
          </div>
        </div>
      </div>
    </nav>
  );
};

// Helper function to check if section has errors
function hasSectionErrors(sectionId: string, errors: FieldErrors): boolean {
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

  const fields = fieldMap[sectionId] || [];
  return fields.some(field => field in errors);
}

export default FormNavigation;
