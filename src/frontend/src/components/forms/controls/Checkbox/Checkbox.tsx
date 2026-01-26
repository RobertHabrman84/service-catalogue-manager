import { FC, InputHTMLAttributes, forwardRef } from 'react';
import styles from './Checkbox.module.css';

interface CheckboxProps extends InputHTMLAttributes<HTMLInputElement> { label?: string; }
export const Checkbox = forwardRef<HTMLInputElement, CheckboxProps>(({ label, ...props }, ref) => (
  <label className={styles.wrapper}>
    <input ref={ref} type="checkbox" className={styles.checkbox} {...props} />
    {label && <span className={styles.label}>{label}</span>}
  </label>
));
