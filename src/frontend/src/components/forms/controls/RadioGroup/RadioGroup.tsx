import { FC } from 'react';
import styles from './RadioGroup.module.css';

interface Option { value: string; label: string; }
interface RadioGroupProps { name: string; options: Option[]; value: string; onChange: (value: string) => void; label?: string; }
export const RadioGroup: FC<RadioGroupProps> = ({ name, options, value, onChange, label }) => (
  <fieldset className={styles.wrapper}>
    {label && <legend className={styles.legend}>{label}</legend>}
    {options.map(o => (
      <label key={o.value} className={styles.option}>
        <input type="radio" name={name} value={o.value} checked={value === o.value} onChange={() => onChange(o.value)} />
        {o.label}
      </label>
    ))}
  </fieldset>
);
