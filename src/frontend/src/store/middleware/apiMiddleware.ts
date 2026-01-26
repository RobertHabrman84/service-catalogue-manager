import { Middleware, isRejectedWithValue } from '@reduxjs/toolkit';
import { addNotification } from '../slices/uiSlice';

/**
 * API Error handling middleware
 * Intercepts rejected actions and shows error notifications
 */
export const apiErrorMiddleware: Middleware = (store) => (next) => (action) => {
  if (isRejectedWithValue(action)) {
    const error = action.payload as { message?: string; status?: number };
    const errorMessage = error?.message || 'An unexpected error occurred';
    
    // Don't show notification for cancelled requests
    if (errorMessage === 'Request cancelled' || errorMessage === 'Aborted') {
      return next(action);
    }

    // Handle specific error codes
    if (error?.status === 401) {
      store.dispatch(
        addNotification({
          id: `error-${Date.now()}`,
          type: 'error',
          title: 'Authentication Required',
          message: 'Please log in to continue.',
          duration: 0,
        })
      );
    } else if (error?.status === 403) {
      store.dispatch(
        addNotification({
          id: `error-${Date.now()}`,
          type: 'error',
          title: 'Access Denied',
          message: 'You do not have permission to perform this action.',
          duration: 0,
        })
      );
    } else if (error?.status === 404) {
      store.dispatch(
        addNotification({
          id: `error-${Date.now()}`,
          type: 'warning',
          title: 'Not Found',
          message: 'The requested resource was not found.',
          duration: 5000,
        })
      );
    } else if (error?.status && error.status >= 500) {
      store.dispatch(
        addNotification({
          id: `error-${Date.now()}`,
          type: 'error',
          title: 'Server Error',
          message: 'A server error occurred. Please try again later.',
          duration: 0,
        })
      );
    } else {
      store.dispatch(
        addNotification({
          id: `error-${Date.now()}`,
          type: 'error',
          title: 'Error',
          message: errorMessage,
          duration: 7000,
        })
      );
    }
  }

  return next(action);
};

/**
 * Loading state middleware
 * Tracks pending async actions
 */
export const loadingMiddleware: Middleware = () => (next) => (action) => {
  // Could be extended to track global loading state
  return next(action);
};

/**
 * Logger middleware for development
 */
export const loggerMiddleware: Middleware = () => (next) => (action) => {
  if (import.meta.env.DEV) {
    console.group(action.type);
    console.log('Action:', action);
    const result = next(action);
    console.groupEnd();
    return result;
  }
  return next(action);
};

export default apiErrorMiddleware;
