// pages/ServiceView/index.tsx
// Service detail view page

import React, { useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import {
  PencilIcon,
  TrashIcon,
  DocumentDuplicateIcon,
  DocumentArrowDownIcon,
  ArrowLeftIcon,
  CheckCircleIcon,
  ClockIcon,
  UserGroupIcon,
  CloudIcon,
  ScaleIcon,
  LinkIcon,
  FolderIcon,
} from '@heroicons/react/24/outline';
import { useService, useDeleteService, usePublishService } from '../../hooks/useServiceCatalog';
import { 
  Spinner, 
  Badge, 
  StatusBadge, 
  SizeBadge, 
  Tabs, 
  TabList, 
  TabPanel, 
  TabPanels,
  DeleteConfirmDialog,
  EmptyState,
} from '../../components/common';
import { PageHeader } from '../../components/common/Breadcrumb';
import clsx from 'clsx';

// Section component for consistent styling
interface SectionProps {
  title: string;
  icon?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
}

const Section: React.FC<SectionProps> = ({ title, icon, children, className }) => (
  <div className={clsx('bg-white rounded-xl border border-gray-200 overflow-hidden', className)}>
    <div className="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
      {icon && <span className="text-gray-400">{icon}</span>}
      <h3 className="font-semibold text-gray-900">{title}</h3>
    </div>
    <div className="p-6">{children}</div>
  </div>
);

// Info row component
interface InfoRowProps {
  label: string;
  value: React.ReactNode;
}

const InfoRow: React.FC<InfoRowProps> = ({ label, value }) => (
  <div className="flex justify-between py-2 border-b border-gray-100 last:border-0">
    <span className="text-sm text-gray-500">{label}</span>
    <span className="text-sm font-medium text-gray-900">{value}</span>
  </div>
);

// Usage Scenario Card
interface UsageScenarioCardProps {
  number: number;
  title: string;
  description: string;
}

const UsageScenarioCard: React.FC<UsageScenarioCardProps> = ({ number, title, description }) => (
  <div className="bg-gray-50 rounded-lg p-4 border-l-4 border-blue-500">
    <div className="flex items-center gap-3 mb-2">
      <span className="w-8 h-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-sm font-bold">
        {number}
      </span>
      <h4 className="font-medium text-gray-900">{title}</h4>
    </div>
    <p className="text-sm text-gray-600 ml-11">{description}</p>
  </div>
);

// Scope List Component
interface ScopeListProps {
  items: Array<{ categoryName: string; items: Array<{ itemDescription: string }> }>;
  variant: 'in' | 'out';
}

const ScopeList: React.FC<ScopeListProps> = ({ items, variant }) => {
  const color = variant === 'in' ? 'green' : 'red';
  const icon = variant === 'in' ? <CheckCircleIcon className="w-4 h-4" /> : (
    <span className="w-4 h-4 flex items-center justify-center">✕</span>
  );

  if (!items || items.length === 0) {
    return <p className="text-sm text-gray-500 italic">Not defined</p>;
  }

  return (
    <div className="space-y-4">
      {items.map((category, idx) => (
        <div key={idx}>
          <h5 className="font-medium text-gray-700 mb-2">{category.categoryName}</h5>
          <ul className="space-y-1">
            {category.items?.map((item, itemIdx) => (
              <li key={itemIdx} className="flex items-start gap-2 text-sm">
                <span className={`text-${color}-500 mt-0.5`}>{icon}</span>
                <span className="text-gray-600">{item.itemDescription}</span>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
};

// Size Option Card
interface SizeOptionCardProps {
  sizeCode: string;
  scope: string;
  duration: string;
  effort: string;
  teamSize: string;
}

const SizeOptionCard: React.FC<SizeOptionCardProps> = ({ sizeCode, scope, duration, effort, teamSize }) => (
  <div className="bg-white rounded-lg border border-gray-200 p-4">
    <div className="flex items-center gap-3 mb-4">
      <SizeBadge sizeCode={sizeCode as any} size="lg" />
      <span className="font-medium text-gray-900">{sizeCode} Size</span>
    </div>
    <div className="space-y-2 text-sm">
      <div className="flex justify-between">
        <span className="text-gray-500">Duration</span>
        <span className="font-medium">{duration}</span>
      </div>
      <div className="flex justify-between">
        <span className="text-gray-500">Effort</span>
        <span className="font-medium">{effort}</span>
      </div>
      <div className="flex justify-between">
        <span className="text-gray-500">Team Size</span>
        <span className="font-medium">{teamSize}</span>
      </div>
    </div>
    {scope && (
      <p className="mt-4 pt-4 border-t border-gray-100 text-sm text-gray-600">
        {scope}
      </p>
    )}
  </div>
);

// Main ServiceView Page
export const ServiceViewPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [activeTab, setActiveTab] = useState('overview');

  const serviceId = parseInt(id || '0', 10);
  const { data: service, isLoading, error } = useService(serviceId);
  const deleteMutation = useDeleteService();
  const publishMutation = usePublishService();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner size="xl" />
      </div>
    );
  }

  if (error || !service) {
    return (
      <EmptyState
        variant="error"
        title="Service not found"
        description="The service you're looking for doesn't exist or has been deleted."
        action={{
          label: 'Back to Catalogue',
          onClick: () => navigate('/catalog'),
        }}
      />
    );
  }

  const handleDelete = async () => {
    await deleteMutation.mutateAsync(serviceId);
    navigate('/catalog');
  };

  const handlePublish = async () => {
    await publishMutation.mutateAsync(serviceId);
  };

  const tabs = [
    { id: 'overview', label: 'Overview' },
    { id: 'scope', label: 'Scope' },
    { id: 'sizing', label: 'Sizing' },
    { id: 'requirements', label: 'Requirements' },
    { id: 'team', label: 'Team & Effort' },
  ];

  return (
    <div className="space-y-6">
      {/* Back link */}
      <Link 
        to="/catalog" 
        className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-gray-700"
      >
        <ArrowLeftIcon className="w-4 h-4" />
        Back to Catalogue
      </Link>

      {/* Header */}
      <div className="bg-white rounded-xl border border-gray-200 p-6">
        <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <Badge variant="blue" size="lg">{service.serviceCode}</Badge>
              <StatusBadge status={service.isPublished ? 'published' : 'draft'} />
              <span className="text-sm text-gray-500">v{service.version}</span>
            </div>
            <h1 className="text-2xl font-bold text-gray-900 mb-2">{service.serviceName}</h1>
            <p className="text-gray-600 max-w-2xl">{service.description}</p>
            
            <div className="flex items-center gap-4 mt-4 text-sm text-gray-500">
              <span className="flex items-center gap-1">
                <FolderIcon className="w-4 h-4" />
                {service.category?.categoryName || 'Uncategorized'}
              </span>
              <span className="flex items-center gap-1">
                <ClockIcon className="w-4 h-4" />
                Updated {new Date(service.updatedAt || service.createdAt).toLocaleDateString()}
              </span>
            </div>
          </div>

          {/* Actions */}
          <div className="flex flex-wrap gap-2">
            {!service.isPublished && (
              <button
                onClick={handlePublish}
                disabled={publishMutation.isPending}
                className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium disabled:opacity-50"
              >
                <CheckCircleIcon className="w-5 h-5" />
                Publish
              </button>
            )}
            <Link
              to={`/services/${serviceId}/edit`}
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
            >
              <PencilIcon className="w-5 h-5" />
              Edit
            </Link>
            <Link
              to={`/export?services=${serviceId}`}
              className="inline-flex items-center gap-2 px-4 py-2 border border-gray-300 bg-white text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              <DocumentArrowDownIcon className="w-5 h-5" />
              Export
            </Link>
            <button
              onClick={() => setShowDeleteDialog(true)}
              className="inline-flex items-center gap-2 px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium"
            >
              <TrashIcon className="w-5 h-5" />
              Delete
            </button>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <Tabs activeTab={activeTab} onChange={setActiveTab}>
        <TabList tabs={tabs} />
        <TabPanels>
          {/* Overview Tab */}
          <TabPanel id="overview">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Usage Scenarios */}
              <div className="lg:col-span-2">
                <Section title="Usage Scenarios" icon={<FolderIcon className="w-5 h-5" />}>
                  <div className="space-y-4">
                    {service.usageScenarios?.map((scenario, idx) => (
                      <UsageScenarioCard
                        key={idx}
                        number={scenario.scenarioNumber}
                        title={scenario.scenarioTitle}
                        description={scenario.scenarioDescription}
                      />
                    )) || <p className="text-gray-500">No usage scenarios defined</p>}
                  </div>
                </Section>
              </div>

              {/* Quick Info */}
              <div className="space-y-6">
                <Section title="Quick Info">
                  <InfoRow label="Service Code" value={service.serviceCode} />
                  <InfoRow label="Version" value={service.version} />
                  <InfoRow label="Category" value={service.category?.categoryName || '-'} />
                  <InfoRow 
                    label="Interaction Level" 
                    value={service.interaction?.interactionLevel?.levelName || '-'} 
                  />
                  <InfoRow 
                    label="Size Options" 
                    value={
                      <div className="flex gap-1">
                        {service.sizeOptions?.map(s => (
                          <SizeBadge key={s.sizeOptionId} sizeCode={s.sizeOption?.sizeCode as any || 'M'} size="xs" />
                        ))}
                      </div>
                    } 
                  />
                </Section>

                {/* Dependencies */}
                {service.dependencies && service.dependencies.length > 0 && (
                  <Section title="Dependencies" icon={<LinkIcon className="w-5 h-5" />}>
                    <div className="space-y-2">
                      {service.dependencies.map((dep, idx) => (
                        <div key={idx} className="flex items-center gap-2">
                          <Badge variant={dep.dependencyType?.typeCode === 'PREREQUISITE' ? 'red' : 'blue'} size="xs">
                            {dep.dependencyType?.typeName}
                          </Badge>
                          <span className="text-sm text-gray-700">{dep.dependentServiceName}</span>
                        </div>
                      ))}
                    </div>
                  </Section>
                )}
              </div>
            </div>
          </TabPanel>

          {/* Scope Tab */}
          <TabPanel id="scope">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Section title="In Scope" className="border-l-4 border-l-green-500">
                <ScopeList items={service.inScopeCategories || []} variant="in" />
              </Section>
              <Section title="Out of Scope" className="border-l-4 border-l-red-500">
                <ScopeList items={service.outScopeCategories || []} variant="out" />
              </Section>
            </div>
          </TabPanel>

          {/* Sizing Tab */}
          <TabPanel id="sizing">
            <Section title="Size Options" icon={<ScaleIcon className="w-5 h-5" />}>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {service.sizeOptions?.map((size) => (
                  <SizeOptionCard
                    key={size.serviceSizeOptionId}
                    sizeCode={size.sizeOption?.sizeCode || 'M'}
                    scope={size.scopeDescription}
                    duration={size.durationDisplay}
                    effort={size.effortDisplay}
                    teamSize={size.teamSizeDisplay}
                  />
                )) || <p className="text-gray-500">No size options defined</p>}
              </div>
            </Section>
          </TabPanel>

          {/* Requirements Tab */}
          <TabPanel id="requirements">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Section title="Prerequisites">
                {service.prerequisites?.length ? (
                  <ul className="space-y-2">
                    {service.prerequisites.map((prereq, idx) => (
                      <li key={idx} className="flex items-start gap-2">
                        <Badge variant="purple" size="xs">{prereq.category?.categoryName}</Badge>
                        <span className="text-sm text-gray-600">{prereq.prerequisiteDescription}</span>
                      </li>
                    ))}
                  </ul>
                ) : <p className="text-gray-500">No prerequisites defined</p>}
              </Section>

              <Section title="Input Parameters">
                {service.inputs?.length ? (
                  <div className="space-y-2">
                    {service.inputs.map((input, idx) => (
                      <div key={idx} className="flex items-center justify-between py-2 border-b border-gray-100">
                        <span className="text-sm font-medium text-gray-900">{input.parameterName}</span>
                        <Badge 
                          variant={input.requirementLevel?.levelCode === 'REQUIRED' ? 'red' : 'gray'} 
                          size="xs"
                        >
                          {input.requirementLevel?.levelName}
                        </Badge>
                      </div>
                    ))}
                  </div>
                ) : <p className="text-gray-500">No input parameters defined</p>}
              </Section>
            </div>
          </TabPanel>

          {/* Team Tab */}
          <TabPanel id="team">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Section title="Responsible Roles" icon={<UserGroupIcon className="w-5 h-5" />}>
                {service.responsibleRoles?.length ? (
                  <div className="space-y-3">
                    {service.responsibleRoles.map((role, idx) => (
                      <div key={idx} className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                        <div className="flex-1">
                          <div className="flex items-center gap-2">
                            <span className="font-medium text-gray-900">{role.role?.roleName}</span>
                            {role.isPrimaryOwner && (
                              <Badge variant="amber" size="xs">Primary Owner</Badge>
                            )}
                          </div>
                          <p className="text-sm text-gray-600 mt-1">{role.responsibility}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : <p className="text-gray-500">No roles defined</p>}
              </Section>

              <Section title="Tools & Frameworks" icon={<CloudIcon className="w-5 h-5" />}>
                {service.toolsFrameworks?.length ? (
                  <div className="flex flex-wrap gap-2">
                    {service.toolsFrameworks.map((tool, idx) => (
                      <Badge key={idx} variant="cyan">
                        {tool.toolName}
                      </Badge>
                    ))}
                  </div>
                ) : <p className="text-gray-500">No tools defined</p>}
              </Section>
            </div>
          </TabPanel>
        </TabPanels>
      </Tabs>

      {/* Delete Dialog */}
      <DeleteConfirmDialog
        isOpen={showDeleteDialog}
        onClose={() => setShowDeleteDialog(false)}
        onConfirm={handleDelete}
        itemName={service.serviceName}
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
};

export default ServiceViewPage;
