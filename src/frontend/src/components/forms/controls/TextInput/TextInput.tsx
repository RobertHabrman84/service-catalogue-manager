import { FC, InputHTMLAttributes, forwardRef } from 'react';
import styles from './TextInput.module.css';

interface TextInputProps extends InputHTMLAttributes<HTMLInputElement> { label?: string; error?: string; }
export const TextInput = forwardRef<HTMLInputElement, TextInputProps>(({ label, error, className, ...props }, ref) => (
  <div className={styles.wrapper}>
    {label && <label className={styles.label}>{label}</label>}
    <input ref={ref} className={`${styles.input} ${error ? styles.error : ''} ${className || ''}`} {...props} />
    {error && <span className={styles.errorMsg}>{error}</span>}
  </div>
));
