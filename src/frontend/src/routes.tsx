import { lazy, Suspense } from 'react';
import { createBrowserRouter, Navigate, Outlet } from 'react-router-dom';

import { MainLayout } from './components/layout/MainLayout';
import { ProtectedRoute } from './components/auth/ProtectedRoute';
import { LoadingSpinner } from './components/common/LoadingSpinner';

// Lazy-loaded pages
const Dashboard = lazy(() => import('./pages/Dashboard'));
const CatalogListPage = lazy(() => import('./pages/Catalog'));
const ServiceFormPage = lazy(() => import('./pages/ServiceForm'));
const ViewServicePage = lazy(() => import('./pages/ServiceView'));
const ImportServicePage = lazy(() => import('./pages/Import'));
const ExportPage = lazy(() => import('./pages/Export'));
const SettingsPage = lazy(() => import('./pages/Settings'));
const LoginPage = lazy(() => import('./pages/Login'));
const NotFoundPage = lazy(() => import('./pages/NotFound'));

// Loading fallback component
const PageLoader = () => (
  <div className="flex items-center justify-center min-h-screen">
    <LoadingSpinner size="lg" />
  </div>
);

// Layout wrapper with suspense
const SuspenseLayout = () => (
  <Suspense fallback={<PageLoader />}>
    <Outlet />
  </Suspense>
);

// Protected layout wrapper
const ProtectedLayout = () => (
  <ProtectedRoute>
    <MainLayout>
      <Suspense fallback={<PageLoader />}>
        <Outlet />
      </Suspense>
    </MainLayout>
  </ProtectedRoute>
);

export const router = createBrowserRouter([
  {
    path: '/',
    element: <SuspenseLayout />,
    children: [
      // Public routes
      {
        path: 'login',
        element: <LoginPage />,
      },
      
      // Protected routes
      {
        element: <ProtectedLayout />,
        children: [
          {
            index: true,
            element: <Navigate to="/dashboard" replace />,
          },
          {
            path: 'dashboard',
            element: <Dashboard />,
          },
          {
            path: 'catalog',
            element: <CatalogListPage />,
          },
          {
            path: 'services',
            children: [
              {
                index: true,
                element: <Navigate to="/catalog" replace />,
              },
              {
                path: 'new',
                element: <ServiceFormPage />,
              },
              {
                path: ':id',
                element: <ViewServicePage />,
              },
              {
                path: ':id/edit',
                element: <ServiceFormPage />,
              },
            ],
          },
          {
            path: 'import',
            element: <ImportServicePage />,
          },
          {
            path: 'export',
            element: <ExportPage />,
          },
          {
            path: 'settings',
            element: <SettingsPage />,
          },
        ],
      },
      
      // 404 catch-all
      {
        path: '*',
        element: <NotFoundPage />,
      },
    ],
  },
]);

// Route constants for use throughout the app
export const ROUTES = {
  HOME: '/',
  LOGIN: '/login',
  DASHBOARD: '/dashboard',
  CATALOG: '/catalog',
  SERVICE_NEW: '/services/new',
  SERVICE_VIEW: (id: string | number) => `/services/${id}`,
  SERVICE_EDIT: (id: string | number) => `/services/${id}/edit`,
  IMPORT: '/import',
  EXPORT: '/export',
  SETTINGS: '/settings',
} as const;

export default router;
