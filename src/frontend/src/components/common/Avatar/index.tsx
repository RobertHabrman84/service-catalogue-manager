// Avatar/index.tsx
// Avatar component with image, initials, and status indicator

import React from 'react';
import clsx from 'clsx';

type AvatarSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';
type AvatarStatus = 'online' | 'offline' | 'busy' | 'away';

interface AvatarProps {
  src?: string | null;
  alt?: string;
  name?: string;
  size?: AvatarSize;
  status?: AvatarStatus;
  rounded?: 'full' | 'lg' | 'md';
  className?: string;
  onClick?: () => void;
}

const SIZE_CLASSES: Record<AvatarSize, string> = {
  xs: 'h-6 w-6 text-xs',
  sm: 'h-8 w-8 text-sm',
  md: 'h-10 w-10 text-base',
  lg: 'h-12 w-12 text-lg',
  xl: 'h-16 w-16 text-xl',
  '2xl': 'h-20 w-20 text-2xl',
};

const STATUS_COLORS: Record<AvatarStatus, string> = {
  online: 'bg-green-500',
  offline: 'bg-gray-400',
  busy: 'bg-red-500',
  away: 'bg-yellow-500',
};

const STATUS_SIZE: Record<AvatarSize, string> = {
  xs: 'h-1.5 w-1.5',
  sm: 'h-2 w-2',
  md: 'h-2.5 w-2.5',
  lg: 'h-3 w-3',
  xl: 'h-3.5 w-3.5',
  '2xl': 'h-4 w-4',
};

const ROUNDED_CLASSES = {
  full: 'rounded-full',
  lg: 'rounded-lg',
  md: 'rounded-md',
};

// Generate color based on name
const getColorFromName = (name: string): string => {
  const colors = [
    'bg-red-500',
    'bg-orange-500',
    'bg-amber-500',
    'bg-yellow-500',
    'bg-lime-500',
    'bg-green-500',
    'bg-emerald-500',
    'bg-teal-500',
    'bg-cyan-500',
    'bg-sky-500',
    'bg-blue-500',
    'bg-indigo-500',
    'bg-violet-500',
    'bg-purple-500',
    'bg-fuchsia-500',
    'bg-pink-500',
    'bg-rose-500',
  ];

  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }

  return colors[Math.abs(hash) % colors.length];
};

// Get initials from name
const getInitials = (name: string): string => {
  if (!name) return '?';
  
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) {
    return parts[0].substring(0, 2).toUpperCase();
  }
  
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
};

export const Avatar: React.FC<AvatarProps> = ({
  src,
  alt,
  name,
  size = 'md',
  status,
  rounded = 'full',
  className,
  onClick,
}) => {
  const [imageError, setImageError] = React.useState(false);

  const showImage = src && !imageError;
  const initials = name ? getInitials(name) : '?';
  const bgColor = name ? getColorFromName(name) : 'bg-gray-400';

  return (
    <div
      className={clsx(
        'relative inline-flex items-center justify-center flex-shrink-0',
        SIZE_CLASSES[size],
        ROUNDED_CLASSES[rounded],
        onClick && 'cursor-pointer',
        className
      )}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
    >
      {showImage ? (
        <img
          src={src}
          alt={alt || name || 'Avatar'}
          className={clsx(
            'h-full w-full object-cover',
            ROUNDED_CLASSES[rounded]
          )}
          onError={() => setImageError(true)}
        />
      ) : (
        <div
          className={clsx(
            'h-full w-full flex items-center justify-center font-medium text-white',
            ROUNDED_CLASSES[rounded],
            bgColor
          )}
        >
          {initials}
        </div>
      )}

      {/* Status Indicator */}
      {status && (
        <span
          className={clsx(
            'absolute bottom-0 right-0 block rounded-full ring-2 ring-white',
            STATUS_SIZE[size],
            STATUS_COLORS[status]
          )}
        />
      )}
    </div>
  );
};

// Avatar Group Component
interface AvatarGroupProps {
  avatars: Array<{
    src?: string;
    name?: string;
    alt?: string;
  }>;
  max?: number;
  size?: AvatarSize;
  className?: string;
}

export const AvatarGroup: React.FC<AvatarGroupProps> = ({
  avatars,
  max = 4,
  size = 'md',
  className,
}) => {
  const visibleAvatars = avatars.slice(0, max);
  const remainingCount = avatars.length - max;

  return (
    <div className={clsx('flex -space-x-2', className)}>
      {visibleAvatars.map((avatar, index) => (
        <Avatar
          key={index}
          src={avatar.src}
          name={avatar.name}
          alt={avatar.alt}
          size={size}
          className="ring-2 ring-white"
        />
      ))}
      
      {remainingCount > 0 && (
        <div
          className={clsx(
            'relative inline-flex items-center justify-center flex-shrink-0 rounded-full bg-gray-200 ring-2 ring-white',
            SIZE_CLASSES[size]
          )}
        >
          <span className="text-gray-600 font-medium">
            +{remainingCount}
          </span>
        </div>
      )}
    </div>
  );
};

// Avatar with Name Component
interface AvatarWithNameProps extends AvatarProps {
  subtitle?: string;
  nameClassName?: string;
  subtitleClassName?: string;
}

export const AvatarWithName: React.FC<AvatarWithNameProps> = ({
  name,
  subtitle,
  nameClassName,
  subtitleClassName,
  ...avatarProps
}) => {
  return (
    <div className="flex items-center gap-3">
      <Avatar name={name} {...avatarProps} />
      <div className="flex flex-col min-w-0">
        {name && (
          <span
            className={clsx(
              'text-sm font-medium text-gray-900 truncate',
              nameClassName
            )}
          >
            {name}
          </span>
        )}
        {subtitle && (
          <span
            className={clsx(
              'text-sm text-gray-500 truncate',
              subtitleClassName
            )}
          >
            {subtitle}
          </span>
        )}
      </div>
    </div>
  );
};

export default Avatar;
