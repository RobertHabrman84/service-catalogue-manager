// ServiceCatalogForm/BasicInfoSection.tsx
// Section 1: Basic Information (Service Code, Name, Category, Description)

import React from 'react';
import { useFormContext, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { TextInput, SelectInput, TextArea } from '../FormControls';
import { lookupService } from '../../../services/api';

export const BasicInfoSection: React.FC = () => {
  const { control, formState: { errors } } = useFormContext();

  // Fetch service categories
  const { data: categories = [], isLoading: categoriesLoading } = useQuery({
    queryKey: ['lookups', 'categories'],
    queryFn: () => lookupService.getServiceCategories(),
  });

  const categoryOptions = Array.isArray(categories) 
    ? categories.map(cat => ({
        value: cat.categoryId,
        label: cat.categoryPath || cat.categoryName,
      }))
    : [];

  return (
    <div className="space-y-6">
      {/* Service Code & Name Row */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Controller
          name="serviceCode"
          control={control}
          render={({ field }) => (
            <TextInput
              {...field}
              label="Service Code"
              placeholder="e.g., ID001"
              required
              error={errors.serviceCode?.message as string}
              helperText="Unique identifier for the service (e.g., ID001, SVC-ARCH-001)"
              maxLength={50}
            />
          )}
        />

        <Controller
          name="version"
          control={control}
          render={({ field }) => (
            <TextInput
              {...field}
              label="Version"
              placeholder="e.g., v1.0"
              error={errors.version?.message as string}
              helperText="Service version number"
              maxLength={20}
            />
          )}
        />
      </div>

      {/* Service Name */}
      <Controller
        name="serviceName"
        control={control}
        render={({ field }) => (
          <TextInput
            {...field}
            label="Service Name"
            placeholder="e.g., Application Landing Zone Design"
            required
            error={errors.serviceName?.message as string}
            helperText="Full descriptive name of the service"
            maxLength={200}
          />
        )}
      />

      {/* Category */}
      <Controller
        name="categoryId"
        control={control}
        render={({ field }) => (
          <SelectInput
            {...field}
            label="Service Category"
            placeholder="Select a category..."
            required
            error={errors.categoryId?.message as string}
            options={categoryOptions}
            isLoading={categoriesLoading}
            helperText="Classification category for the service"
            onChange={(value) => field.onChange(Number(value))}
          />
        )}
      />

      {/* Description */}
      <Controller
        name="description"
        control={control}
        render={({ field }) => (
          <TextArea
            {...field}
            label="Description"
            placeholder="Provide a comprehensive description of the service..."
            required
            error={errors.description?.message as string}
            helperText="Detailed description of what this service provides and its purpose"
            rows={6}
            maxLength={5000}
            showCharCount
          />
        )}
      />

      {/* Quick Tips */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-800 mb-2">
          💡 Tips for Basic Information
        </h4>
        <ul className="text-sm text-blue-700 space-y-1">
          <li>• Use a consistent naming convention for service codes (e.g., ID001, SVC-ARCH-001)</li>
          <li>• The service name should clearly describe what the service delivers</li>
          <li>• Description should explain the value proposition and target audience</li>
          <li>• Choose the most specific category that applies</li>
        </ul>
      </div>
    </div>
  );
};

export default BasicInfoSection;
