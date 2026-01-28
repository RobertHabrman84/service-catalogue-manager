// pages/Dashboard/index.tsx
// Main dashboard page with statistics and recent activity

import React from 'react';
import { Link } from 'react-router-dom';
import {
  FolderIcon,
  DocumentPlusIcon,
  ArrowTrendingUpIcon,
  ClockIcon,
  CheckCircleIcon,
  ExclamationCircleIcon,
  ArrowRightIcon,
  DocumentArrowDownIcon,
} from '@heroicons/react/24/outline';
import { useServices } from '../../hooks/useServiceCatalog';
import { ServiceCatalogItem } from '../../types';
import { Spinner, Badge, StatusBadge, SizeBadge, EmptyState } from '../../components/common';
import clsx from 'clsx';

// Stat card component
interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  change?: { value: number; positive: boolean };
  color: 'blue' | 'green' | 'purple' | 'amber';
  href?: string;
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon, change, color, href }) => {
  const colorClasses = {
    blue: 'bg-blue-50 text-blue-600',
    green: 'bg-green-50 text-green-600',
    purple: 'bg-purple-50 text-purple-600',
    amber: 'bg-amber-50 text-amber-600',
  };

  const content = (
    <div className="bg-white rounded-xl border border-gray-200 p-6 hover:shadow-md transition-shadow">
      <div className="flex items-center justify-between">
        <div className={clsx('p-3 rounded-lg', colorClasses[color])}>
          {icon}
        </div>
        {change && (
          <div className={clsx(
            'flex items-center gap-1 text-sm font-medium',
            change.positive ? 'text-green-600' : 'text-red-600'
          )}>
            <ArrowTrendingUpIcon className={clsx('w-4 h-4', !change.positive && 'rotate-180')} />
            {change.value}%
          </div>
        )}
      </div>
      <div className="mt-4">
        <p className="text-3xl font-bold text-gray-900">{value}</p>
        <p className="text-sm text-gray-500 mt-1">{title}</p>
      </div>
    </div>
  );

  return href ? <Link to={href}>{content}</Link> : content;
};

// Recent services table
interface RecentServicesTableProps {
  services: ServiceCatalogItem[];
  isLoading: boolean;
}

const RecentServicesTable: React.FC<RecentServicesTableProps> = ({ services, isLoading }) => {
  if (isLoading) {
    return (
      <div className="flex justify-center py-8">
        <Spinner size="lg" />
      </div>
    );
  }

  if (services.length === 0) {
    return (
      <EmptyState
        variant="document"
        title="No services yet"
        description="Create your first service to get started."
        action={{
          label: 'Create Service',
          onClick: () => window.location.href = '/services/new',
        }}
        compact
      />
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead>
          <tr>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Service
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Category
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Status
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Updated
            </th>
            <th className="px-4 py-3"></th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {services.map((service) => (
            <tr key={service.serviceId} className="hover:bg-gray-50">
              <td className="px-4 py-4">
                <div>
                  <Link 
                    to={`/services/${service.serviceId}`}
                    className="font-medium text-gray-900 hover:text-blue-600"
                  >
                    {service.serviceName}
                  </Link>
                  <p className="text-sm text-gray-500">{service.serviceCode}</p>
                </div>
              </td>
              <td className="px-4 py-4">
                <Badge variant="gray">
                  {service.category?.categoryName || 'Uncategorized'}
                </Badge>
              </td>
              <td className="px-4 py-4">
                <StatusBadge status={service.isPublished ? 'published' : 'draft'} />
              </td>
              <td className="px-4 py-4 text-sm text-gray-500">
                {service.updatedAt 
                  ? new Date(service.updatedAt).toLocaleDateString()
                  : new Date(service.createdAt).toLocaleDateString()
                }
              </td>
              <td className="px-4 py-4 text-right">
                <Link
                  to={`/services/${service.serviceId}`}
                  className="text-blue-600 hover:text-blue-700 text-sm font-medium"
                >
                  View →
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

// Quick action card
interface QuickActionProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  href: string;
  color: string;
}

const QuickAction: React.FC<QuickActionProps> = ({ title, description, icon, href, color }) => (
  <Link
    to={href}
    className="flex items-center gap-4 p-4 bg-white rounded-lg border border-gray-200 hover:border-gray-300 hover:shadow-sm transition-all group"
  >
    <div className={clsx('p-3 rounded-lg', color)}>
      {icon}
    </div>
    <div className="flex-1">
      <h4 className="font-medium text-gray-900 group-hover:text-blue-600">{title}</h4>
      <p className="text-sm text-gray-500">{description}</p>
    </div>
    <ArrowRightIcon className="w-5 h-5 text-gray-400 group-hover:text-blue-600 group-hover:translate-x-1 transition-all" />
  </Link>
);

// Main Dashboard component
export const DashboardPage: React.FC = () => {
  // Fetch services for statistics using standard useServices hook
  // This ensures query key consistency across the app and proper cache invalidation
  const { data: servicesData, isLoading } = useServices(
    {}, // No filters
    1,  // First page
    10  // 10 items for dashboard preview
  );

  const services = servicesData?.items || [];
  const totalServices = servicesData?.totalCount || 0;
  const publishedCount = services.filter(s => s.isPublished).length;
  const draftCount = services.filter(s => !s.isPublished).length;

  return (
    <div className="space-y-8">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-1 text-gray-500">
          Welcome back! Here's an overview of your service catalogue.
        </p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Services"
          value={totalServices}
          icon={<FolderIcon className="w-6 h-6" />}
          color="blue"
          href="/catalog"
        />
        <StatCard
          title="Published"
          value={publishedCount}
          icon={<CheckCircleIcon className="w-6 h-6" />}
          change={{ value: 12, positive: true }}
          color="green"
        />
        <StatCard
          title="Drafts"
          value={draftCount}
          icon={<ExclamationCircleIcon className="w-6 h-6" />}
          color="amber"
        />
        <StatCard
          title="This Month"
          value={services.filter(s => {
            const created = new Date(s.createdAt);
            const now = new Date();
            return created.getMonth() === now.getMonth() && created.getFullYear() === now.getFullYear();
          }).length}
          icon={<ClockIcon className="w-6 h-6" />}
          color="purple"
        />
      </div>

      {/* Main content grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Recent services */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-xl border border-gray-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">Recent Services</h2>
              <Link
                to="/catalog"
                className="text-sm text-blue-600 hover:text-blue-700 font-medium"
              >
                View all →
              </Link>
            </div>
            <RecentServicesTable services={services.slice(0, 5)} isLoading={isLoading} />
          </div>
        </div>

        {/* Quick actions */}
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
            <div className="space-y-3">
              <QuickAction
                title="Create New Service"
                description="Add a new service to the catalogue"
                icon={<DocumentPlusIcon className="w-5 h-5 text-blue-600" />}
                href="/services/new"
                color="bg-blue-50"
              />
              <QuickAction
                title="Export Catalogue"
                description="Export services to PDF or Markdown"
                icon={<DocumentArrowDownIcon className="w-5 h-5 text-green-600" />}
                href="/export"
                color="bg-green-50"
              />
              <QuickAction
                title="Browse Catalogue"
                description="View and search all services"
                icon={<FolderIcon className="w-5 h-5 text-purple-600" />}
                href="/catalog"
                color="bg-purple-50"
              />
            </div>
          </div>

          {/* Activity feed */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h2>
            <div className="space-y-4">
              {services.slice(0, 4).map((service, index) => (
                <div key={service.serviceId} className="flex items-start gap-3">
                  <div className={clsx(
                    'w-2 h-2 rounded-full mt-2',
                    index === 0 ? 'bg-green-500' : 'bg-gray-300'
                  )} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-gray-900 truncate">
                      <span className="font-medium">{service.serviceName}</span>
                      {' '}was {service.updatedAt ? 'updated' : 'created'}
                    </p>
                    <p className="text-xs text-gray-500">
                      {new Date(service.updatedAt || service.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              ))}
              {services.length === 0 && !isLoading && (
                <p className="text-sm text-gray-500 text-center py-4">No recent activity</p>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
