// ServiceCatalogForm/PrerequisitesSection.tsx
// Section 5: Prerequisites - Organizational, Technical, Documentation requirements

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { BuildingOfficeIcon, CpuChipIcon, DocumentTextIcon } from '@heroicons/react/24/solid';
import { TextArea, SelectInput, Button, Card } from '../../common';
import { lookupService } from '../../../services/api';

const CATEGORY_ICONS: Record<string, React.ReactNode> = {
  'ORGANIZATIONAL': <BuildingOfficeIcon className="w-5 h-5" />,
  'TECHNICAL': <CpuChipIcon className="w-5 h-5" />,
  'DOCUMENTATION': <DocumentTextIcon className="w-5 h-5" />,
};

const CATEGORY_COLORS: Record<string, string> = {
  'ORGANIZATIONAL': 'purple',
  'TECHNICAL': 'blue',
  'DOCUMENTATION': 'amber',
};

export const PrerequisitesSection: React.FC = () => {
  const { control, watch } = useFormContext();
  
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'prerequisites',
  });

  // Fetch prerequisite categories
  const { data: categories = [] } = useQuery({
    queryKey: ['lookups', 'prerequisiteCategories'],
    queryFn: () => lookupService.getPrerequisiteCategories(),
  });

  const categoryOptions = categories.map(cat => ({
    value: cat.prerequisiteCategoryId,
    label: cat.categoryName,
  }));

  const handleAddPrerequisite = (categoryCode?: string) => {
    const category = categoryCode 
      ? categories.find(c => c.categoryCode === categoryCode)
      : categories[0];
    
    append({
      prerequisiteCategoryId: category?.prerequisiteCategoryId || 0,
      prerequisiteDescription: '',
    });
  };

  const watchedPrerequisites = watch('prerequisites') || [];

  // Group prerequisites by category
  const groupedPrerequisites = categories.map(category => ({
    category,
    prerequisites: fields.filter((_, index) => 
      watchedPrerequisites[index]?.prerequisiteCategoryId === category.prerequisiteCategoryId
    ).map((field, idx) => {
      const originalIndex = fields.findIndex(f => f.id === field.id);
      return { field, originalIndex };
    }),
  })).filter(group => group.prerequisites.length > 0);

  return (
    <div className="space-y-6">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Define what must be in place before this service can begin. Prerequisites are grouped
        into organizational, technical, and documentation categories.
      </p>

      {/* Quick Add Buttons */}
      <div className="flex flex-wrap gap-2">
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => handleAddPrerequisite('ORGANIZATIONAL')}
          leftIcon={<BuildingOfficeIcon className="w-4 h-4" />}
          className="border-purple-300 text-purple-700 hover:bg-purple-50"
        >
          Add Organizational
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => handleAddPrerequisite('TECHNICAL')}
          leftIcon={<CpuChipIcon className="w-4 h-4" />}
          className="border-blue-300 text-blue-700 hover:bg-blue-50"
        >
          Add Technical
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => handleAddPrerequisite('DOCUMENTATION')}
          leftIcon={<DocumentTextIcon className="w-4 h-4" />}
          className="border-amber-300 text-amber-700 hover:bg-amber-50"
        >
          Add Documentation
        </Button>
      </div>

      {/* Prerequisites List */}
      {fields.length > 0 ? (
        <div className="space-y-4">
          {fields.map((field, index) => {
            const prereq = watchedPrerequisites[index];
            const category = categories.find(c => c.prerequisiteCategoryId === prereq?.prerequisiteCategoryId);
            const categoryCode = category?.categoryCode || 'ORGANIZATIONAL';
            const color = CATEGORY_COLORS[categoryCode] || 'gray';

            return (
              <Card key={field.id} className={`p-4 border-l-4 border-l-${color}-500`}>
                <div className="flex items-start gap-4">
                  {/* Category Icon */}
                  <div className={`flex-shrink-0 p-2 rounded-lg bg-${color}-100 text-${color}-600`}>
                    {CATEGORY_ICONS[categoryCode]}
                  </div>

                  {/* Content */}
                  <div className="flex-1 space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <Controller
                        name={`prerequisites.${index}.prerequisiteCategoryId`}
                        control={control}
                        render={({ field }) => (
                          <SelectInput
                            {...field}
                            label="Category"
                            options={categoryOptions}
                            onChange={(value) => field.onChange(Number(value))}
                          />
                        )}
                      />
                    </div>

                    <Controller
                      name={`prerequisites.${index}.prerequisiteDescription`}
                      control={control}
                      render={({ field }) => (
                        <TextArea
                          {...field}
                          label="Description"
                          placeholder="Describe the prerequisite requirement..."
                          rows={2}
                          required
                        />
                      )}
                    />
                  </div>

                  {/* Remove Button */}
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => remove(index)}
                    className="text-red-500 hover:text-red-700"
                  >
                    <TrashIcon className="w-4 h-4" />
                  </Button>
                </div>
              </Card>
            );
          })}
        </div>
      ) : (
        <div className="text-center py-8 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
          <p className="text-gray-500 mb-4">No prerequisites defined yet.</p>
          <p className="text-sm text-gray-400 mb-4">
            Prerequisites help ensure the customer is ready for this service.
          </p>
          <Button
            type="button"
            variant="primary"
            onClick={() => handleAddPrerequisite()}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add First Prerequisite
          </Button>
        </div>
      )}

      {/* Examples */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-gray-800 mb-3">
          📋 Example Prerequisites by Category
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div className="p-3 bg-purple-50 rounded-md">
            <div className="flex items-center gap-2 font-medium text-purple-800 mb-2">
              <BuildingOfficeIcon className="w-4 h-4" />
              Organizational
            </div>
            <ul className="text-purple-700 text-xs space-y-1">
              <li>• Stakeholder alignment</li>
              <li>• Budget approval</li>
              <li>• Project sponsor identified</li>
              <li>• Team availability confirmed</li>
            </ul>
          </div>
          <div className="p-3 bg-blue-50 rounded-md">
            <div className="flex items-center gap-2 font-medium text-blue-800 mb-2">
              <CpuChipIcon className="w-4 h-4" />
              Technical
            </div>
            <ul className="text-blue-700 text-xs space-y-1">
              <li>• Cloud subscription active</li>
              <li>• Network connectivity in place</li>
              <li>• Identity provider configured</li>
              <li>• Required permissions granted</li>
            </ul>
          </div>
          <div className="p-3 bg-amber-50 rounded-md">
            <div className="flex items-center gap-2 font-medium text-amber-800 mb-2">
              <DocumentTextIcon className="w-4 h-4" />
              Documentation
            </div>
            <ul className="text-amber-700 text-xs space-y-1">
              <li>• Architecture review completed</li>
              <li>• Security requirements documented</li>
              <li>• Compliance requirements identified</li>
              <li>• Business requirements signed off</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PrerequisitesSection;
