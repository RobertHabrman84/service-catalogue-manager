// ServiceCatalogForm/LicensesSection.test.tsx
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { FormProvider, useForm } from 'react-hook-form';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { LicensesSection } from './LicensesSection';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

const Wrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const methods = useForm({
    defaultValues: {
      licenses: [],
    },
  });

  return (
    <QueryClientProvider client={queryClient}>
      <FormProvider {...methods}>{children}</FormProvider>
    </QueryClientProvider>
  );
};

describe('LicensesSection', () => {
  it('renders correctly', () => {
    render(
      <Wrapper>
        <LicensesSection />
      </Wrapper>
    );
    
    expect(screen.getByText('Licenses')).toBeInTheDocument();
  });
});
