// ServiceCatalogForm/MultiCloudSection.tsx
// Section 15: Multi-Cloud Considerations - Cloud-agnostic design considerations

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { PlusIcon, TrashIcon, ArrowsUpDownIcon } from '@heroicons/react/24/outline';
import { CloudIcon, GlobeAltIcon } from '@heroicons/react/24/solid';
import { TextInput, TextArea, Button, Card } from '../../common';
import { DragDropContext, Droppable, Draggable, DropResult } from '@hello-pangea/dnd';

const CONSIDERATION_SUGGESTIONS = [
  {
    title: 'Design Pattern Abstraction',
    description: 'Use cloud-agnostic design patterns that can be implemented across multiple cloud providers.',
  },
  {
    title: 'Infrastructure as Code Portability',
    description: 'Consider using Terraform or Pulumi for cross-cloud IaC compatibility.',
  },
  {
    title: 'Identity Federation',
    description: 'Design identity solutions that can federate across cloud providers.',
  },
  {
    title: 'Network Connectivity Patterns',
    description: 'Define connectivity patterns that work across AWS, Azure, and GCP.',
  },
  {
    title: 'Data Residency & Compliance',
    description: 'Address data residency requirements that may vary by cloud region.',
  },
  {
    title: 'Vendor Lock-in Mitigation',
    description: 'Identify areas of potential vendor lock-in and mitigation strategies.',
  },
];

export const MultiCloudSection: React.FC = () => {
  const { control } = useFormContext();
  
  const { fields, append, remove, move } = useFieldArray({
    control,
    name: 'multiCloudConsiderations',
  });

  const handleAddConsideration = (title?: string, description?: string) => {
    append({
      considerationTitle: title || '',
      considerationDescription: description || '',
    });
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
          <div className="flex items-center gap-2 mb-2">
            <GlobeAltIcon className="w-6 h-6 text-cyan-500" />
            <h4 className="text-lg font-medium text-gray-900">Multi-Cloud Considerations</h4>
          </div>
          <p className="text-sm text-gray-600">
            Define considerations for multi-cloud or cloud-agnostic service delivery.
          </p>
        </div>
        <Button
          type="button"
          variant="primary"
          size="sm"
          onClick={() => handleAddConsideration()}
          leftIcon={<PlusIcon className="w-4 h-4" />}
        >
          Add Consideration
        </Button>
      </div>

      {/* Considerations List */}
      {fields.length > 0 ? (
        <DragDropContext onDragEnd={handleDragEnd}>
          <Droppable droppableId="multiCloudConsiderations">
            {(provided) => (
              <div {...provided.droppableProps} ref={provided.innerRef} className="space-y-4">
                {fields.map((field, index) => (
                  <Draggable key={field.id} draggableId={field.id} index={index}>
                    {(provided, snapshot) => (
                      <div ref={provided.innerRef} {...provided.draggableProps} className={snapshot.isDragging ? 'shadow-lg' : ''}>
                        <Card className="p-4 border-l-4 border-l-cyan-500">
                          <div className="flex items-start gap-4">
                            <div {...provided.dragHandleProps} className="flex-shrink-0 mt-2 cursor-grab">
                              <ArrowsUpDownIcon className="w-5 h-5 text-gray-400" />
                            </div>
                            <div className="flex-shrink-0 p-2 rounded-lg bg-cyan-100">
                              <CloudIcon className="w-5 h-5 text-cyan-600" />
                            </div>
                            <div className="flex-1 space-y-4">
                              <Controller
                                name={`multiCloudConsiderations.${index}.considerationTitle`}
                                control={control}
                                render={({ field }) => (
                                  <TextInput {...field} label="Consideration Title" placeholder="e.g., Design Pattern Abstraction" />
                                )}
                              />
                              <Controller
                                name={`multiCloudConsiderations.${index}.considerationDescription`}
                                control={control}
                                render={({ field }) => (
                                  <TextArea {...field} label="Description" placeholder="Describe the multi-cloud consideration..." rows={3} />
                                )}
                              />
                            </div>
                            <Button type="button" variant="ghost" size="sm" onClick={() => remove(index)} className="text-red-500 hover:text-red-700">
                              <TrashIcon className="w-4 h-4" />
                            </Button>
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
      ) : (
        <div className="text-center py-8 bg-cyan-50 rounded-lg border-2 border-dashed border-cyan-300">
          <GlobeAltIcon className="w-12 h-12 text-cyan-400 mx-auto mb-4" />
          <p className="text-cyan-700 mb-2">No multi-cloud considerations defined yet.</p>
          <Button type="button" variant="primary" onClick={() => handleAddConsideration()} leftIcon={<PlusIcon className="w-4 h-4" />}>
            Add First Consideration
          </Button>
        </div>
      )}

      {/* Quick Add Suggestions */}
      <div className="bg-cyan-50 border border-cyan-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-cyan-800 mb-3">⚡ Quick Add Common Considerations</h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
          {CONSIDERATION_SUGGESTIONS.map((suggestion) => (
            <Button
              key={suggestion.title}
              type="button"
              variant="outline"
              size="sm"
              onClick={() => handleAddConsideration(suggestion.title, suggestion.description)}
              className="justify-start text-left text-xs border-cyan-300 text-cyan-700 hover:bg-cyan-100"
            >
              <PlusIcon className="w-3 h-3 mr-2 flex-shrink-0" />
              <span className="truncate">{suggestion.title}</span>
            </Button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default MultiCloudSection;
