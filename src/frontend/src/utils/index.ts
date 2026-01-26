// Utils barrel export
// Re-exports all utilities from sub-modules

// Formatters
export {
  formatDate,
  formatDateShort,
  formatDateTime,
  formatRelativeTime,
  formatNumber,
  formatCurrency,
  formatPercent,
  formatFileSize,
  formatDuration,
  truncate,
  capitalize,
  titleCase,
  kebabCase,
  camelCase,
  formatPhone,
  pluralize,
} from './formatters';

// Validators
export {
  validators,
  validate,
  requiredRule,
  emailRule,
  minLengthRule,
  maxLengthRule,
  type ValidationResult,
  type ValidationRule,
} from './validators';

// Helpers
export {
  deepClone,
  deepMerge,
  isObject,
  isEmpty,
  generateId,
  debounce,
  throttle,
  sleep,
  retry,
  groupBy,
  sortBy,
  unique,
  uniqueBy,
  chunk,
  flatten,
  pick,
  omit,
  safeJsonParse,
  downloadFile,
  copyToClipboard,
} from './helpers';

// ============================================
// Constants
// ============================================

export const APP_NAME = 'Service Catalogue Manager';
export const APP_VERSION = '1.0.0';

export const SIZE_OPTIONS = {
  S: { code: 'S', name: 'Small', color: '#10B981' },
  M: { code: 'M', name: 'Medium', color: '#3B82F6' },
  L: { code: 'L', name: 'Large', color: '#F59E0B' },
  XL: { code: 'XL', name: 'Extra Large', color: '#EF4444' },
} as const;

export const SCOPE_TYPES = {
  IN_SCOPE: { id: 1, code: 'IN', name: 'In Scope' },
  OUT_OF_SCOPE: { id: 2, code: 'OUT', name: 'Out of Scope' },
} as const;

export const DEPENDENCY_TYPES = {
  INTERNAL: { id: 1, code: 'INT', name: 'Internal Service' },
  EXTERNAL: { id: 2, code: 'EXT', name: 'External Service' },
  INFRASTRUCTURE: { id: 3, code: 'INF', name: 'Infrastructure' },
} as const;

export const REQUIREMENT_LEVELS = {
  REQUIRED: { id: 1, code: 'REQ', name: 'Required' },
  OPTIONAL: { id: 2, code: 'OPT', name: 'Optional' },
  CONDITIONAL: { id: 3, code: 'CON', name: 'Conditional' },
} as const;

export const STATUS_COLORS = {
  active: 'bg-green-100 text-green-800',
  inactive: 'bg-gray-100 text-gray-800',
  draft: 'bg-yellow-100 text-yellow-800',
  archived: 'bg-red-100 text-red-800',
} as const;

export const ROUTES = {
  HOME: '/',
  DASHBOARD: '/dashboard',
  CATALOG: '/catalog',
  SERVICE_VIEW: '/services/:id',
  SERVICE_CREATE: '/services/new',
  SERVICE_EDIT: '/services/:id/edit',
  EXPORT: '/export',
  SETTINGS: '/settings',
  LOGIN: '/login',
} as const;

export const API_ENDPOINTS = {
  SERVICES: '/api/services',
  LOOKUPS: '/api/lookups',
  EXPORT: '/api/export',
  HEALTH: '/api/health',
} as const;

export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100],
} as const;
