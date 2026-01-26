// SearchInput/index.tsx
// Search input component with debounce and clear functionality

import React, { useState, useEffect, useCallback, forwardRef } from 'react';
import { MagnifyingGlassIcon, XMarkIcon } from '@heroicons/react/24/outline';
import clsx from 'clsx';

interface SearchInputProps {
  value?: string;
  onChange?: (value: string) => void;
  onSearch?: (value: string) => void;
  placeholder?: string;
  debounceMs?: number;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
  autoFocus?: boolean;
  disabled?: boolean;
  showClearButton?: boolean;
  isLoading?: boolean;
}

const SIZE_CLASSES = {
  sm: 'h-8 text-sm pl-8 pr-8',
  md: 'h-10 text-sm pl-10 pr-10',
  lg: 'h-12 text-base pl-12 pr-12',
};

const ICON_SIZE_CLASSES = {
  sm: 'h-4 w-4',
  md: 'h-5 w-5',
  lg: 'h-6 w-6',
};

const ICON_POSITION_CLASSES = {
  sm: 'left-2',
  md: 'left-3',
  lg: 'left-4',
};

const CLEAR_POSITION_CLASSES = {
  sm: 'right-2',
  md: 'right-3',
  lg: 'right-4',
};

export const SearchInput = forwardRef<HTMLInputElement, SearchInputProps>(
  (
    {
      value: controlledValue,
      onChange,
      onSearch,
      placeholder = 'Search...',
      debounceMs = 300,
      size = 'md',
      className,
      autoFocus = false,
      disabled = false,
      showClearButton = true,
      isLoading = false,
    },
    ref
  ) => {
    const [internalValue, setInternalValue] = useState(controlledValue ?? '');
    const isControlled = controlledValue !== undefined;
    const currentValue = isControlled ? controlledValue : internalValue;

    // Debounced search
    useEffect(() => {
      if (!onSearch) return;

      const timer = setTimeout(() => {
        onSearch(currentValue);
      }, debounceMs);

      return () => clearTimeout(timer);
    }, [currentValue, debounceMs, onSearch]);

    const handleChange = useCallback(
      (e: React.ChangeEvent<HTMLInputElement>) => {
        const newValue = e.target.value;
        if (!isControlled) {
          setInternalValue(newValue);
        }
        onChange?.(newValue);
      },
      [isControlled, onChange]
    );

    const handleClear = useCallback(() => {
      if (!isControlled) {
        setInternalValue('');
      }
      onChange?.('');
      onSearch?.('');
    }, [isControlled, onChange, onSearch]);

    const handleKeyDown = useCallback(
      (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === 'Escape') {
          handleClear();
        } else if (e.key === 'Enter') {
          onSearch?.(currentValue);
        }
      },
      [currentValue, handleClear, onSearch]
    );

    return (
      <div className={clsx('relative', className)}>
        {/* Search Icon */}
        <div
          className={clsx(
            'absolute inset-y-0 flex items-center pointer-events-none',
            ICON_POSITION_CLASSES[size]
          )}
        >
          {isLoading ? (
            <svg
              className={clsx('animate-spin text-gray-400', ICON_SIZE_CLASSES[size])}
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              />
            </svg>
          ) : (
            <MagnifyingGlassIcon
              className={clsx('text-gray-400', ICON_SIZE_CLASSES[size])}
            />
          )}
        </div>

        {/* Input */}
        <input
          ref={ref}
          type="text"
          value={currentValue}
          onChange={handleChange}
          onKeyDown={handleKeyDown}
          placeholder={placeholder}
          autoFocus={autoFocus}
          disabled={disabled}
          className={clsx(
            'block w-full rounded-lg border border-gray-300 bg-white',
            'placeholder-gray-400 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-opacity-20',
            'disabled:bg-gray-100 disabled:cursor-not-allowed',
            'transition-colors',
            SIZE_CLASSES[size]
          )}
        />

        {/* Clear Button */}
        {showClearButton && currentValue && !disabled && (
          <button
            type="button"
            onClick={handleClear}
            className={clsx(
              'absolute inset-y-0 flex items-center',
              'text-gray-400 hover:text-gray-600 transition-colors',
              CLEAR_POSITION_CLASSES[size]
            )}
          >
            <XMarkIcon className={ICON_SIZE_CLASSES[size]} />
          </button>
        )}
      </div>
    );
  }
);

SearchInput.displayName = 'SearchInput';

// Search with suggestions
interface SearchWithSuggestionsProps extends SearchInputProps {
  suggestions?: string[];
  onSuggestionClick?: (suggestion: string) => void;
  showSuggestions?: boolean;
}

export const SearchWithSuggestions: React.FC<SearchWithSuggestionsProps> = ({
  suggestions = [],
  onSuggestionClick,
  showSuggestions = true,
  ...props
}) => {
  const [isFocused, setIsFocused] = useState(false);
  const showDropdown = showSuggestions && isFocused && suggestions.length > 0;

  return (
    <div className="relative">
      <SearchInput
        {...props}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setTimeout(() => setIsFocused(false), 200)}
      />
      
      {showDropdown && (
        <div className="absolute z-10 w-full mt-1 bg-white rounded-lg shadow-lg border border-gray-200 py-1 max-h-60 overflow-auto">
          {suggestions.map((suggestion, index) => (
            <button
              key={index}
              type="button"
              onClick={() => {
                onSuggestionClick?.(suggestion);
                props.onChange?.(suggestion);
              }}
              className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100 focus:bg-gray-100 focus:outline-none"
            >
              {suggestion}
            </button>
          ))}
        </div>
      )}
    </div>
  );
};

// Hook for search state management
export const useSearch = (initialValue = '') => {
  const [query, setQuery] = useState(initialValue);
  const [debouncedQuery, setDebouncedQuery] = useState(initialValue);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(query);
    }, 300);

    return () => clearTimeout(timer);
  }, [query]);

  const clear = useCallback(() => {
    setQuery('');
    setDebouncedQuery('');
  }, []);

  return {
    query,
    setQuery,
    debouncedQuery,
    clear,
    isSearching: query !== debouncedQuery,
  };
};

export default SearchInput;
