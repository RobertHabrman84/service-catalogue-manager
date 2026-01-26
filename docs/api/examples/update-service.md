# Update Service Example

## Basic Update

### Request

```http
PUT /api/services/42 HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1...
Content-Type: application/json

{
  "serviceName": "Customer Portal v2",
  "version": "2.0.0",
  "statusId": 2
}
```

### Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "success": true,
  "data": {
    "id": 42,
    "serviceCode": "APP-001",
    "serviceName": "Customer Portal v2",
    "version": "2.0.0",
    "status": "Active",
    "modifiedAt": "2026-01-24T14:00:00Z"
  }
}
```

## Partial Update

Only include fields you want to update:

```json
{
  "shortDescription": "Updated description only"
}
```

## Update with Usage Scenarios

```http
PUT /api/services/42 HTTP/1.1
Content-Type: application/json

{
  "usageScenarios": [
    {
      "id": 1,
      "title": "Updated Scenario",
      "description": "Updated description"
    },
    {
      "title": "New Scenario",
      "description": "This is a new scenario"
    }
  ]
}
```

## cURL Example

```bash
curl -X PUT https://api.servicecatalogue.example.com/api/services/42 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "serviceName": "Updated Name",
    "version": "2.0.0"
  }'
```

## JavaScript Example

```javascript
const response = await fetch(`/api/services/${serviceId}`, {
  method: 'PUT',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    serviceName: 'Updated Name',
    version: '2.0.0'
  })
});

if (response.ok) {
  const result = await response.json();
  console.log('Updated:', result.data);
}
```

## Error Responses

### Not Found

```http
HTTP/1.1 404 Not Found

{
  "success": false,
  "error": {
    "code": "RES_NOT_FOUND",
    "message": "Service with ID 42 not found"
  }
}
```

### Validation Error

```http
HTTP/1.1 400 Bad Request

{
  "success": false,
  "error": {
    "code": "VAL_INVALID_FORMAT",
    "message": "Invalid version format",
    "details": [
      { "field": "version", "message": "Version must follow semantic versioning (e.g., 1.0.0)" }
    ]
  }
}
```
