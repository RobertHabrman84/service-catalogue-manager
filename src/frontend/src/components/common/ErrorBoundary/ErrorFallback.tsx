import { FC } from 'react';

interface ErrorFallbackProps {
  error: Error | null;
  onReset: () => void;
}

export const ErrorFallback: FC<ErrorFallbackProps> = ({ error, onReset }) => (
  <div role="alert" style={{ padding: '20px', textAlign: 'center' }}>
    <h2>Something went wrong</h2>
    <pre style={{ color: 'red' }}>{error?.message}</pre>
    <button onClick={onReset}>Try again</button>
  </div>
);
