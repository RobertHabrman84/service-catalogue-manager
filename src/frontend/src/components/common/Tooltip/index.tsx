// Tooltip/index.tsx
// Tooltip component using Tippy.js patterns

import React, { useState, useRef, useEffect } from 'react';
import clsx from 'clsx';

type TooltipPlacement = 'top' | 'bottom' | 'left' | 'right';
type TooltipVariant = 'dark' | 'light' | 'info' | 'success' | 'warning' | 'error';

interface TooltipProps {
  content: React.ReactNode;
  children: React.ReactElement;
  placement?: TooltipPlacement;
  variant?: TooltipVariant;
  delay?: number;
  disabled?: boolean;
  className?: string;
  arrow?: boolean;
}

const VARIANT_CLASSES: Record<TooltipVariant, string> = {
  dark: 'bg-gray-900 text-white',
  light: 'bg-white text-gray-900 shadow-lg border border-gray-200',
  info: 'bg-blue-600 text-white',
  success: 'bg-green-600 text-white',
  warning: 'bg-amber-500 text-white',
  error: 'bg-red-600 text-white',
};

const ARROW_CLASSES: Record<TooltipPlacement, Record<TooltipVariant, string>> = {
  top: {
    dark: 'border-t-gray-900',
    light: 'border-t-white',
    info: 'border-t-blue-600',
    success: 'border-t-green-600',
    warning: 'border-t-amber-500',
    error: 'border-t-red-600',
  },
  bottom: {
    dark: 'border-b-gray-900',
    light: 'border-b-white',
    info: 'border-b-blue-600',
    success: 'border-b-green-600',
    warning: 'border-b-amber-500',
    error: 'border-b-red-600',
  },
  left: {
    dark: 'border-l-gray-900',
    light: 'border-l-white',
    info: 'border-l-blue-600',
    success: 'border-l-green-600',
    warning: 'border-l-amber-500',
    error: 'border-l-red-600',
  },
  right: {
    dark: 'border-r-gray-900',
    light: 'border-r-white',
    info: 'border-r-blue-600',
    success: 'border-r-green-600',
    warning: 'border-r-amber-500',
    error: 'border-r-red-600',
  },
};

export const Tooltip: React.FC<TooltipProps> = ({
  content,
  children,
  placement = 'top',
  variant = 'dark',
  delay = 0,
  disabled = false,
  className,
  arrow = true,
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [position, setPosition] = useState({ top: 0, left: 0 });
  const triggerRef = useRef<HTMLDivElement>(null);
  const tooltipRef = useRef<HTMLDivElement>(null);
  const timeoutRef = useRef<NodeJS.Timeout>();

  const calculatePosition = () => {
    if (!triggerRef.current || !tooltipRef.current) return;

    const triggerRect = triggerRef.current.getBoundingClientRect();
    const tooltipRect = tooltipRef.current.getBoundingClientRect();
    const gap = 8;

    let top = 0;
    let left = 0;

    switch (placement) {
      case 'top':
        top = triggerRect.top - tooltipRect.height - gap;
        left = triggerRect.left + (triggerRect.width - tooltipRect.width) / 2;
        break;
      case 'bottom':
        top = triggerRect.bottom + gap;
        left = triggerRect.left + (triggerRect.width - tooltipRect.width) / 2;
        break;
      case 'left':
        top = triggerRect.top + (triggerRect.height - tooltipRect.height) / 2;
        left = triggerRect.left - tooltipRect.width - gap;
        break;
      case 'right':
        top = triggerRect.top + (triggerRect.height - tooltipRect.height) / 2;
        left = triggerRect.right + gap;
        break;
    }

    // Boundary checks
    const padding = 8;
    if (left < padding) left = padding;
    if (left + tooltipRect.width > window.innerWidth - padding) {
      left = window.innerWidth - tooltipRect.width - padding;
    }
    if (top < padding) top = padding;
    if (top + tooltipRect.height > window.innerHeight - padding) {
      top = window.innerHeight - tooltipRect.height - padding;
    }

    setPosition({ top, left });
  };

  useEffect(() => {
    if (isVisible) {
      calculatePosition();
      window.addEventListener('scroll', calculatePosition, true);
      window.addEventListener('resize', calculatePosition);
    }
    return () => {
      window.removeEventListener('scroll', calculatePosition, true);
      window.removeEventListener('resize', calculatePosition);
    };
  }, [isVisible]);

  const showTooltip = () => {
    if (disabled) return;
    timeoutRef.current = setTimeout(() => setIsVisible(true), delay);
  };

  const hideTooltip = () => {
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    setIsVisible(false);
  };

  const getArrowStyles = () => {
    const base = 'absolute w-0 h-0 border-solid border-transparent';
    switch (placement) {
      case 'top':
        return clsx(base, 'bottom-[-6px] left-1/2 -translate-x-1/2 border-t-[6px] border-x-[6px]', ARROW_CLASSES.top[variant]);
      case 'bottom':
        return clsx(base, 'top-[-6px] left-1/2 -translate-x-1/2 border-b-[6px] border-x-[6px]', ARROW_CLASSES.bottom[variant]);
      case 'left':
        return clsx(base, 'right-[-6px] top-1/2 -translate-y-1/2 border-l-[6px] border-y-[6px]', ARROW_CLASSES.left[variant]);
      case 'right':
        return clsx(base, 'left-[-6px] top-1/2 -translate-y-1/2 border-r-[6px] border-y-[6px]', ARROW_CLASSES.right[variant]);
    }
  };

  return (
    <>
      <div
        ref={triggerRef}
        className="inline-block"
        onMouseEnter={showTooltip}
        onMouseLeave={hideTooltip}
        onFocus={showTooltip}
        onBlur={hideTooltip}
      >
        {children}
      </div>
      
      {isVisible && (
        <div
          ref={tooltipRef}
          role="tooltip"
          className={clsx(
            'fixed z-50 px-3 py-2 text-sm rounded-md max-w-xs',
            'animate-in fade-in-0 zoom-in-95 duration-150',
            VARIANT_CLASSES[variant],
            className
          )}
          style={{ top: position.top, left: position.left }}
        >
          {content}
          {arrow && <div className={getArrowStyles()} />}
        </div>
      )}
    </>
  );
};

// Simple text tooltip
interface SimpleTooltipProps {
  text: string;
  children: React.ReactElement;
  placement?: TooltipPlacement;
}

export const SimpleTooltip: React.FC<SimpleTooltipProps> = ({ text, children, placement = 'top' }) => (
  <Tooltip content={text} placement={placement}>{children}</Tooltip>
);

// Info tooltip with icon
interface InfoTooltipProps {
  content: React.ReactNode;
  placement?: TooltipPlacement;
  iconClassName?: string;
}

export const InfoTooltip: React.FC<InfoTooltipProps> = ({ content, placement = 'top', iconClassName }) => (
  <Tooltip content={content} placement={placement} variant="info">
    <button type="button" className={clsx('text-gray-400 hover:text-gray-600 focus:outline-none', iconClassName)}>
      <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
        <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
      </svg>
    </button>
  </Tooltip>
);

export default Tooltip;
