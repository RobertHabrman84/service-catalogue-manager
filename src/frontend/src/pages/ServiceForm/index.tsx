// pages/ServiceForm/index.tsx
// Service create/edit form page

import React, { useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';
import { useService, useCreateService, useUpdateService, usePrefetchLookups } from '../../hooks/useServiceCatalog';
import { ServiceCatalogForm } from '../../components/forms/ServiceCatalogForm';
import { ServiceCatalogFormData } from '../../types';
import { Spinner, EmptyState } from '../../components/common';
import { PageHeader } from '../../components/common/Breadcrumb';

export const ServiceFormPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const isEditMode = !!id;
  const serviceId = id ? parseInt(id, 10) : 0;

  // Prefetch lookup data
  const prefetchLookups = usePrefetchLookups();
  useEffect(() => {
    prefetchLookups();
  }, [prefetchLookups]);

  // Fetch service data if editing
  const { data: service, isLoading, error } = useService(serviceId, {
    enabled: isEditMode,
  });

  // Mutations
  const createMutation = useCreateService();
  const updateMutation = useUpdateService();

  const handleSubmit = async (data: ServiceCatalogFormData) => {
    if (isEditMode) {
      await updateMutation.mutateAsync({ id: serviceId, data });
      navigate(`/services/${serviceId}`);
    } else {
      const newService = await createMutation.mutateAsync(data);
      navigate(`/services/${newService.serviceId}`);
    }
  };

  const handleCancel = () => {
    if (isEditMode) {
      navigate(`/services/${serviceId}`);
    } else {
      navigate('/catalog');
    }
  };

  // Loading state for edit mode
  if (isEditMode && isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner size="xl" />
      </div>
    );
  }

  // Error state
  if (isEditMode && (error || !service)) {
    return (
      <EmptyState
        variant="error"
        title="Service not found"
        description="The service you're trying to edit doesn't exist or has been deleted."
        action={{
          label: 'Back to Catalogue',
          onClick: () => navigate('/catalog'),
        }}
      />
    );
  }

  return (
    <div className="space-y-6">
      {/* Back link */}
      <Link 
        to={isEditMode ? `/services/${serviceId}` : '/catalog'}
        className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-gray-700"
      >
        <ArrowLeftIcon className="w-4 h-4" />
        {isEditMode ? 'Back to Service' : 'Back to Catalogue'}
      </Link>

      {/* Page Header */}
      <PageHeader
        title={isEditMode ? `Edit: ${service?.serviceName}` : 'Create New Service'}
        subtitle={isEditMode 
          ? 'Update the service details and configuration' 
          : 'Fill in the form to create a new service in the catalogue'
        }
        breadcrumbs={[
          { label: 'Dashboard', href: '/' },
          { label: 'Service Catalogue', href: '/catalog' },
          { label: isEditMode ? 'Edit Service' : 'Create Service' },
        ]}
      />

      {/* Form */}
      <ServiceCatalogForm
        initialData={service}
        onSubmit={handleSubmit}
        onCancel={handleCancel}
        isLoading={createMutation.isPending || updateMutation.isPending}
        mode={isEditMode ? 'edit' : 'create'}
      />
    </div>
  );
};

// Create Service Page - wrapper for clarity
export const CreateServicePage: React.FC = () => <ServiceFormPage />;

// Edit Service Page - wrapper for clarity
export const EditServicePage: React.FC = () => <ServiceFormPage />;

export default ServiceFormPage;
