// ServiceCatalogForm/ExamplesSection.tsx
// Section 16: Sizing Examples - Real-world examples for each size

import React, { useState } from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon, ChevronDownIcon, ChevronUpIcon } from '@heroicons/react/24/outline';
import { LightBulbIcon, DocumentTextIcon } from '@heroicons/react/24/solid';
import { TextInput, TextArea, SelectInput, Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

const SIZE_COLORS: Record<string, string> = {
  'XS': 'gray',
  'S': 'green',
  'M': 'blue',
  'L': 'purple',
  'XL': 'red',
};

interface ExampleCardProps {
  index: number;
  onRemove: () => void;
  sizeOptions: any[];
  getSizeCode: (id: number) => string;
}

const ExampleCard: React.FC<ExampleCardProps> = ({ index, onRemove, sizeOptions, getSizeCode }) => {
  const { control, watch } = useFormContext();
  const [isExpanded, setIsExpanded] = useState(true);
  
  const { fields: characteristics, append: appendChar, remove: removeChar } = useFieldArray({
    control,
    name: `sizingExamples.${index}.characteristics`,
  });

  const example = watch(`sizingExamples.${index}`);
  const sizeCode = getSizeCode(example?.sizeOptionId);
  const color = SIZE_COLORS[sizeCode] || 'gray';

  const sizeOptionsList = sizeOptions.map(so => ({
    value: so.sizeOptionId,
    label: `${so.sizeName} (${so.sizeCode})`,
  }));

  return (
    <Card className={`border-l-4 border-l-${color}-500`}>
      {/* Header */}
      <div
        className="flex items-center justify-between p-4 cursor-pointer hover:bg-gray-50"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="flex items-center gap-3">
          <Badge variant={color as any}>{sizeCode}</Badge>
          <LightBulbIcon className="w-5 h-5 text-amber-500" />
          <span className="font-medium text-gray-900">
            {example?.exampleTitle || `Example ${index + 1}`}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={(e) => {
              e.stopPropagation();
              onRemove();
            }}
            className="text-red-500 hover:text-red-700"
          >
            <TrashIcon className="w-4 h-4" />
          </Button>
          {isExpanded ? (
            <ChevronUpIcon className="w-5 h-5 text-gray-400" />
          ) : (
            <ChevronDownIcon className="w-5 h-5 text-gray-400" />
          )}
        </div>
      </div>

      {/* Content */}
      {isExpanded && (
        <div className="px-4 pb-4 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Controller
              name={`sizingExamples.${index}.sizeOptionId`}
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
              name={`sizingExamples.${index}.exampleTitle`}
              control={control}
              render={({ field }) => (
                <TextInput
                  {...field}
                  label="Example Title"
                  placeholder="e.g., Single Application Landing Zone"
                />
              )}
            />
          </div>

          <Controller
            name={`sizingExamples.${index}.scenario`}
            control={control}
            render={({ field }) => (
              <TextArea
                {...field}
                label="Scenario Description"
                placeholder="Describe the scenario where this size applies..."
                rows={3}
              />
            )}
          />

          {/* Characteristics */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <label className="block text-sm font-medium text-gray-700">
                Characteristics
              </label>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => appendChar('')}
                leftIcon={<PlusIcon className="w-3 h-3" />}
                className="text-xs"
              >
                Add
              </Button>
            </div>
            <div className="space-y-2">
              {characteristics.map((char, charIndex) => (
                <div key={char.id} className="flex items-center gap-2">
                  <span className="text-gray-400 text-sm">•</span>
                  <Controller
                    name={`sizingExamples.${index}.characteristics.${charIndex}`}
                    control={control}
                    render={({ field }) => (
                      <input
                        {...field}
                        type="text"
                        placeholder="Enter characteristic..."
                        className="flex-1 px-3 py-1.5 border border-gray-300 rounded-md text-sm"
                      />
                    )}
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => removeChar(charIndex)}
                    className="text-gray-400 hover:text-red-500"
                  >
                    <TrashIcon className="w-4 h-4" />
                  </Button>
                </div>
              ))}
              {characteristics.length === 0 && (
                <p className="text-sm text-gray-500 italic">No characteristics added</p>
              )}
            </div>
          </div>

          <Controller
            name={`sizingExamples.${index}.deliverables`}
            control={control}
            render={({ field }) => (
              <TextArea
                {...field}
                label="Key Deliverables (Optional)"
                placeholder="List the main deliverables for this example..."
                rows={2}
              />
            )}
          />
        </div>
      )}
    </Card>
  );
};

export const ExamplesSection: React.FC = () => {
  const { control } = useFormContext();
  
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'sizingExamples',
  });

  // Fetch size options
  const { data: sizeOptions = [] } = useQuery({
    queryKey: ['lookups', 'sizeOptions'],
    queryFn: () => lookupService.getSizeOptions(),
  });

  const getSizeCode = (sizeOptionId: number): string => {
    return sizeOptions.find(so => so.sizeOptionId === sizeOptionId)?.sizeCode || 'M';
  };

  const handleAddExample = () => {
    append({
      sizeOptionId: sizeOptions[0]?.sizeOptionId || 0,
      exampleTitle: '',
      scenario: '',
      characteristics: [''],
      deliverables: '',
    });
  };

  return (
    <div className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center justify-between">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <LightBulbIcon className="w-6 h-6 text-amber-500" />
            <h4 className="text-lg font-medium text-gray-900">Sizing Examples</h4>
          </div>
          <p className="text-sm text-gray-600">
            Provide real-world examples to help customers understand which size applies to their situation.
          </p>
        </div>
        <Button
          type="button"
          variant="primary"
          size="sm"
          onClick={handleAddExample}
          leftIcon={<PlusIcon className="w-4 h-4" />}
        >
          Add Example
        </Button>
      </div>

      {/* Examples List */}
      {fields.length > 0 ? (
        <div className="space-y-4">
          {fields.map((field, index) => (
            <ExampleCard
              key={field.id}
              index={index}
              onRemove={() => remove(index)}
              sizeOptions={sizeOptions}
              getSizeCode={getSizeCode}
            />
          ))}
        </div>
      ) : (
        <div className="text-center py-8 bg-amber-50 rounded-lg border-2 border-dashed border-amber-300">
          <LightBulbIcon className="w-12 h-12 text-amber-400 mx-auto mb-4" />
          <p className="text-amber-700 mb-2">No sizing examples defined yet.</p>
          <p className="text-sm text-amber-600 mb-4">
            Examples help customers understand which size is right for them.
          </p>
          <Button
            type="button"
            variant="primary"
            onClick={handleAddExample}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add First Example
          </Button>
        </div>
      )}

      {/* Example Reference */}
      <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-amber-800 mb-3">
          📋 Example Sizing Examples
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div className="p-3 bg-white rounded-md">
            <Badge variant="green" className="mb-2">S</Badge>
            <div className="font-medium text-gray-800 mb-1">
              Single PaaS Web Application
            </div>
            <ul className="text-gray-600 text-xs space-y-0.5">
              <li>• 1 Landing Zone</li>
              <li>• Standard security</li>
              <li>• Single region</li>
              <li>• No hybrid connectivity</li>
            </ul>
          </div>
          <div className="p-3 bg-white rounded-md">
            <Badge variant="blue" className="mb-2">M</Badge>
            <div className="font-medium text-gray-800 mb-1">
              Multi-tier Application
            </div>
            <ul className="text-gray-600 text-xs space-y-0.5">
              <li>• 2-3 Landing Zones</li>
              <li>• Enhanced security</li>
              <li>• DR considerations</li>
              <li>• Basic hybrid connectivity</li>
            </ul>
          </div>
          <div className="p-3 bg-white rounded-md">
            <Badge variant="purple" className="mb-2">L</Badge>
            <div className="font-medium text-gray-800 mb-1">
              Enterprise Platform
            </div>
            <ul className="text-gray-600 text-xs space-y-0.5">
              <li>• 4+ Landing Zones</li>
              <li>• Highly regulated</li>
              <li>• Multi-region</li>
              <li>• Complex hybrid</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ExamplesSection;
