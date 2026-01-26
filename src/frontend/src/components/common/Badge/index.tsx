// Badge/index.tsx
// Badge component for status indicators and labels

import React from 'react';
import clsx from 'clsx';

type BadgeVariant = 
  | 'gray' 
  | 'red' 
  | 'orange'
  | 'amber'
  | 'yellow' 
  | 'lime'
  | 'green' 
  | 'emerald'
  | 'teal'
  | 'cyan'
  | 'blue' 
  | 'indigo'
  | 'violet'
  | 'purple' 
  | 'fuchsia'
  | 'pink'
  | 'rose';

type BadgeSize = 'xs' | 'sm' | 'md' | 'lg';

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  size?: BadgeSize;
  rounded?: 'sm' | 'md' | 'full';
  dot?: boolean;
  removable?: boolean;
  onRemove?: () => void;
  className?: string;
}

const VARIANT_CLASSES: Record<BadgeVariant, string> = {
  gray: 'bg-gray-100 text-gray-700 ring-gray-500/20',
  red: 'bg-red-100 text-red-700 ring-red-500/20',
  orange: 'bg-orange-100 text-orange-700 ring-orange-500/20',
  amber: 'bg-amber-100 text-amber-700 ring-amber-500/20',
  yellow: 'bg-yellow-100 text-yellow-700 ring-yellow-500/20',
  lime: 'bg-lime-100 text-lime-700 ring-lime-500/20',
  green: 'bg-green-100 text-green-700 ring-green-500/20',
  emerald: 'bg-emerald-100 text-emerald-700 ring-emerald-500/20',
  teal: 'bg-teal-100 text-teal-700 ring-teal-500/20',
  cyan: 'bg-cyan-100 text-cyan-700 ring-cyan-500/20',
  blue: 'bg-blue-100 text-blue-700 ring-blue-500/20',
  indigo: 'bg-indigo-100 text-indigo-700 ring-indigo-500/20',
  violet: 'bg-violet-100 text-violet-700 ring-violet-500/20',
  purple: 'bg-purple-100 text-purple-700 ring-purple-500/20',
  fuchsia: 'bg-fuchsia-100 text-fuchsia-700 ring-fuchsia-500/20',
  pink: 'bg-pink-100 text-pink-700 ring-pink-500/20',
  rose: 'bg-rose-100 text-rose-700 ring-rose-500/20',
};

const DOT_COLORS: Record<BadgeVariant, string> = {
  gray: 'bg-gray-500',
  red: 'bg-red-500',
  orange: 'bg-orange-500',
  amber: 'bg-amber-500',
  yellow: 'bg-yellow-500',
  lime: 'bg-lime-500',
  green: 'bg-green-500',
  emerald: 'bg-emerald-500',
  teal: 'bg-teal-500',
  cyan: 'bg-cyan-500',
  blue: 'bg-blue-500',
  indigo: 'bg-indigo-500',
  violet: 'bg-violet-500',
  purple: 'bg-purple-500',
  fuchsia: 'bg-fuchsia-500',
  pink: 'bg-pink-500',
  rose: 'bg-rose-500',
};

const SIZE_CLASSES: Record<BadgeSize, string> = {
  xs: 'px-1.5 py-0.5 text-xs',
  sm: 'px-2 py-0.5 text-xs',
  md: 'px-2.5 py-1 text-sm',
  lg: 'px-3 py-1.5 text-sm',
};

const ROUNDED_CLASSES = {
  sm: 'rounded',
  md: 'rounded-md',
  full: 'rounded-full',
};

export const Badge: React.FC<BadgeProps> = ({
  children,
  variant = 'gray',
  size = 'sm',
  rounded = 'full',
  dot = false,
  removable = false,
  onRemove,
  className,
}) => {
  return (
    <span
      className={clsx(
        'inline-flex items-center gap-1.5 font-medium ring-1 ring-inset',
        VARIANT_CLASSES[variant],
        SIZE_CLASSES[size],
        ROUNDED_CLASSES[rounded],
        className
      )}
    >
      {dot && (
        <span
          className={clsx(
            'h-1.5 w-1.5 rounded-full',
            DOT_COLORS[variant]
          )}
        />
      )}
      {children}
      {removable && (
        <button
          type="button"
          onClick={onRemove}
          className={clsx(
            'group relative -mr-1 h-3.5 w-3.5 rounded-sm',
            'hover:bg-gray-500/20 focus:outline-none'
          )}
        >
          <span className="sr-only">Remove</span>
          <svg
            viewBox="0 0 14 14"
            className="h-3.5 w-3.5 stroke-current opacity-60 group-hover:opacity-100"
          >
            <path d="M4 4l6 6m0-6l-6 6" />
          </svg>
        </button>
      )}
    </span>
  );
};

// Status Badge - predefined statuses
type StatusType = 'active' | 'inactive' | 'pending' | 'draft' | 'published' | 'archived' | 'error';

const STATUS_CONFIG: Record<StatusType, { variant: BadgeVariant; label: string }> = {
  active: { variant: 'green', label: 'Active' },
  inactive: { variant: 'gray', label: 'Inactive' },
  pending: { variant: 'yellow', label: 'Pending' },
  draft: { variant: 'gray', label: 'Draft' },
  published: { variant: 'green', label: 'Published' },
  archived: { variant: 'gray', label: 'Archived' },
  error: { variant: 'red', label: 'Error' },
};

interface StatusBadgeProps {
  status: StatusType;
  showDot?: boolean;
  size?: BadgeSize;
  className?: string;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({
  status,
  showDot = true,
  size = 'sm',
  className,
}) => {
  const config = STATUS_CONFIG[status];
  
  return (
    <Badge
      variant={config.variant}
      size={size}
      dot={showDot}
      className={className}
    >
      {config.label}
    </Badge>
  );
};

// Size Badge - for T-shirt sizing
type SizeType = 'XS' | 'S' | 'M' | 'L' | 'XL';

const SIZE_CONFIG: Record<SizeType, BadgeVariant> = {
  'XS': 'gray',
  'S': 'green',
  'M': 'blue',
  'L': 'purple',
  'XL': 'red',
};

interface SizeBadgeProps {
  sizeCode: SizeType;
  size?: BadgeSize;
  className?: string;
}

export const SizeBadge: React.FC<SizeBadgeProps> = ({
  sizeCode,
  size = 'sm',
  className,
}) => {
  return (
    <Badge
      variant={SIZE_CONFIG[sizeCode]}
      size={size}
      className={clsx('font-bold', className)}
    >
      {sizeCode}
    </Badge>
  );
};

// Badge Group
interface BadgeGroupProps {
  children: React.ReactNode;
  className?: string;
}

export const BadgeGroup: React.FC<BadgeGroupProps> = ({
  children,
  className,
}) => {
  return (
    <div className={clsx('flex flex-wrap gap-1', className)}>
      {children}
    </div>
  );
};

export default Badge;
