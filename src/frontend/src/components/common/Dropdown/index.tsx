// Dropdown/index.tsx
// Dropdown menu component with keyboard navigation

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { ChevronDownIcon } from '@heroicons/react/24/outline';
import clsx from 'clsx';

export interface DropdownItem {
  id: string;
  label: string;
  icon?: React.ReactNode;
  disabled?: boolean;
  danger?: boolean;
  divider?: boolean;
  onClick?: () => void;
}

interface DropdownProps {
  trigger: React.ReactNode;
  items: DropdownItem[];
  align?: 'left' | 'right';
  width?: 'auto' | 'sm' | 'md' | 'lg' | 'full';
  className?: string;
  menuClassName?: string;
  disabled?: boolean;
}

const WIDTH_CLASSES = {
  auto: 'w-auto min-w-[160px]',
  sm: 'w-40',
  md: 'w-56',
  lg: 'w-72',
  full: 'w-full',
};

export const Dropdown: React.FC<DropdownProps> = ({
  trigger,
  items,
  align = 'left',
  width = 'auto',
  className,
  menuClassName,
  disabled = false,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [focusedIndex, setFocusedIndex] = useState(-1);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  // Close on outside click
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Close on escape
  useEffect(() => {
    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      return () => document.removeEventListener('keydown', handleEscape);
    }
  }, [isOpen]);

  // Keyboard navigation
  const handleKeyDown = useCallback(
    (event: React.KeyboardEvent) => {
      if (!isOpen) {
        if (event.key === 'Enter' || event.key === ' ' || event.key === 'ArrowDown') {
          event.preventDefault();
          setIsOpen(true);
          setFocusedIndex(0);
        }
        return;
      }

      const selectableItems = items.filter((item) => !item.divider && !item.disabled);

      switch (event.key) {
        case 'ArrowDown':
          event.preventDefault();
          setFocusedIndex((prev) =>
            prev < selectableItems.length - 1 ? prev + 1 : 0
          );
          break;
        case 'ArrowUp':
          event.preventDefault();
          setFocusedIndex((prev) =>
            prev > 0 ? prev - 1 : selectableItems.length - 1
          );
          break;
        case 'Enter':
        case ' ':
          event.preventDefault();
          if (focusedIndex >= 0 && selectableItems[focusedIndex]) {
            selectableItems[focusedIndex].onClick?.();
            setIsOpen(false);
          }
          break;
        case 'Tab':
          setIsOpen(false);
          break;
      }
    },
    [isOpen, items, focusedIndex]
  );

  const handleItemClick = (item: DropdownItem) => {
    if (item.disabled) return;
    item.onClick?.();
    setIsOpen(false);
  };

  const toggleDropdown = () => {
    if (!disabled) {
      setIsOpen(!isOpen);
      if (!isOpen) {
        setFocusedIndex(-1);
      }
    }
  };

  return (
    <div
      ref={dropdownRef}
      className={clsx('relative inline-block', className)}
      onKeyDown={handleKeyDown}
    >
      {/* Trigger */}
      <div
        role="button"
        tabIndex={disabled ? -1 : 0}
        aria-haspopup="true"
        aria-expanded={isOpen}
        onClick={toggleDropdown}
        className={clsx(
          'cursor-pointer',
          disabled && 'opacity-50 cursor-not-allowed'
        )}
      >
        {trigger}
      </div>

      {/* Menu */}
      {isOpen && (
        <div
          ref={menuRef}
          role="menu"
          className={clsx(
            'absolute z-50 mt-2 rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none',
            WIDTH_CLASSES[width],
            align === 'right' ? 'right-0' : 'left-0',
            menuClassName
          )}
        >
          <div className="py-1">
            {items.map((item, index) => {
              if (item.divider) {
                return (
                  <div
                    key={`divider-${index}`}
                    className="my-1 border-t border-gray-100"
                  />
                );
              }

              const itemIndex = items
                .slice(0, index)
                .filter((i) => !i.divider && !i.disabled).length;

              return (
                <button
                  key={item.id}
                  role="menuitem"
                  disabled={item.disabled}
                  onClick={() => handleItemClick(item)}
                  className={clsx(
                    'w-full flex items-center gap-2 px-4 py-2 text-sm text-left transition-colors',
                    item.disabled
                      ? 'text-gray-400 cursor-not-allowed'
                      : item.danger
                      ? 'text-red-600 hover:bg-red-50'
                      : 'text-gray-700 hover:bg-gray-100',
                    focusedIndex === itemIndex && !item.disabled && 'bg-gray-100'
                  )}
                >
                  {item.icon && (
                    <span className="flex-shrink-0 w-5 h-5">{item.icon}</span>
                  )}
                  <span className="flex-1">{item.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};

// Simple button dropdown variant
interface DropdownButtonProps extends Omit<DropdownProps, 'trigger'> {
  label: string;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  leftIcon?: React.ReactNode;
}

const BUTTON_VARIANTS = {
  primary: 'bg-blue-600 text-white hover:bg-blue-700 border-transparent',
  secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 border-transparent',
  outline: 'bg-white text-gray-700 hover:bg-gray-50 border-gray-300',
  ghost: 'bg-transparent text-gray-700 hover:bg-gray-100 border-transparent',
};

const BUTTON_SIZES = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-sm',
  lg: 'px-5 py-2.5 text-base',
};

export const DropdownButton: React.FC<DropdownButtonProps> = ({
  label,
  variant = 'outline',
  size = 'md',
  leftIcon,
  ...props
}) => {
  const trigger = (
    <button
      type="button"
      className={clsx(
        'inline-flex items-center gap-2 rounded-md border font-medium shadow-sm transition-colors',
        BUTTON_VARIANTS[variant],
        BUTTON_SIZES[size]
      )}
    >
      {leftIcon}
      <span>{label}</span>
      <ChevronDownIcon className="h-4 w-4" />
    </button>
  );

  return <Dropdown trigger={trigger} {...props} />;
};

export default Dropdown;
