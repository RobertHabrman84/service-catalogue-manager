// ServiceCatalogForm/InteractionSection.tsx
// Section 8: Interaction Requirements - Customer requirements, access, stakeholders

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { 
  ChatBubbleLeftRightIcon, 
  UserGroupIcon, 
  LockClosedIcon,
  ClipboardDocumentCheckIcon 
} from '@heroicons/react/24/solid';
import { TextInput, TextArea, SelectInput, Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

const INTERACTION_LEVEL_COLORS: Record<string, string> = {
  'HIGH': 'red',
  'MEDIUM': 'amber',
  'LOW': 'green',
};

export const InteractionSection: React.FC = () => {
  const { control, watch, formState: { errors } } = useFormContext();

  // Customer Requirements
  const { 
    fields: customerFields, 
    append: appendCustomer, 
    remove: removeCustomer 
  } = useFieldArray({
    control,
    name: 'customerRequirements',
  });

  // Access Requirements
  const { 
    fields: accessFields, 
    append: appendAccess, 
    remove: removeAccess 
  } = useFieldArray({
    control,
    name: 'accessRequirements',
  });

  // Stakeholder Involvements
  const { 
    fields: stakeholderFields, 
    append: appendStakeholder, 
    remove: removeStakeholder 
  } = useFieldArray({
    control,
    name: 'stakeholderInvolvements',
  });

  // Fetch interaction levels
  const { data: interactionLevels = [] } = useQuery({
    queryKey: ['lookups', 'interactionLevels'],
    queryFn: () => lookupService.getInteractionLevels(),
  });

  const interactionLevelOptions = interactionLevels.map(il => ({
    value: il.interactionLevelId,
    label: `${il.levelName} Interaction`,
  }));

  const watchedInteraction = watch('interaction');
  const currentLevel = interactionLevels.find(
    il => il.interactionLevelId === watchedInteraction?.interactionLevelId
  );
  const levelColor = INTERACTION_LEVEL_COLORS[currentLevel?.levelCode || 'MEDIUM'];

  return (
    <div className="space-y-8">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Define how customers interact with this service, what they need to provide,
        what access is required, and which stakeholders should be involved.
      </p>

      {/* Interaction Level */}
      <Card className={`p-4 border-l-4 border-l-${levelColor}-500`}>
        <div className="flex items-start gap-4">
          <div className={`p-2 rounded-lg bg-${levelColor}-100`}>
            <ChatBubbleLeftRightIcon className={`w-6 h-6 text-${levelColor}-600`} />
          </div>
          <div className="flex-1 space-y-4">
            <h4 className="text-lg font-medium text-gray-900">Interaction Level</h4>
            <p className="text-sm text-gray-600">
              How much customer interaction is required during service delivery?
            </p>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Controller
                name="interaction.interactionLevelId"
                control={control}
                render={({ field }) => (
                  <SelectInput
                    {...field}
                    label="Level"
                    options={interactionLevelOptions}
                    required
                    onChange={(value) => field.onChange(Number(value))}
                    error={(errors.interaction as any)?.interactionLevelId?.message}
                  />
                )}
              />

              <Controller
                name="interaction.notes"
                control={control}
                render={({ field }) => (
                  <TextInput
                    {...field}
                    label="Notes"
                    placeholder="Additional context about interaction..."
                  />
                )}
              />
            </div>

            {/* Level Description */}
            <div className={`p-3 rounded-md bg-${levelColor}-50`}>
              {currentLevel?.levelCode === 'HIGH' && (
                <p className="text-sm text-red-700">
                  <strong>High Interaction:</strong> Frequent workshops, daily standups, 
                  continuous collaboration with customer team members.
                </p>
              )}
              {currentLevel?.levelCode === 'MEDIUM' && (
                <p className="text-sm text-amber-700">
                  <strong>Medium Interaction:</strong> Weekly checkpoints, milestone reviews, 
                  periodic working sessions.
                </p>
              )}
              {currentLevel?.levelCode === 'LOW' && (
                <p className="text-sm text-green-700">
                  <strong>Low Interaction:</strong> Kick-off and sign-off meetings, 
                  asynchronous communication, deliverable-based engagement.
                </p>
              )}
            </div>
          </div>
        </div>
      </Card>

      {/* Customer Requirements (Customer Must Provide) */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <ClipboardDocumentCheckIcon className="w-6 h-6 text-blue-500" />
            <h4 className="text-lg font-medium text-gray-900">Customer Must Provide</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => appendCustomer({ requirementDescription: '' })}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Requirement
          </Button>
        </div>

        {customerFields.length > 0 ? (
          <div className="space-y-3">
            {customerFields.map((field, index) => (
              <div key={field.id} className="flex items-start gap-3">
                <span className="text-gray-400 text-sm mt-2 w-6">{index + 1}.</span>
                <Controller
                  name={`customerRequirements.${index}.requirementDescription`}
                  control={control}
                  render={({ field }) => (
                    <TextArea
                      {...field}
                      placeholder="What must the customer provide?"
                      rows={2}
                      className="flex-1"
                    />
                  )}
                />
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={() => removeCustomer(index)}
                  className="text-red-500 hover:text-red-700 mt-1"
                >
                  <TrashIcon className="w-4 h-4" />
                </Button>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-4 bg-blue-50 rounded-lg border border-dashed border-blue-300">
            <p className="text-blue-700 text-sm">No customer requirements defined.</p>
          </div>
        )}
      </div>

      {/* Access Requirements */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <LockClosedIcon className="w-6 h-6 text-purple-500" />
            <h4 className="text-lg font-medium text-gray-900">Access Requirements</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => appendAccess({ requirementDescription: '' })}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Access
          </Button>
        </div>

        {accessFields.length > 0 ? (
          <div className="space-y-3">
            {accessFields.map((field, index) => (
              <div key={field.id} className="flex items-start gap-3">
                <span className="text-gray-400 text-sm mt-2 w-6">{index + 1}.</span>
                <Controller
                  name={`accessRequirements.${index}.requirementDescription`}
                  control={control}
                  render={({ field }) => (
                    <TextArea
                      {...field}
                      placeholder="What access is needed? (e.g., Azure subscription contributor role)"
                      rows={2}
                      className="flex-1"
                    />
                  )}
                />
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={() => removeAccess(index)}
                  className="text-red-500 hover:text-red-700 mt-1"
                >
                  <TrashIcon className="w-4 h-4" />
                </Button>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-4 bg-purple-50 rounded-lg border border-dashed border-purple-300">
            <p className="text-purple-700 text-sm">No access requirements defined.</p>
          </div>
        )}
      </div>

      {/* Stakeholder Involvement */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <UserGroupIcon className="w-6 h-6 text-green-500" />
            <h4 className="text-lg font-medium text-gray-900">Stakeholder Involvement</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => appendStakeholder({ stakeholderRole: '', involvementDescription: '' })}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Stakeholder
          </Button>
        </div>

        {stakeholderFields.length > 0 ? (
          <div className="space-y-4">
            {stakeholderFields.map((field, index) => (
              <Card key={field.id} className="p-4">
                <div className="flex items-start gap-4">
                  <div className="flex-1 grid grid-cols-1 md:grid-cols-2 gap-4">
                    <Controller
                      name={`stakeholderInvolvements.${index}.stakeholderRole`}
                      control={control}
                      render={({ field }) => (
                        <TextInput
                          {...field}
                          label="Stakeholder Role"
                          placeholder="e.g., CTO/CIO or delegate"
                        />
                      )}
                    />

                    <Controller
                      name={`stakeholderInvolvements.${index}.involvementDescription`}
                      control={control}
                      render={({ field }) => (
                        <TextInput
                          {...field}
                          label="Involvement"
                          placeholder="e.g., Kick-off, key decisions, sign-off"
                        />
                      )}
                    />
                  </div>

                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => removeStakeholder(index)}
                    className="text-red-500 hover:text-red-700"
                  >
                    <TrashIcon className="w-4 h-4" />
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        ) : (
          <div className="text-center py-4 bg-green-50 rounded-lg border border-dashed border-green-300">
            <p className="text-green-700 text-sm">No stakeholder involvement defined.</p>
          </div>
        )}
      </div>

      {/* Tips */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-800 mb-2">
          💡 Tips for Interaction Requirements
        </h4>
        <ul className="text-sm text-blue-700 space-y-1">
          <li>• Be specific about what customers need to provide</li>
          <li>• List all required access permissions clearly</li>
          <li>• Identify key stakeholders and their involvement points</li>
          <li>• Match interaction level to service complexity</li>
        </ul>
      </div>
    </div>
  );
};

export default InteractionSection;
