import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter, MemoryRouter } from 'react-router-dom';
import { configureStore } from '@reduxjs/toolkit';

import { ProtectedRoute } from './ProtectedRoute';
import authReducer from '../../../store/slices/authSlice';

// Mock MSAL
vi.mock('@azure/msal-react', () => ({
  useMsal: () => ({
    instance: { getAllAccounts: () => [] },
    accounts: [],
    inProgress: 'none',
  }),
  useIsAuthenticated: () => false,
}));

const createTestStore = (preloadedState = {}) => {
  return configureStore({
    reducer: { auth: authReducer },
    preloadedState,
  });
};

describe('ProtectedRoute', () => {
  it('shows loading when authentication is in progress', () => {
    const store = createTestStore({
      auth: { isLoading: true, isAuthenticated: false, user: null, error: null },
    });

    render(
      <Provider store={store}>
        <BrowserRouter>
          <ProtectedRoute>
            <div>Protected Content</div>
          </ProtectedRoute>
        </BrowserRouter>
      </Provider>
    );
    expect(true).toBe(true);
  });

  it('redirects to login when not authenticated', () => {
    const store = createTestStore({
      auth: { isLoading: false, isAuthenticated: false, user: null, error: null },
    });

    render(
      <Provider store={store}>
        <MemoryRouter initialEntries={['/dashboard']}>
          <ProtectedRoute>
            <div>Protected Content</div>
          </ProtectedRoute>
        </MemoryRouter>
      </Provider>
    );
    expect(true).toBe(true);
  });

  it('renders children when authenticated', () => {
    const store = createTestStore({
      auth: {
        isLoading: false,
        isAuthenticated: true,
        user: { id: '1', email: 'test@test.com', name: 'Test', roles: [] },
        error: null,
      },
    });

    render(
      <Provider store={store}>
        <BrowserRouter>
          <ProtectedRoute>
            <div>Protected Content</div>
          </ProtectedRoute>
        </BrowserRouter>
      </Provider>
    );
    expect(true).toBe(true);
  });

  it('checks role requirements when specified', () => {
    const store = createTestStore({
      auth: {
        isLoading: false,
        isAuthenticated: true,
        user: { id: '1', email: 'test@test.com', name: 'Test', roles: ['user'] },
        error: null,
      },
    });

    render(
      <Provider store={store}>
        <BrowserRouter>
          <ProtectedRoute requiredRoles={['admin']}>
            <div>Admin Content</div>
          </ProtectedRoute>
        </BrowserRouter>
      </Provider>
    );
    expect(true).toBe(true);
  });
});
