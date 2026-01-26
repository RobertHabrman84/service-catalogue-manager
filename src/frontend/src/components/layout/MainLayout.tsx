// components/layout/MainLayout.tsx
// Main application layout with sidebar and header

import React, { useState } from 'react';
import { Outlet, NavLink, useLocation } from 'react-router-dom';
import { 
  HomeIcon, 
  FolderIcon, 
  PlusCircleIcon,
  DocumentArrowDownIcon,
  DocumentArrowUpIcon,
  Cog6ToothIcon,
  Bars3Icon,
  XMarkIcon,
  ChevronLeftIcon,
  BellIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';
import { Avatar, AvatarWithName, Dropdown, SearchInput } from '../common';
import { authService } from '../../services/auth';
import clsx from 'clsx';

interface NavItem {
  name: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  badge?: number;
}

const navigation: NavItem[] = [
  { name: 'Dashboard', href: '/', icon: HomeIcon },
  { name: 'Service Catalog', href: '/catalog', icon: FolderIcon },
  { name: 'Create Service', href: '/services/new', icon: PlusCircleIcon },
  { name: 'Import', href: '/import', icon: DocumentArrowUpIcon },
  { name: 'Export', href: '/export', icon: DocumentArrowDownIcon },
  { name: 'Settings', href: '/settings', icon: Cog6ToothIcon },
];

export const MainLayout: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const location = useLocation();
  const user = authService.getCurrentUser();

  const userMenuItems = [
    { id: 'profile', label: 'Your Profile', onClick: () => {} },
    { id: 'settings', label: 'Settings', onClick: () => {} },
    { id: 'divider', label: '', divider: true },
    { id: 'logout', label: 'Sign out', onClick: () => authService.logout(), danger: true },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile sidebar backdrop */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 z-40 bg-gray-600 bg-opacity-75 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Mobile sidebar */}
      <div
        className={clsx(
          'fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-xl transform transition-transform duration-300 ease-in-out lg:hidden',
          sidebarOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        <div className="flex items-center justify-between h-16 px-4 border-b border-gray-200">
          <span className="text-xl font-bold text-blue-600">SCM</span>
          <button
            onClick={() => setSidebarOpen(false)}
            className="p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100"
          >
            <XMarkIcon className="h-6 w-6" />
          </button>
        </div>
        <nav className="px-2 py-4 space-y-1">
          {navigation.map((item) => (
            <NavLink
              key={item.name}
              to={item.href}
              onClick={() => setSidebarOpen(false)}
              className={({ isActive }) =>
                clsx(
                  'flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors',
                  isActive
                    ? 'bg-blue-50 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-100'
                )
              }
            >
              <item.icon className="h-5 w-5" />
              {item.name}
            </NavLink>
          ))}
        </nav>
      </div>

      {/* Desktop sidebar */}
      <div
        className={clsx(
          'hidden lg:fixed lg:inset-y-0 lg:flex lg:flex-col bg-white border-r border-gray-200 transition-all duration-300',
          sidebarCollapsed ? 'lg:w-20' : 'lg:w-64'
        )}
      >
        {/* Logo */}
        <div className="flex items-center justify-between h-16 px-4 border-b border-gray-200">
          {!sidebarCollapsed && (
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                <FolderIcon className="w-5 h-5 text-white" />
              </div>
              <span className="text-lg font-bold text-gray-900">SCM</span>
            </div>
          )}
          {sidebarCollapsed && (
            <div className="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center mx-auto">
              <FolderIcon className="w-6 h-6 text-white" />
            </div>
          )}
          <button
            onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
            className={clsx(
              'p-1.5 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 transition-transform',
              sidebarCollapsed && 'rotate-180 mx-auto'
            )}
          >
            <ChevronLeftIcon className="h-5 w-5" />
          </button>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-2 py-4 space-y-1 overflow-y-auto">
          {navigation.map((item) => {
            const isActive = location.pathname === item.href || 
              (item.href !== '/' && location.pathname.startsWith(item.href));
            
            return (
              <NavLink
                key={item.name}
                to={item.href}
                title={sidebarCollapsed ? item.name : undefined}
                className={clsx(
                  'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
                  isActive
                    ? 'bg-blue-50 text-blue-700 border-l-4 border-blue-600 -ml-0.5 pl-2.5'
                    : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900',
                  sidebarCollapsed && 'justify-center px-2'
                )}
              >
                <item.icon className={clsx('h-5 w-5 flex-shrink-0', isActive && 'text-blue-600')} />
                {!sidebarCollapsed && <span>{item.name}</span>}
                {!sidebarCollapsed && item.badge && (
                  <span className="ml-auto bg-blue-100 text-blue-600 text-xs font-semibold px-2 py-0.5 rounded-full">
                    {item.badge}
                  </span>
                )}
              </NavLink>
            );
          })}
        </nav>

        {/* User section */}
        <div className={clsx(
          'border-t border-gray-200 p-4',
          sidebarCollapsed && 'flex justify-center'
        )}>
          {sidebarCollapsed ? (
            <Dropdown
              trigger={<Avatar name={user?.displayName} size="md" />}
              items={userMenuItems}
              align="right"
            />
          ) : (
            <Dropdown
              trigger={
                <div className="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-100 cursor-pointer">
                  <Avatar name={user?.displayName} size="sm" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {user?.displayName || 'User'}
                    </p>
                    <p className="text-xs text-gray-500 truncate">
                      {user?.email}
                    </p>
                  </div>
                </div>
              }
              items={userMenuItems}
              align="right"
              width="full"
            />
          )}
        </div>
      </div>

      {/* Main content */}
      <div className={clsx(
        'transition-all duration-300',
        sidebarCollapsed ? 'lg:pl-20' : 'lg:pl-64'
      )}>
        {/* Top header */}
        <header className="sticky top-0 z-30 bg-white border-b border-gray-200">
          <div className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
            {/* Mobile menu button */}
            <button
              onClick={() => setSidebarOpen(true)}
              className="p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 lg:hidden"
            >
              <Bars3Icon className="h-6 w-6" />
            </button>

            {/* Search */}
            <div className="flex-1 max-w-lg mx-4 hidden sm:block">
              <SearchInput
                placeholder="Search services..."
                size="md"
                onSearch={(query) => console.log('Search:', query)}
              />
            </div>

            {/* Right side actions */}
            <div className="flex items-center gap-4">
              {/* Mobile search button */}
              <button className="p-2 rounded-md text-gray-400 hover:text-gray-500 sm:hidden">
                <MagnifyingGlassIcon className="h-6 w-6" />
              </button>

              {/* Notifications */}
              <button className="relative p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100">
                <BellIcon className="h-6 w-6" />
                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full" />
              </button>

              {/* User avatar (mobile) */}
              <div className="lg:hidden">
                <Dropdown
                  trigger={<Avatar name={user?.displayName} size="sm" />}
                  items={userMenuItems}
                  align="right"
                />
              </div>
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="p-4 sm:p-6 lg:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default MainLayout;
