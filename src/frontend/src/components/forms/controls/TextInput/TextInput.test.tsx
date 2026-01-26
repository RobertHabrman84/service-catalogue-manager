import { render, screen } from '@testing-library/react';
import { TextInput } from './TextInput';
describe('TextInput', () => { it('renders', () => { render(<TextInput placeholder="test" />); expect(screen.getByPlaceholderText('test')).toBeInTheDocument(); }); });
