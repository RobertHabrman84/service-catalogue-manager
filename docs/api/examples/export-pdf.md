# Export to PDF Example

## Export Single Service

### Request

```http
GET /api/export/pdf/42 HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1...
Accept: application/pdf
```

### Response

```http
HTTP/1.1 200 OK
Content-Type: application/pdf
Content-Disposition: attachment; filename="APP-001-Customer-Portal.pdf"
Content-Length: 125432

[PDF binary data]
```

## Export with Options

### Request

```http
GET /api/export/pdf/42?includeScenarios=true&includeDependencies=true HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1...
```

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| includeScenarios | bool | true | Include usage scenarios |
| includeDependencies | bool | true | Include dependencies |
| includeTimeline | bool | true | Include timeline |
| includeTeam | bool | true | Include team info |

## Export Full Catalog

### Request

```http
GET /api/export/catalog/pdf HTTP/1.1
Host: api.servicecatalogue.example.com
Authorization: Bearer eyJ0eXAiOiJKV1...
```

### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| statusId | int | Filter by status |
| categoryId | int | Filter by category |

## cURL Example

```bash
# Export single service
curl -X GET "https://api.servicecatalogue.example.com/api/export/pdf/42" \
  -H "Authorization: Bearer $TOKEN" \
  -o "service-42.pdf"

# Export catalog
curl -X GET "https://api.servicecatalogue.example.com/api/export/catalog/pdf" \
  -H "Authorization: Bearer $TOKEN" \
  -o "catalog.pdf"
```

## JavaScript Example

```javascript
const response = await fetch(`/api/export/pdf/${serviceId}`, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

if (response.ok) {
  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  
  const a = document.createElement('a');
  a.href = url;
  a.download = `service-${serviceId}.pdf`;
  a.click();
  
  window.URL.revokeObjectURL(url);
}
```

## Async Export (Large Catalogs)

For large exports, use async endpoint:

### Start Export

```http
POST /api/export/catalog/pdf/async HTTP/1.1

{
  "statusId": 2,
  "notifyEmail": "user@example.com"
}
```

### Response

```json
{
  "exportId": "abc123",
  "status": "Processing",
  "estimatedTime": 120
}
```

### Check Status

```http
GET /api/export/status/abc123
```

### Download When Ready

```http
GET /api/export/download/abc123
```

## Error Responses

### Service Not Found

```json
{
  "success": false,
  "error": {
    "code": "RES_NOT_FOUND",
    "message": "Service not found"
  }
}
```

### Export Failed

```json
{
  "success": false,
  "error": {
    "code": "BIZ_EXPORT_FAILED",
    "message": "Failed to generate PDF"
  }
}
```
