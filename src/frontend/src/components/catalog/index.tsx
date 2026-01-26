import React, { useState } from 'react';
import { Link } from 'react-router-dom';

// ============================================
// Types
// ============================================
interface ServiceCardData {
  serviceId: number;
  serviceCode: string;
  serviceName: string;
  version: string;
  categoryName: string;
  description: string;
  isActive: boolean;
  modifiedDate: string;
  usageScenariosCount: number;
  dependenciesCount: number;
}

// ============================================
// CatalogCard Component
// ============================================
interface CatalogCardProps {
  service: ServiceCardData;
  onEdit?: (id: number) => void;
  onDelete?: (id: number) => void;
  onExport?: (id: number) => void;
}

export const CatalogCard: React.FC<CatalogCardProps> = ({
  service,
  onEdit,
  onDelete,
  onExport,
}) => {
  const [showMenu, setShowMenu] = useState(false);

  const truncateDescription = (text: string, maxLength = 150) => {
    if (text.length <= maxLength) return text;
    return text.slice(0, maxLength) + '...';
  };

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
      <div className="p-5">
        <div className="flex items-start justify-between mb-3">
          <div>
            <Link
              to={`/services/${service.serviceId}`}
              className="text-lg font-semibold text-gray-900 hover:text-blue-600"
            >
              {service.serviceName}
            </Link>
            <p className="text-sm text-gray-500 mt-1">
              {service.serviceCode} • {service.version}
            </p>
          </div>
          <div className="relative">
            <button
              onClick={() => setShowMenu(!showMenu)}
              className="p-1 rounded-full hover:bg-gray-100"
            >
              <svg className="w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
              </svg>
            </button>
            {showMenu && (
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10 border">
                <div className="py-1">
                  <button onClick={() => { onEdit?.(service.serviceId); setShowMenu(false); }} className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100">Edit</button>
                  <button onClick={() => { onExport?.(service.serviceId); setShowMenu(false); }} className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100">Export</button>
                  <button onClick={() => { onDelete?.(service.serviceId); setShowMenu(false); }} className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50">Delete</button>
                </div>
              </div>
            )}
          </div>
        </div>

        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
          {service.categoryName}
        </span>
        <span className={`ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${service.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}`}>
          {service.isActive ? 'Active' : 'Inactive'}
        </span>

        <p className="mt-3 text-sm text-gray-600">{truncateDescription(service.description)}</p>

        <div className="mt-4 flex items-center space-x-4 text-sm text-gray-500">
          <span>{service.usageScenariosCount} scenarios</span>
          <span>{service.dependenciesCount} dependencies</span>
        </div>

        <div className="mt-4 pt-4 border-t flex items-center justify-between">
          <span className="text-xs text-gray-400">Updated {new Date(service.modifiedDate).toLocaleDateString()}</span>
          <Link to={`/services/${service.serviceId}`} className="text-sm font-medium text-blue-600 hover:text-blue-800">View details →</Link>
        </div>
      </div>
    </div>
  );
};

// ============================================
// CatalogTable Component
// ============================================
interface CatalogTableProps {
  services: ServiceCardData[];
  onSort?: (column: string) => void;
  sortColumn?: string;
  sortDirection?: 'asc' | 'desc';
  onRowClick?: (id: number) => void;
}

export const CatalogTable: React.FC<CatalogTableProps> = ({ services, onSort, sortColumn, sortDirection, onRowClick }) => {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th onClick={() => onSort?.('serviceCode')} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase cursor-pointer hover:bg-gray-100">Code</th>
            <th onClick={() => onSort?.('serviceName')} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase cursor-pointer hover:bg-gray-100">Name</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            <th onClick={() => onSort?.('modifiedDate')} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase cursor-pointer hover:bg-gray-100">Modified</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {services.map((service) => (
            <tr key={service.serviceId} onClick={() => onRowClick?.(service.serviceId)} className="hover:bg-gray-50 cursor-pointer">
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{service.serviceCode}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{service.serviceName}</td>
              <td className="px-6 py-4 whitespace-nowrap"><span className="px-2.5 py-0.5 rounded-full text-xs bg-blue-100 text-blue-800">{service.categoryName}</span></td>
              <td className="px-6 py-4 whitespace-nowrap"><span className={`px-2.5 py-0.5 rounded-full text-xs ${service.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}`}>{service.isActive ? 'Active' : 'Inactive'}</span></td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{new Date(service.modifiedDate).toLocaleDateString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

// ============================================
// CatalogFilters Component
// ============================================
interface FilterState {
  searchTerm: string;
  categoryId: number | null;
  isActive: boolean | null;
}

interface CatalogFiltersProps {
  filters: FilterState;
  onFiltersChange: (filters: FilterState) => void;
  categories: Array<{ id: number; name: string }>;
}

export const CatalogFilters: React.FC<CatalogFiltersProps> = ({ filters, onFiltersChange, categories }) => {
  return (
    <div className="bg-white p-4 rounded-lg shadow-sm border mb-6">
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Search</label>
          <input
            type="text"
            placeholder="Search services..."
            value={filters.searchTerm}
            onChange={(e) => onFiltersChange({ ...filters, searchTerm: e.target.value })}
            className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
          <select
            value={filters.categoryId ?? ''}
            onChange={(e) => onFiltersChange({ ...filters, categoryId: e.target.value ? parseInt(e.target.value) : null })}
            className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
          >
            <option value="">All Categories</option>
            {categories.map((cat) => (<option key={cat.id} value={cat.id}>{cat.name}</option>))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select
            value={filters.isActive === null ? '' : filters.isActive.toString()}
            onChange={(e) => onFiltersChange({ ...filters, isActive: e.target.value === '' ? null : e.target.value === 'true' })}
            className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
          >
            <option value="">All</option>
            <option value="true">Active</option>
            <option value="false">Inactive</option>
          </select>
        </div>
        <div className="flex items-end">
          <button onClick={() => onFiltersChange({ searchTerm: '', categoryId: null, isActive: null })} className="px-4 py-2 text-sm border rounded-md hover:bg-gray-50">Reset</button>
        </div>
      </div>
    </div>
  );
};

export default { CatalogCard, CatalogTable, CatalogFilters };
