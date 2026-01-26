// ServiceCatalogForm/OutputsSection.tsx
// Section 10: Outputs (Deliverables) - Define service outputs/deliverables

import React, { useState } from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { PlusIcon, TrashIcon, ChevronDownIcon, ChevronUpIcon } from '@heroicons/react/24/outline';
import { DocumentArrowUpIcon, FolderIcon } from '@heroicons/react/24/solid';
import { TextInput, Button, Card } from '../../common';

interface OutputCategoryFieldProps {
  index: number;
  onRemove: () => void;
  canRemove: boolean;
}

const OutputCategoryField: React.FC<OutputCategoryFieldProps> = ({
  index,
  onRemove,
  canRemove,
}) => {
  const { control } = useFormContext();
  const [isExpanded, setIsExpanded] = useState(true);
  
  const { fields: items, append: appendItem, remove: removeItem } = useFieldArray({
    control,
    name: `outputCategories.${index}.items`,
  });

  return (
    <Card className="border-l-4 border-l-emerald-500">
      {/* Category Header */}
      <div 
        className="flex items-center justify-between p-4 cursor-pointer hover:bg-gray-50"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="flex items-center gap-3">
          <FolderIcon className="w-5 h-5 text-emerald-500" />
          <Controller
            name={`outputCategories.${index}.categoryName`}
            control={control}
            render={({ field }) => (
              <input
                {...field}
                type="text"
                placeholder={`Deliverable Category ${index + 1}...`}
                className="font-medium text-gray-900 bg-transparent border-none focus:ring-0 p-0 min-w-[200px]"
                onClick={(e) => e.stopPropagation()}
              />
            )}
          />
          <span className="text-sm text-gray-500">
            ({items.length} items)
          </span>
        </div>
        <div className="flex items-center gap-2">
          {canRemove && (
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
          )}
          {isExpanded ? (
            <ChevronUpIcon className="w-5 h-5 text-gray-400" />
          ) : (
            <ChevronDownIcon className="w-5 h-5 text-gray-400" />
          )}
        </div>
      </div>

      {/* Category Items (Deliverables) */}
      {isExpanded && (
        <div className="px-4 pb-4 space-y-2">
          {items.map((item, itemIndex) => (
            <div key={item.id} className="flex items-center gap-2">
              <DocumentArrowUpIcon className="w-4 h-4 text-emerald-400 flex-shrink-0" />
              <Controller
                name={`outputCategories.${index}.items.${itemIndex}`}
                control={control}
                render={({ field }) => (
                  <input
                    {...field}
                    type="text"
                    placeholder="Enter deliverable item..."
                    className="flex-1 px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-emerald-500 focus:border-emerald-500"
                  />
                )}
              />
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => removeItem(itemIndex)}
                disabled={items.length === 1}
                className="text-gray-400 hover:text-red-500"
              >
                <TrashIcon className="w-4 h-4" />
              </Button>
            </div>
          ))}
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => appendItem('')}
            leftIcon={<PlusIcon className="w-4 h-4" />}
            className="text-emerald-600 hover:text-emerald-700"
          >
            Add Deliverable
          </Button>
        </div>
      )}
    </Card>
  );
};

export const OutputsSection: React.FC = () => {
  const { control, formState: { errors } } = useFormContext();
  
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'outputCategories',
  });

  const handleAddCategory = () => {
    append({ categoryName: '', items: [''] });
  };

  return (
    <div className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-gray-600">
            Define the outputs and deliverables that customers receive from this service.
            Group related deliverables into logical categories.
          </p>
        </div>
        <Button
          type="button"
          variant="primary"
          size="sm"
          onClick={handleAddCategory}
          leftIcon={<PlusIcon className="w-4 h-4" />}
        >
          Add Category
        </Button>
      </div>

      {/* Error Message */}
      {errors.outputCategories?.message && (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-md p-3">
          {errors.outputCategories.message as string}
        </div>
      )}

      {/* Output Categories */}
      {fields.length > 0 ? (
        <div className="space-y-4">
          {fields.map((field, index) => (
            <OutputCategoryField
              key={field.id}
              index={index}
              onRemove={() => remove(index)}
              canRemove={fields.length > 1}
            />
          ))}
        </div>
      ) : (
        <div className="text-center py-8 bg-emerald-50 rounded-lg border-2 border-dashed border-emerald-300">
          <DocumentArrowUpIcon className="w-12 h-12 text-emerald-400 mx-auto mb-4" />
          <p className="text-emerald-700 mb-2">No output categories defined yet.</p>
          <p className="text-sm text-emerald-600 mb-4">
            Outputs define what customers receive from this service.
          </p>
          <Button
            type="button"
            variant="primary"
            onClick={handleAddCategory}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add First Category
          </Button>
        </div>
      )}

      {/* Example Outputs */}
      <div className="bg-emerald-50 border border-emerald-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-emerald-800 mb-3">
          📦 Example Output Structure
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
          <div className="p-3 bg-white rounded-md">
            <div className="flex items-center gap-2 font-medium text-gray-800 mb-2">
              <FolderIcon className="w-4 h-4 text-emerald-500" />
              Technical Architecture Design Document
            </div>
            <ul className="text-gray-600 text-xs space-y-1 ml-6">
              <li>• Landing Zone Architecture overview</li>
              <li>• Network topology and security design</li>
              <li>• Identity and access management design</li>
              <li>• Governance and policy framework</li>
              <li>• Operational model recommendations</li>
            </ul>
          </div>
          <div className="p-3 bg-white rounded-md">
            <div className="flex items-center gap-2 font-medium text-gray-800 mb-2">
              <FolderIcon className="w-4 h-4 text-emerald-500" />
              Implementation Guidance
            </div>
            <ul className="text-gray-600 text-xs space-y-1 ml-6">
              <li>• Infrastructure as Code templates</li>
              <li>• Deployment runbooks</li>
              <li>• Configuration guidelines</li>
              <li>• Testing and validation criteria</li>
            </ul>
          </div>
          <div className="p-3 bg-white rounded-md">
            <div className="flex items-center gap-2 font-medium text-gray-800 mb-2">
              <FolderIcon className="w-4 h-4 text-emerald-500" />
              Diagrams and Visualizations
            </div>
            <ul className="text-gray-600 text-xs space-y-1 ml-6">
              <li>• High-level architecture diagram</li>
              <li>• Detailed component diagrams</li>
              <li>• Network flow diagrams</li>
              <li>• Data flow diagrams</li>
            </ul>
          </div>
          <div className="p-3 bg-white rounded-md">
            <div className="flex items-center gap-2 font-medium text-gray-800 mb-2">
              <FolderIcon className="w-4 h-4 text-emerald-500" />
              Handover Materials
            </div>
            <ul className="text-gray-600 text-xs space-y-1 ml-6">
              <li>• Knowledge transfer sessions</li>
              <li>• Operations handover documentation</li>
              <li>• Training materials</li>
              <li>• Support escalation procedures</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Tips */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-800 mb-2">
          💡 Tips for Defining Outputs
        </h4>
        <ul className="text-sm text-blue-700 space-y-1">
          <li>• Group related deliverables into logical categories</li>
          <li>• Be specific about what each deliverable includes</li>
          <li>• Include both documents and activities (workshops, sessions)</li>
          <li>• Consider different audiences (technical, management)</li>
          <li>• Align outputs with customer expectations set during scoping</li>
        </ul>
      </div>
    </div>
  );
};

export default OutputsSection;
