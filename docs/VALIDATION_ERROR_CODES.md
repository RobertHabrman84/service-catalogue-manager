# Import Validation Error Codes

## Overview

This document describes all validation error codes that can be returned by the Import Validation Service.

## Error Code Categories

### Data Annotation Errors (DATA_ANNOTATION)

Errors from C# Data Annotations validation.

| Field | Error | Description |
|-------|-------|-------------|
| ServiceCode | Required | ServiceCode is required |
| ServiceName | Required | ServiceName is required |
| Category | Required | Category is required |
| Description | Required | Description is required |
| ServiceName | StringLength | ServiceName exceeds 200 characters |

### Format Validation Errors (INVALID_FORMAT)

Errors related to data format validation.

| Field | Code | Description | Example |
|-------|------|-------------|---------|
| ServiceCode | INVALID_FORMAT | ServiceCode must match pattern ID0XX | "INVALID" → should be "ID001" |

### Not Found Errors (NOT_FOUND)

Errors when referenced entities are not found.

| Field | Code | Description |
|-------|------|-------------|
| Category | NOT_FOUND | Category path not found in lookup table |

### Lookup Not Found Errors (LOOKUP_NOT_FOUND)

Errors when lookup values cannot be resolved.

| Field | Code | Description | Example |
|-------|------|-------------|---------|
| SizeOptions.SizeCode | LOOKUP_NOT_FOUND | Size option not found | "XXXL" not valid |
| Dependencies.RequirementLevel | LOOKUP_NOT_FOUND | Requirement level not found | "INVALID" not valid |
| ServiceInputs.RequirementLevel | LOOKUP_NOT_FOUND | Requirement level not found | Must be REQUIRED/RECOMMENDED/OPTIONAL |
| Prerequisites.Category | LOOKUP_NOT_FOUND | Prerequisite category not found | Must be Organizational/Technical/Documentation |
| StakeholderInteraction.InteractionLevel | LOOKUP_NOT_FOUND | Interaction level not found | Must be LOW/MEDIUM/HIGH |
| ResponsibleRoles.RoleName | LOOKUP_NOT_FOUND | Role not found in lookup table | Role doesn't exist |

### Duplicate Errors

Errors when duplicate values are found.

| Field | Code | Description |
|-------|------|-------------|
| ServiceCode | DUPLICATE_SERVICE_CODE | Service with this code already exists in database |
| UsageScenarios | DUPLICATE_SCENARIO | Duplicate scenario numbers found within service |
| SizeOptions | DUPLICATE_SIZE | Duplicate size codes found within service |

### Range Validation Errors (INVALID_RANGE)

Errors related to numeric range validation.

| Field | Code | Description |
|-------|------|-------------|
| SizeOptions.Effort | INVALID_RANGE | HoursMin cannot be greater than HoursMax |

### Negative Value Errors (NEGATIVE_VALUE)

Errors when negative values are not allowed.

| Field | Code | Description |
|-------|------|-------------|
| SizeOptions.Effort.Hours | NEGATIVE_VALUE | Hours cannot be negative |
| SizeOptions.DurationInDays | NEGATIVE_VALUE | DurationInDays cannot be negative |

### Reference Validation Errors

Errors related to cross-references within data.

| Field | Code | Description |
|-------|------|-------------|
| Dependencies.ServiceCode | REFERENCE_NOT_FOUND | Referenced service does not exist |
| Dependencies.ServiceCode | CIRCULAR_REFERENCE | Service cannot depend on itself |
| ResponsibleRoles | MISSING_PRIMARY_OWNER | At least one role must be marked as primary owner |
| ResponsibleRoles | MULTIPLE_PRIMARY_OWNERS | Only one role can be marked as primary owner |

## Error Response Format

```json
{
  "isValid": false,
  "errors": [
    {
      "field": "ServiceCode",
      "message": "ServiceCode must match pattern ^ID\\d{3}$ (e.g., ID001)",
      "code": "INVALID_FORMAT"
    },
    {
      "field": "SizeOptions.SizeCode",
      "message": "Size option not found: XXXL",
      "code": "LOOKUP_NOT_FOUND"
    }
  ]
}
```

## Validation Flow

```
1. Data Annotations Validation
   ↓
2. Business Rules Validation
   - ServiceCode format
   - Category existence
   - Service name length
   - Duplicate scenarios
   - Duplicate sizes
   - Effort value ranges
   ↓
3. Lookup Validation
   - Size options exist
   - Requirement levels exist
   - Roles exist
   - Prerequisite categories exist
   - Interaction levels exist
   ↓
4. Duplicate Detection
   - ServiceCode uniqueness
   ↓
5. Cross-Reference Validation
   - Dependency references exist
   - No circular references
   - Primary owner validation
```

## Examples

### Example 1: Invalid ServiceCode Format

**Input:**
```json
{
  "serviceCode": "INVALID",
  "serviceName": "Test Service",
  "category": "Services/Architecture",
  "description": "Test"
}
```

**Error:**
```json
{
  "field": "ServiceCode",
  "message": "ServiceCode must match pattern ^ID\\d{3}$ (e.g., ID001)",
  "code": "INVALID_FORMAT"
}
```

### Example 2: Duplicate Scenario Numbers

**Input:**
```json
{
  "usageScenarios": [
    {
      "scenarioNumber": 1,
      "scenarioTitle": "Scenario A",
      "scenarioDescription": "Description A"
    },
    {
      "scenarioNumber": 1,
      "scenarioTitle": "Scenario B",
      "scenarioDescription": "Description B"
    }
  ]
}
```

**Error:**
```json
{
  "field": "UsageScenarios",
  "message": "Duplicate scenario numbers found: 1",
  "code": "DUPLICATE_SCENARIO"
}
```

### Example 3: Invalid Size Option

**Input:**
```json
{
  "sizeOptions": [
    {
      "sizeCode": "XXXL",
      "description": "Extra extra extra large",
      "duration": "20 weeks"
    }
  ]
}
```

**Error:**
```json
{
  "field": "SizeOptions.SizeCode",
  "message": "Size option not found: XXXL",
  "code": "LOOKUP_NOT_FOUND"
}
```

### Example 4: Circular Dependency

**Input:**
```json
{
  "serviceCode": "ID001",
  "dependencies": {
    "prerequisite": [
      {
        "serviceCode": "ID001",
        "serviceName": "Self",
        "requirementLevel": "REQUIRED"
      }
    ]
  }
}
```

**Error:**
```json
{
  "field": "Dependencies.ServiceCode",
  "message": "Service cannot depend on itself: ID001",
  "code": "CIRCULAR_REFERENCE"
}
```

### Example 5: No Primary Owner

**Input:**
```json
{
  "responsibleRoles": [
    {
      "roleName": "Cloud Architect",
      "isPrimaryOwner": false
    },
    {
      "roleName": "Solution Architect",
      "isPrimaryOwner": false
    }
  ]
}
```

**Error:**
```json
{
  "field": "ResponsibleRoles",
  "message": "At least one responsible role must be marked as primary owner",
  "code": "MISSING_PRIMARY_OWNER"
}
```

## Best Practices

### For API Consumers

1. **Always validate before import**: Use the validation endpoint before attempting import
2. **Handle all error codes**: Implement handling for all documented error codes
3. **Display user-friendly messages**: Translate error codes to user-friendly messages
4. **Collect all errors**: Fix all validation errors before retry, not just the first one

### For Developers

1. **Add new error codes to this document**: Keep documentation up-to-date
2. **Use descriptive error messages**: Include context (e.g., actual value, expected format)
3. **Provide actionable guidance**: Tell users how to fix the error
4. **Log validation failures**: Include full error details for debugging

## Testing Validation

### Valid Service Example

```json
{
  "serviceCode": "ID001",
  "serviceName": "Test Service",
  "version": "v1.0",
  "category": "Services/Architecture",
  "description": "Complete service description",
  "usageScenarios": [
    {
      "scenarioNumber": 1,
      "scenarioTitle": "Scenario 1",
      "scenarioDescription": "Description 1"
    }
  ],
  "sizeOptions": [
    {
      "sizeCode": "M",
      "description": "Medium",
      "duration": "4-6 weeks",
      "effort": {
        "hoursMin": 100,
        "hoursMax": 200
      }
    }
  ],
  "responsibleRoles": [
    {
      "roleName": "Cloud Architect",
      "isPrimaryOwner": true
    }
  ]
}
```

This example should pass all validation checks.

## Related Documentation

- [Import Feature Documentation](../IMPORT_FEATURE.md)
- [API Documentation](../api/README.md)
- [Validation Service Implementation](../Services/Import/ImportValidationService.cs)
