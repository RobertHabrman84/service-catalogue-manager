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
// Environment Configuration
// ========================================

const isDevelopment = import.meta.env.MODE === 'development';
const envSkipAuth = import.meta.env.VITE_SKIP_AUTH === 'true';
const skipAuth = isDevelopment && envSkipAuth;

// Only log in development mode (without sensitive data)
if (isDevelopment) {
  console.log('🔧 Development Mode:', {
    skipAuth,
    mode: import.meta.env.MODE,
  });
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
