# Create Service Example

## Basic Example

### Request

```http
POST /api/services HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1...
Content-Type: application/json

{
  "serviceCode": "APP-001",
  "serviceName": "Customer Portal",
  "shortDescription": "Web-based customer self-service portal",
  "statusId": 1,
  "categoryId": 1
}
```

### Response

```http
HTTP/1.1 201 Created
Content-Type: application/json
Location: /api/services/42

{
  "success": true,
  "data": {
    "id": 42,
    "serviceCode": "APP-001",
    "serviceName": "Customer Portal",
    "shortDescription": "Web-based customer self-service portal",
    "status": "Draft",
    "category": "Application",
    "createdAt": "2026-01-24T12:00:00Z"
  }
}
```

## Full Example with All Fields

### Request

```http
POST /api/services HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1...
Content-Type: application/json

{
  "serviceCode": "APP-002",
  "serviceName": "Order Management System",
  "version": "1.0.0",
  "shortDescription": "Centralized order processing system",
  "longDescription": "Complete order management solution...",
  "statusId": 1,
  "categoryId": 1,
  "ownerEmail": "team@example.com",
  "businessUnitId": 1,
  "usageScenarios": [
    {
      "title": "Process New Order",
      "description": "Customer places a new order",
      "actorRole": "Customer",
      "steps": "1. Select products\n2. Add to cart\n3. Checkout"
    }
  ],
  "dependencies": [
    {
      "dependsOnServiceId": 10,
      "dependencyTypeId": 1,
      "isRequired": true,
      "description": "Requires Payment Gateway"
    }
  ]
}
```

## cURL Example

```bash
curl -X POST https://api.servicecatalogue.example.com/api/services \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "serviceCode": "APP-001",
    "serviceName": "Customer Portal",
    "shortDescription": "Web-based portal",
    "statusId": 1,
    "categoryId": 1
  }'
```

## JavaScript Example

```javascript
const response = await fetch('/api/services', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    serviceCode: 'APP-001',
    serviceName: 'Customer Portal',
    shortDescription: 'Web-based portal',
    statusId: 1,
    categoryId: 1
  })
});

const result = await response.json();
console.log('Created service:', result.data.id);
```

## Error Responses

### Validation Error

```json
{
  "success": false,
  "error": {
    "code": "VAL_REQUIRED_FIELD",
    "message": "Validation failed",
    "details": [
      { "field": "serviceCode", "message": "Service code is required" },
      { "field": "serviceName", "message": "Service name is required" }
    ]
  }
}
```

### Duplicate Code

```json
{
  "success": false,
  "error": {
    "code": "BIZ_SERVICE_CODE_EXISTS",
    "message": "A service with code 'APP-001' already exists"
  }
}
```
