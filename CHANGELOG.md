# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- React frontend with TypeScript
- Azure Functions backend with .NET 8
- Azure SQL Database schema
- Azure DevOps CI/CD pipelines
- E2E tests with Playwright
- Performance tests with k6

## [1.0.0] - 2026-01-22

### Added
- **Service Catalog Management**
  - Create, read, update, delete service catalog items
  - Support for comprehensive service metadata
  - Usage scenarios definition
  - Dependencies management
  - Scope definition (in/out of scope)
  - Prerequisites tracking
  - Tools and licenses management
  - Input/output parameters
  - Timeline and phases
  - Sizing options (S/M/L)
  - Effort estimation
  - Team allocation
  - Multi-cloud considerations

- **Export Functionality**
  - Export to PDF format
  - Export to Markdown format
  - Export history tracking
  - Customizable export options

- **uuBookKit Integration**
  - Publish to uuBookKit platform
  - Sync catalog with uuBookKit
  - Publish status tracking

- **Authentication & Authorization**
  - Azure AD integration
  - Role-based access control
  - Protected routes

- **User Interface**
  - Responsive dashboard
  - Service catalog list with filtering
  - Service detail view
  - Form-based service editor
  - Export dialog
  - Settings page

- **Infrastructure**
  - Azure Static Web Apps hosting
  - Azure Functions serverless backend
  - Azure SQL Database
  - Azure Blob Storage for exports
  - Azure Key Vault for secrets
  - Azure Application Gateway with WAF

### Security
- HTTPS encryption
- Azure AD authentication
- Input validation
- SQL injection prevention
- XSS protection

### Documentation
- Architecture documentation
- API documentation
- Development guides
- Deployment guides
