import { render, screen } from '@testing-library/react';
import { MultiSelect } from './MultiSelect';
describe('MultiSelect', () => { it('renders options', () => { render(<MultiSelect options={[{value:'1',label:'One'}]} value={[]} onChange={() => {}} />); expect(screen.getByText('One')).toBeInTheDocument(); }); });
