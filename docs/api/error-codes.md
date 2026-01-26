# API Error Codes

## HTTP Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 204 | No Content | Successful, no body |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Authentication required |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict |
| 422 | Unprocessable | Validation failed |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Error | Server error |

## Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": [
      {
        "field": "fieldName",
        "message": "Field-specific error"
      }
    ],
    "traceId": "abc123"
  }
}
```

## Application Error Codes

### Authentication Errors (AUTH_*)

| Code | Description |
|------|-------------|
| `AUTH_TOKEN_MISSING` | Authorization header missing |
| `AUTH_TOKEN_INVALID` | Token validation failed |
| `AUTH_TOKEN_EXPIRED` | Token has expired |
| `AUTH_INSUFFICIENT_SCOPE` | Missing required scope |

### Validation Errors (VAL_*)

| Code | Description |
|------|-------------|
| `VAL_REQUIRED_FIELD` | Required field is missing |
| `VAL_INVALID_FORMAT` | Invalid field format |
| `VAL_MAX_LENGTH` | Field exceeds max length |
| `VAL_MIN_LENGTH` | Field below min length |
| `VAL_INVALID_EMAIL` | Invalid email format |
| `VAL_INVALID_VERSION` | Invalid version format |

### Resource Errors (RES_*)

| Code | Description |
|------|-------------|
| `RES_NOT_FOUND` | Resource not found |
| `RES_ALREADY_EXISTS` | Resource already exists |
| `RES_CONFLICT` | Resource conflict |
| `RES_DELETED` | Resource was deleted |

### Business Errors (BIZ_*)

| Code | Description |
|------|-------------|
| `BIZ_SERVICE_CODE_EXISTS` | Service code already used |
| `BIZ_CIRCULAR_DEPENDENCY` | Circular dependency detected |
| `BIZ_INVALID_STATUS` | Invalid status transition |
| `BIZ_EXPORT_FAILED` | Export generation failed |

### System Errors (SYS_*)

| Code | Description |
|------|-------------|
| `SYS_DATABASE_ERROR` | Database operation failed |
| `SYS_EXTERNAL_SERVICE` | External service unavailable |
| `SYS_RATE_LIMIT` | Rate limit exceeded |
| `SYS_INTERNAL_ERROR` | Unexpected server error |

## Handling Errors

### JavaScript Example

```javascript
try {
  const response = await api.createService(data);
} catch (error) {
  if (error.response?.status === 400) {
    const { code, details } = error.response.data.error;
    if (code === 'VAL_REQUIRED_FIELD') {
      // Handle validation error
      details.forEach(d => showFieldError(d.field, d.message));
    }
  } else if (error.response?.status === 401) {
    // Redirect to login
  } else {
    // Show generic error
  }
}
```

### C# Example

```csharp
try
{
    var result = await client.CreateServiceAsync(request);
}
catch (ApiException ex) when (ex.StatusCode == 400)
{
    var error = ex.GetError();
    if (error.Code == "VAL_REQUIRED_FIELD")
    {
        // Handle validation
    }
}
```

## Troubleshooting

### Common Issues

1. **401 on valid token**: Check audience (aud) claim
2. **403 with correct role**: Verify scope requirements
3. **400 on valid data**: Check date/number formats
4. **409 conflict**: Resource may be soft-deleted
