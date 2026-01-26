// ServiceCatalogForm/DependenciesSection.tsx
// Section 3: Dependencies - Define service relationships (prerequisites, triggers, parallel)

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon, LinkIcon } from '@heroicons/react/24/outline';
import { TextInput, SelectInput, TextArea, Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

const DEPENDENCY_TYPE_COLORS: Record<string, string> = {
  'PREREQUISITE': 'red',
  'TRIGGERS': 'green',
  'PARALLEL': 'blue',
};

const DEPENDENCY_TYPE_ICONS: Record<string, string> = {
  'PREREQUISITE': '⬅️',
  'TRIGGERS': '➡️',
  'PARALLEL': '↔️',
};

export const DependenciesSection: React.FC = () => {
  const { control, formState: { errors }, watch } = useFormContext();
  
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'dependencies',
  });

  // Fetch lookup data
  const { data: dependencyTypes = [] } = useQuery({
    queryKey: ['lookups', 'dependencyTypes'],
    queryFn: () => lookupService.getDependencyTypes(),
  });

  const { data: requirementLevels = [] } = useQuery({
    queryKey: ['lookups', 'requirementLevels'],
    queryFn: () => lookupService.getRequirementLevels(),
  });

  const { data: existingServices = [] } = useQuery({
    queryKey: ['services', 'list'],
    queryFn: () => lookupService.getServicesList(),
  });

  const dependencyTypeOptions = dependencyTypes.map(dt => ({
    value: dt.dependencyTypeId,
    label: `${DEPENDENCY_TYPE_ICONS[dt.typeCode] || ''} ${dt.typeName}`,
  }));

  const requirementLevelOptions = requirementLevels.map(rl => ({
    value: rl.requirementLevelId,
    label: rl.levelName,
  }));

  const serviceOptions = existingServices.map(s => ({
    value: s.serviceId,
    label: `${s.serviceCode} - ${s.serviceName}`,
  }));

  const handleAddDependency = (typeCode: string) => {
    const depType = dependencyTypes.find(dt => dt.typeCode === typeCode);
    append({
      dependencyTypeId: depType?.dependencyTypeId || 0,
      dependentServiceId: null,
      dependentServiceName: '',
      requirementLevelId: null,
      notes: '',
    });
  };

  // Group dependencies by type
  const watchedDependencies = watch('dependencies') || [];
  const groupedDependencies = {
    PREREQUISITE: fields.filter((_, i) => {
      const typeId = watchedDependencies[i]?.dependencyTypeId;
      return dependencyTypes.find(dt => dt.dependencyTypeId === typeId)?.typeCode === 'PREREQUISITE';
    }),
    TRIGGERS: fields.filter((_, i) => {
      const typeId = watchedDependencies[i]?.dependencyTypeId;
      return dependencyTypes.find(dt => dt.dependencyTypeId === typeId)?.typeCode === 'TRIGGERS';
    }),
    PARALLEL: fields.filter((_, i) => {
      const typeId = watchedDependencies[i]?.dependencyTypeId;
      return dependencyTypes.find(dt => dt.dependencyTypeId === typeId)?.typeCode === 'PARALLEL';
    }),
  };

  return (
    <div className="space-y-6">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Define relationships with other services. This helps users understand what services
        are required before, enabled after, or can run alongside this service.
      </p>

      {/* Quick Add Buttons */}
      <div className="flex flex-wrap gap-2">
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => handleAddDependency('PREREQUISITE')}
          leftIcon={<span>⬅️</span>}
          className="border-red-300 text-red-700 hover:bg-red-50"
        >
          Add Prerequisite
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => handleAddDependency('TRIGGERS')}
          leftIcon={<span>➡️</span>}
          className="border-green-300 text-green-700 hover:bg-green-50"
        >
          Add Triggers
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => handleAddDependency('PARALLEL')}
          leftIcon={<span>↔️</span>}
          className="border-blue-300 text-blue-700 hover:bg-blue-50"
        >
          Add Parallel
        </Button>
      </div>

      {/* Dependencies List */}
      {fields.length > 0 ? (
        <div className="space-y-4">
          {fields.map((field, index) => {
            const dep = watchedDependencies[index];
            const depType = dependencyTypes.find(dt => dt.dependencyTypeId === dep?.dependencyTypeId);
            const typeCode = depType?.typeCode || 'PREREQUISITE';
            const color = DEPENDENCY_TYPE_COLORS[typeCode];

            return (
              <Card 
                key={field.id} 
                className={`p-4 border-l-4 border-l-${color}-500`}
              >
                <div className="flex items-start justify-between mb-4">
                  <Badge variant={color as any}>
                    {DEPENDENCY_TYPE_ICONS[typeCode]} {depType?.typeName || 'Dependency'}
                  </Badge>
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

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Dependency Type */}
                  <Controller
                    name={`dependencies.${index}.dependencyTypeId`}
                    control={control}
                    render={({ field }) => (
                      <SelectInput
                        {...field}
                        label="Dependency Type"
                        options={dependencyTypeOptions}
                        onChange={(value) => field.onChange(Number(value))}
                      />
                    )}
                  />

                  {/* Requirement Level */}
                  <Controller
                    name={`dependencies.${index}.requirementLevelId`}
                    control={control}
                    render={({ field }) => (
                      <SelectInput
                        {...field}
                        label="Requirement Level"
                        options={requirementLevelOptions}
                        placeholder="Select level..."
                        onChange={(value) => field.onChange(value ? Number(value) : null)}
                      />
                    )}
                  />

                  {/* Existing Service Selection */}
                  <Controller
                    name={`dependencies.${index}.dependentServiceId`}
                    control={control}
                    render={({ field }) => (
                      <SelectInput
                        {...field}
                        label="Select Existing Service"
                        options={serviceOptions}
                        placeholder="Choose from catalog..."
                        helperText="Or enter name manually below"
                        onChange={(value) => field.onChange(value ? Number(value) : null)}
                      />
                    )}
                  />

                  {/* Manual Service Name */}
                  <Controller
                    name={`dependencies.${index}.dependentServiceName`}
                    control={control}
                    render={({ field }) => (
                      <TextInput
                        {...field}
                        label="Service Name (Manual)"
                        placeholder="e.g., Enterprise Landing Zone Design"
                        helperText="Use if service is not in catalog"
                      />
                    )}
                  />
                </div>

                {/* Notes */}
                <div className="mt-4">
                  <Controller
                    name={`dependencies.${index}.notes`}
                    control={control}
                    render={({ field }) => (
                      <TextArea
                        {...field}
                        label="Notes"
                        placeholder="Additional context about this dependency..."
                        rows={2}
                      />
                    )}
                  />
                </div>
              </Card>
            );
          })}
        </div>
      ) : (
        <div className="text-center py-8 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
          <LinkIcon className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500 mb-2">No dependencies defined yet.</p>
          <p className="text-sm text-gray-400">
            Dependencies help users understand how this service relates to others.
          </p>
        </div>
      )}

      {/* Dependency Types Explanation */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-gray-800 mb-3">
          📋 Dependency Types Explained
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div className="p-3 bg-red-50 rounded-md">
            <div className="font-medium text-red-800 mb-1">⬅️ Prerequisites</div>
            <p className="text-red-700 text-xs">
              Services that must be completed BEFORE this service can start.
            </p>
          </div>
          <div className="p-3 bg-green-50 rounded-md">
            <div className="font-medium text-green-800 mb-1">➡️ Triggers</div>
            <p className="text-green-700 text-xs">
              Services that this service enables or triggers AFTER completion.
            </p>
          </div>
          <div className="p-3 bg-blue-50 rounded-md">
            <div className="font-medium text-blue-800 mb-1">↔️ Parallel</div>
            <p className="text-blue-700 text-xs">
              Services that can be executed simultaneously WITH this service.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DependenciesSection;
