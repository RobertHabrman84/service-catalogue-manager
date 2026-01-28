# Service Catalogue Manager - Deployment Guide

## 🚀 Quick Start (Sandbox Environment)

### Prerequisites
- .NET 8.0 SDK
- Node.js 18+ 
- Azure Functions Core Tools v4
- PowerShell 7+ (optional, for scripts)

### 1. Clone Repository
```bash
git clone <repository-url>
cd service-catalogue-manager
```

### 2. Start Application (SQLite Mode - Default)
```powershell
# Use the fixed script
./start-all-fixed.ps1

# Or with specific options
./start-all-fixed.ps1 -UseSQLite -RecreateDb
```

### 3. Access Application
- **Backend API**: http://localhost:7071/api
- **Frontend**: http://localhost:3000
- **API Health**: http://localhost:7071/api/health

## 🔧 Configuration Options

### Database Options

#### Option 1: SQLite (Default - Sandbox)
```powershell
./start-all-fixed.ps1 -UseSQLite
```
- Database file: `ServiceCatalogueManager.db`
- No Docker required
- Perfect for development/sandbox

#### Option 2: Docker SQL Server
```powershell
./start-all-fixed.ps1 -UseDocker
```
- Requires Docker Desktop
- SQL Server 2022 container
- Connection: `localhost:1433`

### Mode Options

#### Backend Only
```powershell
./start-all-fixed.ps1 -BackendOnly
```

#### Frontend Only
```powershell
./start-all-fixed.ps1 -FrontendOnly
```

#### Database Only
```powershell
./start-all-fixed.ps1 -DbOnly
```

## 📁 Project Structure

```
service-catalogue-manager/
├── src/
│   ├── backend/ServiceCatalogueManager.Api/  # .NET 8 Azure Functions API
│   └── frontend/                           # Next.js React frontend
├── database/
│   ├── scripts/
│   │   ├── setup-db.ps1           # Docker SQL Server setup
│   │   └── setup-sqlite.ps1       # SQLite setup (sandbox)
│   └── schema/                    # Database schema files
├── start-all-fixed.ps1            # Fixed main script
└── start-all.ps1                # Original script (requires Docker)
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Database Connection Errors
**Problem**: "Cannot open database 'ServiceCatalogueManager' requested by the login."

**Solution**: Use SQLite mode for sandbox:
```powershell
./start-all-fixed.ps1 -UseSQLite -RecreateDb
```

#### 2. Port Already in Use
**Problem**: "Port 7071 is already in use"

**Solution**: Change ports in `local.settings.json` or kill existing processes

#### 3. Missing Dependencies
**Problem**: "node_modules not found"

**Solution**: 
```bash
cd src/frontend
npm install
```

#### 4. .NET Build Errors
**Problem**: Build fails with package errors

**Solution**:
```bash
cd src/backend/ServiceCatalogueManager.Api
dotnet restore
dotnet build
```

### Log Files
Logs are stored in:
- Backend: `logs/backend-YYYY-MM-DD-HHMMSS.log`
- Frontend: `logs/frontend-YYYY-MM-DD-HHMMSS.log`

## 🔐 Configuration Files

### SQLite Configuration
File: `src/backend/ServiceCatalogueManager.Api/local.settings.sqlite.json`
```json
{
  "AzureSQL__ConnectionString": "Data Source=ServiceCatalogueManager.db;Version=3;",
  "ConnectionStrings__AzureSQL": "Data Source=ServiceCatalogueManager.db;Version=3;"
}
```

### Docker SQL Server Configuration
File: `src/backend/ServiceCatalogueManager.Api/local.settings.json`
```json
{
  "AzureSQL__ConnectionString": "Server=localhost;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;",
  "ConnectionStrings__AzureSQL": "Server=localhost;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
}
```

## 🧪 Testing

### Test Backend API
```bash
curl http://localhost:7071/api/health
```

### Test Frontend
Open: http://localhost:3000

### Test Database Connection
```bash
# For SQLite (check if file exists)
ls ServiceCatalogueManager.db

# For Docker SQL Server
docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT 1"
```

## 📝 Development Workflow

### 1. Start Development Environment
```powershell
./start-all-fixed.ps1 -UseSQLite
```

### 2. Make Changes
- Backend: Edit files in `src/backend/ServiceCatalogueManager.Api/`
- Frontend: Edit files in `src/frontend/`

### 3. Test Changes
- Backend will auto-restart on file changes
- Frontend will hot-reload on file changes

### 4. Clean Up
```powershell
# Stop all services (close PowerShell windows)
# Or manually kill processes on ports 7071 and 3000
```

## 🚨 Important Notes

### Sandbox Environment
- Default mode uses SQLite database (no Docker required)
- Database file is created in project root: `ServiceCatalogueManager.db`
- All data is local to the sandbox

### Production Deployment
- Use Docker SQL Server for production: `./start-all-fixed.ps1 -UseDocker`
- Configure proper connection strings
- Set up proper authentication (Azure AD)
- Use Application Insights for monitoring

### Database Schema
- EF Core migrations are automatically applied
- Migrations are in: `src/backend/ServiceCatalogueManager.Api/Migrations/`
- Initial migration: `20260126081837_InitialCreate`

## 🔗 Useful Commands

### Database Operations
```powershell
# Recreate database
./start-all-fixed.ps1 -RecreateDb

# Check database health
./start-all-fixed.ps1 -DbOnly
```

### Build Operations
```powershell
# Clean build
./start-all-fixed.ps1 -CleanBuild

# Skip build (faster restart)
./start-all-fixed.ps1 -SkipBuild
```

### Service Control
```powershell
# Start only backend
./start-all-fixed.ps1 -BackendOnly

# Start only frontend  
./start-all-fixed.ps1 -FrontendOnly

# Skip health checks (faster)
./start-all-fixed.ps1 -SkipHealthCheck
```

## 📞 Need Help?

Check the logs in `logs/` directory or:
1. Verify all prerequisites are installed
2. Check configuration files
3. Review error messages in logs
4. Ensure ports are available
5. Try SQLite mode for sandbox issues