import { FC } from 'react';
import styles from './Notification.module.css';

interface NotificationProps {
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  onClose?: () => void;
}

export const Notification: FC<NotificationProps> = ({ type, message, onClose }) => (
  <div className={`${styles.notification} ${styles[type]}`}>
    <span className={styles.message}>{message}</span>
    {onClose && (
      <button className={styles.closeBtn} onClick={onClose}>×</button>
    )}
  </div>
);
