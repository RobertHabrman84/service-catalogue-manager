import { FC, InputHTMLAttributes, forwardRef } from 'react';
import styles from './NumberInput.module.css';

interface NumberInputProps extends InputHTMLAttributes<HTMLInputElement> { label?: string; error?: string; }
export const NumberInput = forwardRef<HTMLInputElement, NumberInputProps>(({ label, error, ...props }, ref) => (
  <div className={styles.wrapper}>
    {label && <label className={styles.label}>{label}</label>}
    <input ref={ref} type="number" className={`${styles.input} ${error ? styles.error : ''}`} {...props} />
    {error && <span className={styles.errorMsg}>{error}</span>}
  </div>
));
