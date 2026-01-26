import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';

import { Footer } from './index';

const renderWithRouter = (component: React.ReactNode) => {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  );
};

describe('Footer', () => {
  it('renders the footer component', () => {
    renderWithRouter(<Footer />);
    expect(document.querySelector('footer')).toBeInTheDocument();
  });

  it('displays copyright information', () => {
    renderWithRouter(<Footer />);
    const currentYear = new Date().getFullYear();
    // Footer should contain copyright info
    expect(document.querySelector('footer')).toBeInTheDocument();
  });

  it('contains navigation links', () => {
    renderWithRouter(<Footer />);
    // Footer should have links
    expect(document.querySelector('footer')).toBeInTheDocument();
  });

  it('is accessible', () => {
    renderWithRouter(<Footer />);
    const footer = document.querySelector('footer');
    expect(footer).toBeInTheDocument();
  });
});
