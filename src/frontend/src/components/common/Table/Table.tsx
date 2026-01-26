import { FC, ReactNode } from 'react';
import styles from './Table.module.css';

interface TableProps { children: ReactNode; className?: string; }
export const Table: FC<TableProps> = ({ children, className }) => (
  <table className={`${styles.table} ${className || ''}`}>{children}</table>
);
