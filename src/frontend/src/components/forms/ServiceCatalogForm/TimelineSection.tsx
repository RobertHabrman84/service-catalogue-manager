// ServiceCatalogForm/TimelineSection.tsx
// Section 11: Timeline & Phases - Define service delivery phases

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { PlusIcon, TrashIcon, ArrowsUpDownIcon } from '@heroicons/react/24/outline';
import { ClockIcon, FlagIcon } from '@heroicons/react/24/solid';
import { TextInput, Button, Card } from '../../common';
import { DragDropContext, Droppable, Draggable, DropResult } from '@hello-pangea/dnd';

const PHASE_COLORS = [
  'blue', 'indigo', 'purple', 'pink', 'red', 'orange', 'amber', 'yellow', 'lime', 'green'
];

export const TimelineSection: React.FC = () => {
  const { control, watch } = useFormContext();
  
  const { fields, append, remove, move } = useFieldArray({
    control,
    name: 'timelinePhases',
  });

  const handleAddPhase = () => {
    append({
      phaseNumber: fields.length + 1,
      phaseName: '',
    });
  };

  const handleDragEnd = (result: DropResult) => {
    if (!result.destination) return;
    move(result.source.index, result.destination.index);
  };

  const watchedPhases = watch('timelinePhases') || [];

  return (
    <div className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-gray-600">
            Define the phases or milestones in the service delivery timeline.
            Drag to reorder phases.
          </p>
        </div>
        <Button
          type="button"
          variant="primary"
          size="sm"
          onClick={handleAddPhase}
          leftIcon={<PlusIcon className="w-4 h-4" />}
        >
          Add Phase
        </Button>
      </div>

      {/* Timeline Visual */}
      {fields.length > 0 && (
        <div className="relative py-4">
          {/* Timeline Line */}
          <div className="absolute top-1/2 left-0 right-0 h-1 bg-gray-200 -translate-y-1/2" />
          
          {/* Phase Indicators */}
          <div className="relative flex justify-between">
            {fields.map((field, index) => {
              const color = PHASE_COLORS[index % PHASE_COLORS.length];
              const phase = watchedPhases[index];
              
              return (
                <div key={field.id} className="flex flex-col items-center">
                  <div className={`w-8 h-8 rounded-full bg-${color}-500 flex items-center justify-center text-white font-bold text-sm z-10`}>
                    {index + 1}
                  </div>
                  <div className="mt-2 text-xs text-center max-w-[80px] truncate">
                    {phase?.phaseName || `Phase ${index + 1}`}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Phases List */}
      {fields.length > 0 ? (
        <DragDropContext onDragEnd={handleDragEnd}>
          <Droppable droppableId="timelinePhases">
            {(provided) => (
              <div
                {...provided.droppableProps}
                ref={provided.innerRef}
                className="space-y-3"
              >
                {fields.map((field, index) => {
                  const color = PHASE_COLORS[index % PHASE_COLORS.length];

                  return (
                    <Draggable key={field.id} draggableId={field.id} index={index}>
                      {(provided, snapshot) => (
                        <div
                          ref={provided.innerRef}
                          {...provided.draggableProps}
                          className={snapshot.isDragging ? 'shadow-lg' : ''}
                        >
                          <Card className={`p-4 border-l-4 border-l-${color}-500`}>
                            <div className="flex items-center gap-4">
                              {/* Drag Handle */}
                              <div
                                {...provided.dragHandleProps}
                                className="cursor-grab active:cursor-grabbing"
                              >
                                <ArrowsUpDownIcon className="w-5 h-5 text-gray-400" />
                              </div>

                              {/* Phase Number */}
                              <div className={`flex-shrink-0 w-10 h-10 rounded-full bg-${color}-100 flex items-center justify-center`}>
                                <span className={`text-lg font-bold text-${color}-600`}>
                                  {index + 1}
                                </span>
                              </div>

                              {/* Phase Name */}
                              <Controller
                                name={`timelinePhases.${index}.phaseName`}
                                control={control}
                                render={({ field }) => (
                                  <TextInput
                                    {...field}
                                    placeholder={`Phase ${index + 1} name (e.g., Discovery, Design, Implementation)`}
                                    className="flex-1"
                                  />
                                )}
                              />

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
          <ClockIcon className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500 mb-2">No timeline phases defined yet.</p>
          <p className="text-sm text-gray-400 mb-4">
            Phases help customers understand the service delivery journey.
          </p>
          <Button
            type="button"
            variant="primary"
            onClick={handleAddPhase}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add First Phase
          </Button>
        </div>
      )}

      {/* Quick Add Common Phases */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-gray-800 mb-3">
          ⚡ Quick Add Common Phases
        </h4>
        <div className="flex flex-wrap gap-2">
          {[
            'Discovery & Assessment',
            'Requirements Gathering',
            'Architecture Design',
            'Review & Approval',
            'Implementation',
            'Testing & Validation',
            'Documentation',
            'Knowledge Transfer',
            'Handover & Closure',
          ].map((phaseName) => (
            <Button
              key={phaseName}
              type="button"
              variant="outline"
              size="sm"
              onClick={() => append({ phaseNumber: fields.length + 1, phaseName })}
              className="text-xs"
            >
              + {phaseName}
            </Button>
          ))}
        </div>
      </div>

      {/* Example Timeline */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-800 mb-3">
          📅 Example Service Timeline
        </h4>
        <div className="flex items-center gap-2 overflow-x-auto pb-2">
          {['Kick-off', 'Discovery', 'Design', 'Review', 'Refinement', 'Sign-off'].map((phase, idx) => (
            <React.Fragment key={phase}>
              <div className="flex items-center gap-2 flex-shrink-0">
                <div className={`w-6 h-6 rounded-full bg-${PHASE_COLORS[idx]}-500 flex items-center justify-center text-white text-xs font-bold`}>
                  {idx + 1}
                </div>
                <span className="text-sm text-gray-700 whitespace-nowrap">{phase}</span>
              </div>
              {idx < 5 && (
                <div className="w-8 h-0.5 bg-gray-300 flex-shrink-0" />
              )}
            </React.Fragment>
          ))}
          <FlagIcon className="w-5 h-5 text-green-500 flex-shrink-0 ml-2" />
        </div>
      </div>
    </div>
  );
};

export default TimelineSection;
