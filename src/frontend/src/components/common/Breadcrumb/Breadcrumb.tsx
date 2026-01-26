import { FC } from 'react';
import { Link } from 'react-router-dom';
import styles from './Breadcrumb.module.css';

interface BreadcrumbItem { label: string; href?: string; }
interface BreadcrumbProps { items: BreadcrumbItem[]; }

export const Breadcrumb: FC<BreadcrumbProps> = ({ items }) => (
  <nav className={styles.breadcrumb}>
    {items.map((item, index) => (
      <span key={index} className={styles.item}>
        {index > 0 && <span className={styles.separator}>/</span>}
        {item.href ? <Link to={item.href}>{item.label}</Link> : <span>{item.label}</span>}
      </span>
    ))}
  </nav>
);
