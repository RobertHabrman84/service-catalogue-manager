import { render, screen } from '@testing-library/react';
import { TextArea } from './TextArea';
describe('TextArea', () => { it('renders', () => { render(<TextArea placeholder="test" />); expect(screen.getByPlaceholderText('test')).toBeInTheDocument(); }); });
