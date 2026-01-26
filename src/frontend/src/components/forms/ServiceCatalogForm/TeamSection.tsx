// ServiceCatalogForm/TeamSection.tsx
// Section 14: Team Allocation - Define roles and FTE allocation by size

import React from 'react';
import { useFormContext, useFieldArray, Controller } from 'react-hook-form';
import { useQuery } from '@tanstack/react-query';
import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { UserGroupIcon, UserIcon, StarIcon } from '@heroicons/react/24/solid';
import { TextArea, SelectInput, NumberInput, Checkbox, Button, Card, Badge } from '../../common';
import { lookupService } from '../../../services/api';

const SIZE_COLORS: Record<string, string> = {
  'XS': 'gray',
  'S': 'green',
  'M': 'blue',
  'L': 'purple',
  'XL': 'red',
};

export const TeamSection: React.FC = () => {
  const { control, watch } = useFormContext();
  
  // Responsible Roles
  const { 
    fields: roleFields, 
    append: appendRole, 
    remove: removeRole 
  } = useFieldArray({
    control,
    name: 'responsibleRoles',
  });

  // Team Allocations
  const { 
    fields: allocationFields, 
    append: appendAllocation, 
    remove: removeAllocation 
  } = useFieldArray({
    control,
    name: 'teamAllocations',
  });

  // Fetch lookups
  const { data: roles = [] } = useQuery({
    queryKey: ['lookups', 'roles'],
    queryFn: () => lookupService.getRoles(),
  });

  const { data: sizeOptions = [] } = useQuery({
    queryKey: ['lookups', 'sizeOptions'],
    queryFn: () => lookupService.getSizeOptions(),
  });

  const roleOptions = roles.map(r => ({
    value: r.roleId,
    label: r.roleName,
  }));

  const sizeOptionsList = sizeOptions.map(so => ({
    value: so.sizeOptionId,
    label: `${so.sizeName} (${so.sizeCode})`,
    code: so.sizeCode,
  }));

  const getSizeCode = (sizeOptionId: number): string => {
    return sizeOptions.find(so => so.sizeOptionId === sizeOptionId)?.sizeCode || 'M';
  };

  const getRoleName = (roleId: number): string => {
    return roles.find(r => r.roleId === roleId)?.roleName || 'Unknown Role';
  };

  const watchedRoles = watch('responsibleRoles') || [];
  const watchedAllocations = watch('teamAllocations') || [];

  const handleAddRole = () => {
    appendRole({
      roleId: roles[0]?.roleId || 0,
      isPrimaryOwner: false,
      responsibility: '',
    });
  };

  const handleAddAllocation = () => {
    appendAllocation({
      sizeOptionId: sizeOptions[0]?.sizeOptionId || 0,
      roleId: roles[0]?.roleId || 0,
      fteAllocation: 0.5,
      notes: '',
    });
  };

  // Calculate total FTE by size
  const fteTotals = sizeOptions.reduce((acc, so) => {
    acc[so.sizeOptionId] = watchedAllocations
      .filter(a => a.sizeOptionId === so.sizeOptionId)
      .reduce((sum, a) => sum + (a.fteAllocation || 0), 0);
    return acc;
  }, {} as Record<number, number>);

  return (
    <div className="space-y-8">
      {/* Section Description */}
      <p className="text-sm text-gray-600">
        Define the team roles responsible for delivering this service and their FTE allocation by size.
      </p>

      {/* Responsible Roles */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <UserIcon className="w-6 h-6 text-indigo-500" />
            <h4 className="text-lg font-medium text-gray-900">Responsible Roles</h4>
          </div>
          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={handleAddRole}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Role
          </Button>
        </div>

        {roleFields.length > 0 ? (
          <div className="space-y-3">
            {roleFields.map((field, index) => {
              const role = watchedRoles[index];

              return (
                <Card key={field.id} className={`p-4 ${role?.isPrimaryOwner ? 'border-l-4 border-l-yellow-500' : ''}`}>
                  <div className="flex items-start gap-4">
                    {role?.isPrimaryOwner && (
                      <StarIcon className="w-5 h-5 text-yellow-500 flex-shrink-0 mt-1" />
                    )}

                    <div className="flex-1 space-y-4">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <Controller
                          name={`responsibleRoles.${index}.roleId`}
                          control={control}
                          render={({ field }) => (
                            <SelectInput
                              {...field}
                              label="Role"
                              options={roleOptions}
                              onChange={(value) => field.onChange(Number(value))}
                            />
                          )}
                        />

                        <div className="flex items-end">
                          <Controller
                            name={`responsibleRoles.${index}.isPrimaryOwner`}
                            control={control}
                            render={({ field }) => (
                              <Checkbox
                                {...field}
                                label="Primary Owner"
                                checked={field.value}
                                onChange={(e) => field.onChange(e.target.checked)}
                              />
                            )}
                          />
                        </div>
                      </div>

                      <Controller
                        name={`responsibleRoles.${index}.responsibility`}
                        control={control}
                        render={({ field }) => (
                          <TextArea
                            {...field}
                            label="Responsibilities"
                            placeholder="Describe the role's responsibilities in this service..."
                            rows={2}
                          />
                        )}
                      />
                    </div>

                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeRole(index)}
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
          <div className="text-center py-6 bg-indigo-50 rounded-lg border-2 border-dashed border-indigo-300">
            <UserIcon className="w-10 h-10 text-indigo-400 mx-auto mb-2" />
            <p className="text-indigo-700">No responsible roles defined yet.</p>
          </div>
        )}
      </div>

      {/* Divider */}
      <div className="border-t border-gray-200" />

      {/* Team Allocations */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <UserGroupIcon className="w-6 h-6 text-teal-500" />
            <h4 className="text-lg font-medium text-gray-900">Team Allocation by Size</h4>
          </div>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleAddAllocation}
            leftIcon={<PlusIcon className="w-4 h-4" />}
          >
            Add Allocation
          </Button>
        </div>

        {/* FTE Totals Summary */}
        {allocationFields.length > 0 && (
          <div className="bg-gray-50 rounded-lg p-4 mb-4">
            <h5 className="text-sm font-medium text-gray-700 mb-2">Total FTE by Size</h5>
            <div className="flex flex-wrap gap-4">
              {sizeOptions.map(so => (
                <div key={so.sizeOptionId} className="flex items-center gap-2">
                  <Badge variant={SIZE_COLORS[so.sizeCode] as any}>
                    {so.sizeCode}
                  </Badge>
                  <span className="font-semibold text-gray-900">
                    {(fteTotals[so.sizeOptionId] || 0).toFixed(2)} FTE
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

        {allocationFields.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Size</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">FTE</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Notes</th>
                  <th className="px-4 py-3 w-10"></th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {allocationFields.map((field, index) => {
                  const allocation = watchedAllocations[index];
                  const sizeCode = getSizeCode(allocation?.sizeOptionId);

                  return (
                    <tr key={field.id}>
                      <td className="px-4 py-2">
                        <Controller
                          name={`teamAllocations.${index}.sizeOptionId`}
                          control={control}
                          render={({ field }) => (
                            <SelectInput
                              {...field}
                              options={sizeOptionsList}
                              size="sm"
                              onChange={(value) => field.onChange(Number(value))}
                            />
                          )}
                        />
                      </td>
                      <td className="px-4 py-2">
                        <Controller
                          name={`teamAllocations.${index}.roleId`}
                          control={control}
                          render={({ field }) => (
                            <SelectInput
                              {...field}
                              options={roleOptions}
                              size="sm"
                              onChange={(value) => field.onChange(Number(value))}
                            />
                          )}
                        />
                      </td>
                      <td className="px-4 py-2 w-32">
                        <Controller
                          name={`teamAllocations.${index}.fteAllocation`}
                          control={control}
                          render={({ field }) => (
                            <NumberInput
                              {...field}
                              min={0}
                              max={5}
                              step={0.1}
                              size="sm"
                              onChange={(value) => field.onChange(Number(value))}
                            />
                          )}
                        />
                      </td>
                      <td className="px-4 py-2">
                        <Controller
                          name={`teamAllocations.${index}.notes`}
                          control={control}
                          render={({ field }) => (
                            <input
                              {...field}
                              type="text"
                              placeholder="Notes..."
                              className="w-full px-2 py-1 text-sm border border-gray-300 rounded"
                            />
                          )}
                        />
                      </td>
                      <td className="px-4 py-2">
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          onClick={() => removeAllocation(index)}
                          className="text-red-500 hover:text-red-700"
                        >
                          <TrashIcon className="w-4 h-4" />
                        </Button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-6 bg-teal-50 rounded-lg border-2 border-dashed border-teal-300">
            <UserGroupIcon className="w-10 h-10 text-teal-400 mx-auto mb-2" />
            <p className="text-teal-700">No team allocations defined yet.</p>
          </div>
        )}
      </div>

      {/* Example Allocations */}
      <div className="bg-teal-50 border border-teal-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-teal-800 mb-2">
          👥 Example Team Allocation
        </h4>
        <table className="min-w-full text-sm text-teal-700">
          <thead>
            <tr>
              <th className="text-left py-1">Role</th>
              <th className="text-center py-1">S</th>
              <th className="text-center py-1">M</th>
              <th className="text-center py-1">L</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="py-1">Cloud Architect</td>
              <td className="text-center">0.5</td>
              <td className="text-center">0.8</td>
              <td className="text-center">1.0</td>
            </tr>
            <tr>
              <td className="py-1">Security Architect</td>
              <td className="text-center">0.2</td>
              <td className="text-center">0.3</td>
              <td className="text-center">0.5</td>
            </tr>
            <tr>
              <td className="py-1">Project Manager</td>
              <td className="text-center">0.2</td>
              <td className="text-center">0.3</td>
              <td className="text-center">0.5</td>
            </tr>
            <tr className="font-semibold">
              <td className="py-1">Total FTE</td>
              <td className="text-center">0.9</td>
              <td className="text-center">1.4</td>
              <td className="text-center">2.0</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default TeamSection;
