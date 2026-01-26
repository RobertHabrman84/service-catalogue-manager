import { FC, ReactNode } from 'react';
import styles from './Modal.module.css';

interface ModalFooterProps { children: ReactNode; }
export const ModalFooter: FC<ModalFooterProps> = ({ children }) => (
  <div className={styles.footer}>{children}</div>
);
