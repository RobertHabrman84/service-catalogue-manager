import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, act, waitFor } from '@testing-library/react';

import {
  useDebounce,
  useLocalStorage,
  usePagination,
} from './index';

describe('useDebounce', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('returns initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('test', 500));
    expect(result.current).toBe('test');
  });

  it('debounces value changes', async () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'updated' });
    expect(result.current).toBe('initial');

    act(() => {
      vi.advanceTimersByTime(500);
    });

    expect(result.current).toBe('updated');
  });
});

describe('useLocalStorage', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('returns initial value when no stored value', () => {
    const { result } = renderHook(() => useLocalStorage('test-key', 'default'));
    expect(result.current[0]).toBe('default');
  });

  it('stores and retrieves values', () => {
    const { result } = renderHook(() => useLocalStorage('test-key', 'default'));
    
    act(() => {
      result.current[1]('new value');
    });

    expect(result.current[0]).toBe('new value');
  });
});

describe('usePagination', () => {
  it('initializes with default values', () => {
    const { result } = renderHook(() => usePagination({ totalCount: 100 }));
    
    expect(result.current.page).toBe(1);
    expect(result.current.pageSize).toBe(20);
    expect(result.current.totalCount).toBe(100);
  });

  it('calculates total pages correctly', () => {
    const { result } = renderHook(() => usePagination({ totalCount: 100, pageSize: 10 }));
    
    expect(result.current.totalPages).toBe(10);
  });

  it('handles next page', () => {
    const { result } = renderHook(() => usePagination({ totalCount: 100 }));
    
    act(() => {
      result.current.nextPage();
    });

    expect(result.current.page).toBe(2);
  });

  it('handles previous page', () => {
    const { result } = renderHook(() => usePagination({ totalCount: 100, initialPage: 3 }));
    
    act(() => {
      result.current.prevPage();
    });

    expect(result.current.page).toBe(2);
  });

  it('does not go below page 1', () => {
    const { result } = renderHook(() => usePagination({ totalCount: 100 }));
    
    act(() => {
      result.current.prevPage();
    });

    expect(result.current.page).toBe(1);
  });
});
