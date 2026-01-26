import { FC, SelectHTMLAttributes, forwardRef } from 'react';
import styles from './SelectInput.module.css';

interface Option { value: string | number; label: string; }
interface SelectInputProps extends SelectHTMLAttributes<HTMLSelectElement> { label?: string; error?: string; options: Option[]; }
export const SelectInput = forwardRef<HTMLSelectElement, SelectInputProps>(({ label, error, options, className, ...props }, ref) => (
  <div className={styles.wrapper}>
    {label && <label className={styles.label}>{label}</label>}
    <select ref={ref} className={`${styles.select} ${error ? styles.error : ''} ${className || ''}`} {...props}>
      <option value="">Select...</option>
      {options.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
    </select>
    {error && <span className={styles.errorMsg}>{error}</span>}
  </div>
));
