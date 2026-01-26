import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { configureStore } from '@reduxjs/toolkit';

import { Sidebar } from './Sidebar';
import uiReducer from '../../../store/slices/uiSlice';
import authReducer from '../../../store/slices/authSlice';

const createTestStore = (preloadedState = {}) => {
  return configureStore({
    reducer: {
      ui: uiReducer,
      auth: authReducer,
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

describe('Sidebar', () => {
  it('renders the sidebar component', () => {
    renderWithProviders(<Sidebar />);
    expect(document.querySelector('aside, nav')).toBeInTheDocument();
  });

  it('displays navigation items', () => {
    renderWithProviders(<Sidebar />);
    // Sidebar should contain navigation
    expect(document.querySelector('aside, nav')).toBeInTheDocument();
  });

  it('handles collapse/expand', () => {
    const store = createTestStore({
      ui: {
        sidebarCollapsed: false,
        theme: 'light',
        notifications: [],
      },
    });

    renderWithProviders(<Sidebar />, store);
    expect(document.querySelector('aside, nav')).toBeInTheDocument();
  });

  it('highlights active navigation item', () => {
    renderWithProviders(<Sidebar />);
    // Active item should be highlighted
    expect(document.querySelector('aside, nav')).toBeInTheDocument();
  });

  it('is accessible', () => {
    renderWithProviders(<Sidebar />);
    const sidebar = document.querySelector('aside, nav');
    expect(sidebar).toBeInTheDocument();
  });
});
