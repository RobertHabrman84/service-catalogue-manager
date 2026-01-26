import { FC, ReactNode } from 'react';
import styles from './Modal.module.css';

interface ModalHeaderProps { children: ReactNode; onClose?: () => void; }
export const ModalHeader: FC<ModalHeaderProps> = ({ children, onClose }) => (
  <div className={styles.header}>
    <h3>{children}</h3>
    {onClose && <button className={styles.closeBtn} onClick={onClose}>×</button>}
  </div>
);
