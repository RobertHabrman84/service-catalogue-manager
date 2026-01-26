# Import Module - Frontend Documentation

## Overview

The Import Module provides a user-friendly interface for importing services into the Service Catalogue Manager.

## Features

- ✅ Single service import with 3-step wizard
- ✅ Bulk import for multiple services
- ✅ Real-time validation
- ✅ Detailed error messages
- ✅ Progress indicators
- ✅ Success confirmation with links

## Components

### 1. ImportPage
**Location:** `src/components/Import/ImportPage.tsx`

**Features:**
- 3-step wizard (Upload → Validate → Import)
- File upload with drag-and-drop
- Real-time validation
- Service details preview
- Success/error handling

**Usage:**
```tsx
import ImportPage from './components/Import/ImportPage';

<Route path="/import" element={<ImportPage />} />
```

### 2. BulkImportPage
**Location:** `src/components/Import/BulkImportPage.tsx`

**Features:**
- Upload JSON array of services
- Batch import processing
- Summary statistics
- Individual service results
- Success/failure breakdown

**Usage:**
```tsx
import BulkImportPage from './components/Import/BulkImportPage';

<Route path="/import/bulk" element={<BulkImportPage />} />
```

### 3. ValidationResults
**Location:** `src/components/Import/ValidationResults.tsx`

**Features:**
- Grouped error display
- Error code badges
- Help links
- Field-specific errors

**Props:**
```tsx
interface ValidationResultsProps {
  errors: ValidationError[];
}
```

### 4. ImportResults
**Location:** `src/components/Import/ImportResults.tsx`

**Features:**
- Success/failure display
- Service ID and code
- Links to view service
- Detailed error messages

**Props:**
```tsx
interface ImportResultsProps {
  result: ImportResult;
}
```

## Service (API Client)

### ImportService
**Location:** `src/services/importService.ts`

**Methods:**
```typescript
// Check API health
async checkHealth(): Promise<HealthStatus>

// Validate service
async validateImport(serviceData: any): Promise<{ isValid: boolean; errors?: ValidationError[] }>

// Import single service
async importService(serviceData: any): Promise<ImportResult>

// Bulk import
async bulkImportServices(servicesData: any[]): Promise<BulkImportResult>

// Parse JSON file
async parseJsonFile(file: File): Promise<any>
```

## Workflow

### Single Service Import

```
1. User uploads JSON file
   ↓
2. File parsed and validated locally
   ↓
3. API validation called
   ↓
4. If valid: Show preview + Import button
   If invalid: Show error messages
   ↓
5. User confirms import
   ↓
6. API import called
   ↓
7. Show success/failure result
```

### Bulk Service Import

```
1. User uploads JSON file (array)
   ↓
2. File parsed
   ↓
3. Bulk import API called
   ↓
4. Show summary (total/success/fail)
   ↓
5. Show individual results
   ↓
6. User can view successful imports
```

## State Management

### ImportPage State

```typescript
const [step, setStep] = useState<'upload' | 'validating' | 'validated' | 'importing' | 'complete'>();
const [file, setFile] = useState<File | null>(null);
const [serviceData, setServiceData] = useState<any>(null);
const [validationErrors, setValidationErrors] = useState<ValidationError[]>([]);
const [importResult, setImportResult] = useState<ImportResult | null>(null);
const [error, setError] = useState<string | null>(null);
```

### BulkImportPage State

```typescript
const [file, setFile] = useState<File | null>(null);
const [importing, setImporting] = useState(false);
const [result, setResult] = useState<BulkImportResult | null>(null);
const [error, setError] = useState<string | null>(null);
```

## Error Handling

### Types of Errors

1. **File Type Error**
   - Message: "Please select a JSON file"
   - Action: User must select .json file

2. **JSON Parse Error**
   - Message: "Invalid JSON file"
   - Action: User must fix JSON syntax

3. **Validation Errors**
   - Displayed per field
   - Includes error code
   - Links to documentation

4. **Import Errors**
   - Server errors
   - Network errors
   - Business logic errors

### Error Display

```tsx
// Field-specific errors
<ValidationResults errors={validationErrors} />

// General errors
<div className="bg-red-50 border border-red-200 rounded-lg">
  <AlertCircle />
  <p>{error}</p>
</div>
```

## Styling

### Tailwind Classes

**Primary Actions:**
```css
bg-blue-600 text-white hover:bg-blue-700
```

**Success States:**
```css
bg-green-50 border-green-200 text-green-800
```

**Error States:**
```css
bg-red-50 border-red-200 text-red-800
```

**Disabled States:**
```css
disabled:bg-gray-300 disabled:cursor-not-allowed
```

### Icons

From `lucide-react`:
- `Upload` - File upload
- `CheckCircle` - Success
- `XCircle` - Error
- `AlertCircle` - Warning
- `Loader` - Loading state
- `ExternalLink` - External links

## API Integration

### Configuration

`.env`:
```env
REACT_APP_API_URL=http://localhost:7071/api
```

### Axios Instance

```typescript
this.axiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});
```

### Error Handling

```typescript
try {
  const response = await this.axiosInstance.post('/services/import', data);
  return response.data;
} catch (error: any) {
  if (error.response?.status === 400) {
    // Validation error
    return { success: false, errors: error.response.data.errors };
  }
  // Other errors
  throw error;
}
```

## Testing

### Component Tests

```bash
npm test -- ImportPage
npm test -- BulkImportPage
npm test -- ValidationResults
npm test -- ImportResults
```

### Integration Tests

```bash
npm test -- importService
```

### E2E Tests

```bash
npm run test:e2e
```

## Performance

### Optimizations

1. **File Reading**
   - Async file reading
   - No blocking operations

2. **State Updates**
   - Minimal re-renders
   - Efficient state updates

3. **API Calls**
   - Debounced where appropriate
   - Proper error handling

## Accessibility

- ✅ Semantic HTML
- ✅ ARIA labels
- ✅ Keyboard navigation
- ✅ Screen reader support
- ✅ Focus management
- ✅ Color contrast WCAG AA

## Browser Compatibility

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Future Enhancements

1. **Import History**
   - View past imports
   - Re-import functionality
   - Export logs

2. **Templates**
   - Save common configurations
   - Quick import from templates

3. **Advanced Features**
   - Schedule imports
   - Import from URL
   - Batch validation
   - Progress tracking

4. **UI Improvements**
   - Dark mode
   - Customizable themes
   - Advanced filtering
   - Export functionality

## Troubleshooting

### Common Issues

**Upload not working:**
- Check file type is `.json`
- Verify file size
- Check browser console

**Validation failing:**
- Review error messages
- Check JSON structure
- Verify required fields

**Import failing:**
- Check API connection
- Verify backend is running
- Review server logs

### Debug Mode

Add to `.env`:
```env
REACT_APP_DEBUG=true
```

## Support

For issues or questions:
1. Check [API Documentation](../../../docs/API.md)
2. Review [Error Codes](../../../docs/VALIDATION_ERROR_CODES.md)
3. See [Troubleshooting Guide](../../../docs/API_QUICKSTART.md#troubleshooting)

---

**Last Updated:** January 26, 2026  
**Version:** 1.0
