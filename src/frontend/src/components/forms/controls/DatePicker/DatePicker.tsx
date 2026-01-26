import { FC, InputHTMLAttributes, forwardRef } from 'react';
import styles from './DatePicker.module.css';

interface DatePickerProps extends InputHTMLAttributes<HTMLInputElement> { label?: string; error?: string; }
export const DatePicker = forwardRef<HTMLInputElement, DatePickerProps>(({ label, error, ...props }, ref) => (
  <div className={styles.wrapper}>
    {label && <label className={styles.label}>{label}</label>}
    <input ref={ref} type="date" className={`${styles.input} ${error ? styles.error : ''}`} {...props} />
    {error && <span className={styles.errorMsg}>{error}</span>}
  </div>
));
