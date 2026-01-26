# Service Catalogue Import API Documentation

## Base URL
```
https://<your-function-app>.azurewebsites.net/api
```

For local development:
```
http://localhost:7071/api
```

## Authentication
All endpoints (except health check) require Function-level authentication using the `x-functions-key` header or `code` query parameter.

```bash
curl -H "x-functions-key: YOUR_FUNCTION_KEY" ...
# OR
curl "...?code=YOUR_FUNCTION_KEY"
```

---

## Endpoints

### 1. Import Single Service
Import a single service into the catalog.

**Endpoint:** `POST /services/import`

**Request Body:**
```json
{
  "serviceCode": "ID001",
  "serviceName": "Enterprise Scale Landing Zone Design",
  "version": "v1.0",
  "category": "Services/Architecture",
  "description": "Complete enterprise-scale landing zone architecture and documentation",
  "usageScenarios": [
    {
      "scenarioNumber": 1,
      "scenarioTitle": "New Azure Enterprise Setup",
      "scenarioDescription": "Organization establishing initial Azure presence"
    }
  ],
  "sizeOptions": [
    {
      "sizeCode": "M",
      "description": "Medium complexity",
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
      "isPrimaryOwner": true,
      "responsibilities": "Overall design and architecture"
    }
  ]
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Service imported successfully",
  "serviceId": 42,
  "serviceCode": "ID001"
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Service import failed validation",
  "errors": [
    {
      "field": "ServiceCode",
      "message": "ServiceCode must match pattern ^ID\\d{3}$ (e.g., ID001)",
      "code": "INVALID_FORMAT"
    }
  ]
}
```

**cURL Example:**
```bash
curl -X POST "http://localhost:7071/api/services/import" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: YOUR_KEY" \
  -d @service.json
```

---

### 2. Bulk Import Services
Import multiple services in a single request.

**Endpoint:** `POST /services/import/bulk`

**Request Body:**
```json
[
  {
    "serviceCode": "ID001",
    "serviceName": "Service 1",
    "version": "v1.0",
    "category": "Services/Architecture",
    "description": "Description 1",
    "responsibleRoles": [
      {
        "roleName": "Cloud Architect",
        "isPrimaryOwner": true
      }
    ]
  },
  {
    "serviceCode": "ID002",
    "serviceName": "Service 2",
    "version": "v1.0",
    "category": "Services/Architecture",
    "description": "Description 2",
    "responsibleRoles": [
      {
        "roleName": "Cloud Architect",
        "isPrimaryOwner": true
      }
    ]
  }
]
```

**Success Response (200 OK):**
```json
{
  "totalCount": 2,
  "successCount": 2,
  "failCount": 0,
  "results": [
    {
      "success": true,
      "serviceId": 42,
      "serviceCode": "ID001",
      "errors": null
    },
    {
      "success": true,
      "serviceId": 43,
      "serviceCode": "ID002",
      "errors": null
    }
  ]
}
```

**Partial Success Response (207 Multi-Status):**
```json
{
  "totalCount": 2,
  "successCount": 1,
  "failCount": 1,
  "results": [
    {
      "success": true,
      "serviceId": 42,
      "serviceCode": "ID001",
      "errors": null
    },
    {
      "success": false,
      "serviceId": null,
      "serviceCode": "INVALID",
      "errors": [
        {
          "field": "ServiceCode",
          "message": "ServiceCode must match pattern ^ID\\d{3}$",
          "code": "INVALID_FORMAT"
        }
      ]
    }
  ]
}
```

**cURL Example:**
```bash
curl -X POST "http://localhost:7071/api/services/import/bulk" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: YOUR_KEY" \
  -d @services-bulk.json
```

---

### 3. Validate Import (Dry-Run)
Validate service data without actually importing it.

**Endpoint:** `POST /services/import/validate`

**Request Body:**
Same as single import endpoint.

**Success Response (200 OK):**
```json
{
  "isValid": true,
  "message": "Validation passed - service is ready to import",
  "serviceCode": "ID001"
}
```

**Validation Failed Response (400 Bad Request):**
```json
{
  "isValid": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "ServiceCode",
      "message": "ServiceCode must match pattern ^ID\\d{3}$",
      "code": "INVALID_FORMAT"
    },
    {
      "field": "ResponsibleRoles",
      "message": "At least one responsible role must be marked as primary owner",
      "code": "MISSING_PRIMARY_OWNER"
    }
  ]
}
```

**cURL Example:**
```bash
curl -X POST "http://localhost:7071/api/services/import/validate" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: YOUR_KEY" \
  -d @service.json
```

---

### 4. Health Check
Check API health status (no authentication required).

**Endpoint:** `GET /services/import/health`

**Success Response (200 OK):**
```json
{
  "status": "healthy",
  "service": "Service Catalogue Import API",
  "timestamp": "2026-01-26T11:30:00.000Z"
}
```

**cURL Example:**
```bash
curl "http://localhost:7071/api/services/import/health"
```

---

## Error Codes

### HTTP Status Codes
- `200 OK` - Request successful
- `207 Multi-Status` - Bulk import with some failures
- `400 Bad Request` - Invalid request or validation errors
- `500 Internal Server Error` - Unexpected server error

### Validation Error Codes
See [VALIDATION_ERROR_CODES.md](VALIDATION_ERROR_CODES.md) for complete list.

Common codes:
- `INVALID_FORMAT` - Data format incorrect
- `NOT_FOUND` - Referenced entity not found
- `DUPLICATE_SERVICE_CODE` - Service code already exists
- `MISSING_PRIMARY_OWNER` - No primary owner specified
- `LOOKUP_NOT_FOUND` - Lookup value not found

---

## Complete Request Examples

### Minimal Service
```json
{
  "serviceCode": "ID001",
  "serviceName": "Minimal Service",
  "version": "v1.0",
  "category": "Services/Architecture",
  "description": "Minimal service with required fields only",
  "responsibleRoles": [
    {
      "roleName": "Cloud Architect",
      "isPrimaryOwner": true
    }
  ]
}
```

### Complete Service with All Fields
```json
{
  "serviceCode": "ID001",
  "serviceName": "Enterprise Scale Landing Zone Design",
  "version": "v1.0",
  "category": "Services/Architecture",
  "description": "Complete enterprise-scale landing zone architecture",
  "notes": "Additional notes here",
  "usageScenarios": [
    {
      "scenarioNumber": 1,
      "scenarioTitle": "New Azure Enterprise Setup",
      "scenarioDescription": "Organization establishing initial Azure presence",
      "sortOrder": 1
    }
  ],
  "dependencies": {
    "prerequisite": [
      {
        "serviceCode": "ID000",
        "serviceName": "Foundation Service",
        "requirementLevel": "REQUIRED",
        "notes": "Must be completed first"
      }
    ]
  },
  "scope": {
    "inScope": [
      {
        "categoryNumber": 1,
        "categoryName": "Landing Zone Architecture",
        "items": [
          "Hub-spoke network topology",
          "Identity and access management"
        ],
        "sortOrder": 1
      }
    ],
    "outOfScope": [
      "Application migration",
      "Data migration"
    ]
  },
  "prerequisites": {
    "organizational": [
      {
        "name": "Azure Subscription",
        "description": "Active Azure subscription with appropriate permissions",
        "requirementLevel": "REQUIRED"
      }
    ]
  },
  "toolsAndEnvironment": {
    "cloudPlatforms": ["Azure Portal", "Azure CLI"],
    "designTools": ["Visio", "Draw.io"]
  },
  "licenses": {
    "requiredByCustomer": ["Azure Subscription"],
    "recommendedOptional": ["Azure DevOps"]
  },
  "stakeholderInteraction": {
    "interactionLevel": "HIGH",
    "customerMustProvide": ["Technical requirements"],
    "workshopParticipation": ["Cloud Architect", "Security Lead"]
  },
  "serviceInputs": [
    {
      "parameterName": "Target Region",
      "description": "Azure region for deployment",
      "requirementLevel": "REQUIRED",
      "dataType": "String",
      "exampleValue": "West Europe"
    }
  ],
  "serviceOutputs": [
    {
      "categoryNumber": 1,
      "categoryName": "Architecture Documents",
      "items": [
        {
          "itemName": "Network Architecture Diagram",
          "itemDescription": "Complete network topology"
        }
      ]
    }
  ],
  "timeline": [
    {
      "phaseNumber": 1,
      "phaseName": "Discovery",
      "description": "Requirements gathering",
      "durationBySize": "S: 1 week, M: 2 weeks, L: 3 weeks"
    }
  ],
  "sizeOptions": [
    {
      "sizeCode": "M",
      "description": "Medium complexity landing zone",
      "duration": "4-6 weeks",
      "durationInDays": 30,
      "complexity": "Medium",
      "effort": {
        "hoursMin": 100,
        "hoursMax": 200
      },
      "effortBreakdown": {
        "requirements": 20,
        "design": 40,
        "implementation": 80,
        "testing": 30,
        "documentation": 30
      },
      "teamAllocation": {
        "cloudArchitects": 1,
        "developers": 2,
        "projectManagers": 1
      }
    }
  ],
  "responsibleRoles": [
    {
      "roleName": "Cloud Architect",
      "isPrimaryOwner": true,
      "responsibilities": "Overall design and architecture decisions"
    }
  ],
  "multiCloudConsiderations": [
    {
      "considerationTitle": "Multi-Region Support",
      "description": "Design supports deployment across multiple regions"
    }
  ]
}
```

---

## PowerShell Examples

### Import Single Service
```powershell
$headers = @{
    "Content-Type" = "application/json"
    "x-functions-key" = "YOUR_FUNCTION_KEY"
}

$body = Get-Content -Path "service.json" -Raw

$response = Invoke-RestMethod `
    -Uri "http://localhost:7071/api/services/import" `
    -Method Post `
    -Headers $headers `
    -Body $body

Write-Output $response
```

### Bulk Import
```powershell
$headers = @{
    "Content-Type" = "application/json"
    "x-functions-key" = "YOUR_FUNCTION_KEY"
}

$body = Get-Content -Path "services-bulk.json" -Raw

$response = Invoke-RestMethod `
    -Uri "http://localhost:7071/api/services/import/bulk" `
    -Method Post `
    -Headers $headers `
    -Body $body

Write-Output "Imported: $($response.successCount)/$($response.totalCount)"
```

---

## Rate Limits
- No enforced rate limits currently
- Consider implementing rate limiting for production use

## Best Practices

1. **Always validate first** - Use `/validate` endpoint before importing
2. **Use bulk import** - More efficient for multiple services
3. **Handle errors gracefully** - Check response status and error details
4. **Log requests** - Keep track of imports for auditing
5. **Use HTTPS** - Always use HTTPS in production

---

## Support
For issues or questions, see:
- [Validation Error Codes](VALIDATION_ERROR_CODES.md)
- [Import Feature Documentation](IMPORT_FEATURE.md)
- [Project Plan](PROJECT_PLAN.md)
