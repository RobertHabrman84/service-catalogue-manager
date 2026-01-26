import { FC, useRef, ChangeEvent } from 'react';
import styles from './FileUpload.module.css';

interface FileUploadProps { label?: string; accept?: string; multiple?: boolean; onUpload: (files: FileList) => void; }
export const FileUpload: FC<FileUploadProps> = ({ label, accept, multiple, onUpload }) => {
  const inputRef = useRef<HTMLInputElement>(null);
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => { if (e.target.files) onUpload(e.target.files); };
  return (
    <div className={styles.wrapper}>
      {label && <label className={styles.label}>{label}</label>}
      <div className={styles.dropzone} onClick={() => inputRef.current?.click()}>
        <input ref={inputRef} type="file" accept={accept} multiple={multiple} onChange={handleChange} hidden />
        <p>Click or drag files to upload</p>
      </div>
    </div>
  );
};
