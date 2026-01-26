# API Specification

## Overview

The Service Catalogue Manager API follows REST principles and uses JSON for request/response payloads.

## Base URL

| Environment | URL |
|-------------|-----|
| Development | `http://localhost:7071/api` |
| Staging | `https://api.staging.servicecatalogue.example.com` |
| Production | `https://api.servicecatalogue.example.com` |

## Authentication

All endpoints (except `/health`) require Azure AD Bearer token authentication.

```http
Authorization: Bearer <access_token>
```

## API Versioning

API version is specified via URL path: `/api/v1/services`

## Endpoints Overview

### Service Catalog

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/services` | List all services |
| GET | `/services/{id}` | Get service by ID |
| GET | `/services/code/{code}` | Get service by code |
| POST | `/services` | Create new service |
| PUT | `/services/{id}` | Update service |
| DELETE | `/services/{id}` | Delete service |

### Lookups

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/lookups` | Get all lookup data |
| GET | `/lookups/statuses` | Get service statuses |
| GET | `/lookups/categories` | Get service categories |

### Export

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/export/pdf/{id}` | Export service to PDF |
| GET | `/export/markdown/{id}` | Export service to Markdown |
| GET | `/export/catalog/pdf` | Export full catalog to PDF |

### UuBookKit

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/uubookkit/publish/{id}` | Publish to UuBookKit |
| GET | `/uubookkit/status/{pageId}` | Get publish status |
| POST | `/uubookkit/sync` | Sync entire catalog |

## Request/Response Format

### Standard Response

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully"
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Service code is required",
    "details": [...]
  }
}
```

## Pagination

```http
GET /api/services?page=1&pageSize=20&sortBy=name&sortOrder=asc
```

## Filtering

```http
GET /api/services?statusId=1&categoryId=2&search=keyword
```

## Rate Limiting

- 1000 requests per minute per IP
- 429 Too Many Requests when exceeded
