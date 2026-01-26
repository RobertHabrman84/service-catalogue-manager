import { FC, ReactNode } from 'react';
import styles from './Card.module.css';

interface CardHeaderProps { children: ReactNode; }
export const CardHeader: FC<CardHeaderProps> = ({ children }) => (
  <div className={styles.header}>{children}</div>
);
