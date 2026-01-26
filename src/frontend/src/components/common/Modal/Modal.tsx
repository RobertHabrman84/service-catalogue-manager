import { FC, ReactNode, useEffect } from 'react';
import styles from './Modal.module.css';

interface ModalProps { isOpen: boolean; onClose: () => void; children: ReactNode; size?: 'sm' | 'md' | 'lg'; }
export const Modal: FC<ModalProps> = ({ isOpen, onClose, children, size = 'md' }) => {
  useEffect(() => {
    if (isOpen) document.body.style.overflow = 'hidden';
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);
  
  if (!isOpen) return null;
  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={`${styles.modal} ${styles[size]}`} onClick={e => e.stopPropagation()}>
        {children}
      </div>
    </div>
  );
};
