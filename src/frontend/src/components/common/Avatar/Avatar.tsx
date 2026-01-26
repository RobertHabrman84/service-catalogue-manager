import { FC } from 'react';
import styles from './Avatar.module.css';

interface AvatarProps { src?: string; alt?: string; name?: string; size?: 'sm' | 'md' | 'lg'; }

export const Avatar: FC<AvatarProps> = ({ src, alt, name, size = 'md' }) => {
  const initials = name?.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  
  return (
    <div className={`${styles.avatar} ${styles[size]}`}>
      {src ? <img src={src} alt={alt || name} /> : <span>{initials || '?'}</span>}
    </div>
  );
};
