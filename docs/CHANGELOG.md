# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.8.0] - 2026-01-28

### Added - Flexible JSON Import Support
- **Custom JSON Converters** for backward-compatible import
  - `ScopeItemsFlexibleConverter` - accepts both string arrays and object arrays for scope items
  - `ResponsibilitiesFlexibleConverter` - accepts both string and string array for responsibilities
  - `CharacteristicsFlexibleConverter` - accepts both old and new format for characteristics

- **Extended Import Models**
  - `SizeOptionImportModel` - added support for new JSON fields (`sizeCode`, `effort`, `teamAllocation`, `effortBreakdown`, `complexityAdditions`, `sizingCriteria`, `scopeDependencies`)
  - `SizingExampleImportModel` - added `exampleName`, `scenario`, `deliverables` fields
  - Helper methods for format normalization (`GetEffectiveSizeName()`, `GetTeamAllocationsNormalized()`, etc.)

- **Null-safe Helper Methods**
  - `ToolsAndEnvironmentImportModel` - added `GetCollaborationToolsSafe()` and other safe accessors

### Changed
- `ImportOrchestrationService.ImportSizeOptionsAsync()` - now uses normalized helper methods for both old and new formats
- `ImportFunction` - centralized `JsonSerializerOptions` for consistent deserialization
- All import models now support both legacy and new JSON structures

### Fixed
- Import now accepts JSON files with `items` as string arrays (not just object arrays)
- Import now accepts JSON files with `responsibilities` as string arrays
- Import now accepts JSON files missing `collaborationTools` field
- Import now accepts JSON files with `sizeCode` instead of `sizeName`
- Import now accepts JSON files with `effort` object instead of `effortRange` string
- Import now accepts JSON files with array-based `teamAllocation` instead of object-based

### Technical Details
- No database schema changes required
- Full backward compatibility with existing JSON format
- All conversions happen at deserialization/import layer

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
