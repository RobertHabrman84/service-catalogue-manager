import { FC, ReactNode } from 'react';
import styles from './Card.module.css';

interface CardBodyProps { children: ReactNode; }
export const CardBody: FC<CardBodyProps> = ({ children }) => (
  <div className={styles.body}>{children}</div>
);
