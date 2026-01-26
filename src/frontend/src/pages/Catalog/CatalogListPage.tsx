// pages/Catalog/CatalogListPage.tsx
// Service catalog list page with filtering and search

import React, { useState, useMemo } from 'react';
import { Link, useSearchParams, useNavigate } from 'react-router-dom';
import { 
  PlusIcon, 
  FunnelIcon, 
  Squares2X2Icon, 
  ListBulletIcon,
  EllipsisVerticalIcon,
  PencilIcon,
  TrashIcon,
  DocumentDuplicateIcon,
  EyeIcon,
  ArrowPathIcon,
} from '@heroicons/react/24/outline';
import { useServices, useDeleteService, useDuplicateService, useServiceCategories } from '../../hooks/useServiceCatalog';
import { ServiceCatalogFilters, ServiceCatalogItem } from '../../types';
import { 
  SearchInput, 
  Badge, 
  StatusBadge, 
  SizeBadge,
  Dropdown, 
  Spinner, 
  EmptyState,
  NoSearchResults,
  DeleteConfirmDialog,
  Pagination,
} from '../../components/common';
import { PageHeader } from '../../components/common/Breadcrumb';
import clsx from 'clsx';

type ViewMode = 'grid' | 'list';

// Service Card Component (for grid view)
interface ServiceCardProps {
  service: ServiceCatalogItem;
  onEdit: () => void;
  onDelete: () => void;
  onDuplicate: () => void;
}

const ServiceCard: React.FC<ServiceCardProps> = ({ service, onEdit, onDelete, onDuplicate }) => {
  const menuItems = [
    { id: 'view', label: 'View Details', icon: <EyeIcon className="w-4 h-4" />, onClick: () => {} },
    { id: 'edit', label: 'Edit', icon: <PencilIcon className="w-4 h-4" />, onClick: onEdit },
    { id: 'duplicate', label: 'Duplicate', icon: <DocumentDuplicateIcon className="w-4 h-4" />, onClick: onDuplicate },
    { id: 'divider', label: '', divider: true },
    { id: 'delete', label: 'Delete', icon: <TrashIcon className="w-4 h-4" />, onClick: onDelete, danger: true },
  ];

  return (
    <div className="bg-white rounded-xl border border-gray-200 p-5 hover:shadow-md hover:border-gray-300 transition-all group">
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2">
          <Badge variant="blue">{service.serviceCode}</Badge>
          <StatusBadge status={service.isPublished ? 'published' : 'draft'} showDot={false} />
        </div>
        <Dropdown
          trigger={
            <button className="p-1 rounded-md text-gray-400 hover:text-gray-600 hover:bg-gray-100 opacity-0 group-hover:opacity-100 transition-opacity">
              <EllipsisVerticalIcon className="w-5 h-5" />
            </button>
          }
          items={menuItems}
          align="right"
        />
      </div>

      <Link to={`/services/${service.serviceId}`}>
        <h3 className="font-semibold text-gray-900 hover:text-blue-600 transition-colors line-clamp-2 mb-2">
          {service.serviceName}
        </h3>
      </Link>

      <p className="text-sm text-gray-500 line-clamp-2 mb-4">
        {service.description}
      </p>

      <div className="flex items-center justify-between pt-3 border-t border-gray-100">
        <span className="text-xs text-gray-400">
          {service.category?.categoryName || 'Uncategorized'}
        </span>
        <div className="flex gap-1">
          {service.sizeOptions?.slice(0, 3).map((size) => (
            <SizeBadge 
              key={size.sizeOptionId} 
              sizeCode={size.sizeOption?.sizeCode as any || 'M'} 
              size="xs" 
            />
          ))}
        </div>
      </div>
    </div>
  );
};

// Service Row Component (for list view)
interface ServiceRowProps {
  service: ServiceCatalogItem;
  onEdit: () => void;
  onDelete: () => void;
  onDuplicate: () => void;
}

const ServiceRow: React.FC<ServiceRowProps> = ({ service, onEdit, onDelete, onDuplicate }) => {
  const menuItems = [
    { id: 'view', label: 'View Details', icon: <EyeIcon className="w-4 h-4" />, onClick: () => {} },
    { id: 'edit', label: 'Edit', icon: <PencilIcon className="w-4 h-4" />, onClick: onEdit },
    { id: 'duplicate', label: 'Duplicate', icon: <DocumentDuplicateIcon className="w-4 h-4" />, onClick: onDuplicate },
    { id: 'divider', label: '', divider: true },
    { id: 'delete', label: 'Delete', icon: <TrashIcon className="w-4 h-4" />, onClick: onDelete, danger: true },
  ];

  return (
    <tr className="hover:bg-gray-50 group">
      <td className="px-4 py-4">
        <div className="flex items-center gap-3">
          <div>
            <Link 
              to={`/services/${service.serviceId}`}
              className="font-medium text-gray-900 hover:text-blue-600"
            >
              {service.serviceName}
            </Link>
            <div className="flex items-center gap-2 mt-1">
              <Badge variant="blue" size="xs">{service.serviceCode}</Badge>
              <span className="text-xs text-gray-400">v{service.version}</span>
            </div>
          </div>
        </div>
      </td>
      <td className="px-4 py-4">
        <span className="text-sm text-gray-600">
          {service.category?.categoryName || 'Uncategorized'}
        </span>
      </td>
      <td className="px-4 py-4">
        <StatusBadge status={service.isPublished ? 'published' : 'draft'} />
      </td>
      <td className="px-4 py-4">
        <div className="flex gap-1">
          {service.sizeOptions?.slice(0, 3).map((size) => (
            <SizeBadge 
              key={size.sizeOptionId} 
              sizeCode={size.sizeOption?.sizeCode as any || 'M'} 
              size="xs" 
            />
          ))}
          {(service.sizeOptions?.length || 0) > 3 && (
            <span className="text-xs text-gray-400">+{(service.sizeOptions?.length || 0) - 3}</span>
          )}
        </div>
      </td>
      <td className="px-4 py-4 text-sm text-gray-500">
        {new Date(service.updatedAt || service.createdAt).toLocaleDateString()}
      </td>
      <td className="px-4 py-4 text-right">
        <Dropdown
          trigger={
            <button className="p-1 rounded-md text-gray-400 hover:text-gray-600 hover:bg-gray-100 opacity-0 group-hover:opacity-100 transition-opacity">
              <EllipsisVerticalIcon className="w-5 h-5" />
            </button>
          }
          items={menuItems}
          align="right"
        />
      </td>
    </tr>
  );
};

// Filter panel component
interface FilterPanelProps {
  filters: ServiceCatalogFilters;
  onFilterChange: (filters: ServiceCatalogFilters) => void;
  categories: Array<{ categoryId: number; categoryName: string }>;
}

const FilterPanel: React.FC<FilterPanelProps> = ({ filters, onFilterChange, categories }) => {
  return (
    <div className="bg-white rounded-lg border border-gray-200 p-4 mb-6">
      <div className="flex flex-wrap gap-4">
        <div className="w-48">
          <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
          <select
            value={filters.categoryId || ''}
            onChange={(e) => onFilterChange({ ...filters, categoryId: e.target.value ? Number(e.target.value) : undefined })}
            className="w-full rounded-md border-gray-300 text-sm"
          >
            <option value="">All Categories</option>
            {categories.map((cat) => (
              <option key={cat.categoryId} value={cat.categoryId}>
                {cat.categoryName}
              </option>
            ))}
          </select>
        </div>

        <div className="w-40">
          <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select
            value={filters.isPublished === undefined ? '' : filters.isPublished.toString()}
            onChange={(e) => onFilterChange({ 
              ...filters, 
              isPublished: e.target.value === '' ? undefined : e.target.value === 'true' 
            })}
            className="w-full rounded-md border-gray-300 text-sm"
          >
            <option value="">All Status</option>
            <option value="true">Published</option>
            <option value="false">Draft</option>
          </select>
        </div>

        <div className="w-40">
          <label className="block text-sm font-medium text-gray-700 mb-1">Sort By</label>
          <select
            value={filters.sortBy || 'updatedAt'}
            onChange={(e) => onFilterChange({ ...filters, sortBy: e.target.value })}
            className="w-full rounded-md border-gray-300 text-sm"
          >
            <option value="updatedAt">Last Updated</option>
            <option value="serviceName">Name</option>
            <option value="serviceCode">Code</option>
            <option value="createdAt">Created Date</option>
          </select>
        </div>

        <div className="flex items-end">
          <button
            onClick={() => onFilterChange({})}
            className="px-3 py-2 text-sm text-gray-600 hover:text-gray-900"
          >
            Clear Filters
          </button>
        </div>
      </div>
    </div>
  );
};

// Main Catalog List Page
export const CatalogListPage: React.FC = () => {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  
  // State
  const [viewMode, setViewMode] = useState<ViewMode>('grid');
  const [showFilters, setShowFilters] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<ServiceCatalogItem | null>(null);
  
  // Parse URL params
  const currentPage = parseInt(searchParams.get('page') || '1', 10);
  const searchQuery = searchParams.get('search') || '';
  
  const filters: ServiceCatalogFilters = useMemo(() => ({
    search: searchQuery || undefined,
    categoryId: searchParams.get('category') ? Number(searchParams.get('category')) : undefined,
    isPublished: searchParams.get('status') === 'published' ? true : 
                 searchParams.get('status') === 'draft' ? false : undefined,
    sortBy: searchParams.get('sortBy') || 'updatedAt',
    sortDirection: (searchParams.get('sortDir') as 'asc' | 'desc') || 'desc',
  }), [searchParams, searchQuery]);

  // Queries
  const { data: servicesData, isLoading, refetch } = useServices(filters, currentPage, 12);
  const { data: categories = [] } = useServiceCategories();
  const deleteMutation = useDeleteService();
  const duplicateMutation = useDuplicateService();

  const services = servicesData?.items || [];
  const totalPages = servicesData?.totalPages || 1;

  // Handlers
  const handleSearch = (query: string) => {
    const newParams = new URLSearchParams(searchParams);
    if (query) {
      newParams.set('search', query);
    } else {
      newParams.delete('search');
    }
    newParams.set('page', '1');
    setSearchParams(newParams);
  };

  const handleFilterChange = (newFilters: ServiceCatalogFilters) => {
    const newParams = new URLSearchParams();
    if (newFilters.search) newParams.set('search', newFilters.search);
    if (newFilters.categoryId) newParams.set('category', newFilters.categoryId.toString());
    if (newFilters.isPublished !== undefined) newParams.set('status', newFilters.isPublished ? 'published' : 'draft');
    if (newFilters.sortBy) newParams.set('sortBy', newFilters.sortBy);
    newParams.set('page', '1');
    setSearchParams(newParams);
  };

  const handlePageChange = (page: number) => {
    const newParams = new URLSearchParams(searchParams);
    newParams.set('page', page.toString());
    setSearchParams(newParams);
  };

  const handleDelete = async () => {
    if (deleteTarget) {
      await deleteMutation.mutateAsync(deleteTarget.serviceId);
      setDeleteTarget(null);
    }
  };

  const handleDuplicate = async (service: ServiceCatalogItem) => {
    const newCode = `${service.serviceCode}-COPY`;
    await duplicateMutation.mutateAsync({ id: service.serviceId, newCode });
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <PageHeader
        title="Service Catalogue"
        subtitle={`${servicesData?.totalCount || 0} services in total`}
        breadcrumbs={[
          { label: 'Dashboard', href: '/' },
          { label: 'Service Catalogue' },
        ]}
        actions={
          <Link
            to="/services/new"
            className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
          >
            <PlusIcon className="w-5 h-5" />
            Create Service
          </Link>
        }
      />

      {/* Toolbar */}
      <div className="flex flex-col sm:flex-row gap-4 justify-between">
        <div className="flex gap-4 flex-1">
          <SearchInput
            value={searchQuery}
            onChange={handleSearch}
            placeholder="Search services..."
            className="w-full max-w-md"
          />
          <button
            onClick={() => setShowFilters(!showFilters)}
            className={clsx(
              'inline-flex items-center gap-2 px-4 py-2 border rounded-lg transition-colors',
              showFilters 
                ? 'bg-blue-50 border-blue-200 text-blue-700' 
                : 'bg-white border-gray-300 text-gray-700 hover:bg-gray-50'
            )}
          >
            <FunnelIcon className="w-5 h-5" />
            Filters
          </button>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => refetch()}
            className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg"
            title="Refresh"
          >
            <ArrowPathIcon className="w-5 h-5" />
          </button>
          <div className="flex border border-gray-300 rounded-lg overflow-hidden">
            <button
              onClick={() => setViewMode('grid')}
              className={clsx(
                'p-2 transition-colors',
                viewMode === 'grid' ? 'bg-gray-100 text-gray-900' : 'bg-white text-gray-500 hover:bg-gray-50'
              )}
            >
              <Squares2X2Icon className="w-5 h-5" />
            </button>
            <button
              onClick={() => setViewMode('list')}
              className={clsx(
                'p-2 transition-colors',
                viewMode === 'list' ? 'bg-gray-100 text-gray-900' : 'bg-white text-gray-500 hover:bg-gray-50'
              )}
            >
              <ListBulletIcon className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Filters */}
      {showFilters && (
        <FilterPanel
          filters={filters}
          onFilterChange={handleFilterChange}
          categories={categories}
        />
      )}

      {/* Content */}
      {isLoading ? (
        <div className="flex justify-center py-12">
          <Spinner size="xl" />
        </div>
      ) : services.length === 0 ? (
        searchQuery ? (
          <NoSearchResults query={searchQuery} onClear={() => handleSearch('')} />
        ) : (
          <EmptyState
            variant="document"
            title="No services in catalogue"
            description="Get started by creating your first service."
            action={{
              label: 'Create Service',
              onClick: () => navigate('/services/new'),
            }}
          />
        )
      ) : viewMode === 'grid' ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {services.map((service) => (
            <ServiceCard
              key={service.serviceId}
              service={service}
              onEdit={() => navigate(`/services/${service.serviceId}/edit`)}
              onDelete={() => setDeleteTarget(service)}
              onDuplicate={() => handleDuplicate(service)}
            />
          ))}
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Service</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Sizes</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Updated</th>
                <th className="px-4 py-3"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {services.map((service) => (
                <ServiceRow
                  key={service.serviceId}
                  service={service}
                  onEdit={() => navigate(`/services/${service.serviceId}/edit`)}
                  onDelete={() => setDeleteTarget(service)}
                  onDuplicate={() => handleDuplicate(service)}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center">
          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            onPageChange={handlePageChange}
          />
        </div>
      )}

      {/* Delete Dialog */}
      <DeleteConfirmDialog
        isOpen={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={handleDelete}
        itemName={deleteTarget?.serviceName}
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
};

export default CatalogListPage;
