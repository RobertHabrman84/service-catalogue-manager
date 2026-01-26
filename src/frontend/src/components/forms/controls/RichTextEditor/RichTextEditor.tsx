import { FC, useState } from 'react';
import styles from './RichTextEditor.module.css';

interface RichTextEditorProps { value: string; onChange: (value: string) => void; label?: string; }
export const RichTextEditor: FC<RichTextEditorProps> = ({ value, onChange, label }) => (
  <div className={styles.wrapper}>
    {label && <label className={styles.label}>{label}</label>}
    <div className={styles.toolbar}>
      <button type="button" onClick={() => document.execCommand('bold')}>B</button>
      <button type="button" onClick={() => document.execCommand('italic')}>I</button>
      <button type="button" onClick={() => document.execCommand('underline')}>U</button>
    </div>
    <div className={styles.editor} contentEditable dangerouslySetInnerHTML={{ __html: value }} onInput={(e) => onChange(e.currentTarget.innerHTML)} />
  </div>
);
