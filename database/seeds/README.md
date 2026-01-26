# Database Seed Data

This directory contains seed data scripts for the Service Catalogue Manager.

## Overview

Seed data is used to populate the database with initial reference data and sample records for development/testing.

## Seed Files

| File | Description | Environment |
|------|-------------|-------------|
| `01_lookup_data.sql` | Reference/lookup table data | All |
| `02_sample_services_dev.sql` | Sample services for development | Development |
| `03_test_data.sql` | Test data for automated testing | Test |

## Execution Order

Seeds must be executed in numerical order:

```bash
1. 01_lookup_data.sql      # Required for all environments
2. 02_sample_services_dev.sql  # Development only
3. 03_test_data.sql        # Test environment only
```

## Running Seeds

### Using PowerShell Script

```powershell
# Seed all data
.\scripts\seed-database.ps1

# Seed specific environment
.\scripts\seed-database.ps1 -Environment Development

# Seed only lookup data
.\scripts\seed-database.ps1 -LookupOnly
```

### Manual Execution

```sql
-- Run in SQL Server Management Studio or sqlcmd
:r 01_lookup_data.sql
:r 02_sample_services_dev.sql
```

## Seed Data Details

### 01_lookup_data.sql

Contains reference data for:

- **Service Status**: Draft, Pending Review, Active, Deprecated, Retired
- **Service Category**: Infrastructure, Application, Data, Security, etc.
- **Business Unit**: IT Operations, Development, Security, etc.
- **Responsible Role**: Service Owner, Technical Lead, Developer, etc.
- **Dependency Type**: Required, Optional, Runtime, Build
- **Interaction Type**: REST API, GraphQL, Message Queue, etc.
- **Data Type**: String, Number, Boolean, JSON, etc.
- **License Type**: Open Source, Commercial, Enterprise, etc.
- **Cloud Provider**: Azure, AWS, GCP, On-Premise
- **Effort Category**: Analysis, Development, Testing, etc.
- **Scope Category**: Functional, Technical, Security, etc.

### 02_sample_services_dev.sql

Contains sample services for development:

- Example infrastructure service
- Example application service
- Example integration service
- Complete with scenarios, dependencies, inputs/outputs

### 03_test_data.sql

Contains data specifically for automated tests:

- Predictable IDs for test assertions
- Edge case data
- Validation test data

## Environment Guidelines

| Environment | Lookup Data | Sample Data | Test Data |
|-------------|-------------|-------------|-----------|
| Development | ✅ | ✅ | Optional |
| Test | ✅ | ❌ | ✅ |
| Staging | ✅ | ❌ | ❌ |
| Production | ✅ | ❌ | ❌ |

## Idempotency

All seed scripts are designed to be **idempotent** - they can be run multiple times without creating duplicate data:

```sql
-- Example pattern
IF NOT EXISTS (SELECT 1 FROM [dbo].[ServiceStatus] WHERE [Code] = 'ACTIVE')
BEGIN
    INSERT INTO [dbo].[ServiceStatus] ...
END
```

## Customization

### Adding New Lookup Values

1. Add INSERT statement to `01_lookup_data.sql`
2. Use the existing pattern for consistency
3. Include all required fields

### Adding Sample Services

1. Add to `02_sample_services_dev.sql`
2. Include all related data (scenarios, dependencies, etc.)
3. Use realistic but clearly fake data

## Best Practices

1. **Never include real customer data**
2. **Use clear naming** to identify seed data (e.g., "Sample Service A")
3. **Maintain referential integrity** - insert in correct order
4. **Document special cases** in comments
5. **Keep production seeds minimal** - only essential lookup data

## Clearing Seed Data

### Development Reset

```powershell
# Reset entire database
.\scripts\reset-database.ps1

# This will:
# 1. Drop all data
# 2. Re-run migrations
# 3. Re-run seeds
```

### Selective Clear

```sql
-- Clear sample services (keep lookups)
DELETE FROM [dbo].[ServiceCatalogItem] WHERE ServiceCode LIKE 'SAMPLE-%';
```

## Related Documentation

- [Database Schema](../schema/README.md)
- [Migrations](../migrations/README.md)
- [Reset Database Script](../scripts/reset-database.ps1)
