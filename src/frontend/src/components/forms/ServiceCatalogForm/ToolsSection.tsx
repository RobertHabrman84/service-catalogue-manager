// ServiceCatalogForm/ToolsSection.tsx
// Section 6: Tools & Frameworks - Cloud capabilities, IaC, design tools

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { CloudIcon, WrenchScrewdriverIcon } from '@heroicons/react/24/solid';
import { TextInput, SelectInput, TextArea, Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

export const ToolsSection: React.FC = () => {
  const { control, watch } = useFormContext();
  
  // Cloud Provider Capabilities
  const { 
    fields: capabilityFields, 
    append: appendCapability, 
    remove: removeCapability 
  } = useFieldArray({
    control,
    name: 'cloudProviderCapabilities',
  });

  // Tools & Frameworks
  const { 
    fields: toolFields, 
    append: appendTool, 
    remove: removeTool 
  } = useFieldArray({
    control,
    name: 'toolsFrameworks',
  });

  // Fetch lookup data
  const { data: cloudProviders = [] } = useQuery({
    queryKey: ['lookups', 'cloudProviders'],
    queryFn: () => lookupService.getCloudProviders(),
  });

  const { data: toolCategories = [] } = useQuery({
    queryKey: ['lookups', 'toolCategories'],
    queryFn: () => lookupService.getToolCategories(),
  });

  const cloudProviderOptions = cloudProviders.map(cp => ({
    value: cp.cloudProviderId,
    label: cp.providerName,
  }));

  const toolCategoryOptions = toolCategories.map(tc => ({
    value: tc.toolCategoryId,
    label: tc.categoryName,
  }));

  const CAPABILITY_TYPES = [
    { value: 'Reference Architecture', label: 'Reference Architecture' },
    { value: 'Landing Zone Accelerator', label: 'Landing Zone Accelerator' },
    { value: 'Well-Architected Framework', label: 'Well-Architected Framework' },
    { value: 'Best Practices', label: 'Best Practices' },
    { value: 'Security Baseline', label: 'Security Baseline' },
    { value: 'Compliance Framework', label: 'Compliance Framework' },
  ];

  const handleAddCapability = () => {
    appendCapability({
      cloudProviderId: cloudProviders[0]?.cloudProviderId || 0,
      capabilityType: '',
      capabilityName: '',
      notes: '',
    });
  };

  const handleAddTool = () => {
    appendTool({
      toolCategoryId: toolCategories[0]?.toolCategoryId || 0,
      toolName: '',
      description: '',
    });
  };

  const watchedCapabilities = watch('cloudProviderCapabilities') || [];
  const watchedTools = watch('toolsFrameworks') || [];

  return (
    <div className="space-y-8">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Define the cloud provider capabilities, reference architectures, tools, and frameworks
        used in delivering this service.
      </p>

      {/* Cloud Provider Capabilities */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <CloudIcon className="w-6 h-6 text-blue-500" />
            <h4 className="text-lg font-medium text-gray-900">Cloud Provider Capabilities</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddCapability}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Capability
          </Button>
        </div>

        {capabilityFields.length > 0 ? (
          <div className="space-y-4">
            {capabilityFields.map((field, index) => {
              const capability = watchedCapabilities[index];
              const provider = cloudProviders.find(
                cp => cp.cloudProviderId === capability?.cloudProviderId
              );

              return (
                <Card key={field.id} className="p-4">
                  <div className="flex items-start gap-4">
                    {/* Provider Badge */}
                    <Badge variant="blue" className="flex-shrink-0">
                      {provider?.providerCode || 'CLOUD'}
                    </Badge>

                    {/* Content */}
                    <div className="flex-1">
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                        <Controller
                          name={`cloudProviderCapabilities.${index}.cloudProviderId`}
                          control={control}
                          render={({ field }) => (
                            <SelectInput
                              {...field}
                              label="Cloud Provider"
                              options={cloudProviderOptions}
                              onChange={(value) => field.onChange(Number(value))}
                            />
                          )}
                        />

                        <Controller
                          name={`cloudProviderCapabilities.${index}.capabilityType`}
                          control={control}
                          render={({ field }) => (
                            <SelectInput
                              {...field}
                              label="Capability Type"
                              options={CAPABILITY_TYPES}
                              placeholder="Select type..."
                            />
                          )}
                        />

                        <Controller
                          name={`cloudProviderCapabilities.${index}.capabilityName`}
                          control={control}
                          render={({ field }) => (
                            <TextInput
                              {...field}
                              label="Capability Name"
                              placeholder="e.g., AWS Well-Architected Framework"
                            />
                          )}
                        />
                      </div>

                      <Controller
                        name={`cloudProviderCapabilities.${index}.notes`}
                        control={control}
                        render={({ field }) => (
                          <TextInput
                            {...field}
                            label="Notes"
                            placeholder="Additional notes..."
                          />
                        )}
                      />
                    </div>

                    {/* Remove Button */}
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeCapability(index)}
                      className="text-red-500 hover:text-red-700"
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
            <CloudIcon className="w-10 h-10 text-blue-400 mx-auto mb-2" />
            <p className="text-blue-700">No cloud capabilities defined yet.</p>
          </div>
        )}
      </div>

      {/* Divider */}
      <div className="border-t border-gray-200" />

      {/* Tools & Frameworks */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <WrenchScrewdriverIcon className="w-6 h-6 text-orange-500" />
            <h4 className="text-lg font-medium text-gray-900">Tools & Frameworks</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddTool}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Tool
          </Button>
        </div>

        {toolFields.length > 0 ? (
          <div className="space-y-4">
            {toolFields.map((field, index) => {
              const tool = watchedTools[index];
              const category = toolCategories.find(
                tc => tc.toolCategoryId === tool?.toolCategoryId
              );

              return (
                <Card key={field.id} className="p-4">
                  <div className="flex items-start gap-4">
                    {/* Category Badge */}
                    <Badge variant="orange" className="flex-shrink-0">
                      {category?.categoryCode || 'TOOL'}
                    </Badge>

                    {/* Content */}
                    <div className="flex-1">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <Controller
                          name={`toolsFrameworks.${index}.toolCategoryId`}
                          control={control}
                          render={({ field }) => (
                            <SelectInput
                              {...field}
                              label="Category"
                              options={toolCategoryOptions}
                              onChange={(value) => field.onChange(Number(value))}
                            />
                          )}
                        />

                        <Controller
                          name={`toolsFrameworks.${index}.toolName`}
                          control={control}
                          render={({ field }) => (
                            <TextInput
                              {...field}
                              label="Tool/Framework Name"
                              placeholder="e.g., Terraform, Draw.io"
                            />
                          )}
                        />
                      </div>

                      <Controller
                        name={`toolsFrameworks.${index}.description`}
                        control={control}
                        render={({ field }) => (
                          <TextArea
                            {...field}
                            label="Description"
                            placeholder="How is this tool used in the service?"
                            rows={2}
                          />
                        )}
                      />
                    </div>

                    {/* Remove Button */}
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeTool(index)}
                      className="text-red-500 hover:text-red-700"
                    >
                      <TrashIcon className="w-4 h-4" />
                    </Button>
                  </div>
                </Card>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-6 bg-orange-50 rounded-lg border-2 border-dashed border-orange-300">
            <WrenchScrewdriverIcon className="w-10 h-10 text-orange-400 mx-auto mb-2" />
            <p className="text-orange-700">No tools or frameworks defined yet.</p>
          </div>
        )}
      </div>

      {/* Common Tools Reference */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-gray-800 mb-3">
          🔧 Common Tools by Category
        </h4>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-xs">
          <div>
            <div className="font-medium text-gray-700 mb-1">IaC Frameworks</div>
            <ul className="text-gray-600 space-y-0.5">
              <li>• Terraform</li>
              <li>• Bicep</li>
              <li>• CloudFormation</li>
              <li>• Pulumi</li>
            </ul>
          </div>
          <div>
            <div className="font-medium text-gray-700 mb-1">Design Tools</div>
            <ul className="text-gray-600 space-y-0.5">
              <li>• Draw.io</li>
              <li>• Lucidchart</li>
              <li>• Visio</li>
              <li>• Miro</li>
            </ul>
          </div>
          <div>
            <div className="font-medium text-gray-700 mb-1">Assessment</div>
            <ul className="text-gray-600 space-y-0.5">
              <li>• Azure Advisor</li>
              <li>• AWS Trusted Advisor</li>
              <li>• Cloud Adoption Framework</li>
            </ul>
          </div>
          <div>
            <div className="font-medium text-gray-700 mb-1">Documentation</div>
            <ul className="text-gray-600 space-y-0.5">
              <li>• Confluence</li>
              <li>• SharePoint</li>
              <li>• uuBookKit</li>
              <li>• Notion</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ToolsSection;
