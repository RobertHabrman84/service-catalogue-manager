import { render, screen } from '@testing-library/react';
import { Switch } from './Switch';
describe('Switch', () => { it('renders', () => { render(<Switch label="Toggle" />); expect(screen.getByText('Toggle')).toBeInTheDocument(); }); });
