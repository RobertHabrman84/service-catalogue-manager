import { render, screen } from '@testing-library/react';
import { SelectInput } from './SelectInput';
describe('SelectInput', () => { it('renders options', () => { render(<SelectInput options={[{value:'1',label:'One'}]} />); expect(screen.getByText('One')).toBeInTheDocument(); }); });
