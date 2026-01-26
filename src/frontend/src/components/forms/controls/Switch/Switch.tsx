import { FC, InputHTMLAttributes, forwardRef } from 'react';
import styles from './Switch.module.css';

interface SwitchProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> { label?: string; }
export const Switch = forwardRef<HTMLInputElement, SwitchProps>(({ label, ...props }, ref) => (
  <label className={styles.wrapper}>
    <input ref={ref} type="checkbox" className={styles.input} {...props} />
    <span className={styles.slider}></span>
    {label && <span className={styles.label}>{label}</span>}
  </label>
));
