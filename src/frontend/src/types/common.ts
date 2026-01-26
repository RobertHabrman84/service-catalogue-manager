// Common Types

export type SortOrder = 'asc' | 'desc';

export interface SortConfig {
  field: string;
  order: SortOrder;
}

export interface FilterConfig {
  field: string;
  operator: FilterOperator;
  value: unknown;
}

export type FilterOperator = 
  | 'equals' 
  | 'notEquals' 
  | 'contains' 
  | 'startsWith' 
  | 'endsWith' 
  | 'greaterThan' 
  | 'lessThan' 
  | 'greaterThanOrEqual' 
  | 'lessThanOrEqual' 
  | 'in' 
  | 'notIn' 
  | 'between' 
  | 'isNull' 
  | 'isNotNull';

export interface PaginationConfig {
  page: number;
  pageSize: number;
}

export interface ListQueryParams {
  pagination?: PaginationConfig;
  sort?: SortConfig;
  filters?: FilterConfig[];
  search?: string;
}

export interface SelectOption<T = string | number> {
  value: T;
  label: string;
  disabled?: boolean;
  description?: string;
  icon?: string;
}

export interface TreeNode<T = unknown> {
  id: string | number;
  label: string;
  data?: T;
  children?: TreeNode<T>[];
  isExpanded?: boolean;
  isSelected?: boolean;
  isDisabled?: boolean;
}

export interface BreadcrumbItem {
  label: string;
  href?: string;
  icon?: string;
}

export interface MenuItem {
  id: string;
  label: string;
  href?: string;
  icon?: string;
  onClick?: () => void;
  disabled?: boolean;
  children?: MenuItem[];
}

export interface TabItem {
  id: string;
  label: string;
  icon?: string;
  disabled?: boolean;
  badge?: string | number;
}

export interface ColumnDefinition<T = unknown> {
  id: string;
  header: string;
  accessor: keyof T | ((row: T) => unknown);
  sortable?: boolean;
  filterable?: boolean;
  width?: string | number;
  minWidth?: string | number;
  maxWidth?: string | number;
  align?: 'left' | 'center' | 'right';
  render?: (value: unknown, row: T) => React.ReactNode;
}

export interface AsyncState<T> {
  data: T | null;
  isLoading: boolean;
  error: string | null;
}

export interface LoadingState {
  isLoading: boolean;
  loadingMessage?: string;
}

export interface ErrorState {
  hasError: boolean;
  errorMessage?: string;
  errorCode?: string;
}

// Date/Time helpers
export type DateFormat = 'short' | 'medium' | 'long' | 'full' | 'iso';
export type TimeFormat = 'short' | 'medium' | 'long';

// Status types
export type Status = 'idle' | 'loading' | 'success' | 'error';
export type OperationStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';

// Form related
export interface FormFieldError {
  field: string;
  message: string;
}

export interface FormState<T> {
  values: T;
  errors: FormFieldError[];
  touched: Record<keyof T, boolean>;
  isSubmitting: boolean;
  isValid: boolean;
  isDirty: boolean;
}

// Theme types
export type ThemeMode = 'light' | 'dark' | 'system';

// Size variants
export type Size = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

// Color variants
export type ColorVariant = 'primary' | 'secondary' | 'success' | 'warning' | 'error' | 'info';

// Position
export type Position = 'top' | 'right' | 'bottom' | 'left';
export type Alignment = 'start' | 'center' | 'end';
