# Database

This directory contains all database-related scripts for the Service Catalogue Manager application.

## Structure

```
database/
├── schema/              # Schema definition scripts
│   ├── 001_initial_schema.sql
│   ├── 002_lookup_tables.sql
│   ├── 003_lookup_data.sql
│   ├── 004_views.sql
│   ├── 005_stored_procedures.sql
│   ├── 006_indexes.sql
│   └── 007_functions.sql
├── migrations/          # Flyway-style migrations
│   ├── V1.0.0__initial_schema.sql
│   ├── V1.0.1__add_audit_columns.sql
│   └── V1.0.2__add_full_text_search.sql
├── seeds/              # Seed data scripts
│   ├── 01_lookup_data.sql
│   ├── 02_sample_services_dev.sql
│   └── 03_test_data.sql
└── scripts/            # Utility scripts
    ├── run-migrations.ps1
    ├── seed-database.ps1
    ├── reset-database.ps1
    └── generate-migration.ps1
```

## Prerequisites

- SQL Server 2019+ or Azure SQL Database
- PowerShell 7+ (for running scripts)
- SQL Server Management Studio or Azure Data Studio (optional)

## Quick Start

### 1. Start Local SQL Server

```bash
# Using Docker
docker-compose up -d sqlserver
```

### 2. Run Migrations

```powershell
cd database/scripts
./run-migrations.ps1 -Environment Development
```

### 3. Seed Data

```powershell
./seed-database.ps1 -Environment Development
```

## Connection Strings

### Local Development

```
Server=localhost;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;
```

### Azure SQL Database

```
Server=tcp:scm-prod-weu-sql.database.windows.net,1433;Database=ServiceCatalogueManager;Authentication=Active Directory Default;
```

## Schema Overview

### Main Tables

- `ServiceCatalogItem` - Main service catalog items
- `UsageScenario` - Usage scenarios for each service
- `ServiceDependency` - Service dependencies
- `ServiceScopeCategory` / `ServiceScopeItem` - Scope definitions
- `ServicePrerequisite` - Prerequisites
- `CloudProviderCapability` - Cloud provider capabilities
- `ServiceToolFramework` - Tools and frameworks
- `ServiceLicense` - Licenses
- `ServiceInteraction` - Interaction details
- `ServiceInput` - Input parameters
- `ServiceOutputCategory` / `ServiceOutputItem` - Outputs
- `TimelinePhase` - Timeline phases
- `ServiceSizeOption` - Size options (S/M/L)
- `SizingCriteria` / `SizingParameter` - Sizing details
- `EffortEstimationItem` - Effort estimation
- `SizingExample` - Sizing examples
- `ServiceResponsibleRole` / `ServiceTeamAllocation` - Team allocation
- `ServiceMultiCloudConsideration` - Multi-cloud considerations

### Lookup Tables

- `LU_ServiceCategory` - Service categories (hierarchical)
- `LU_SizeOption` - Size options
- `LU_CloudProvider` - Cloud providers
- `LU_DependencyType` - Dependency types
- `LU_PrerequisiteCategory` - Prerequisite categories
- `LU_LicenseType` - License types
- `LU_ToolCategory` - Tool categories
- `LU_ScopeType` - Scope types
- `LU_InteractionLevel` - Interaction levels
- `LU_RequirementLevel` - Requirement levels
- `LU_Role` - Roles

## Naming Conventions

- Tables: PascalCase (e.g., `ServiceCatalogItem`)
- Lookup tables: `LU_` prefix (e.g., `LU_ServiceCategory`)
- Columns: PascalCase (e.g., `ServiceName`)
- Primary keys: `{TableName}ID` (e.g., `ServiceID`)
- Foreign keys: `{ReferencedTable}ID` (e.g., `CategoryID`)
- Indexes: `IX_{TableName}_{Column}` (e.g., `IX_ServiceCatalogItem_Category`)
- Views: `vw_{Description}` (e.g., `vw_ServiceOverview`)

## Migrations

We use Flyway-style versioned migrations. Each migration file follows the naming convention:

```
V{version}__{description}.sql
```

Example: `V1.0.0__initial_schema.sql`

### Creating a New Migration

```powershell
./scripts/generate-migration.ps1 -Name "add_new_feature"
```

This creates a new migration file with the next version number.

## Best Practices

1. **Always create migrations** - Never modify database schema directly
2. **Test migrations** - Run migrations in dev before staging/prod
3. **Backup before migration** - Always backup before running migrations in prod
4. **Use transactions** - Wrap migrations in transactions where possible
5. **Document changes** - Add comments explaining the purpose of changes
