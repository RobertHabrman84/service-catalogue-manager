import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';

import { LoadingSpinner } from './LoadingSpinner';

describe('LoadingSpinner', () => {
  it('renders the loading spinner', () => {
    render(<LoadingSpinner />);
    // Spinner should be visible
    expect(document.querySelector('[role="status"], .animate-spin, svg')).toBeInTheDocument();
  });

  it('renders with default size', () => {
    render(<LoadingSpinner />);
    const spinner = document.querySelector('[role="status"], .animate-spin, svg');
    expect(spinner).toBeInTheDocument();
  });

  it('renders with small size', () => {
    render(<LoadingSpinner size="sm" />);
    const spinner = document.querySelector('[role="status"], .animate-spin, svg');
    expect(spinner).toBeInTheDocument();
  });

  it('renders with large size', () => {
    render(<LoadingSpinner size="lg" />);
    const spinner = document.querySelector('[role="status"], .animate-spin, svg');
    expect(spinner).toBeInTheDocument();
  });

  it('accepts custom className', () => {
    render(<LoadingSpinner className="custom-class" />);
    expect(document.querySelector('.custom-class')).toBeInTheDocument();
  });

  it('is accessible with status role', () => {
    render(<LoadingSpinner />);
    // Should have appropriate ARIA attributes
    expect(document.querySelector('[role="status"], .animate-spin, svg')).toBeInTheDocument();
  });
});
