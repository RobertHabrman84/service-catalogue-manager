# API Documentation

## Overview

The Service Catalogue Manager API provides RESTful endpoints for managing service catalog data.

## Quick Links

- [Endpoints Reference](./endpoints.md)
- [Authentication](./authentication.md)
- [Error Codes](./error-codes.md)
- [Examples](./examples/)

## Base URLs

| Environment | URL |
|-------------|-----|
| Development | `http://localhost:7071/api` |
| Staging | `https://api.staging.servicecatalogue.example.com/api` |
| Production | `https://api.servicecatalogue.example.com/api` |

## Authentication

All API requests (except `/health`) require Bearer token authentication:

```http
Authorization: Bearer <access_token>
```

See [Authentication Guide](./authentication.md) for details.

## Request Format

### Headers

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer <token>
```

### Request Body

```json
{
  "serviceCode": "SVC-001",
  "serviceName": "Example Service",
  "statusId": 1
}
```

## Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    "id": 1,
    "serviceCode": "SVC-001",
    "serviceName": "Example Service"
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      {
        "field": "serviceCode",
        "message": "Service code is required"
      }
    ]
  }
}
```

## Pagination

List endpoints support pagination:

```http
GET /api/services?page=1&pageSize=20
```

Response includes pagination metadata:

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 5,
    "totalItems": 100
  }
}
```

## Rate Limiting

- 1000 requests per minute per IP
- 429 status code when exceeded
- `Retry-After` header indicates wait time

## Versioning

API version is included in the URL path:

```
/api/v1/services
```

## SDK & Tools

- [Postman Collection](./postman-collection.json)
- [OpenAPI Specification](./openapi.yaml)
