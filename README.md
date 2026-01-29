# Service Catalogue Manager

[![Build Status](https://dev.azure.com/yourorg/service-catalogue-manager/_apis/build/status/CI?branchName=main)](https://dev.azure.com/yourorg/service-catalogue-manager/_build/latest?definitionId=1&branchName=main)
[![Azure Static Web Apps](https://img.shields.io/badge/Azure-Static%20Web%20Apps-blue)](https://azure.microsoft.com/services/app-service/static/)
[![.NET 8](https://img.shields.io/badge/.NET-8.0-purple)](https://dotnet.microsoft.com/)
[![React 18](https://img.shields.io/badge/React-18.x-blue)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Enterprise web application for managing service catalog items for cloud architecture and consulting services.

## 🚀 Quick Start

**One-command startup** - Run the entire application:

```powershell
.\start-scm.ps1
```

This script will:
1. ✅ Create SQL Server database in Docker
2. ✅ Initialize database schema from db_structure.sql
3. ✅ Build the backend (.NET)
4. ✅ Build the frontend (React)
5. ✅ Start both services in separate windows

**Prerequisites:**
- Docker Desktop (running)
- .NET 8 SDK
- Node.js 18+
- PowerShell 7+

**After startup:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:7071
- Database: localhost:1433 (in Docker container)

**To stop:**
- Close the backend and frontend terminal windows
- Run: `docker stop scm-sqlserver`

## ⚡ Latest Updates (29. ledna 2026)

**✅ Version 2.9.3 - Critical Bugfix 🔴**

- 🐛 **FIXED:** Missing primary key configuration for LU_EffortCategory entity
- ✅ Application is now fully functional (was completely broken)
- 📝 See CHANGELOG-v2.9.3.md for detailed fix documentation


**✅ Version 2.9 - One-Command Startup ⭐⭐⭐**

New features:
- 🚀 **start-scm.ps1** - Complete automated startup script
- 🐳 Automatic Docker database setup with schema initialization
- 🔧 Automatic build and startup of all services
- ✅ No manual configuration needed

**✅ Version 1.5 - FINAL JSON FIX (PREVIOUS) ⭐⭐⭐**

This version includes ALL previous fixes PLUS:
- 📄 **PERFECT JSON guaranteed to work** (Application_Landing_Zone_Design_PERFECT.json)
- 🔧 Fixed missing collaborationTools field
- 🔧 All fields have correct types (no unexpected nulls)
- 🔧 All 31 tools properly structured
- ✅ **JSON import GUARANTEED TO WORK**

**All previous fixes included:**
- 🔧 start-all.ps1 improvements (30s timeout) - v1.4
- 🔧 Method signature fixes - v1.3
- 🔧 ServiceCatalogFunctions.cs syntax - v1.2
- 🔧 Microsoft.Identity.Web 3.9.0 - v1.2
- 🔧 IN-MEMORY database fallback - v1.1
- 🔧 Enhanced error handling - v1.1
- 🔧 Authorization fixes - v1.1
- 🔧 Backend compilation fixes - v1.0
- 🔧 PDF Extractor validation - v1.0

**📖 Documentation:**
- [JSON-IMPORT-FIX-v1.5-FINAL.md](JSON-IMPORT-FIX-v1.5-FINAL.md) - **v1.5 GUARANTEED FIX** ⭐
- [docs/IMPORT-TO-MSSQL-VERIFICATION.md](docs/IMPORT-TO-MSSQL-VERIFICATION.md) - **VERIFY DATA SAVED TO MSSQL** ⭐⭐⭐
- [docs/IMPORT-DATABASE-VERIFICATION.md](docs/IMPORT-DATABASE-VERIFICATION.md) - Detailed import verification guide
- [scripts/README.md](scripts/README.md) - Test scripts documentation
- [SCRIPT-AND-JSON-FIXES-v1.4.md](SCRIPT-AND-JSON-FIXES-v1.4.md) - v1.4 improvements
- [SIGNATURE-FIXES-v1.3.md](SIGNATURE-FIXES-v1.3.md) - v1.3 method signatures
- [BUILD-FIXES-v1.2.md](BUILD-FIXES-v1.2.md) - v1.2 syntax fixes  
- [RUNTIME-FIXES-v1.1.md](RUNTIME-FIXES-v1.1.md) - v1.1 runtime fixes
- [OPRAVY-CHANGELOG.md](OPRAVY-CHANGELOG.md) - v1.0 initial fixes  
- [examples/](examples/) - **PERFECT** validated JSON ready for import ⭐

## ✅ Import Database Verification

**Question: Are JSON import data actually saved to MSSQL database?**

**Answer: YES!** ✅ Data from JSON import are persistently saved to MSSQL database.

**Quick Verification:**
```powershell
# 1. Start backend API (Terminal 1)
cd src/backend/ServiceCatalogueManager.Api
func start

# 2. Run verification test (Terminal 2)
./scripts/test-import-to-database.ps1
```

**What this test does:**
- ✅ Tests SQL Server connection
- ✅ Imports JSON via API
- ✅ **Verifies data in MSSQL database with direct SQL query**
- ✅ Shows detailed report with all related records

**Expected result:**
```
✅ SUCCESS: Data from JSON was successfully saved to MSSQL database!

Database Verification Details:
  Service ID:         123
  Service Code:       TEST-SERVICE-001
  Related Data:
    - Usage Scenarios:  2
    - Inputs:           3
    - Output Categories: 1
```

**See detailed documentation:**
- [docs/IMPORT-TO-MSSQL-VERIFICATION.md](docs/IMPORT-TO-MSSQL-VERIFICATION.md) - Complete verification guide
- [scripts/test-import-to-database.ps1](scripts/test-import-to-database.ps1) - PowerShell test script
- [scripts/test-import-to-database.sh](scripts/test-import-to-database.sh) - Bash test script
- [scripts/verify-import-data.sql](scripts/verify-import-data.sql) - SQL verification script

## 🎯 Overview

The Service Catalogue Manager enables organizations to:

- **Create & Manage** service catalog items with comprehensive metadata
- **Define** sizing options, prerequisites, dependencies, and deliverables
- **Export** services to Markdown and PDF formats
- **Publish** documentation to uuBookKit platform
- **Collaborate** with role-based access via Azure AD

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   React SPA     │────▶│ Azure Functions │────▶│   Azure SQL     │
│ (Static Web App)│     │   (.NET 8)      │     │   Database      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       
         │                       ▼                       
         │              ┌─────────────────┐              
         └─────────────▶│    Azure AD     │              
                        │   (Entra ID)    │              
                        └─────────────────┘              
```

## 🚀 Quick Start

### Prerequisites

- Node.js 20.x or later
- .NET 8.0 SDK
- Azure CLI
- Azure Functions Core Tools v4
- SQL Server (local) or Azure SQL Database

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://dev.azure.com/yourorg/service-catalogue-manager/_git/service-catalogue-manager
   cd service-catalogue-manager
   ```

2. **Setup environment**
   ```powershell
   ./scripts/dev/setup-local-env.ps1
   ```

3. **Start the database** (using Docker)
   ```bash
   docker-compose up -d
   ```

4. **Run database migrations**
   ```powershell
   ./database/scripts/run-migrations.ps1 -Environment local
   ```

5. **Start the backend**
   ```powershell
   ./scripts/dev/start-backend.ps1
   ```

6. **Start the frontend** (in a new terminal)
   ```powershell
   ./scripts/dev/start-frontend.ps1
   ```

7. **Access the application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:7071/api

## 📁 Project Structure

```
service-catalogue-manager/
├── .azuredevops/          # Azure DevOps configuration
├── .vscode/               # VS Code settings
├── docs/                  # Documentation
│   ├── architecture/      # Architecture documentation
│   ├── guides/            # Development guides
│   ├── api/               # API documentation
│   └── adr/               # Architecture Decision Records
├── database/              # Database scripts
│   ├── schema/            # Schema definitions
│   ├── migrations/        # Database migrations
│   ├── seeds/             # Seed data
│   └── scripts/           # Utility scripts
├── pipelines/             # Azure DevOps pipelines
├── src/
│   ├── frontend/          # React application
│   └── backend/           # Azure Functions API
├── tests/
│   ├── e2e/               # End-to-end tests (Playwright)
│   └── performance/       # Performance tests (k6)
└── scripts/               # Development scripts
```

## 🔧 Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Frontend | React + TypeScript | 18.x |
| UI Framework | TailwindCSS | 3.x |
| Build Tool | Vite | 5.x |
| Backend | Azure Functions | .NET 8 |
| ORM | Entity Framework Core | 8.x |
| Database | Azure SQL Database | - |
| Authentication | Azure AD (Entra ID) | - |
| E2E Testing | Playwright | - |
| Unit Testing | Vitest / xUnit | - |

## 📖 Documentation

- [Development Setup Guide](docs/guides/development-setup.md)
- [Architecture Overview](docs/architecture/overview.md)
- [API Documentation](docs/api/README.md)
- [Testing Guide](docs/guides/testing-guide.md)
- [Deployment Guide](docs/guides/deployment-guide.md)

## 🧪 Testing

### Unit Tests

```bash
# Frontend
cd src/frontend && npm test

# Backend
cd src/backend && dotnet test
```

### E2E Tests

```bash
cd tests/e2e && npm run test
```

### Performance Tests

```bash
cd tests/performance/k6 && k6 run scripts/load-test.js
```

## 🚢 Deployment

The application is deployed automatically via Azure DevOps pipelines:

- **Development**: Triggered on push to `develop` branch
- **Staging**: Triggered on push to `release/*` branches
- **Production**: Triggered manually after staging approval

See [Deployment Guide](docs/guides/deployment-guide.md) for details.

## 🤝 Contributing

1. Create a feature branch from `develop`
2. Make your changes
3. Write/update tests
4. Submit a pull request

See [Contributing Guide](docs/guides/contributing.md) for more details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions or issues:

- Create an issue in Azure DevOps
- Contact the development team
- Check the [Troubleshooting Guide](docs/guides/troubleshooting.md)

---

**Version**: 1.0.0  
**Last Updated**: January 2026
=======
# service-catalogue-manager
>>>>>>> f4f2cc2941dbe01c84e5780a8efc644c189e30db
