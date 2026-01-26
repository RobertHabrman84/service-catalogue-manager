# Quick Start Guide - Import API

## 1. Prerequisites

- .NET 8 SDK
- Azure Functions Core Tools
- Service Catalogue Manager project
- Postman (optional)

## 2. Local Development Setup

### Start the API

```bash
cd src/backend/ServiceCatalogueManager.Api
func start
```

The API will start on `http://localhost:7071`

### Verify API is Running

```bash
curl http://localhost:7071/api/services/import/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "Service Catalogue Import API",
  "timestamp": "2026-01-26T11:30:00.000Z"
}
```

## 3. Import Your First Service

### Step 1: Create a JSON file

Create `service.json`:
```json
{
  "serviceCode": "ID001",
  "serviceName": "My First Service",
  "version": "v1.0",
  "category": "Services/Architecture",
  "description": "Test service for import",
  "responsibleRoles": [
    {
      "roleName": "Cloud Architect",
      "isPrimaryOwner": true
    }
  ]
}
```

### Step 2: Validate the service

```bash
curl -X POST http://localhost:7071/api/services/import/validate \
  -H "Content-Type: application/json" \
  -d @service.json
```

If valid, you'll see:
```json
{
  "isValid": true,
  "message": "Validation passed - service is ready to import",
  "serviceCode": "ID001"
}
```

### Step 3: Import the service

```bash
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @service.json
```

Success response:
```json
{
  "success": true,
  "message": "Service imported successfully",
  "serviceId": 1,
  "serviceCode": "ID001"
}
```

## 4. Using Postman

### Import Collection

1. Open Postman
2. Click **Import**
3. Select `docs/postman/ServiceCatalogueImportAPI.postman_collection.json`
4. Import environment: `docs/postman/Local.postman_environment.json`

### Configure Environment

1. Select "Service Catalogue Import - Local" environment
2. Set variables:
   - `baseUrl`: `http://localhost:7071/api` (already set)
   - `functionKey`: Leave empty for local development

### Run Requests

1. Select "Import Single Service" request
2. Click **Send**
3. Check response

## 5. Common Workflows

### Workflow 1: Import from PDF

```bash
# 1. Extract PDF to JSON (from tools/pdf-extractor)
cd tools/pdf-extractor
python extract_services.py

# 2. Validate the extracted JSON
curl -X POST http://localhost:7071/api/services/import/validate \
  -H "Content-Type: application/json" \
  -d @output/Enterprise_Scale_LZ.json

# 3. Import if validation passed
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @output/Enterprise_Scale_LZ.json
```

### Workflow 2: Bulk Import

```bash
# 1. Create bulk JSON file with array of services
cat > services-bulk.json << 'EOF'
[
  {
    "serviceCode": "ID001",
    "serviceName": "Service 1",
    "version": "v1.0",
    "category": "Services/Architecture",
    "description": "First service",
    "responsibleRoles": [
      { "roleName": "Cloud Architect", "isPrimaryOwner": true }
    ]
  },
  {
    "serviceCode": "ID002",
    "serviceName": "Service 2",
    "version": "v1.0",
    "category": "Services/Architecture",
    "description": "Second service",
    "responsibleRoles": [
      { "roleName": "Cloud Architect", "isPrimaryOwner": true }
    ]
  }
]
EOF

# 2. Import all services
curl -X POST http://localhost:7071/api/services/import/bulk \
  -H "Content-Type: application/json" \
  -d @services-bulk.json
```

### Workflow 3: Handle Validation Errors

```bash
# Import with invalid data
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d '{
    "serviceCode": "INVALID",
    "serviceName": "Test",
    "version": "v1.0",
    "category": "Services/Architecture",
    "description": "Test",
    "responsibleRoles": [
      { "roleName": "Cloud Architect", "isPrimaryOwner": true }
    ]
  }'
```

Response will show validation errors:
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

## 6. PowerShell Examples

### Import Single Service
```powershell
$service = @{
    serviceCode = "ID001"
    serviceName = "My Service"
    version = "v1.0"
    category = "Services/Architecture"
    description = "Test service"
    responsibleRoles = @(
        @{
            roleName = "Cloud Architect"
            isPrimaryOwner = $true
        }
    )
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod `
    -Uri "http://localhost:7071/api/services/import" `
    -Method Post `
    -ContentType "application/json" `
    -Body $service

Write-Output "Imported: $($response.serviceCode) with ID $($response.serviceId)"
```

### Bulk Import from Folder
```powershell
$jsonFiles = Get-ChildItem -Path ".\output" -Filter "*.json"
$services = @()

foreach ($file in $jsonFiles) {
    $services += Get-Content $file.FullName | ConvertFrom-Json
}

$body = $services | ConvertTo-Json -Depth 20

$response = Invoke-RestMethod `
    -Uri "http://localhost:7071/api/services/import/bulk" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body

Write-Output "Imported $($response.successCount) of $($response.totalCount) services"
```

## 7. Troubleshooting

### API won't start
- Check .NET 8 SDK is installed: `dotnet --version`
- Check Azure Functions Core Tools: `func --version`
- Check port 7071 is available

### Validation errors
- Check [VALIDATION_ERROR_CODES.md](VALIDATION_ERROR_CODES.md)
- Verify JSON schema matches [service-import-schema.json](../schemas/service-import-schema.json)
- Use validation endpoint before import

### Import fails silently
- Check logs in console where API is running
- Verify database connection
- Check all lookup tables are seeded

## 8. Next Steps

- Read full [API Documentation](API.md)
- Review [Validation Error Codes](VALIDATION_ERROR_CODES.md)
- See [Complete Examples](API.md#complete-request-examples)
- Deploy to Azure (see deployment guide)

## 9. Tips

✅ **Always validate first** - Use `/validate` endpoint  
✅ **Check health** - Use `/health` before importing  
✅ **Start small** - Test with minimal service first  
✅ **Use Postman** - Easier for testing and debugging  
✅ **Check logs** - Console output shows detailed errors  
✅ **Bulk import** - More efficient for multiple services  

---

**Ready to import? Start with step 3 above! 🚀**
