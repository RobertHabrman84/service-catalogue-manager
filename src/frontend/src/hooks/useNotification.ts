import { useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { RootState, AppDispatch } from '../store/store';
import {
  addNotification,
  removeNotification,
  clearAllNotifications,
  NotificationType,
} from '../store/slices/uiSlice';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message?: string;
  duration?: number;
  dismissible?: boolean;
}

export interface UseNotificationResult {
  notifications: Notification[];
  showNotification: (notification: Omit<Notification, 'id'>) => string;
  showSuccess: (title: string, message?: string) => string;
  showError: (title: string, message?: string) => string;
  showWarning: (title: string, message?: string) => string;
  showInfo: (title: string, message?: string) => string;
  dismiss: (id: string) => void;
  dismissAll: () => void;
}

const generateId = (): string => {
  return `notification-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};

export const useNotification = (): UseNotificationResult => {
  const dispatch = useDispatch<AppDispatch>();
  const notifications = useSelector((state: RootState) => state.ui.notifications);

  const showNotification = useCallback(
    (notification: Omit<Notification, 'id'>): string => {
      const id = generateId();
      const fullNotification: Notification = {
        id,
        duration: 5000,
        dismissible: true,
        ...notification,
      };

      dispatch(addNotification(fullNotification));

      // Auto-dismiss after duration
      if (fullNotification.duration && fullNotification.duration > 0) {
        setTimeout(() => {
          dispatch(removeNotification(id));
        }, fullNotification.duration);
      }

      return id;
    },
    [dispatch]
  );

  const showSuccess = useCallback(
    (title: string, message?: string): string => {
      return showNotification({ type: 'success', title, message });
    },
    [showNotification]
  );

  const showError = useCallback(
    (title: string, message?: string): string => {
      return showNotification({ type: 'error', title, message, duration: 0 });
    },
    [showNotification]
  );

  const showWarning = useCallback(
    (title: string, message?: string): string => {
      return showNotification({ type: 'warning', title, message, duration: 8000 });
    },
    [showNotification]
  );

  const showInfo = useCallback(
    (title: string, message?: string): string => {
      return showNotification({ type: 'info', title, message });
    },
    [showNotification]
  );

  const dismiss = useCallback(
    (id: string) => {
      dispatch(removeNotification(id));
    },
    [dispatch]
  );

  const dismissAll = useCallback(() => {
    dispatch(clearAllNotifications());
  }, [dispatch]);

  return {
    notifications,
    showNotification,
    showSuccess,
    showError,
    showWarning,
    showInfo,
    dismiss,
    dismissAll,
  };
};

export default useNotification;
