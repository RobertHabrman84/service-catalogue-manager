// Validation utilities

export const validators = {
  /**
   * Check if value is not empty
   */
  required: (value: unknown): boolean => {
    if (value === null || value === undefined) return false;
    if (typeof value === 'string') return value.trim().length > 0;
    if (Array.isArray(value)) return value.length > 0;
    return true;
  },

  /**
   * Validate email format
   */
  email: (value: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(value);
  },

  /**
   * Validate URL format
   */
  url: (value: string): boolean => {
    try {
      new URL(value);
      return true;
    } catch {
      return false;
    }
  },

  /**
   * Validate minimum length
   */
  minLength: (value: string, min: number): boolean => {
    return value.length >= min;
  },

  /**
   * Validate maximum length
   */
  maxLength: (value: string, max: number): boolean => {
    return value.length <= max;
  },

  /**
   * Validate string length range
   */
  lengthRange: (value: string, min: number, max: number): boolean => {
    return value.length >= min && value.length <= max;
  },

  /**
   * Validate minimum value
   */
  min: (value: number, min: number): boolean => {
    return value >= min;
  },

  /**
   * Validate maximum value
   */
  max: (value: number, max: number): boolean => {
    return value <= max;
  },

  /**
   * Validate number range
   */
  range: (value: number, min: number, max: number): boolean => {
    return value >= min && value <= max;
  },

  /**
   * Validate pattern match
   */
  pattern: (value: string, regex: RegExp): boolean => {
    return regex.test(value);
  },

  /**
   * Validate alphanumeric only
   */
  alphanumeric: (value: string): boolean => {
    return /^[a-zA-Z0-9]+$/.test(value);
  },

  /**
   * Validate numeric only
   */
  numeric: (value: string): boolean => {
    return /^\d+$/.test(value);
  },

  /**
   * Validate phone number (basic)
   */
  phone: (value: string): boolean => {
    return /^[+]?[\d\s()-]{7,}$/.test(value);
  },

  /**
   * Validate date string
   */
  date: (value: string): boolean => {
    const date = new Date(value);
    return !isNaN(date.getTime());
  },

  /**
   * Validate date is in the future
   */
  futureDate: (value: string): boolean => {
    const date = new Date(value);
    return date > new Date();
  },

  /**
   * Validate date is in the past
   */
  pastDate: (value: string): boolean => {
    const date = new Date(value);
    return date < new Date();
  },

  /**
   * Validate unique values in array
   */
  unique: <T>(values: T[]): boolean => {
    return new Set(values).size === values.length;
  },

  /**
   * Validate service code format (alphanumeric with hyphens)
   */
  serviceCode: (value: string): boolean => {
    return /^[A-Z][A-Z0-9-]{2,49}$/.test(value);
  },

  /**
   * Validate version format (semver-like)
   */
  version: (value: string): boolean => {
    return /^\d+\.\d+(\.\d+)?(-[a-zA-Z0-9]+)?$/.test(value);
  },
};

export type ValidationResult = {
  isValid: boolean;
  errors: string[];
};

export type ValidationRule<T = unknown> = {
  validate: (value: T) => boolean;
  message: string;
};

/**
 * Run multiple validation rules
 */
export const validate = <T>(value: T, rules: ValidationRule<T>[]): ValidationResult => {
  const errors: string[] = [];
  
  for (const rule of rules) {
    if (!rule.validate(value)) {
      errors.push(rule.message);
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

/**
 * Create a required rule
 */
export const requiredRule = (message = 'This field is required'): ValidationRule => ({
  validate: validators.required,
  message,
});

/**
 * Create an email rule
 */
export const emailRule = (message = 'Please enter a valid email'): ValidationRule<string> => ({
  validate: validators.email,
  message,
});

/**
 * Create a min length rule
 */
export const minLengthRule = (min: number, message?: string): ValidationRule<string> => ({
  validate: (value) => validators.minLength(value, min),
  message: message || `Must be at least ${min} characters`,
});

/**
 * Create a max length rule
 */
export const maxLengthRule = (max: number, message?: string): ValidationRule<string> => ({
  validate: (value) => validators.maxLength(value, max),
  message: message || `Must be no more than ${max} characters`,
});

export default validators;
