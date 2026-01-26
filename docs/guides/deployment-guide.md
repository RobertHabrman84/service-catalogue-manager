# Deployment Guide

## Environments

| Environment | URL | Branch |
|-------------|-----|--------|
| Development | dev.servicecatalogue.example.com | develop |
| Staging | staging.servicecatalogue.example.com | release/* |
| Production | servicecatalogue.example.com | main |

## CI/CD Pipeline

### Pipeline Overview

```
Code Push → Build → Test → Security Scan → Deploy
```

### Pipelines

| Pipeline | Trigger | Actions |
|----------|---------|---------|
| CI | PR, develop | Build, Test, Scan |
| CD-Dev | develop merge | Deploy to Dev |
| CD-Staging | release/* | Deploy to Staging |
| CD-Prod | main merge | Deploy to Production |

## Manual Deployment

### Prerequisites

- Azure CLI installed
- Proper Azure permissions
- Access to Key Vault secrets

### Backend Deployment

```bash
cd src/backend/ServiceCatalogueManager.Api

# Build
dotnet publish -c Release -o ./publish

# Deploy to Azure Functions
func azure functionapp publish <app-name>
```

### Frontend Deployment

```bash
cd src/frontend

# Build
npm run build

# Deploy to Static Web App
swa deploy ./dist --env production
```

## Database Migrations

### Pre-deployment

```bash
# Review pending migrations
cd database/scripts
pwsh ./run-migrations.ps1 -DryRun

# Apply migrations
pwsh ./run-migrations.ps1 -ConnectionString $CONNECTION_STRING
```

### Rollback

```bash
# Rollback last migration
pwsh ./run-migrations.ps1 -Rollback -Steps 1
```

## Configuration

### Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_CONNECTION` | SQL connection string |
| `AZURE_AD_TENANT_ID` | Azure AD tenant |
| `AZURE_AD_CLIENT_ID` | App registration ID |
| `BLOB_STORAGE_CONNECTION` | Blob storage connection |
| `UUBOOKKIT_BASE_URL` | UuBookKit API URL |

### Key Vault

Secrets are stored in Azure Key Vault:
- `database-connection-string`
- `uubookkit-api-key`
- `blob-storage-key`

## Health Checks

### Endpoints

- `/api/health` - Basic health check
- `/api/health/ready` - Readiness check
- `/api/health/live` - Liveness check

### Monitoring

- Azure Application Insights
- Custom dashboards in Azure Monitor
- Alert rules for errors and latency

## Rollback Procedures

### Application Rollback

```bash
# Azure Functions - swap slots
az functionapp deployment slot swap -g <rg> -n <app> --slot staging --target-slot production

# Static Web App - redeploy previous version
swa deploy --deployment-token $TOKEN --app-location ./prev-build
```

### Database Rollback

1. Stop application
2. Restore database from backup
3. Deploy previous application version
4. Verify functionality
5. Resume traffic

## Post-Deployment

1. Run smoke tests
2. Monitor error rates
3. Check performance metrics
4. Verify integrations
5. Update status page
