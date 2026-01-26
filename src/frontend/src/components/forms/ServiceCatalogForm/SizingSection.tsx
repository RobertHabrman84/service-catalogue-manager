// ServiceCatalogForm/SizingSection.tsx
// Section 12: Sizing Options - Define S/M/L sizing with criteria

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { ScaleIcon } from '@heroicons/react/24/solid';
import { TextInput, TextArea, SelectInput, Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

const SIZE_COLORS: Record<string, string> = {
  'XS': 'gray',
  'S': 'green',
  'M': 'blue',
  'L': 'purple',
  'XL': 'red',
};

const SIZE_ICONS: Record<string, string> = {
  'XS': '🔹',
  'S': '🟢',
  'M': '🔵',
  'L': '🟣',
  'XL': '🔴',
};

export const SizingSection: React.FC = () => {
  const { control, watch, formState: { errors } } = useFormContext();
  
  // Size Options
  const { 
    fields: sizeFields, 
    append: appendSize, 
    remove: removeSize 
  } = useFieldArray({
    control,
    name: 'sizeOptions',
  });

  // Sizing Criteria
  const { 
    fields: criteriaFields, 
    append: appendCriteria, 
    remove: removeCriteria 
  } = useFieldArray({
    control,
    name: 'sizingCriteria',
  });

  // Fetch size options
  const { data: sizeOptionsLookup = [] } = useQuery({
    queryKey: ['lookups', 'sizeOptions'],
    queryFn: () => lookupService.getSizeOptions(),
  });

  const sizeOptionsList = sizeOptionsLookup.map(so => ({
    value: so.sizeOptionId,
    label: `${SIZE_ICONS[so.sizeCode] || ''} ${so.sizeName} (${so.sizeCode})`,
    code: so.sizeCode,
  }));

  const watchedSizeOptions = watch('sizeOptions') || [];
  const watchedCriteria = watch('sizingCriteria') || [];

  const handleAddSizeOption = () => {
    const usedSizeIds = watchedSizeOptions.map(s => s.sizeOptionId);
    const availableSize = sizeOptionsLookup.find(so => !usedSizeIds.includes(so.sizeOptionId));
    
    if (availableSize) {
      appendSize({
        sizeOptionId: availableSize.sizeOptionId,
        scopeDescription: '',
        durationDisplay: '',
        effortDisplay: '',
        teamSizeDisplay: '',
        complexity: '',
      });
    }
  };

  const handleAddCriteria = () => {
    appendCriteria({
      criteriaName: '',
      values: sizeOptionsLookup.map(so => ({
        sizeOptionId: so.sizeOptionId,
        criteriaValue: '',
      })),
    });
  };

  // Get size code for a size option
  const getSizeCode = (sizeOptionId: number): string => {
    return sizeOptionsLookup.find(so => so.sizeOptionId === sizeOptionId)?.sizeCode || 'M';
  };

  return (
    <div className="space-y-8">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Define size options (T-shirt sizing) for this service. Each size represents
        a different scope, duration, and effort level.
      </p>

      {/* Error Message */}
      {errors.sizeOptions?.message && (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-md p-3">
          {errors.sizeOptions.message as string}
        </div>
      )}

      {/* Size Options */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <ScaleIcon className="w-6 h-6 text-blue-500" />
            <h4 className="text-lg font-medium text-gray-900">Size Options</h4>
          </div>
          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={handleAddSizeOption}
            leftIcon={<PlusIcon className="w-4 h-4" />}
            disabled={watchedSizeOptions.length >= sizeOptionsLookup.length}
          >
            Add Size
          </Button>
        </div>

        {sizeFields.length > 0 ? (
          <div className="space-y-4">
            {sizeFields.map((field, index) => {
              const sizeOption = watchedSizeOptions[index];
              const sizeCode = getSizeCode(sizeOption?.sizeOptionId);
              const color = SIZE_COLORS[sizeCode] || 'gray';

              return (
                <Card key={field.id} className={`p-4 border-l-4 border-l-${color}-500`}>
                  <div className="flex items-start justify-between mb-4">
                    <Badge variant={color as any} size="lg">
                      {SIZE_ICONS[sizeCode]} {sizeCode}
                    </Badge>
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeSize(index)}
                      className="text-red-500 hover:text-red-700"
                    >
                      <TrashIcon className="w-4 h-4" />
                    </Button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <Controller
                      name={`sizeOptions.${index}.sizeOptionId`}
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
                      name={`sizeOptions.${index}.complexity`}
                      control={control}
                      render={({ field }) => (
                        <TextInput
                          {...field}
                          label="Complexity"
                          placeholder="e.g., Low, Medium, High"
                        />
                      )}
                    />
                  </div>

                  <Controller
                    name={`sizeOptions.${index}.scopeDescription`}
                    control={control}
                    render={({ field }) => (
                      <TextArea
                        {...field}
                        label="Scope Description"
                        placeholder="Describe what's included at this size..."
                        rows={2}
                        className="mb-4"
                      />
                    )}
                  />

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <Controller
                      name={`sizeOptions.${index}.durationDisplay`}
                      control={control}
                      render={({ field }) => (
                        <TextInput
                          {...field}
                          label="Duration"
                          placeholder="e.g., 2-3 weeks"
                        />
                      )}
                    />

                    <Controller
                      name={`sizeOptions.${index}.effortDisplay`}
                      control={control}
                      render={({ field }) => (
                        <TextInput
                          {...field}
                          label="Effort"
                          placeholder="e.g., 40-60 hours"
                        />
                      )}
                    />

                    <Controller
                      name={`sizeOptions.${index}.teamSizeDisplay`}
                      control={control}
                      render={({ field }) => (
                        <TextInput
                          {...field}
                          label="Team Size"
                          placeholder="e.g., 2-3 resources"
                        />
                      )}
                    />
                  </div>
                </Card>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-8 bg-blue-50 rounded-lg border-2 border-dashed border-blue-300">
            <ScaleIcon className="w-12 h-12 text-blue-400 mx-auto mb-4" />
            <p className="text-blue-700 mb-2">No size options defined yet.</p>
            <p className="text-sm text-blue-600 mb-4">
              At least one size option is required.
            </p>
            <Button
              type="button"
              variant="primary"
              onClick={handleAddSizeOption}
              leftIcon={<PlusIcon className="w-4 h-4" />}
            >
              Add First Size
            </Button>
          </div>
        )}
      </div>

      {/* Divider */}
      <div className="border-t border-gray-200" />

      {/* Sizing Criteria */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h4 className="text-lg font-medium text-gray-900">Sizing Criteria</h4>
            <p className="text-sm text-gray-600">
              Define criteria to help customers determine which size applies to them.
            </p>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddCriteria}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Criteria
          </Button>
        </div>

        {criteriaFields.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Criteria
                  </th>
                  {sizeOptionsLookup.map(so => (
                    <th key={so.sizeOptionId} className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                      {SIZE_ICONS[so.sizeCode]} {so.sizeCode}
                    </th>
                  ))}
                  <th className="px-4 py-3 w-10"></th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {criteriaFields.map((field, index) => (
                  <tr key={field.id}>
                    <td className="px-4 py-2">
                      <Controller
                        name={`sizingCriteria.${index}.criteriaName`}
                        control={control}
                        render={({ field }) => (
                          <TextInput
                            {...field}
                            placeholder="e.g., Number of Landing Zones"
                            size="sm"
                          />
                        )}
                      />
                    </td>
                    {sizeOptionsLookup.map((so, soIndex) => (
                      <td key={so.sizeOptionId} className="px-4 py-2">
                        <Controller
                          name={`sizingCriteria.${index}.values.${soIndex}.criteriaValue`}
                          control={control}
                          render={({ field }) => (
                            <TextInput
                              {...field}
                              placeholder="Value"
                              size="sm"
                              className="text-center"
                            />
                          )}
                        />
                      </td>
                    ))}
                    <td className="px-4 py-2">
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        onClick={() => removeCriteria(index)}
                        className="text-red-500 hover:text-red-700"
                      >
                        <TrashIcon className="w-4 h-4" />
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-6 bg-gray-50 rounded-lg border border-dashed border-gray-300">
            <p className="text-gray-500 text-sm">No sizing criteria defined.</p>
          </div>
        )}
      </div>

      {/* Example Criteria */}
      <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-amber-800 mb-2">
          📏 Example Sizing Criteria
        </h4>
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="text-amber-800">
                <th className="text-left py-1">Criteria</th>
                <th className="text-center py-1">S</th>
                <th className="text-center py-1">M</th>
                <th className="text-center py-1">L</th>
              </tr>
            </thead>
            <tbody className="text-amber-700">
              <tr>
                <td className="py-1">Number of Landing Zones</td>
                <td className="text-center">1</td>
                <td className="text-center">2-3</td>
                <td className="text-center">4+</td>
              </tr>
              <tr>
                <td className="py-1">Cloud Providers</td>
                <td className="text-center">Single</td>
                <td className="text-center">Single</td>
                <td className="text-center">Multi</td>
              </tr>
              <tr>
                <td className="py-1">Compliance Requirements</td>
                <td className="text-center">Standard</td>
                <td className="text-center">Regulated</td>
                <td className="text-center">Highly Regulated</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default SizingSection;
