// Notification/index.tsx
// Toast notification component with context provider

import React, { createContext, useContext, useState, useCallback, Fragment } from 'react';
import { Transition } from '@headlessui/react';
import { 
  CheckCircleIcon, 
  ExclamationTriangleIcon, 
  InformationCircleIcon,
  XCircleIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';
import clsx from 'clsx';

// Types
type NotificationType = 'success' | 'error' | 'warning' | 'info';

interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message?: string;
  duration?: number;
  action?: {
    label: string;
    onClick: () => void;
  };
}

interface NotificationContextType {
  notifications: Notification[];
  addNotification: (notification: Omit<Notification, 'id'>) => string;
  removeNotification: (id: string) => void;
  success: (title: string, message?: string) => void;
  error: (title: string, message?: string) => void;
  warning: (title: string, message?: string) => void;
  info: (title: string, message?: string) => void;
}

// Context
const NotificationContext = createContext<NotificationContextType | null>(null);

// Config
const TYPE_CONFIG: Record<NotificationType, {
  icon: React.ReactNode;
  iconColor: string;
  bgColor: string;
  borderColor: string;
}> = {
  success: {
    icon: <CheckCircleIcon className="h-6 w-6" />,
    iconColor: 'text-green-400',
    bgColor: 'bg-green-50',
    borderColor: 'border-green-200',
  },
  error: {
    icon: <XCircleIcon className="h-6 w-6" />,
    iconColor: 'text-red-400',
    bgColor: 'bg-red-50',
    borderColor: 'border-red-200',
  },
  warning: {
    icon: <ExclamationTriangleIcon className="h-6 w-6" />,
    iconColor: 'text-amber-400',
    bgColor: 'bg-amber-50',
    borderColor: 'border-amber-200',
  },
  info: {
    icon: <InformationCircleIcon className="h-6 w-6" />,
    iconColor: 'text-blue-400',
    bgColor: 'bg-blue-50',
    borderColor: 'border-blue-200',
  },
};

const DEFAULT_DURATION = 5000;

// Single notification item
interface NotificationItemProps {
  notification: Notification;
  onRemove: (id: string) => void;
}

const NotificationItem: React.FC<NotificationItemProps> = ({ 
  notification, 
  onRemove 
}) => {
  const [show, setShow] = useState(true);
  const config = TYPE_CONFIG[notification.type];

  // Auto-dismiss
  React.useEffect(() => {
    const duration = notification.duration ?? DEFAULT_DURATION;
    if (duration > 0) {
      const timer = setTimeout(() => {
        setShow(false);
      }, duration);
      return () => clearTimeout(timer);
    }
  }, [notification.duration]);

  const handleClose = () => {
    setShow(false);
  };

  return (
    <Transition
      show={show}
      as={Fragment}
      enter="transform ease-out duration-300 transition"
      enterFrom="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
      enterTo="translate-y-0 opacity-100 sm:translate-x-0"
      leave="transition ease-in duration-100"
      leaveFrom="opacity-100"
      leaveTo="opacity-0"
      afterLeave={() => onRemove(notification.id)}
    >
      <div
        className={clsx(
          'pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg shadow-lg ring-1 ring-black ring-opacity-5',
          config.bgColor,
          config.borderColor,
          'border'
        )}
      >
        <div className="p-4">
          <div className="flex items-start">
            {/* Icon */}
            <div className={clsx('flex-shrink-0', config.iconColor)}>
              {config.icon}
            </div>

            {/* Content */}
            <div className="ml-3 w-0 flex-1 pt-0.5">
              <p className="text-sm font-medium text-gray-900">
                {notification.title}
              </p>
              {notification.message && (
                <p className="mt-1 text-sm text-gray-500">
                  {notification.message}
                </p>
              )}
              {notification.action && (
                <div className="mt-3">
                  <button
                    type="button"
                    onClick={notification.action.onClick}
                    className="text-sm font-medium text-blue-600 hover:text-blue-500"
                  >
                    {notification.action.label}
                  </button>
                </div>
              )}
            </div>

            {/* Close button */}
            <div className="ml-4 flex flex-shrink-0">
              <button
                type="button"
                onClick={handleClose}
                className="inline-flex rounded-md text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
              >
                <span className="sr-only">Close</span>
                <XMarkIcon className="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  );
};

// Notification container
const NotificationContainer: React.FC<{
  notifications: Notification[];
  onRemove: (id: string) => void;
}> = ({ notifications, onRemove }) => {
  return (
    <div
      aria-live="assertive"
      className="pointer-events-none fixed inset-0 z-50 flex items-end px-4 py-6 sm:items-start sm:p-6"
    >
      <div className="flex w-full flex-col items-center space-y-4 sm:items-end">
        {notifications.map((notification) => (
          <NotificationItem
            key={notification.id}
            notification={notification}
            onRemove={onRemove}
          />
        ))}
      </div>
    </div>
  );
};

// Provider component
export const NotificationProvider: React.FC<{ children: React.ReactNode }> = ({ 
  children 
}) => {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  const addNotification = useCallback((notification: Omit<Notification, 'id'>): string => {
    const id = `notification-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    const newNotification: Notification = { ...notification, id };
    
    setNotifications((prev) => [...prev, newNotification]);
    return id;
  }, []);

  const removeNotification = useCallback((id: string) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
  }, []);

  const success = useCallback((title: string, message?: string) => {
    addNotification({ type: 'success', title, message });
  }, [addNotification]);

  const error = useCallback((title: string, message?: string) => {
    addNotification({ type: 'error', title, message, duration: 8000 });
  }, [addNotification]);

  const warning = useCallback((title: string, message?: string) => {
    addNotification({ type: 'warning', title, message });
  }, [addNotification]);

  const info = useCallback((title: string, message?: string) => {
    addNotification({ type: 'info', title, message });
  }, [addNotification]);

  return (
    <NotificationContext.Provider
      value={{
        notifications,
        addNotification,
        removeNotification,
        success,
        error,
        warning,
        info,
      }}
    >
      {children}
      <NotificationContainer
        notifications={notifications}
        onRemove={removeNotification}
      />
    </NotificationContext.Provider>
  );
};

// Hook
export const useNotification = (): NotificationContextType => {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotification must be used within a NotificationProvider');
  }
  return context;
};

// Standalone toast function (for use outside React)
let toastRef: NotificationContextType | null = null;

export const setToastRef = (ref: NotificationContextType) => {
  toastRef = ref;
};

export const toast = {
  success: (title: string, message?: string) => toastRef?.success(title, message),
  error: (title: string, message?: string) => toastRef?.error(title, message),
  warning: (title: string, message?: string) => toastRef?.warning(title, message),
  info: (title: string, message?: string) => toastRef?.info(title, message),
};

export default NotificationProvider;
