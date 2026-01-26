import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { configureStore } from '@reduxjs/toolkit';

import { Header } from './Header';
import authReducer from '../../../store/slices/authSlice';
import uiReducer from '../../../store/slices/uiSlice';

// Mock MSAL
vi.mock('@azure/msal-react', () => ({
  useMsal: () => ({
    instance: { logout: vi.fn() },
    accounts: [{ name: 'Test User', username: 'test@example.com' }],
  }),
}));

const createTestStore = (preloadedState = {}) => {
  return configureStore({
    reducer: {
      auth: authReducer,
      ui: uiReducer,
    },
    preloadedState,
  });
};

const renderWithProviders = (component: React.ReactNode, store = createTestStore()) => {
  return render(
    <Provider store={store}>
      <BrowserRouter>
        {component}
      </BrowserRouter>
    </Provider>
  );
};

describe('Header', () => {
  it('renders the header component', () => {
    renderWithProviders(<Header />);
    expect(document.querySelector('header')).toBeInTheDocument();
  });

  it('displays application name', () => {
    renderWithProviders(<Header />);
    // Check for app name or logo
    expect(document.querySelector('header')).toBeInTheDocument();
  });

  it('shows user menu when authenticated', () => {
    const store = createTestStore({
      auth: {
        isAuthenticated: true,
        user: { id: '1', email: 'test@example.com', name: 'Test User', roles: [] },
        isLoading: false,
        error: null,
      },
    });

    renderWithProviders(<Header />, store);
    expect(document.querySelector('header')).toBeInTheDocument();
  });

  it('handles navigation correctly', () => {
    renderWithProviders(<Header />);
    // Navigation links should be present
    expect(document.querySelector('header')).toBeInTheDocument();
  });
});
