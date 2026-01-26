import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MsalProvider } from '@azure/msal-react';
import { ToastContainer } from 'react-toastify';

import App from './App';
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

const AppContent = () => (
  <Provider store={store}>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <App />
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
      </BrowserRouter>
    </QueryClientProvider>
  </Provider>
);

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    {skipAuth ? (
      <AppContent />
    ) : (
      <MsalProvider instance={msalInstance}>
        <AppContent />
      </MsalProvider>
    )}
  </React.StrictMode>
);
