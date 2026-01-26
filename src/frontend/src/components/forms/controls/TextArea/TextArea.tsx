import { FC, TextareaHTMLAttributes, forwardRef } from 'react';
import styles from './TextArea.module.css';

interface TextAreaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> { label?: string; error?: string; }
export const TextArea = forwardRef<HTMLTextAreaElement, TextAreaProps>(({ label, error, className, ...props }, ref) => (
  <div className={styles.wrapper}>
    {label && <label className={styles.label}>{label}</label>}
    <textarea ref={ref} className={`${styles.textarea} ${error ? styles.error : ''} ${className || ''}`} {...props} />
    {error && <span className={styles.errorMsg}>{error}</span>}
  </div>
));
