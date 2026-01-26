import { Suspense } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useIsAuthenticated } from '@azure/msal-react';

import { Layout } from './components/common/Layout';
import { LoadingSpinner } from './components/common/LoadingSpinner';
import { ProtectedRoute } from './components/auth/ProtectedRoute';

// Pages
import { DashboardPage as Dashboard } from './pages/Dashboard';
import { CatalogListPage } from './pages/Catalog';
import { CreateServicePage, EditServicePage } from './pages/ServiceForm';
import { ServiceViewPage as ViewServicePage } from './pages/ServiceView';
import { ExportPage } from './pages/Export';
import { SettingsPage } from './pages/Settings';
import { LoginPage } from './pages/Login';
import { NotFoundPage } from './pages/NotFound';

function App() {
  const skipAuth = import.meta.env.VITE_SKIP_AUTH === 'true' || import.meta.env.VITE_DEV_MODE === 'true';
  const isAuthenticated = skipAuth || useIsAuthenticated();

  if (skipAuth) {
    console.log('🔥 APP: Auth bypassed - rendering without ProtectedRoute');
  }

  return (
    <Suspense fallback={<LoadingSpinner fullScreen />}>
      <Routes>
        {/* Public routes */}
        <Route path="/login" element={<LoginPage />} />

        {/* Protected routes */}
        <Route
          element={
            skipAuth ? <Layout /> : (
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            )
          }
        >
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/catalog" element={<CatalogListPage />} />
          <Route path="/catalog/new" element={<CreateServicePage />} />
          <Route path="/catalog/:id" element={<ViewServicePage />} />
          <Route path="/catalog/:id/edit" element={<EditServicePage />} />
          <Route path="/export" element={<ExportPage />} />
          <Route path="/settings" element={<SettingsPage />} />
        </Route>

        {/* 404 */}
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </Suspense>
  );
}

export default App;
