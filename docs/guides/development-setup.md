# Development Setup Guide

## Prerequisites

### Required Software

| Software | Version | Download |
|----------|---------|----------|
| Node.js | 18.x LTS | https://nodejs.org |
| .NET SDK | 8.0 | https://dotnet.microsoft.com |
| Azure Functions Core Tools | 4.x | https://github.com/Azure/azure-functions-core-tools |
| SQL Server | 2019+ or Azure SQL | - |
| Git | Latest | https://git-scm.com |
| VS Code | Latest | https://code.visualstudio.com |

### Recommended VS Code Extensions

- C# Dev Kit
- Azure Functions
- ESLint
- Prettier
- Tailwind CSS IntelliSense

## Clone Repository

```bash
git clone https://dev.azure.com/your-org/service-catalogue-manager/_git/service-catalogue-manager
cd service-catalogue-manager
```

## Database Setup

### Option 1: Local SQL Server

```bash
# Create database
sqlcmd -S localhost -Q "CREATE DATABASE ServiceCatalogueManager"

# Run migrations
cd database/scripts
pwsh ./run-migrations.ps1 -ConnectionString "Server=localhost;Database=ServiceCatalogueManager;Trusted_Connection=True"
```

### Option 2: Docker

```bash
docker-compose up -d sqlserver
```

## Backend Setup

```bash
cd src/backend/ServiceCatalogueManager.Api

# Copy settings
cp local.settings.example.json local.settings.json

# Edit local.settings.json with your connection string

# Restore packages
dotnet restore

# Run
func start
```

Backend will be available at `http://localhost:7071`

## Frontend Setup

```bash
cd src/frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env.development

# Start development server
npm run dev
```

Frontend will be available at `http://localhost:5173`

## Verify Installation

1. Open http://localhost:5173
2. Login with test credentials
3. Verify API connection in browser console

## Common Issues

### Port Already in Use

```bash
# Find process using port
netstat -ano | findstr :7071

# Kill process
taskkill /PID <pid> /F
```

### Database Connection Failed

- Verify SQL Server is running
- Check connection string in local.settings.json
- Ensure firewall allows connections

### CORS Errors

Add frontend URL to allowed origins in Azure Functions configuration.

## Next Steps

1. Read [Coding Standards](./coding-standards.md)
2. Review [Git Workflow](./git-workflow.md)
3. Explore [API Documentation](../api/README.md)
