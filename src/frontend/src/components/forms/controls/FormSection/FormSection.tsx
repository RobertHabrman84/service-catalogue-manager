import { FC, ReactNode } from 'react';
import styles from './FormSection.module.css';

interface FormSectionProps { title?: string; description?: string; children: ReactNode; }
export const FormSection: FC<FormSectionProps> = ({ title, description, children }) => (
  <section className={styles.section}>
    {title && <h3 className={styles.title}>{title}</h3>}
    {description && <p className={styles.description}>{description}</p>}
    <div className={styles.content}>{children}</div>
  </section>
);
