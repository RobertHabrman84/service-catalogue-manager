import { FC } from 'react';
import styles from './LoadingOverlay.module.css';

interface LoadingOverlayProps {
  message?: string;
}

export const LoadingOverlay: FC<LoadingOverlayProps> = ({ message = 'Loading...' }) => {
  return (
    <div className={styles.overlay}>
      <div className={styles.spinner}></div>
      <p>{message}</p>
    </div>
  );
};
