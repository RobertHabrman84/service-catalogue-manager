# Publish to UuBookKit Example

## Publish Single Service

### Request

```http
POST /api/uubookkit/publish/42 HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1...
Content-Type: application/json

{
  "pageId": "optional-existing-page-id",
  "awid": "workspace-awid"
}
```

### Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "success": true,
  "data": {
    "pageId": "abc123def456",
    "pageUrl": "https://uuapp.plus4u.net/uu-bookkit/abc123/page/xyz",
    "status": "Published",
    "publishedAt": "2026-01-24T12:00:00Z"
  }
}
```

## Create New Page

If `pageId` is not provided, a new page will be created:

```http
POST /api/uubookkit/publish/42 HTTP/1.1
Content-Type: application/json

{
  "awid": "workspace-awid"
}
```

### Response

```json
{
  "success": true,
  "data": {
    "pageId": "new-page-id",
    "pageUrl": "https://uuapp.plus4u.net/...",
    "status": "Created",
    "publishedAt": "2026-01-24T12:00:00Z"
  }
}
```

## Check Publish Status

### Request

```http
GET /api/uubookkit/status/abc123def456 HTTP/1.1
Authorization: Bearer eyJ0eXAiOiJKV1...
```

### Response

```json
{
  "pageId": "abc123def456",
  "status": "Published",
  "lastPublished": "2026-01-24T12:00:00Z",
  "version": "1.0.0",
  "url": "https://uuapp.plus4u.net/..."
}
```

## Sync Entire Catalog

### Request

```http
POST /api/uubookkit/sync HTTP/1.1
Authorization: Bearer eyJ0eXAiOiJKV1...
Content-Type: application/json

{
  "awid": "workspace-awid",
  "statusFilter": [2],
  "createMissing": true
}
```

### Response

```json
{
  "success": true,
  "data": {
    "syncId": "sync-123",
    "totalServices": 50,
    "published": 48,
    "created": 2,
    "failed": 0,
    "details": [
      {
        "serviceId": 42,
        "serviceCode": "APP-001",
        "status": "Published",
        "pageId": "abc123"
      }
    ]
  }
}
```

## cURL Example

```bash
# Publish single service
curl -X POST "https://api.servicecatalogue.example.com/api/uubookkit/publish/42" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"awid": "workspace-awid"}'

# Sync catalog
curl -X POST "https://api.servicecatalogue.example.com/api/uubookkit/sync" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"awid": "workspace-awid", "createMissing": true}'
```

## JavaScript Example

```javascript
// Publish service
const response = await fetch(`/api/uubookkit/publish/${serviceId}`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    awid: 'workspace-awid'
  })
});

const result = await response.json();
if (result.success) {
  console.log('Published to:', result.data.pageUrl);
}
```

## Error Responses

### UuBookKit Unavailable

```json
{
  "success": false,
  "error": {
    "code": "SYS_EXTERNAL_SERVICE",
    "message": "UuBookKit service is unavailable"
  }
}
```

### Invalid Workspace

```json
{
  "success": false,
  "error": {
    "code": "BIZ_INVALID_WORKSPACE",
    "message": "Invalid or inaccessible workspace AWID"
  }
}
```
