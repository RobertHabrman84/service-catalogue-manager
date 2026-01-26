// ServiceCatalogForm/ScopeSection.tsx
// Section 4: Scope - Define what's in scope and out of scope

import React, { useState } from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { PlusIcon, TrashIcon, ChevronDownIcon, ChevronUpIcon } from '@heroicons/react/24/outline';
import { CheckCircleIcon, XCircleIcon } from '@heroicons/react/24/solid';
import { TextInput, Button, Card } from '../../common';

interface ScopeCategoryFieldProps {
  baseName: string;
  index: number;
  onRemove: () => void;
  canRemove: boolean;
  variant: 'in' | 'out';
}

const ScopeCategoryField: React.FC<ScopeCategoryFieldProps> = ({
  baseName,
  index,
  onRemove,
  canRemove,
  variant,
}) => {
  const { control } = useFormContext();
  const [isExpanded, setIsExpanded] = useState(true);
  
  const { fields: items, append: appendItem, remove: removeItem } = useFieldArray({
    control,
    name: `${baseName}.${index}.items`,
  });

  const colorClass = variant === 'in' ? 'green' : 'red';

  return (
    <Card className={`border-l-4 border-l-${colorClass}-500`}>
      {/* Category Header */}
      <div 
        className="flex items-center justify-between p-4 cursor-pointer hover:bg-gray-50"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="flex items-center gap-3">
          {variant === 'in' ? (
            <CheckCircleIcon className="w-5 h-5 text-green-500" />
          ) : (
            <XCircleIcon className="w-5 h-5 text-red-500" />
          )}
          <Controller
            name={`${baseName}.${index}.categoryName`}
            control={control}
            render={({ field }) => (
              <input
                {...field}
                type="text"
                placeholder={`Category ${index + 1} name...`}
                className="font-medium text-gray-900 bg-transparent border-none focus:ring-0 p-0"
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

      {/* Category Items */}
      {isExpanded && (
        <div className="px-4 pb-4 space-y-2">
          {items.map((item, itemIndex) => (
            <div key={item.id} className="flex items-center gap-2">
              <span className="text-gray-400 text-sm w-6">{itemIndex + 1}.</span>
              <Controller
                name={`${baseName}.${index}.items.${itemIndex}`}
                control={control}
                render={({ field }) => (
                  <input
                    {...field}
                    type="text"
                    placeholder="Enter scope item..."
                    className="flex-1 px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-blue-500 focus:border-blue-500"
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
            className="text-gray-600"
          >
            Add Item
          </Button>
        </div>
      )}
    </Card>
  );
};

export const ScopeSection: React.FC = () => {
  const { control } = useFormContext();
  
  const { 
    fields: inScopeFields, 
    append: appendInScope, 
    remove: removeInScope 
  } = useFieldArray({
    control,
    name: 'inScopeCategories',
  });

  const { 
    fields: outScopeFields, 
    append: appendOutScope, 
    remove: removeOutScope 
  } = useFieldArray({
    control,
    name: 'outScopeCategories',
  });

  const handleAddInScopeCategory = () => {
    appendInScope({ categoryName: '', items: [''] });
  };

  const handleAddOutScopeCategory = () => {
    appendOutScope({ categoryName: '', items: [''] });
  };

  return (
    <div className="space-y-8">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Clearly define what is included (in scope) and excluded (out of scope) from this service.
        This helps set clear expectations with customers.
      </p>

      {/* In Scope Section */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <CheckCircleIcon className="w-6 h-6 text-green-500" />
            <h4 className="text-lg font-medium text-gray-900">In Scope</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddInScopeCategory}
            leftIcon={<PlusIcon className="w-4 h-4" />}
            className="border-green-300 text-green-700 hover:bg-green-50"
          >
            Add Category
          </Button>
        </div>

        <div className="space-y-4">
          {inScopeFields.map((field, index) => (
            <ScopeCategoryField
              key={field.id}
              baseName="inScopeCategories"
              index={index}
              onRemove={() => removeInScope(index)}
              canRemove={inScopeFields.length > 1}
              variant="in"
            />
          ))}
        </div>

        {inScopeFields.length === 0 && (
          <div className="text-center py-6 bg-green-50 rounded-lg border-2 border-dashed border-green-300">
            <p className="text-green-700 mb-2">No in-scope categories defined.</p>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleAddInScopeCategory}
              className="border-green-300 text-green-700"
            >
              Add First Category
            </Button>
          </div>
        )}
      </div>

      {/* Divider */}
      <div className="border-t border-gray-200" />

      {/* Out of Scope Section */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <XCircleIcon className="w-6 h-6 text-red-500" />
            <h4 className="text-lg font-medium text-gray-900">Out of Scope</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddOutScopeCategory}
            leftIcon={<PlusIcon className="w-4 h-4" />}
            className="border-red-300 text-red-700 hover:bg-red-50"
          >
            Add Category
          </Button>
        </div>

        <div className="space-y-4">
          {outScopeFields.map((field, index) => (
            <ScopeCategoryField
              key={field.id}
              baseName="outScopeCategories"
              index={index}
              onRemove={() => removeOutScope(index)}
              canRemove={outScopeFields.length > 1}
              variant="out"
            />
          ))}
        </div>

        {outScopeFields.length === 0 && (
          <div className="text-center py-6 bg-red-50 rounded-lg border-2 border-dashed border-red-300">
            <p className="text-red-700 mb-2">No out-of-scope categories defined.</p>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleAddOutScopeCategory}
              className="border-red-300 text-red-700"
            >
              Add First Category
            </Button>
          </div>
        )}
      </div>

      {/* Tips */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-800 mb-2">
          💡 Tips for Defining Scope
        </h4>
        <ul className="text-sm text-blue-700 space-y-1">
          <li>• Be specific - vague scope leads to misunderstandings</li>
          <li>• Group related items into logical categories</li>
          <li>• Out of scope is just as important as in scope</li>
          <li>• Consider edge cases and explicitly address them</li>
          <li>• Use consistent terminology with other services</li>
        </ul>
      </div>
    </div>
  );
};

export default ScopeSection;
