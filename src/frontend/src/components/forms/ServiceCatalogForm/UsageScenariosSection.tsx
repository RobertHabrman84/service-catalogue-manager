// ServiceCatalogForm/UsageScenariosSection.tsx
// Section 2: Usage Scenarios - Define when and how the service is used

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { PlusIcon, TrashIcon, ArrowsUpDownIcon } from '@heroicons/react/24/outline';
import { TextInput, TextArea, Button, Card } from '../../common';
import { DragDropContext, Droppable, Draggable, DropResult } from '@hello-pangea/dnd';

export const UsageScenariosSection: React.FC = () => {
  const { control, formState: { errors } } = useFormContext();
  
  const { fields, append, remove, move } = useFieldArray({
    control,
    name: 'usageScenarios',
  });

  const handleAddScenario = () => {
    append({
      scenarioNumber: fields.length + 1,
      scenarioTitle: '',
      scenarioDescription: '',
    });
  };

  const handleRemoveScenario = (index: number) => {
    if (fields.length > 1) {
      remove(index);
    }
  };

  const handleDragEnd = (result: DropResult) => {
    if (!result.destination) return;
    move(result.source.index, result.destination.index);
  };

  return (
    <div className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-gray-600">
            Define specific scenarios where this service is applicable. Each scenario should describe
            a distinct use case or situation where this service provides value.
          </p>
        </div>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={handleAddScenario}
          leftIcon={<PlusIcon className="w-4 h-4" />}
        >
          Add Scenario
        </Button>
      </div>

      {/* Error Message */}
      {errors.usageScenarios?.message && (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-md p-3">
          {errors.usageScenarios.message as string}
        </div>
      )}

      {/* Scenarios List */}
      <DragDropContext onDragEnd={handleDragEnd}>
        <Droppable droppableId="usageScenarios">
          {(provided) => (
            <div
              {...provided.droppableProps}
              ref={provided.innerRef}
              className="space-y-4"
            >
              {fields.map((field, index) => (
                <Draggable key={field.id} draggableId={field.id} index={index}>
                  {(provided, snapshot) => (
                    <div
                      ref={provided.innerRef}
                      {...provided.draggableProps}
                      className={`${snapshot.isDragging ? 'shadow-lg' : ''}`}
                    >
                      <Card className="p-4 border-l-4 border-l-blue-500">
                        <div className="flex items-start gap-4">
                          {/* Drag Handle */}
                          <div
                            {...provided.dragHandleProps}
                            className="flex-shrink-0 mt-2 cursor-grab active:cursor-grabbing"
                          >
                            <ArrowsUpDownIcon className="w-5 h-5 text-gray-400" />
                          </div>

                          {/* Scenario Number */}
                          <div className="flex-shrink-0 w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center">
                            <span className="text-lg font-semibold text-blue-700">
                              {index + 1}
                            </span>
                          </div>

                          {/* Scenario Content */}
                          <div className="flex-1 space-y-4">
                            <Controller
                              name={`usageScenarios.${index}.scenarioTitle`}
                              control={control}
                              render={({ field }) => (
                                <TextInput
                                  {...field}
                                  label="Scenario Title"
                                  placeholder="e.g., New Application Deployment"
                                  required
                                  error={
                                    (errors.usageScenarios as any)?.[index]?.scenarioTitle?.message
                                  }
                                />
                              )}
                            />

                            <Controller
                              name={`usageScenarios.${index}.scenarioDescription`}
                              control={control}
                              render={({ field }) => (
                                <TextArea
                                  {...field}
                                  label="Description"
                                  placeholder="Describe when and why this scenario applies..."
                                  required
                                  rows={3}
                                  error={
                                    (errors.usageScenarios as any)?.[index]?.scenarioDescription?.message
                                  }
                                />
                              )}
                            />
                          </div>

                          {/* Remove Button */}
                          <div className="flex-shrink-0">
                            <Button
                              type="button"
                              variant="ghost"
                              size="sm"
                              onClick={() => handleRemoveScenario(index)}
                              disabled={fields.length === 1}
                              className="text-red-500 hover:text-red-700 hover:bg-red-50"
                            >
                              <TrashIcon className="w-5 h-5" />
                            </Button>
                          </div>
                        </div>
                      </Card>
                    </div>
                  )}
                </Draggable>
              ))}
              {provided.placeholder}
            </div>
          )}
        </Droppable>
      </DragDropContext>

      {/* Empty State */}
      {fields.length === 0 && (
        <div className="text-center py-8 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
          <p className="text-gray-500 mb-4">No usage scenarios defined yet.</p>
          <Button
            type="button"
            variant="primary"
            onClick={handleAddScenario}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add First Scenario
          </Button>
        </div>
      )}

      {/* Example Scenarios */}
      <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-amber-800 mb-2">
          📝 Example Usage Scenarios
        </h4>
        <div className="text-sm text-amber-700 space-y-2">
          <div>
            <strong>Scenario 1: New Application Deployment</strong>
            <p className="text-xs mt-1">
              When a business unit needs to deploy a new application to the cloud,
              requiring a secure, compliant landing zone with appropriate network isolation.
            </p>
          </div>
          <div>
            <strong>Scenario 2: Application Modernization</strong>
            <p className="text-xs mt-1">
              When migrating a legacy application to cloud-native architecture,
              requiring redesigned infrastructure and updated security controls.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UsageScenariosSection;
