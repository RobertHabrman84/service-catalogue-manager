import { FC, ReactNode } from 'react';
import styles from './Dropdown.module.css';

interface DropdownItemProps { children: ReactNode; onClick?: () => void; disabled?: boolean; }
export const DropdownItem: FC<DropdownItemProps> = ({ children, onClick, disabled }) => (
  <button className={styles.item} onClick={onClick} disabled={disabled}>{children}</button>
);
