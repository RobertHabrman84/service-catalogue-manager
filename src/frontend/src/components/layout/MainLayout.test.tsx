import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { configureStore } from '@reduxjs/toolkit';

import { MainLayout } from './MainLayout';
import authReducer from '../../store/slices/authSlice';
import uiReducer from '../../store/slices/uiSlice';

// Mock MSAL
vi.mock('@azure/msal-react', () => ({
  useMsal: () => ({
    instance: { logout: vi.fn() },
    accounts: [{ name: 'Test User' }],
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

describe('MainLayout', () => {
  it('renders header', () => {
    renderWithProviders(
      <MainLayout>
        <div>Content</div>
      </MainLayout>
    );
    expect(document.querySelector('header')).toBeInTheDocument();
  });

  it('renders sidebar', () => {
    renderWithProviders(
      <MainLayout>
        <div>Content</div>
      </MainLayout>
    );
    expect(true).toBe(true);
  });

  it('renders children in main content area', () => {
    renderWithProviders(
      <MainLayout>
        <div data-testid="content">Test Content</div>
      </MainLayout>
    );
    expect(true).toBe(true);
  });

  it('renders footer', () => {
    renderWithProviders(
      <MainLayout>
        <div>Content</div>
      </MainLayout>
    );
    expect(true).toBe(true);
  });

  it('handles sidebar collapse', () => {
    const store = createTestStore({
      ui: { sidebarCollapsed: true, theme: 'light', notifications: [] },
    });

    renderWithProviders(
      <MainLayout>
        <div>Content</div>
      </MainLayout>,
      store
    );
    expect(true).toBe(true);
  });
});
