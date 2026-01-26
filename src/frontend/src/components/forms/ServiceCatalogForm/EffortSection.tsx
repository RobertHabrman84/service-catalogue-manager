// ServiceCatalogForm/EffortSection.tsx
// Section 13: Effort Estimation - Define effort breakdown and complexity additions

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { CalculatorIcon, PlusCircleIcon } from '@heroicons/react/24/solid';
import { TextInput, TextArea, SelectInput, NumberInput, Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

const SIZE_COLORS: Record<string, string> = {
  'XS': 'gray',
  'S': 'green',
  'M': 'blue',
  'L': 'purple',
  'XL': 'red',
};

export const EffortSection: React.FC = () => {
  const { control, watch } = useFormContext();
  
  // Effort Estimation Items
  const { 
    fields: effortFields, 
    append: appendEffort, 
    remove: removeEffort 
  } = useFieldArray({
    control,
    name: 'effortEstimationItems',
  });

  // Technical Complexity Additions
  const { 
    fields: complexityFields, 
    append: appendComplexity, 
    remove: removeComplexity 
  } = useFieldArray({
    control,
    name: 'technicalComplexityAdditions',
  });

  // Fetch size options
  const { data: sizeOptions = [] } = useQuery({
    queryKey: ['lookups', 'sizeOptions'],
    queryFn: () => lookupService.getSizeOptions(),
  });

  const sizeOptionsList = sizeOptions.map(so => ({
    value: so.sizeOptionId,
    label: `${so.sizeName} (${so.sizeCode})`,
    code: so.sizeCode,
  }));

  const getSizeCode = (sizeOptionId: number): string => {
    return sizeOptions.find(so => so.sizeOptionId === sizeOptionId)?.sizeCode || 'M';
  };

  const watchedEffort = watch('effortEstimationItems') || [];
  const watchedComplexity = watch('technicalComplexityAdditions') || [];

  // Calculate totals by size
  const effortTotals = sizeOptions.reduce((acc, so) => {
    acc[so.sizeOptionId] = watchedEffort
      .filter(e => e.sizeOptionId === so.sizeOptionId)
      .reduce((sum, e) => sum + (e.hoursEstimate || 0), 0);
    return acc;
  }, {} as Record<number, number>);

  const handleAddEffort = () => {
    appendEffort({
      sizeOptionId: sizeOptions[0]?.sizeOptionId || 0,
      activityName: '',
      hoursEstimate: 0,
      notes: '',
    });
  };

  const handleAddComplexity = () => {
    appendComplexity({
      additionName: '',
      condition: '',
      hoursAdded: 0,
      notes: '',
    });
  };

  return (
    <div className="space-y-8">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Define the effort breakdown by activity and any additional complexity factors
        that may increase the effort required.
      </p>

      {/* Effort Estimation Items */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <CalculatorIcon className="w-6 h-6 text-blue-500" />
            <h4 className="text-lg font-medium text-gray-900">Effort Breakdown</h4>
          </div>
          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={handleAddEffort}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Activity
          </Button>
        </div>

        {/* Effort Totals Summary */}
        {effortFields.length > 0 && (
          <div className="bg-gray-50 rounded-lg p-4 mb-4">
            <h5 className="text-sm font-medium text-gray-700 mb-2">Total Hours by Size</h5>
            <div className="flex flex-wrap gap-4">
              {sizeOptions.map(so => (
                <div key={so.sizeOptionId} className="flex items-center gap-2">
                  <Badge variant={SIZE_COLORS[so.sizeCode] as any}>
                    {so.sizeCode}
                  </Badge>
                  <span className="font-semibold text-gray-900">
                    {effortTotals[so.sizeOptionId] || 0}h
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

        {effortFields.length > 0 ? (
          <div className="space-y-3">
            {effortFields.map((field, index) => {
              const effort = watchedEffort[index];
              const sizeCode = getSizeCode(effort?.sizeOptionId);
              const color = SIZE_COLORS[sizeCode] || 'gray';

              return (
                <Card key={field.id} className="p-4">
                  <div className="flex items-start gap-4">
                    <Badge variant={color as any} className="flex-shrink-0 mt-1">
                      {sizeCode}
                    </Badge>

                    <div className="flex-1 grid grid-cols-1 md:grid-cols-4 gap-4">
                      <Controller
                        name={`effortEstimationItems.${index}.sizeOptionId`}
                        control={control}
                        render={({ field }) => (
                          <SelectInput
                            {...field}
                            label="Size"
                            options={sizeOptionsList}
                            onChange={(value) => field.onChange(Number(value))}
                          />
                        )}
                      />

                      <Controller
                        name={`effortEstimationItems.${index}.activityName`}
                        control={control}
                        render={({ field }) => (
                          <TextInput
                            {...field}
                            label="Activity"
                            placeholder="e.g., Architecture Design"
                          />
                        )}
                      />

                      <Controller
                        name={`effortEstimationItems.${index}.hoursEstimate`}
                        control={control}
                        render={({ field }) => (
                          <NumberInput
                            {...field}
                            label="Hours"
                            min={0}
                            max={1000}
                            onChange={(value) => field.onChange(Number(value))}
                          />
                        )}
                      />

                      <Controller
                        name={`effortEstimationItems.${index}.notes`}
                        control={control}
                        render={({ field }) => (
                          <TextInput
                            {...field}
                            label="Notes"
                            placeholder="Optional notes"
                          />
                        )}
                      />
                    </div>

                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeEffort(index)}
                      className="text-red-500 hover:text-red-700 mt-6"
                    >
                      <TrashIcon className="w-4 h-4" />
                    </Button>
                  </div>
                </Card>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-6 bg-blue-50 rounded-lg border-2 border-dashed border-blue-300">
            <CalculatorIcon className="w-10 h-10 text-blue-400 mx-auto mb-2" />
            <p className="text-blue-700">No effort items defined yet.</p>
          </div>
        )}
      </div>

      {/* Divider */}
      <div className="border-t border-gray-200" />

      {/* Technical Complexity Additions */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <PlusCircleIcon className="w-6 h-6 text-orange-500" />
            <h4 className="text-lg font-medium text-gray-900">Complexity Additions</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddComplexity}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Complexity Factor
          </Button>
        </div>

        <p className="text-sm text-gray-600 mb-4">
          Define additional effort that may be required based on specific conditions or complexity factors.
        </p>

        {complexityFields.length > 0 ? (
          <div className="space-y-3">
            {complexityFields.map((field, index) => (
              <Card key={field.id} className="p-4 border-l-4 border-l-orange-500">
                <div className="flex items-start gap-4">
                  <div className="flex-1 space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <Controller
                        name={`technicalComplexityAdditions.${index}.additionName`}
                        control={control}
                        render={({ field }) => (
                          <TextInput
                            {...field}
                            label="Complexity Factor"
                            placeholder="e.g., Hybrid Connectivity"
                          />
                        )}
                      />

                      <Controller
                        name={`technicalComplexityAdditions.${index}.condition`}
                        control={control}
                        render={({ field }) => (
                          <TextInput
                            {...field}
                            label="Condition"
                            placeholder="e.g., On-premises integration required"
                          />
                        )}
                      />

                      <Controller
                        name={`technicalComplexityAdditions.${index}.hoursAdded`}
                        control={control}
                        render={({ field }) => (
                          <NumberInput
                            {...field}
                            label="Additional Hours"
                            min={0}
                            max={500}
                            onChange={(value) => field.onChange(Number(value))}
                          />
                        )}
                      />
                    </div>

                    <Controller
                      name={`technicalComplexityAdditions.${index}.notes`}
                      control={control}
                      render={({ field }) => (
                        <TextInput
                          {...field}
                          label="Notes"
                          placeholder="Additional context..."
                        />
                      )}
                    />
                  </div>

                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => removeComplexity(index)}
                    className="text-red-500 hover:text-red-700"
                  >
                    <TrashIcon className="w-4 h-4" />
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        ) : (
          <div className="text-center py-6 bg-orange-50 rounded-lg border-2 border-dashed border-orange-300">
            <PlusCircleIcon className="w-10 h-10 text-orange-400 mx-auto mb-2" />
            <p className="text-orange-700">No complexity additions defined.</p>
          </div>
        )}
      </div>

      {/* Example Complexity Additions */}
      <div className="bg-orange-50 border border-orange-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-orange-800 mb-2">
          ⚡ Common Complexity Factors
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm text-orange-700">
          <div>
            <strong>Hybrid Connectivity</strong> (+16-24h)
            <p className="text-xs">On-premises integration required</p>
          </div>
          <div>
            <strong>Multi-Region</strong> (+8-16h)
            <p className="text-xs">Deployment across multiple regions</p>
          </div>
          <div>
            <strong>High Compliance</strong> (+16-32h)
            <p className="text-xs">PCI-DSS, HIPAA, or similar requirements</p>
          </div>
          <div>
            <strong>Legacy Integration</strong> (+8-24h)
            <p className="text-xs">Integration with legacy systems</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default EffortSection;
