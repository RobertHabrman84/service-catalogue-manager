# Database Migrations

This directory contains database migration scripts for the Service Catalogue Manager.

## Migration Strategy

We use a **versioned migration** approach following the pattern `V{major}.{minor}.{patch}__{description}.sql`.

### Naming Convention

```
V1.0.0__initial_schema.sql
V1.0.1__add_audit_columns.sql
V1.0.2__add_full_text_search.sql
V1.1.0__add_new_feature.sql
```

- **V** - Version prefix (required)
- **1.0.0** - Semantic version number
- **__** - Double underscore separator
- **description** - Brief description with underscores

## Migration Files

| Version | Description | Date |
|---------|-------------|------|
| V1.0.0 | Initial database schema | 2026-01 |
| V1.0.1 | Add audit columns (CreatedAt, UpdatedAt, etc.) | 2026-01 |
| V1.0.2 | Add full-text search capabilities | 2026-01 |

## Running Migrations

### Using EF Core (Recommended)

```bash
# Apply all pending migrations
dotnet ef database update

# Apply specific migration
dotnet ef database update V1.0.1__add_audit_columns

# Rollback to previous migration
dotnet ef database update V1.0.0__initial_schema
```

### Using PowerShell Script

```powershell
# Run all migrations
.\scripts\run-migrations.ps1

# Run with specific environment
.\scripts\run-migrations.ps1 -Environment Development
```

### Manual Execution

```sql
-- Connect to database and run scripts in order
:r V1.0.0__initial_schema.sql
:r V1.0.1__add_audit_columns.sql
:r V1.0.2__add_full_text_search.sql
```

## Creating New Migrations

### Using EF Core

```bash
# Create a new migration
dotnet ef migrations add AddNewFeature

# Generate SQL script
dotnet ef migrations script V1.0.2 V1.1.0 -o migrations/V1.1.0__add_new_feature.sql
```

### Manual Creation

1. Create a new file following the naming convention
2. Include rollback logic in comments
3. Test on a development database first
4. Add entry to this README

## Best Practices

1. **Always backup** before running migrations in production
2. **Test migrations** on a copy of production data
3. **Include rollback scripts** when possible
4. **Keep migrations small** and focused
5. **Never modify** existing migrations after deployment
6. **Use transactions** where supported

## Rollback

Each migration should include rollback instructions as comments:

```sql
-- ROLLBACK:
-- DROP TABLE [dbo].[NewTable];
-- ALTER TABLE [dbo].[ExistingTable] DROP COLUMN [NewColumn];
```

## Environment Configuration

Migrations use connection strings from:
- `local.settings.json` (local development)
- Azure Key Vault (staging/production)

## Troubleshooting

### Migration Failed

1. Check the error message
2. Verify database connectivity
3. Check for conflicting schema changes
4. Review transaction logs

### Rollback Required

1. Identify the last successful migration
2. Run rollback scripts in reverse order
3. Document the issue
4. Create a fix migration

## Related Documentation

- [Database Schema](../schema/README.md)
- [Seed Data](../seeds/README.md)
- [Development Setup](../../docs/guides/development-setup.md)
