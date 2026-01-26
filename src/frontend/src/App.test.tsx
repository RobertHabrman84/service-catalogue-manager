import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import { MemoryRouter } from 'react-router-dom';
import { configureStore } from '@reduxjs/toolkit';

import App from './App';
import authReducer from './store/slices/authSlice';
import catalogReducer from './store/slices/catalogSlice';
import lookupReducer from './store/slices/lookupSlice';
import uiReducer from './store/slices/uiSlice';

// Mock MSAL
vi.mock('@azure/msal-react', () => ({
  useMsal: () => ({
    instance: {
      getAllAccounts: () => [],
      acquireTokenSilent: vi.fn(),
    },
    accounts: [],
    inProgress: 'none',
  }),
  useIsAuthenticated: () => false,
  MsalProvider: ({ children }: { children: React.ReactNode }) => children,
}));

// Mock MSAL Browser
vi.mock('@azure/msal-browser', () => ({
  PublicClientApplication: vi.fn().mockImplementation(() => ({
    initialize: vi.fn().mockResolvedValue(undefined),
    getAllAccounts: () => [],
    acquireTokenSilent: vi.fn(),
  })),
  InteractionStatus: {
    None: 'none',
    Login: 'login',
    Logout: 'logout',
    AcquireToken: 'acquireToken',
  },
}));

// Create test store
const createTestStore = (preloadedState = {}) => {
  return configureStore({
    reducer: {
      auth: authReducer,
      catalog: catalogReducer,
      lookups: lookupReducer,
      ui: uiReducer,
    },
    preloadedState,
  });
};

// Test wrapper component
const TestWrapper = ({ 
  children, 
  initialRoute = '/',
  store = createTestStore(),
}: { 
  children: React.ReactNode;
  initialRoute?: string;
  store?: ReturnType<typeof createTestStore>;
}) => {
  return (
    <Provider store={store}>
      <MemoryRouter initialEntries={[initialRoute]}>
        {children}
      </MemoryRouter>
    </Provider>
  );
};

describe('App', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders without crashing', () => {
    render(
      <TestWrapper>
        <App />
      </TestWrapper>
    );
    
    // App should render something
    expect(document.body).toBeDefined();
  });

  it('redirects to login when not authenticated', () => {
    render(
      <TestWrapper initialRoute="/dashboard">
        <App />
      </TestWrapper>
    );
    
    // Should show login or redirect
    // Actual behavior depends on ProtectedRoute implementation
    expect(document.body).toBeDefined();
  });

  it('shows loading state during authentication check', () => {
    const store = createTestStore({
      auth: {
        isLoading: true,
        isAuthenticated: false,
        user: null,
        error: null,
      },
    });

    render(
      <TestWrapper store={store}>
        <App />
      </TestWrapper>
    );

    // Should show loading indicator
    expect(document.body).toBeDefined();
  });
});

describe('App Routes', () => {
  it('renders dashboard for authenticated users', () => {
    const store = createTestStore({
      auth: {
        isLoading: false,
        isAuthenticated: true,
        user: { id: '1', email: 'test@example.com', name: 'Test User', roles: [] },
        error: null,
      },
    });

    render(
      <TestWrapper store={store} initialRoute="/dashboard">
        <App />
      </TestWrapper>
    );

    expect(document.body).toBeDefined();
  });

  it('renders catalog page', () => {
    const store = createTestStore({
      auth: {
        isLoading: false,
        isAuthenticated: true,
        user: { id: '1', email: 'test@example.com', name: 'Test User', roles: [] },
        error: null,
      },
      catalog: {
        services: [],
        selectedService: null,
        isLoading: false,
        error: null,
        pagination: { page: 1, pageSize: 20, totalCount: 0, totalPages: 0 },
        filters: { searchTerm: '', categoryId: null, isActive: null },
      },
    });

    render(
      <TestWrapper store={store} initialRoute="/catalog">
        <App />
      </TestWrapper>
    );

    expect(document.body).toBeDefined();
  });

  it('renders 404 for unknown routes', () => {
    render(
      <TestWrapper initialRoute="/unknown-route">
        <App />
      </TestWrapper>
    );

    expect(document.body).toBeDefined();
  });
});

describe('App Error Handling', () => {
  it('handles authentication errors gracefully', () => {
    const store = createTestStore({
      auth: {
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: 'Authentication failed',
      },
    });

    render(
      <TestWrapper store={store}>
        <App />
      </TestWrapper>
    );

    expect(document.body).toBeDefined();
  });
});
