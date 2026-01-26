import { FC, ReactNode } from 'react';
import styles from './Table.module.css';

interface TableRowProps { children: ReactNode; onClick?: () => void; }
export const TableRow: FC<TableRowProps> = ({ children, onClick }) => (
  <tr className={`${styles.row} ${onClick ? styles.clickable : ''}`} onClick={onClick}>{children}</tr>
);
