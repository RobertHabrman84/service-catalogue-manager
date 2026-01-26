// ServiceCatalogForm/LicensesSection.tsx
// Section 7: Licenses - Software and cloud service licenses required

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { DocumentTextIcon } from '@heroicons/react/24/solid';
import { TextInput, SelectInput, TextArea } from '../FormControls';
import { Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

export const LicensesSection: React.FC = () => {
  const { control, watch } = useFormContext();
  
  // Licenses
  const { 
    fields: licenseFields, 
    append: appendLicense, 
    remove: removeLicense 
  } = useFieldArray({
    control,
    name: 'licenses',
  });

  // Fetch lookup data
  const { data: licenseTypes = [] } = useQuery({
    queryKey: ['lookups', 'licenseTypes'],
    queryFn: () => lookupService.getLicenseTypes(),
  });

  const { data: cloudProviders = [] } = useQuery({
    queryKey: ['lookups', 'cloudProviders'],
    queryFn: () => lookupService.getCloudProviders(),
  });

  const licenseTypeOptions = licenseTypes.map(lt => ({
    value: lt.licenseTypeId,
    label: lt.typeName,
  }));

  const cloudProviderOptions = [
    { value: 0, label: 'Not Cloud Specific' },
    ...cloudProviders.map(cp => ({
      value: cp.cloudProviderId,
      label: cp.providerName,
    })),
  ];

  const handleAddLicense = () => {
    appendLicense({
      licenseTypeId: licenseTypes[0]?.licenseTypeId || 0,
      licenseDescription: '',
      cloudProviderId: null,
    });
  };

  return (
    <div className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center gap-3 pb-4 border-b border-gray-200">
        <div className="p-2 bg-indigo-100 rounded-lg">
          <DocumentTextIcon className="w-6 h-6 text-indigo-600" />
        </div>
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Licenses</h3>
          <p className="text-sm text-gray-500">
            Define software and cloud service licenses required for this service
          </p>
        </div>
      </div>

      {/* Licenses List */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h4 className="text-md font-medium text-gray-900">
            Required Licenses
            <Badge variant="gray" className="ml-2">
              {licenseFields.length}
            </Badge>
          </h4>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddLicense}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add License
          </Button>
        </div>

        {licenseFields.length === 0 ? (
          <Card className="p-6 text-center bg-gray-50">
            <DocumentTextIcon className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-gray-500">No licenses added yet</p>
            <p className="text-sm text-gray-400 mt-1">
              Click "Add License" to specify required licenses
            </p>
          </Card>
        ) : (
          <div className="space-y-4">
            {licenseFields.map((field, index) => (
              <Card key={field.id} className="p-4">
                <div className="flex items-start justify-between mb-4">
                  <Badge variant="blue">License #{index + 1}</Badge>
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => removeLicense(index)}
                    className="text-red-600 hover:text-red-700 hover:bg-red-50"
                  >
                    <TrashIcon className="w-4 h-4" />
                  </Button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <Controller
                    name={`licenses.${index}.licenseTypeId`}
                    control={control}
                    render={({ field }) => (
                      <SelectInput
                        label="License Type"
                        options={licenseTypeOptions}
                        value={field.value}
                        onChange={(value) => field.onChange(Number(value))}
                        required
                      />
                    )}
                  />

                  <Controller
                    name={`licenses.${index}.cloudProviderId`}
                    control={control}
                    render={({ field }) => (
                      <SelectInput
                        label="Cloud Provider"
                        options={cloudProviderOptions}
                        value={field.value || 0}
                        onChange={(value) => field.onChange(value === 0 ? null : Number(value))}
                        hint="Select if license is cloud-specific"
                      />
                    )}
                  />

                  <div className="md:col-span-2">
                    <Controller
                      name={`licenses.${index}.licenseDescription`}
                      control={control}
                      render={({ field }) => (
                        <TextArea
                          label="Description"
                          placeholder="Describe the license requirements and usage..."
                          rows={3}
                          {...field}
                        />
                      )}
                    />
                  </div>
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* License Summary */}
      {licenseFields.length > 0 && (
        <div className="bg-indigo-50 rounded-lg p-4 mt-6">
          <h4 className="text-sm font-medium text-indigo-900 mb-2">
            License Summary
          </h4>
          <div className="flex flex-wrap gap-2">
            {licenseFields.map((field, index) => {
              const typeId = watch(`licenses.${index}.licenseTypeId`);
              const licenseType = licenseTypes.find(lt => lt.licenseTypeId === typeId);
              return (
                <Badge key={field.id} variant="indigo">
                  {licenseType?.typeName || 'Unknown Type'}
                </Badge>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};

export default LicensesSection;
