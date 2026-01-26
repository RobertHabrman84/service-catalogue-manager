import React, { ReactElement, ReactNode } from 'react';
import { render, RenderOptions, RenderResult } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { configureStore, PreloadedState } from '@reduxjs/toolkit';
import { RootState } from '../store/store';
import authReducer from '../store/slices/authSlice';
import catalogReducer from '../store/slices/catalogSlice';
import lookupReducer from '../store/slices/lookupSlice';
import uiReducer from '../store/slices/uiSlice';
import serviceReducer from '../store/slices/serviceSlice';
import exportReducer from '../store/slices/exportSlice';

// Create a test store
export const createTestStore = (preloadedState?: PreloadedState<RootState>) => {
  return configureStore({
    reducer: {
      auth: authReducer,
      catalog: catalogReducer,
      lookups: lookupReducer,
      ui: uiReducer,
      services: serviceReducer,
      export: exportReducer,
    },
    preloadedState,
  });
};

// Wrapper with all providers
interface AllProvidersProps {
  children: ReactNode;
  store?: ReturnType<typeof createTestStore>;
}

export const AllProviders: React.FC<AllProvidersProps> = ({ children, store }) => {
  const testStore = store || createTestStore();

  return (
    <Provider store={testStore}>
      <BrowserRouter>{children}</BrowserRouter>
    </Provider>
  );
};

// Custom render with providers
interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  preloadedState?: PreloadedState<RootState>;
  store?: ReturnType<typeof createTestStore>;
}

export const renderWithProviders = (
  ui: ReactElement,
  options: CustomRenderOptions = {}
): RenderResult & { store: ReturnType<typeof createTestStore> } => {
  const { preloadedState, store = createTestStore(preloadedState), ...renderOptions } = options;

  const Wrapper: React.FC<{ children: ReactNode }> = ({ children }) => (
    <AllProviders store={store}>{children}</AllProviders>
  );

  return {
    store,
    ...render(ui, { wrapper: Wrapper, ...renderOptions }),
  };
};

// Re-export everything from testing-library
export * from '@testing-library/react';
export { renderWithProviders as render };

// Mock window.matchMedia
export const mockMatchMedia = (matches = false) => {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });
};

// Mock IntersectionObserver
export const mockIntersectionObserver = () => {
  const mockIntersectionObserver = vi.fn();
  mockIntersectionObserver.mockReturnValue({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  });
  window.IntersectionObserver = mockIntersectionObserver;
};

// Mock ResizeObserver
export const mockResizeObserver = () => {
  const mockResizeObserver = vi.fn();
  mockResizeObserver.mockReturnValue({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  });
  window.ResizeObserver = mockResizeObserver;
};

// Wait for async operations
export const waitForAsync = () => new Promise((resolve) => setTimeout(resolve, 0));

// Create mock service data
export const createMockService = (overrides = {}) => ({
  serviceId: 1,
  serviceCode: 'TEST-001',
  serviceName: 'Test Service',
  version: '1.0.0',
  categoryId: 1,
  description: 'Test description',
  notes: '',
  isActive: true,
  isPublished: false,
  createdAt: '2024-01-01T00:00:00Z',
  createdBy: 'test@example.com',
  updatedAt: '2024-01-01T00:00:00Z',
  updatedBy: 'test@example.com',
  ...overrides,
});

// Create mock user
export const createMockUser = (overrides = {}) => ({
  id: 'user-1',
  email: 'test@example.com',
  name: 'Test User',
  username: 'test@example.com',
  roles: ['ServiceCatalog.Viewer'],
  tenantId: 'tenant-1',
  ...overrides,
});
