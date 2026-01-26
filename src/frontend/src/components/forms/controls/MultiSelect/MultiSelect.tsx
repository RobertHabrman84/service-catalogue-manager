import { FC, useState } from 'react';
import styles from './MultiSelect.module.css';

interface Option { value: string | number; label: string; }
interface MultiSelectProps { label?: string; options: Option[]; value: (string | number)[]; onChange: (values: (string | number)[]) => void; error?: string; }
export const MultiSelect: FC<MultiSelectProps> = ({ label, options, value, onChange, error }) => {
  const toggle = (v: string | number) => onChange(value.includes(v) ? value.filter(x => x !== v) : [...value, v]);
  return (
    <div className={styles.wrapper}>
      {label && <label className={styles.label}>{label}</label>}
      <div className={styles.options}>
        {options.map(o => (
          <label key={o.value} className={styles.option}>
            <input type="checkbox" checked={value.includes(o.value)} onChange={() => toggle(o.value)} />
            {o.label}
          </label>
        ))}
      </div>
      {error && <span className={styles.errorMsg}>{error}</span>}
    </div>
  );
};
