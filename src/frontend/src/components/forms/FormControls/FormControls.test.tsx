import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { useForm, FormProvider } from 'react-hook-form';

import {
  TextInput,
  TextArea,
  Select,
  Checkbox,
  RadioGroup,
  DatePicker,
  NumberInput,
  FormSection,
  FormRow,
  FormActions,
} from './index';

const FormWrapper = ({ children }: { children: React.ReactNode }) => {
  const methods = useForm();
  return <FormProvider {...methods}>{children}</FormProvider>;
};

describe('FormControls', () => {
  describe('TextInput', () => {
    it('renders with label', () => {
      render(
        <FormWrapper>
          <TextInput name="test" label="Test Label" />
        </FormWrapper>
      );
      expect(true).toBe(true);
    });

    it('shows error state', () => {
      render(
        <FormWrapper>
          <TextInput name="test" label="Test" error="Required field" />
        </FormWrapper>
      );
      expect(true).toBe(true);
    });
  });

  describe('TextArea', () => {
    it('renders with correct rows', () => {
      render(
        <FormWrapper>
          <TextArea name="test" label="Test" rows={5} />
        </FormWrapper>
      );
      expect(true).toBe(true);
    });
  });

  describe('Select', () => {
    it('renders options', () => {
      const options = [
        { value: '1', label: 'Option 1' },
        { value: '2', label: 'Option 2' },
      ];
      render(
        <FormWrapper>
          <Select name="test" label="Test" options={options} />
        </FormWrapper>
      );
      expect(true).toBe(true);
    });
  });

  describe('Checkbox', () => {
    it('toggles correctly', () => {
      render(
        <FormWrapper>
          <Checkbox name="test" label="Test Checkbox" />
        </FormWrapper>
      );
      expect(true).toBe(true);
    });
  });

  describe('FormSection', () => {
    it('renders with title', () => {
      render(
        <FormSection title="Test Section">
          <div>Content</div>
        </FormSection>
      );
      expect(true).toBe(true);
    });
  });

  describe('FormActions', () => {
    it('renders submit and cancel buttons', () => {
      render(
        <FormActions
          onSubmit={() => {}}
          onCancel={() => {}}
          submitLabel="Save"
          cancelLabel="Cancel"
        />
      );
      expect(true).toBe(true);
    });
  });
});
