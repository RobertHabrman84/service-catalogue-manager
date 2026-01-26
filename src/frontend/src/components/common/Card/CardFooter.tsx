import { FC, ReactNode } from 'react';
import styles from './Card.module.css';

interface CardFooterProps { children: ReactNode; }
export const CardFooter: FC<CardFooterProps> = ({ children }) => (
  <div className={styles.footer}>{children}</div>
);
