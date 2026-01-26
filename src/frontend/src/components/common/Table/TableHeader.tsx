import { FC, ReactNode } from 'react';
import styles from './Table.module.css';

interface TableHeaderProps { children: ReactNode; }
export const TableHeader: FC<TableHeaderProps> = ({ children }) => (
  <thead className={styles.header}><tr>{children}</tr></thead>
);
