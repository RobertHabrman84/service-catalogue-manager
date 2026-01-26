import { FC, InputHTMLAttributes, forwardRef } from 'react';
import styles from './RadioGroup.module.css';

interface RadioButtonProps extends InputHTMLAttributes<HTMLInputElement> { label: string; }
export const RadioButton = forwardRef<HTMLInputElement, RadioButtonProps>(({ label, ...props }, ref) => (
  <label className={styles.option}><input ref={ref} type="radio" {...props} />{label}</label>
));
