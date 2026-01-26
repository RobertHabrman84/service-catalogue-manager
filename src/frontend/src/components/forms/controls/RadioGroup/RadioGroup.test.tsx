import { render, screen } from '@testing-library/react';
import { RadioGroup } from './RadioGroup';
describe('RadioGroup', () => { it('renders options', () => { render(<RadioGroup name="test" options={[{value:'1',label:'One'}]} value="" onChange={() => {}} />); expect(screen.getByText('One')).toBeInTheDocument(); }); });
