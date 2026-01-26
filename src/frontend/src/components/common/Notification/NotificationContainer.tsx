import { FC } from 'react';
import styles from './Notification.module.css';

interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
}

interface NotificationContainerProps {
  notifications: Notification[];
  onDismiss: (id: string) => void;
}

export const NotificationContainer: FC<NotificationContainerProps> = ({ notifications, onDismiss }) => (
  <div className={styles.container}>
    {notifications.map(n => (
      <div key={n.id} className={`${styles.notification} ${styles[n.type]}`}>
        <span>{n.message}</span>
        <button onClick={() => onDismiss(n.id)}>×</button>
      </div>
    ))}
  </div>
);
