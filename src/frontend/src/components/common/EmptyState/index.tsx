// EmptyState/index.tsx
// Empty state component for no data scenarios

import React from 'react';
import { 
  DocumentIcon, 
  FolderIcon, 
  MagnifyingGlassIcon,
  PlusCircleIcon,
  ExclamationTriangleIcon,
  ServerIcon,
  CloudIcon,
  UserGroupIcon,
} from '@heroicons/react/24/outline';
import clsx from 'clsx';

type EmptyStateVariant = 
  | 'default' 
  | 'search' 
  | 'folder' 
  | 'document' 
  | 'error' 
  | 'server' 
  | 'cloud'
  | 'users'
  | 'custom';

interface EmptyStateProps {
  variant?: EmptyStateVariant;
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
    icon?: React.ReactNode;
  };
  secondaryAction?: {
    label: string;
    onClick: () => void;
  };
  className?: string;
  compact?: boolean;
}

const VARIANT_ICONS: Record<Exclude<EmptyStateVariant, 'custom'>, React.ReactNode> = {
  default: <DocumentIcon className="w-12 h-12" />,
  search: <MagnifyingGlassIcon className="w-12 h-12" />,
  folder: <FolderIcon className="w-12 h-12" />,
  document: <DocumentIcon className="w-12 h-12" />,
  error: <ExclamationTriangleIcon className="w-12 h-12" />,
  server: <ServerIcon className="w-12 h-12" />,
  cloud: <CloudIcon className="w-12 h-12" />,
  users: <UserGroupIcon className="w-12 h-12" />,
};

const VARIANT_COLORS: Record<Exclude<EmptyStateVariant, 'custom'>, string> = {
  default: 'text-gray-400',
  search: 'text-blue-400',
  folder: 'text-amber-400',
  document: 'text-gray-400',
  error: 'text-red-400',
  server: 'text-purple-400',
  cloud: 'text-cyan-400',
  users: 'text-green-400',
};

export const EmptyState: React.FC<EmptyStateProps> = ({
  variant = 'default',
  icon,
  title,
  description,
  action,
  secondaryAction,
  className,
  compact = false,
}) => {
  const IconComponent = variant === 'custom' ? icon : VARIANT_ICONS[variant];
  const iconColor = variant === 'custom' ? 'text-gray-400' : VARIANT_COLORS[variant];

  return (
    <div
      className={clsx(
        'flex flex-col items-center justify-center text-center',
        compact ? 'py-8 px-4' : 'py-16 px-6',
        className
      )}
    >
      {/* Icon */}
      {IconComponent && (
        <div className={clsx('mb-4', iconColor)}>
          {IconComponent}
        </div>
      )}

      {/* Title */}
      <h3 className={clsx(
        'font-medium text-gray-900',
        compact ? 'text-base' : 'text-lg'
      )}>
        {title}
      </h3>

      {/* Description */}
      {description && (
        <p className={clsx(
          'mt-2 text-gray-500 max-w-md',
          compact ? 'text-sm' : 'text-base'
        )}>
          {description}
        </p>
      )}

      {/* Actions */}
      {(action || secondaryAction) && (
        <div className="mt-6 flex flex-col sm:flex-row items-center gap-3">
          {action && (
            <button
              type="button"
              onClick={action.onClick}
              className={clsx(
                'inline-flex items-center gap-2 rounded-md bg-blue-600 text-white font-medium',
                'hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2',
                'transition-colors',
                compact ? 'px-3 py-1.5 text-sm' : 'px-4 py-2 text-sm'
              )}
            >
              {action.icon || <PlusCircleIcon className="w-5 h-5" />}
              {action.label}
            </button>
          )}
          
          {secondaryAction && (
            <button
              type="button"
              onClick={secondaryAction.onClick}
              className={clsx(
                'inline-flex items-center gap-2 rounded-md text-gray-600 font-medium',
                'hover:text-gray-900 hover:bg-gray-100',
                'transition-colors',
                compact ? 'px-3 py-1.5 text-sm' : 'px-4 py-2 text-sm'
              )}
            >
              {secondaryAction.label}
            </button>
          )}
        </div>
      )}
    </div>
  );
};

// Pre-configured empty states
export const NoServicesFound: React.FC<{ onCreateNew?: () => void }> = ({ onCreateNew }) => (
  <EmptyState
    variant="document"
    title="No services found"
    description="Get started by creating your first service in the catalogue."
    action={onCreateNew ? {
      label: 'Create New Service',
      onClick: onCreateNew,
    } : undefined}
  />
);

export const NoSearchResults: React.FC<{ query?: string; onClear?: () => void }> = ({ 
  query, 
  onClear 
}) => (
  <EmptyState
    variant="search"
    title="No results found"
    description={query 
      ? `No services match "${query}". Try a different search term.`
      : 'No services match your search criteria.'
    }
    action={onClear ? {
      label: 'Clear Search',
      onClick: onClear,
      icon: undefined,
    } : undefined}
  />
);

export const ServerError: React.FC<{ onRetry?: () => void }> = ({ onRetry }) => (
  <EmptyState
    variant="error"
    title="Something went wrong"
    description="We couldn't load the data. Please try again later."
    action={onRetry ? {
      label: 'Try Again',
      onClick: onRetry,
      icon: undefined,
    } : undefined}
  />
);

export const NoDataAvailable: React.FC<{ message?: string }> = ({ 
  message = 'No data available at this time.' 
}) => (
  <EmptyState
    variant="default"
    title="No data"
    description={message}
    compact
  />
);

export default EmptyState;
