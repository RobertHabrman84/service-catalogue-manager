import { render, screen } from '@testing-library/react';
import { NumberInput } from './NumberInput';
describe('NumberInput', () => { it('renders', () => { render(<NumberInput placeholder="0" />); expect(screen.getByPlaceholderText('0')).toBeInTheDocument(); }); });
