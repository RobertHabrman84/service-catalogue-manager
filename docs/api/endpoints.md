# API Endpoints

## Service Catalog

### List Services

```http
GET /api/services
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Page number (default: 1) |
| pageSize | int | Items per page (default: 20) |
| search | string | Search term |
| statusId | int | Filter by status |
| categoryId | int | Filter by category |
| sortBy | string | Sort field |
| sortOrder | string | asc or desc |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "serviceCode": "SVC-001",
      "serviceName": "Service Name",
      "status": "Active",
      "category": "Application"
    }
  ],
  "pagination": { ... }
}
```

### Get Service by ID

```http
GET /api/services/{id}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "serviceCode": "SVC-001",
  "serviceName": "Service Name",
  "version": "1.0.0",
  "shortDescription": "...",
  "longDescription": "...",
  "usageScenarios": [...],
  "dependencies": [...]
}
```

### Create Service

```http
POST /api/services
```

**Request Body:**
```json
{
  "serviceCode": "SVC-001",
  "serviceName": "New Service",
  "shortDescription": "Description",
  "statusId": 1,
  "categoryId": 1
}
```

**Response:** `201 Created`

### Update Service

```http
PUT /api/services/{id}
```

**Request Body:**
```json
{
  "serviceName": "Updated Name",
  "version": "2.0.0",
  "statusId": 2
}
```

**Response:** `200 OK`

### Delete Service

```http
DELETE /api/services/{id}
```

**Response:** `204 No Content`

---

## Lookups

### Get All Lookups

```http
GET /api/lookups
```

**Response:**
```json
{
  "statuses": [...],
  "categories": [...],
  "dependencyTypes": [...],
  "cloudProviders": [...]
}
```

### Get Service Statuses

```http
GET /api/lookups/statuses
```

### Get Service Categories

```http
GET /api/lookups/categories
```

---

## Export

### Export to PDF

```http
GET /api/export/pdf/{id}
```

**Response:** PDF file download

### Export to Markdown

```http
GET /api/export/markdown/{id}
```

**Response:** Markdown file download

### Export Catalog to PDF

```http
GET /api/export/catalog/pdf
```

---

## UuBookKit

### Publish Service

```http
POST /api/uubookkit/publish/{id}
```

**Request Body:**
```json
{
  "pageId": "optional-page-id"
}
```

### Get Publish Status

```http
GET /api/uubookkit/status/{pageId}
```

### Sync Catalog

```http
POST /api/uubookkit/sync
```

---

## Health

### Health Check

```http
GET /api/health
```

**Response:** `200 OK`
```json
{
  "status": "Healthy",
  "timestamp": "2026-01-24T12:00:00Z"
}
```
