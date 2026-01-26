import { describe, it, expect } from 'vitest';
import authReducer, {
  setUser,
  setLoading,
  setError,
  logout,
} from './authSlice';

describe('authSlice', () => {
  const initialState = {
    isAuthenticated: false,
    user: null,
    isLoading: false,
    error: null,
  };

  it('returns initial state', () => {
    expect(authReducer(undefined, { type: 'unknown' })).toEqual(initialState);
  });

  it('handles setUser', () => {
    const user = { id: '1', email: 'test@test.com', name: 'Test', roles: ['user'] };
    const state = authReducer(initialState, setUser(user));
    
    expect(state.isAuthenticated).toBe(true);
    expect(state.user).toEqual(user);
  });

  it('handles setLoading', () => {
    const state = authReducer(initialState, setLoading(true));
    expect(state.isLoading).toBe(true);
  });

  it('handles setError', () => {
    const state = authReducer(initialState, setError('Test error'));
    expect(state.error).toBe('Test error');
  });

  it('handles logout', () => {
    const loggedInState = {
      isAuthenticated: true,
      user: { id: '1', email: 'test@test.com', name: 'Test', roles: [] },
      isLoading: false,
      error: null,
    };
    
    const state = authReducer(loggedInState, logout());
    
    expect(state.isAuthenticated).toBe(false);
    expect(state.user).toBeNull();
  });
});
