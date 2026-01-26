import { FC, ReactNode, useState } from 'react';
import styles from './Tooltip.module.css';

interface TooltipProps { content: string; children: ReactNode; position?: 'top' | 'bottom' | 'left' | 'right'; }

export const Tooltip: FC<TooltipProps> = ({ content, children, position = 'top' }) => {
  const [visible, setVisible] = useState(false);
  
  return (
    <div className={styles.wrapper} onMouseEnter={() => setVisible(true)} onMouseLeave={() => setVisible(false)}>
      {children}
      {visible && <div className={`${styles.tooltip} ${styles[position]}`}>{content}</div>}
    </div>
  );
};
