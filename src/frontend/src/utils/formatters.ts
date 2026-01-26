// Formatting utilities

/**
 * Format date to localized string
 */
export const formatDate = (
  date: string | Date,
  options?: Intl.DateTimeFormatOptions,
  locale = 'cs-CZ'
): string => {
  const d = typeof date === 'string' ? new Date(date) : date;
  
  if (isNaN(d.getTime())) {
    return '';
  }

  const defaultOptions: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    ...options,
  };

  return d.toLocaleDateString(locale, defaultOptions);
};

/**
 * Format date to short format
 */
export const formatDateShort = (date: string | Date, locale = 'cs-CZ'): string => {
  return formatDate(date, { year: 'numeric', month: '2-digit', day: '2-digit' }, locale);
};

/**
 * Format date and time
 */
export const formatDateTime = (date: string | Date, locale = 'cs-CZ'): string => {
  return formatDate(
    date,
    {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    },
    locale
  );
};

/**
 * Format relative time (e.g., "2 hours ago")
 */
export const formatRelativeTime = (date: string | Date, locale = 'cs-CZ'): string => {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const diffInSeconds = Math.floor((now.getTime() - d.getTime()) / 1000);

  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });

  if (diffInSeconds < 60) {
    return rtf.format(-diffInSeconds, 'second');
  }
  if (diffInSeconds < 3600) {
    return rtf.format(-Math.floor(diffInSeconds / 60), 'minute');
  }
  if (diffInSeconds < 86400) {
    return rtf.format(-Math.floor(diffInSeconds / 3600), 'hour');
  }
  if (diffInSeconds < 604800) {
    return rtf.format(-Math.floor(diffInSeconds / 86400), 'day');
  }
  if (diffInSeconds < 2592000) {
    return rtf.format(-Math.floor(diffInSeconds / 604800), 'week');
  }
  if (diffInSeconds < 31536000) {
    return rtf.format(-Math.floor(diffInSeconds / 2592000), 'month');
  }
  return rtf.format(-Math.floor(diffInSeconds / 31536000), 'year');
};

/**
 * Format number with locale
 */
export const formatNumber = (
  value: number,
  options?: Intl.NumberFormatOptions,
  locale = 'cs-CZ'
): string => {
  return value.toLocaleString(locale, options);
};

/**
 * Format currency
 */
export const formatCurrency = (
  value: number,
  currency = 'CZK',
  locale = 'cs-CZ'
): string => {
  return formatNumber(value, { style: 'currency', currency }, locale);
};

/**
 * Format percentage
 */
export const formatPercent = (
  value: number,
  decimals = 0,
  locale = 'cs-CZ'
): string => {
  return formatNumber(value / 100, {
    style: 'percent',
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  }, locale);
};

/**
 * Format file size
 */
export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 B';

  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
};

/**
 * Format duration in hours/minutes
 */
export const formatDuration = (hours: number): string => {
  if (hours < 1) {
    return `${Math.round(hours * 60)} min`;
  }
  if (hours < 24) {
    const h = Math.floor(hours);
    const m = Math.round((hours - h) * 60);
    return m > 0 ? `${h} h ${m} min` : `${h} h`;
  }
  const days = Math.floor(hours / 24);
  const remainingHours = Math.round(hours % 24);
  return remainingHours > 0 ? `${days} d ${remainingHours} h` : `${days} d`;
};

/**
 * Truncate text with ellipsis
 */
export const truncate = (text: string, maxLength: number, ellipsis = '...'): string => {
  if (text.length <= maxLength) {
    return text;
  }
  return text.slice(0, maxLength - ellipsis.length) + ellipsis;
};

/**
 * Capitalize first letter
 */
export const capitalize = (text: string): string => {
  if (!text) return '';
  return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();
};

/**
 * Convert to title case
 */
export const titleCase = (text: string): string => {
  return text
    .toLowerCase()
    .split(' ')
    .map(word => capitalize(word))
    .join(' ');
};

/**
 * Convert to kebab-case
 */
export const kebabCase = (text: string): string => {
  return text
    .replace(/([a-z])([A-Z])/g, '$1-$2')
    .replace(/[\s_]+/g, '-')
    .toLowerCase();
};

/**
 * Convert to camelCase
 */
export const camelCase = (text: string): string => {
  return text
    .replace(/[-_\s]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ''))
    .replace(/^(.)/, (c) => c.toLowerCase());
};

/**
 * Format phone number
 */
export const formatPhone = (phone: string): string => {
  const cleaned = phone.replace(/\D/g, '');
  if (cleaned.length === 9) {
    return `${cleaned.slice(0, 3)} ${cleaned.slice(3, 6)} ${cleaned.slice(6)}`;
  }
  if (cleaned.length === 12 && cleaned.startsWith('420')) {
    return `+420 ${cleaned.slice(3, 6)} ${cleaned.slice(6, 9)} ${cleaned.slice(9)}`;
  }
  return phone;
};

/**
 * Pluralize word based on count
 */
export const pluralize = (
  count: number,
  singular: string,
  plural: string,
  includeCount = true
): string => {
  const word = count === 1 ? singular : plural;
  return includeCount ? `${count} ${word}` : word;
};

export default {
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
};
