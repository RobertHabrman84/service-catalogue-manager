// ServiceCatalogForm/InputsSection.tsx
// Section 9: Inputs (Parameters) - Define service input parameters

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon, ArrowsUpDownIcon } from '@heroicons/react/24/outline';
import { DocumentArrowDownIcon } from '@heroicons/react/24/solid';
import { TextInput, TextArea, SelectInput, Button, Card, Badge } from '../../common';
import { DragDropContext, Droppable, Draggable, DropResult } from '@hello-pangea/dnd';
import { lookupService } from '../../../services/api';

const DATA_TYPES = [
  { value: 'Text', label: 'Text' },
  { value: 'Number', label: 'Number' },
  { value: 'Boolean', label: 'Boolean (Yes/No)' },
  { value: 'List', label: 'List/Selection' },
  { value: 'Date', label: 'Date' },
  { value: 'File', label: 'File/Document' },
  { value: 'JSON', label: 'JSON/Structured Data' },
];

const REQUIREMENT_LEVEL_COLORS: Record<string, string> = {
  'REQUIRED': 'red',
  'RECOMMENDED': 'amber',
  'OPTIONAL': 'gray',
};

export const InputsSection: React.FC = () => {
  const { control, watch } = useFormContext();
  
  const { fields, append, remove, move } = useFieldArray({
    control,
    name: 'inputs',
  });

  // Fetch requirement levels
  const { data: requirementLevels = [] } = useQuery({
    queryKey: ['lookups', 'requirementLevels'],
    queryFn: () => lookupService.getRequirementLevels(),
  });

  const requirementLevelOptions = requirementLevels.map(rl => ({
    value: rl.requirementLevelId,
    label: rl.levelName,
  }));

  const handleAddInput = () => {
    append({
      parameterName: '',
      parameterDescription: '',
      requirementLevelId: requirementLevels.find(rl => rl.levelCode === 'REQUIRED')?.requirementLevelId || 0,
      dataType: 'Text',
      defaultValue: '',
    });
  };

  const handleDragEnd = (result: DropResult) => {
    if (!result.destination) return;
    move(result.source.index, result.destination.index);
  };

  const watchedInputs = watch('inputs') || [];

  return (
    <div className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-gray-600">
            Define the input parameters that customers need to provide for this service.
            This helps create a clear intake process.
          </p>
        </div>
        <Button
          type="button"
          variant="primary"
          size="sm"
          onClick={handleAddInput}
          leftIcon={<PlusIcon className="w-4 h-4" />}
        >
          Add Parameter
        </Button>
      </div>

      {/* Parameters List */}
      {fields.length > 0 ? (
        <DragDropContext onDragEnd={handleDragEnd}>
          <Droppable droppableId="inputs">
            {(provided) => (
              <div
                {...provided.droppableProps}
                ref={provided.innerRef}
                className="space-y-4"
              >
                {fields.map((field, index) => {
                  const input = watchedInputs[index];
                  const reqLevel = requirementLevels.find(
                    rl => rl.requirementLevelId === input?.requirementLevelId
                  );
                  const levelColor = REQUIREMENT_LEVEL_COLORS[reqLevel?.levelCode || 'REQUIRED'];

                  return (
                    <Draggable key={field.id} draggableId={field.id} index={index}>
                      {(provided, snapshot) => (
                        <div
                          ref={provided.innerRef}
                          {...provided.draggableProps}
                          className={snapshot.isDragging ? 'shadow-lg' : ''}
                        >
                          <Card className={`p-4 border-l-4 border-l-${levelColor}-500`}>
                            <div className="flex items-start gap-4">
                              {/* Drag Handle */}
                              <div
                                {...provided.dragHandleProps}
                                className="flex-shrink-0 mt-2 cursor-grab active:cursor-grabbing"
                              >
                                <ArrowsUpDownIcon className="w-5 h-5 text-gray-400" />
                              </div>

                              {/* Parameter Number */}
                              <div className="flex-shrink-0 w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">
                                <span className="text-sm font-medium text-gray-600">
                                  {index + 1}
                                </span>
                              </div>

                              {/* Parameter Content */}
                              <div className="flex-1 space-y-4">
                                {/* First Row: Name and Requirement Level */}
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                  <Controller
                                    name={`inputs.${index}.parameterName`}
                                    control={control}
                                    render={({ field }) => (
                                      <TextInput
                                        {...field}
                                        label="Parameter Name"
                                        placeholder="e.g., Application Name"
                                        required
                                      />
                                    )}
                                  />

                                  <Controller
                                    name={`inputs.${index}.requirementLevelId`}
                                    control={control}
                                    render={({ field }) => (
                                      <SelectInput
                                        {...field}
                                        label="Requirement Level"
                                        options={requirementLevelOptions}
                                        onChange={(value) => field.onChange(Number(value))}
                                      />
                                    )}
                                  />

                                  <Controller
                                    name={`inputs.${index}.dataType`}
                                    control={control}
                                    render={({ field }) => (
                                      <SelectInput
                                        {...field}
                                        label="Data Type"
                                        options={DATA_TYPES}
                                      />
                                    )}
                                  />
                                </div>

                                {/* Second Row: Description */}
                                <Controller
                                  name={`inputs.${index}.parameterDescription`}
                                  control={control}
                                  render={({ field }) => (
                                    <TextArea
                                      {...field}
                                      label="Description"
                                      placeholder="Describe what this parameter is for and any constraints..."
                                      rows={2}
                                    />
                                  )}
                                />

                                {/* Third Row: Default Value */}
                                <Controller
                                  name={`inputs.${index}.defaultValue`}
                                  control={control}
                                  render={({ field }) => (
                                    <TextInput
                                      {...field}
                                      label="Default Value (Optional)"
                                      placeholder="Default value if not specified by customer"
                                    />
                                  )}
                                />

                                {/* Badges */}
                                <div className="flex items-center gap-2">
                                  <Badge variant={levelColor as any}>
                                    {reqLevel?.levelName || 'Required'}
                                  </Badge>
                                  <Badge variant="gray">
                                    {input?.dataType || 'Text'}
                                  </Badge>
                                </div>
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
                        </div>
                      )}
                    </Draggable>
                  );
                })}
                {provided.placeholder}
              </div>
            )}
          </Droppable>
        </DragDropContext>
      ) : (
        <div className="text-center py-8 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
          <DocumentArrowDownIcon className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500 mb-2">No input parameters defined yet.</p>
          <p className="text-sm text-gray-400 mb-4">
            Input parameters define what information customers need to provide.
          </p>
          <Button
            type="button"
            variant="primary"
            onClick={handleAddInput}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add First Parameter
          </Button>
        </div>
      )}

      {/* Summary */}
      {fields.length > 0 && (
        <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
          <h4 className="text-sm font-medium text-gray-800 mb-3">
            📋 Parameter Summary
          </h4>
          <div className="flex gap-4 text-sm">
            <div>
              <span className="text-red-600 font-medium">
                {watchedInputs.filter(i => 
                  requirementLevels.find(rl => rl.requirementLevelId === i?.requirementLevelId)?.levelCode === 'REQUIRED'
                ).length}
              </span>
              <span className="text-gray-600"> Required</span>
            </div>
            <div>
              <span className="text-amber-600 font-medium">
                {watchedInputs.filter(i => 
                  requirementLevels.find(rl => rl.requirementLevelId === i?.requirementLevelId)?.levelCode === 'RECOMMENDED'
                ).length}
              </span>
              <span className="text-gray-600"> Recommended</span>
            </div>
            <div>
              <span className="text-gray-600 font-medium">
                {watchedInputs.filter(i => 
                  requirementLevels.find(rl => rl.requirementLevelId === i?.requirementLevelId)?.levelCode === 'OPTIONAL'
                ).length}
              </span>
              <span className="text-gray-600"> Optional</span>
            </div>
          </div>
        </div>
      )}

      {/* Example Parameters */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-800 mb-2">
          💡 Common Input Parameters
        </h4>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-xs text-blue-700">
          <ul className="space-y-1">
            <li>• Project Name</li>
            <li>• Application Name</li>
            <li>• Environment</li>
          </ul>
          <ul className="space-y-1">
            <li>• Business Unit</li>
            <li>• Cost Center</li>
            <li>• Owner Email</li>
          </ul>
          <ul className="space-y-1">
            <li>• Compliance Requirements</li>
            <li>• Data Classification</li>
            <li>• SLA Requirements</li>
          </ul>
          <ul className="space-y-1">
            <li>• Target Go-Live Date</li>
            <li>• Budget Range</li>
            <li>• Integration Points</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default InputsSection;
