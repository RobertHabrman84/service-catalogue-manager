// Spinner/index.tsx
// Loading spinner component with various sizes and styles

import React from 'react';
import clsx from 'clsx';

type SpinnerSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
type SpinnerVariant = 'primary' | 'secondary' | 'white' | 'dark';

interface SpinnerProps {
  size?: SpinnerSize;
  variant?: SpinnerVariant;
  className?: string;
  label?: string;
}

const SIZE_CLASSES: Record<SpinnerSize, string> = {
  xs: 'h-3 w-3',
  sm: 'h-4 w-4',
  md: 'h-6 w-6',
  lg: 'h-8 w-8',
  xl: 'h-12 w-12',
};

const VARIANT_CLASSES: Record<SpinnerVariant, string> = {
  primary: 'text-blue-600',
  secondary: 'text-gray-600',
  white: 'text-white',
  dark: 'text-gray-900',
};

export const Spinner: React.FC<SpinnerProps> = ({
  size = 'md',
  variant = 'primary',
  className,
  label,
}) => {
  return (
    <div
      role="status"
      className={clsx('inline-flex items-center', className)}
    >
      <svg
        className={clsx(
          'animate-spin',
          SIZE_CLASSES[size],
          VARIANT_CLASSES[variant]
        )}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle
          className="opacity-25"
          cx="12"
          cy="12"
          r="10"
          stroke="currentColor"
          strokeWidth="4"
        />
        <path
          className="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        />
      </svg>
      {label && <span className="sr-only">{label}</span>}
    </div>
  );
};

// Full page loading spinner
interface LoadingOverlayProps {
  message?: string;
  transparent?: boolean;
}

export const LoadingOverlay: React.FC<LoadingOverlayProps> = ({
  message = 'Loading...',
  transparent = false,
}) => {
  return (
    <div
      className={clsx(
        'fixed inset-0 z-50 flex items-center justify-center',
        transparent ? 'bg-white/50' : 'bg-white'
      )}
    >
      <div className="flex flex-col items-center gap-4">
        <Spinner size="xl" />
        <p className="text-gray-600 font-medium">{message}</p>
      </div>
    </div>
  );
};

// Inline loading indicator
interface LoadingInlineProps {
  message?: string;
  size?: SpinnerSize;
  className?: string;
}

export const LoadingInline: React.FC<LoadingInlineProps> = ({
  message,
  size = 'sm',
  className,
}) => {
  return (
    <div className={clsx('flex items-center gap-2', className)}>
      <Spinner size={size} />
      {message && <span className="text-sm text-gray-600">{message}</span>}
    </div>
  );
};

// Skeleton loader for content placeholders
interface SkeletonProps {
  width?: string | number;
  height?: string | number;
  rounded?: 'none' | 'sm' | 'md' | 'lg' | 'full';
  className?: string;
  animate?: boolean;
}

const ROUNDED_CLASSES = {
  none: 'rounded-none',
  sm: 'rounded-sm',
  md: 'rounded-md',
  lg: 'rounded-lg',
  full: 'rounded-full',
};

export const Skeleton: React.FC<SkeletonProps> = ({
  width,
  height,
  rounded = 'md',
  className,
  animate = true,
}) => {
  return (
    <div
      className={clsx(
        'bg-gray-200',
        animate && 'animate-pulse',
        ROUNDED_CLASSES[rounded],
        className
      )}
      style={{
        width: typeof width === 'number' ? `${width}px` : width,
        height: typeof height === 'number' ? `${height}px` : height,
      }}
    />
  );
};

// Skeleton text lines
interface SkeletonTextProps {
  lines?: number;
  lastLineWidth?: string;
  className?: string;
}

export const SkeletonText: React.FC<SkeletonTextProps> = ({
  lines = 3,
  lastLineWidth = '60%',
  className,
}) => {
  return (
    <div className={clsx('space-y-2', className)}>
      {Array.from({ length: lines }).map((_, index) => (
        <Skeleton
          key={index}
          height={16}
          width={index === lines - 1 ? lastLineWidth : '100%'}
        />
      ))}
    </div>
  );
};

// Skeleton card
export const SkeletonCard: React.FC<{ className?: string }> = ({ className }) => {
  return (
    <div className={clsx('bg-white rounded-lg border border-gray-200 p-4', className)}>
      <div className="flex items-center gap-4 mb-4">
        <Skeleton width={48} height={48} rounded="full" />
        <div className="flex-1">
          <Skeleton height={20} width="60%" className="mb-2" />
          <Skeleton height={16} width="40%" />
        </div>
      </div>
      <SkeletonText lines={3} />
    </div>
  );
};

// Skeleton table
interface SkeletonTableProps {
  rows?: number;
  columns?: number;
  className?: string;
}

export const SkeletonTable: React.FC<SkeletonTableProps> = ({
  rows = 5,
  columns = 4,
  className,
}) => {
  return (
    <div className={clsx('bg-white rounded-lg border border-gray-200 overflow-hidden', className)}>
      {/* Header */}
      <div className="bg-gray-50 px-4 py-3 flex gap-4">
        {Array.from({ length: columns }).map((_, i) => (
          <Skeleton key={i} height={16} className="flex-1" />
        ))}
      </div>
      
      {/* Rows */}
      {Array.from({ length: rows }).map((_, rowIndex) => (
        <div
          key={rowIndex}
          className="px-4 py-3 flex gap-4 border-t border-gray-100"
        >
          {Array.from({ length: columns }).map((_, colIndex) => (
            <Skeleton key={colIndex} height={16} className="flex-1" />
          ))}
        </div>
      ))}
    </div>
  );
};

export default Spinner;
