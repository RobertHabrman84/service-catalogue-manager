import { describe, it, expect } from 'vitest';
import uiReducer, {
  toggleSidebar,
  setTheme,
  addNotification,
  removeNotification,
} from './uiSlice';

describe('uiSlice', () => {
  const initialState = {
    sidebarCollapsed: false,
    theme: 'light' as const,
    notifications: [],
  };

  it('returns initial state', () => {
    expect(uiReducer(undefined, { type: 'unknown' })).toEqual(initialState);
  });

  it('handles toggleSidebar', () => {
    const state = uiReducer(initialState, toggleSidebar());
    expect(state.sidebarCollapsed).toBe(true);
    
    const state2 = uiReducer(state, toggleSidebar());
    expect(state2.sidebarCollapsed).toBe(false);
  });

  it('handles setTheme', () => {
    const state = uiReducer(initialState, setTheme('dark'));
    expect(state.theme).toBe('dark');
  });

  it('handles addNotification', () => {
    const notification = { id: '1', type: 'success' as const, message: 'Test' };
    const state = uiReducer(initialState, addNotification(notification));
    expect(state.notifications).toHaveLength(1);
    expect(state.notifications[0]).toEqual(notification);
  });

  it('handles removeNotification', () => {
    const stateWithNotification = {
      ...initialState,
      notifications: [{ id: '1', type: 'success' as const, message: 'Test' }],
    };
    
    const state = uiReducer(stateWithNotification, removeNotification('1'));
    expect(state.notifications).toHaveLength(0);
  });
});
