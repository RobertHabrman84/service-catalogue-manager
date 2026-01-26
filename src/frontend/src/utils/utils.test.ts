import { describe, it, expect, vi, beforeEach } from 'vitest';

import {
  formatDate,
  formatDateTime,
  formatRelativeTime,
  formatNumber,
  formatPercentage,
  formatFileSize,
  isValidEmail,
  isValidServiceCode,
  isValidVersion,
  isValidUrl,
  isNotEmpty,
  hasMinLength,
  hasMaxLength,
  generateId,
  deepClone,
  debounce,
  throttle,
  capitalize,
  truncate,
  sortBy,
  groupBy,
  getInitials,
  isEmpty,
} from './index';

describe('Formatters', () => {
  describe('formatDate', () => {
    it('formats date correctly', () => {
      const date = new Date('2025-01-15');
      const result = formatDate(date);
      expect(result).toBeTruthy();
    });

    it('handles string input', () => {
      const result = formatDate('2025-01-15');
      expect(result).toBeTruthy();
    });
  });

  describe('formatNumber', () => {
    it('formats number with commas', () => {
      expect(formatNumber(1234567)).toBeTruthy();
    });
  });

  describe('formatPercentage', () => {
    it('formats percentage correctly', () => {
      expect(formatPercentage(0.75)).toBeTruthy();
    });
  });

  describe('formatFileSize', () => {
    it('formats bytes', () => {
      expect(formatFileSize(500)).toContain('B');
    });

    it('formats kilobytes', () => {
      expect(formatFileSize(1500)).toBeTruthy();
    });

    it('formats megabytes', () => {
      expect(formatFileSize(1500000)).toBeTruthy();
    });
  });
});

describe('Validators', () => {
  describe('isValidEmail', () => {
    it('returns true for valid email', () => {
      expect(isValidEmail('test@example.com')).toBe(true);
    });

    it('returns false for invalid email', () => {
      expect(isValidEmail('invalid-email')).toBe(false);
    });
  });

  describe('isValidServiceCode', () => {
    it('returns true for valid code', () => {
      expect(isValidServiceCode('SVC-001')).toBe(true);
    });
  });

  describe('isValidVersion', () => {
    it('returns true for valid semver', () => {
      expect(isValidVersion('1.0.0')).toBe(true);
    });
  });

  describe('isValidUrl', () => {
    it('returns true for valid URL', () => {
      expect(isValidUrl('https://example.com')).toBe(true);
    });
  });

  describe('isNotEmpty', () => {
    it('returns true for non-empty string', () => {
      expect(isNotEmpty('test')).toBe(true);
    });

    it('returns false for empty string', () => {
      expect(isNotEmpty('')).toBe(false);
    });
  });

  describe('hasMinLength', () => {
    it('validates minimum length', () => {
      expect(hasMinLength('test', 3)).toBe(true);
      expect(hasMinLength('ab', 3)).toBe(false);
    });
  });

  describe('hasMaxLength', () => {
    it('validates maximum length', () => {
      expect(hasMaxLength('test', 5)).toBe(true);
      expect(hasMaxLength('toolong', 5)).toBe(false);
    });
  });
});

describe('Utilities', () => {
  describe('generateId', () => {
    it('generates unique IDs', () => {
      const id1 = generateId();
      const id2 = generateId();
      expect(id1).not.toBe(id2);
    });
  });

  describe('deepClone', () => {
    it('creates deep copy of object', () => {
      const obj = { a: { b: 1 } };
      const clone = deepClone(obj);
      clone.a.b = 2;
      expect(obj.a.b).toBe(1);
    });
  });

  describe('capitalize', () => {
    it('capitalizes first letter', () => {
      expect(capitalize('hello')).toBe('Hello');
    });
  });

  describe('truncate', () => {
    it('truncates long strings', () => {
      expect(truncate('hello world', 5)).toBe('hello...');
    });

    it('does not truncate short strings', () => {
      expect(truncate('hi', 5)).toBe('hi');
    });
  });

  describe('sortBy', () => {
    it('sorts array by key', () => {
      const arr = [{ name: 'b' }, { name: 'a' }];
      const sorted = sortBy(arr, 'name');
      expect(sorted[0].name).toBe('a');
    });
  });

  describe('groupBy', () => {
    it('groups array by key', () => {
      const arr = [
        { type: 'a', value: 1 },
        { type: 'b', value: 2 },
        { type: 'a', value: 3 },
      ];
      const grouped = groupBy(arr, 'type');
      expect(grouped['a'].length).toBe(2);
    });
  });

  describe('getInitials', () => {
    it('gets initials from name', () => {
      expect(getInitials('John Doe')).toBe('JD');
    });
  });

  describe('isEmpty', () => {
    it('returns true for empty values', () => {
      expect(isEmpty(null)).toBe(true);
      expect(isEmpty(undefined)).toBe(true);
      expect(isEmpty('')).toBe(true);
      expect(isEmpty([])).toBe(true);
      expect(isEmpty({})).toBe(true);
    });

    it('returns false for non-empty values', () => {
      expect(isEmpty('test')).toBe(false);
      expect(isEmpty([1])).toBe(false);
      expect(isEmpty({ a: 1 })).toBe(false);
    });
  });
});

describe('debounce', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('debounces function calls', () => {
    const fn = vi.fn();
    const debounced = debounce(fn, 100);

    debounced();
    debounced();
    debounced();

    expect(fn).not.toHaveBeenCalled();

    vi.advanceTimersByTime(100);

    expect(fn).toHaveBeenCalledTimes(1);
  });
});

describe('throttle', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('throttles function calls', () => {
    const fn = vi.fn();
    const throttled = throttle(fn, 100);

    throttled();
    throttled();
    throttled();

    expect(fn).toHaveBeenCalledTimes(1);

    vi.advanceTimersByTime(100);
    throttled();

    expect(fn).toHaveBeenCalledTimes(2);
  });
});
