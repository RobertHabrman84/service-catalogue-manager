import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'react-redux';
import { RouterProvider } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MsalProvider } from '@azure/msal-react';
import { ToastContainer } from 'react-toastify';

import { router } from './routes';
import { store } from '@store/store';
import { msalInstance } from '@services/auth/msalInstance';

import '@styles/index.css';
import 'react-toastify/dist/ReactToastify.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

// ========================================
// 🔥 FORCE AUTH BYPASS - VŽDY VYPNUTO PRO DEV
// ========================================

const FORCE_SKIP_AUTH = true;

const envSkipAuth = import.meta.env.VITE_SKIP_AUTH === 'true';
const envDevMode = import.meta.env.VITE_DEV_MODE === 'true';
const skipAuth = FORCE_SKIP_AUTH || envSkipAuth || envDevMode;

console.log('🔥 AUTH BYPASS (V3):', {
  FORCE_SKIP_AUTH,
  envSkipAuth,
  envDevMode,
  finalSkipAuth: skipAuth,
  allEnv: import.meta.env
});

if (skipAuth) {
  console.log('✅ AUTH BYPASSED - NO MSAL LOADED');
} else {
  console.log('⚠️ AUTH ENABLED - MSAL WILL LOAD');
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Provider store={store}>
      <QueryClientProvider client={queryClient}>
        {skipAuth ? (
          <RouterProvider router={router} />
        ) : (
          <MsalProvider instance={msalInstance}>
            <RouterProvider router={router} />
          </MsalProvider>
        )}
        <ToastContainer
          position="top-right"
          autoClose={5000}
          hideProgressBar={false}
          newestOnTop
          closeOnClick
          rtl={false}
          pauseOnFocusLoss
          draggable
          pauseOnHover
          theme="light"
        />
      </QueryClientProvider>
    </Provider>
  </React.StrictMode>
);
