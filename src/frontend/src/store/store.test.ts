import { describe, it, expect } from 'vitest';
import { configureStore } from '@reduxjs/toolkit';

import { store, RootState, AppDispatch } from './store';
import authReducer from './slices/authSlice';
import catalogReducer from './slices/catalogSlice';
import lookupReducer from './slices/lookupSlice';
import uiReducer from './slices/uiSlice';

describe('Store', () => {
  it('has correct initial state structure', () => {
    const state = store.getState();
    
    expect(state).toHaveProperty('auth');
    expect(state).toHaveProperty('catalog');
    expect(state).toHaveProperty('lookups');
    expect(state).toHaveProperty('ui');
  });

  it('can be configured with preloaded state', () => {
    const preloadedState = {
      auth: {
        isAuthenticated: true,
        user: { id: '1', email: 'test@test.com', name: 'Test', roles: [] },
        isLoading: false,
        error: null,
      },
    };

    const testStore = configureStore({
      reducer: {
        auth: authReducer,
        catalog: catalogReducer,
        lookups: lookupReducer,
        ui: uiReducer,
      },
      preloadedState,
    });

    expect(testStore.getState().auth.isAuthenticated).toBe(true);
  });
});
