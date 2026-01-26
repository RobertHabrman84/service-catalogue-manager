# Service Catalogue Manager

[![Build Status](https://dev.azure.com/yourorg/service-catalogue-manager/_apis/build/status/CI?branchName=main)](https://dev.azure.com/yourorg/service-catalogue-manager/_build/latest?definitionId=1&branchName=main)
[![Azure Static Web Apps](https://img.shields.io/badge/Azure-Static%20Web%20Apps-blue)](https://azure.microsoft.com/services/app-service/static/)
[![.NET 8](https://img.shields.io/badge/.NET-8.0-purple)](https://dotnet.microsoft.com/)
[![React 18](https://img.shields.io/badge/React-18.x-blue)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Enterprise web application for managing service catalog items for cloud architecture and consulting services.

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
