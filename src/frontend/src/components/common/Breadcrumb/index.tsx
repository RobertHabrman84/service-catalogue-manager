// Breadcrumb/index.tsx
// Breadcrumb navigation component

import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ChevronRightIcon, HomeIcon } from '@heroicons/react/24/outline';
import clsx from 'clsx';

export interface BreadcrumbItem {
  label: string;
  href?: string;
  icon?: React.ReactNode;
}

interface BreadcrumbProps {
  items?: BreadcrumbItem[];
  separator?: React.ReactNode;
  showHome?: boolean;
  homeHref?: string;
  className?: string;
  maxItems?: number;
}

// Auto-generate breadcrumbs from URL
const generateBreadcrumbsFromPath = (pathname: string): BreadcrumbItem[] => {
  const paths = pathname.split('/').filter(Boolean);
  
  return paths.map((path, index) => {
    const href = '/' + paths.slice(0, index + 1).join('/');
    const label = path
      .replace(/-/g, ' ')
      .replace(/\b\w/g, (char) => char.toUpperCase());
    
    return { label, href };
  });
};

export const Breadcrumb: React.FC<BreadcrumbProps> = ({
  items,
  separator,
  showHome = true,
  homeHref = '/',
  className,
  maxItems,
}) => {
  const location = useLocation();
  
  // Use provided items or auto-generate from URL
  const breadcrumbItems = items || generateBreadcrumbsFromPath(location.pathname);
  
  // Handle max items with ellipsis
  let displayItems = breadcrumbItems;
  let showEllipsis = false;
  
  if (maxItems && breadcrumbItems.length > maxItems) {
    displayItems = [
      breadcrumbItems[0],
      ...breadcrumbItems.slice(-(maxItems - 1)),
    ];
    showEllipsis = true;
  }

  const defaultSeparator = (
    <ChevronRightIcon className="h-4 w-4 text-gray-400 flex-shrink-0" />
  );

  return (
    <nav className={clsx('flex', className)} aria-label="Breadcrumb">
      <ol className="flex items-center flex-wrap gap-y-2">
        {/* Home Link */}
        {showHome && (
          <li className="flex items-center">
            <Link
              to={homeHref}
              className="text-gray-400 hover:text-gray-500 transition-colors"
            >
              <HomeIcon className="h-5 w-5" aria-hidden="true" />
              <span className="sr-only">Home</span>
            </Link>
          </li>
        )}

        {/* Breadcrumb Items */}
        {displayItems.map((item, index) => {
          const isLast = index === displayItems.length - 1;
          const showSeparator = showHome || index > 0;
          
          // Show ellipsis after first item if we're truncating
          const showEllipsisHere = showEllipsis && index === 0;

          return (
            <React.Fragment key={item.href || item.label}>
              {/* Separator */}
              {showSeparator && (
                <li className="flex items-center mx-2">
                  {separator || defaultSeparator}
                </li>
              )}

              {/* Ellipsis */}
              {showEllipsisHere && (
                <>
                  <li className="flex items-center">
                    <span className="text-gray-400 text-sm">...</span>
                  </li>
                  <li className="flex items-center mx-2">
                    {separator || defaultSeparator}
                  </li>
                </>
              )}

              {/* Breadcrumb Item */}
              <li className="flex items-center">
                {isLast || !item.href ? (
                  <span
                    className={clsx(
                      'flex items-center gap-1.5 text-sm font-medium',
                      isLast ? 'text-gray-800' : 'text-gray-500'
                    )}
                    aria-current={isLast ? 'page' : undefined}
                  >
                    {item.icon}
                    {item.label}
                  </span>
                ) : (
                  <Link
                    to={item.href}
                    className="flex items-center gap-1.5 text-sm text-gray-500 hover:text-gray-700 transition-colors"
                  >
                    {item.icon}
                    {item.label}
                  </Link>
                )}
              </li>
            </React.Fragment>
          );
        })}
      </ol>
    </nav>
  );
};

// Page Header with Breadcrumb
interface PageHeaderProps {
  title: string;
  subtitle?: string;
  breadcrumbs?: BreadcrumbItem[];
  actions?: React.ReactNode;
  className?: string;
}

export const PageHeader: React.FC<PageHeaderProps> = ({
  title,
  subtitle,
  breadcrumbs,
  actions,
  className,
}) => {
  return (
    <div className={clsx('mb-6', className)}>
      <Breadcrumb items={breadcrumbs} className="mb-4" />
      
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
          {subtitle && (
            <p className="mt-1 text-sm text-gray-500">{subtitle}</p>
          )}
        </div>
        
        {actions && (
          <div className="flex items-center gap-3">
            {actions}
          </div>
        )}
      </div>
    </div>
  );
};

export default Breadcrumb;
