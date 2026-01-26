import { FC, ReactNode } from 'react';
import styles from './Table.module.css';

interface TableCellProps { children: ReactNode; header?: boolean; }
export const TableCell: FC<TableCellProps> = ({ children, header }) => 
  header ? <th className={styles.th}>{children}</th> : <td className={styles.td}>{children}</td>;
