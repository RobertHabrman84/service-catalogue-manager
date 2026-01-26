import { useEffect, useRef, useCallback, RefObject } from 'react';

type Handler = (event: MouseEvent | TouchEvent) => void;

/**
 * Hook that detects clicks outside of a specified element
 * @param handler - The callback function to execute when clicking outside
 * @param enabled - Whether the hook is enabled (default: true)
 * @returns A ref to attach to the element
 */
export function useClickOutside<T extends HTMLElement = HTMLElement>(
  handler: Handler,
  enabled: boolean = true
): RefObject<T> {
  const ref = useRef<T>(null);
  const handlerRef = useRef<Handler>(handler);

  // Update handler ref when handler changes
  useEffect(() => {
    handlerRef.current = handler;
  }, [handler]);

  useEffect(() => {
    if (!enabled) {
      return;
    }

    const listener = (event: MouseEvent | TouchEvent) => {
      const el = ref.current;
      
      // Do nothing if clicking ref's element or descendent elements
      if (!el || el.contains(event.target as Node)) {
        return;
      }

      handlerRef.current(event);
    };

    // Use mousedown and touchstart for earlier detection
    document.addEventListener('mousedown', listener);
    document.addEventListener('touchstart', listener);

    return () => {
      document.removeEventListener('mousedown', listener);
      document.removeEventListener('touchstart', listener);
    };
  }, [enabled]);

  return ref;
}

/**
 * Hook that detects clicks outside of multiple elements
 * @param refs - Array of refs to check against
 * @param handler - The callback function to execute when clicking outside all refs
 * @param enabled - Whether the hook is enabled (default: true)
 */
export function useClickOutsideMultiple(
  refs: RefObject<HTMLElement>[],
  handler: Handler,
  enabled: boolean = true
): void {
  const handlerRef = useRef<Handler>(handler);

  useEffect(() => {
    handlerRef.current = handler;
  }, [handler]);

  useEffect(() => {
    if (!enabled) {
      return;
    }

    const listener = (event: MouseEvent | TouchEvent) => {
      // Check if click is inside any of the refs
      const isInside = refs.some((ref) => {
        const el = ref.current;
        return el && el.contains(event.target as Node);
      });

      if (!isInside) {
        handlerRef.current(event);
      }
    };

    document.addEventListener('mousedown', listener);
    document.addEventListener('touchstart', listener);

    return () => {
      document.removeEventListener('mousedown', listener);
      document.removeEventListener('touchstart', listener);
    };
  }, [refs, enabled]);
}

/**
 * Hook for handling escape key and click outside together
 * Useful for modals and dropdowns
 */
export function useClickOutsideOrEscape<T extends HTMLElement = HTMLElement>(
  handler: () => void,
  enabled: boolean = true
): RefObject<T> {
  const ref = useClickOutside<T>(handler, enabled);

  useEffect(() => {
    if (!enabled) {
      return;
    }

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        handler();
      }
    };

    document.addEventListener('keydown', handleEscape);

    return () => {
      document.removeEventListener('keydown', handleEscape);
    };
  }, [handler, enabled]);

  return ref;
}

/**
 * Creates a click outside handler with callback
 * Alternative API using callback ref pattern
 */
export function useClickOutsideCallback(
  callback: Handler,
  enabled: boolean = true
): (node: HTMLElement | null) => void {
  const callbackRef = useRef<Handler>(callback);
  const nodeRef = useRef<HTMLElement | null>(null);

  useEffect(() => {
    callbackRef.current = callback;
  }, [callback]);

  useEffect(() => {
    if (!enabled || !nodeRef.current) {
      return;
    }

    const listener = (event: MouseEvent | TouchEvent) => {
      if (!nodeRef.current || nodeRef.current.contains(event.target as Node)) {
        return;
      }
      callbackRef.current(event);
    };

    document.addEventListener('mousedown', listener);
    document.addEventListener('touchstart', listener);

    return () => {
      document.removeEventListener('mousedown', listener);
      document.removeEventListener('touchstart', listener);
    };
  }, [enabled]);

  return useCallback((node: HTMLElement | null) => {
    nodeRef.current = node;
  }, []);
}

export default useClickOutside;
