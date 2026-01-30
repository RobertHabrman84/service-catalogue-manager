# Database Migration: AddItemNameColumns

**Date:** 2026-01-29  
**Migration ID:** 20260129231604  
**Status:** ✅ Ready to apply

---

## Overview

This migration adds the `ItemName` column to two tables:
- `ServiceScopeItem`
- `ServiceOutputItem`

This resolves the SQL error: **"Invalid column name 'ItemName'"** that occurred during service import operations.

---

## Problem Description

The Entity Framework models `ServiceScopeItem` and `ServiceOutputItem` both contain an `ItemName` property, but the database schema was missing these columns. This caused `DbUpdateException` errors when trying to insert data:

```
Microsoft.EntityFrameworkCore.DbUpdateException: An error occurred while saving the entity changes.
---> Microsoft.Data.SqlClient.SqlException (0x80131904): Invalid column name 'ItemName'.
```

---

## Changes

### Table: ServiceScopeItem
**Added column:**
- `ItemName` NVARCHAR(500) NOT NULL DEFAULT ''

### Table: ServiceOutputItem
**Added column:**
- `ItemName` NVARCHAR(500) NOT NULL DEFAULT ''

---

## Files Modified

### 1. Database Schema
- `db_structure.sql` - Updated table definitions

### 2. Entity Framework
- `Migrations/20260129231604_AddItemNameColumns.cs` - EF Core migration
- `Migrations/ServiceCatalogDbContextModelSnapshot.cs` - Updated model snapshot
- `Data/DbContext/ServiceCatalogDbContext.cs` - Added property mappings

### 3. SQL Scripts
- `scripts/migrations/20260129_AddItemNameColumns.sql` - Forward migration
- `scripts/migrations/20260129_RollbackItemNameColumns.sql` - Rollback script

---

## How to Apply

### Option 1: Using Entity Framework (Recommended for development)
```bash
cd src/backend/ServiceCatalogueManager.Api
dotnet ef database update
```

### Option 2: Using SQL Script (Recommended for production)
```bash
# Connect to your SQL Server database
sqlcmd -S <server> -d <database> -i scripts/migrations/20260129_AddItemNameColumns.sql
```

### Option 3: Azure SQL Database
```bash
# Using Azure CLI
az sql db execute \
  --resource-group <rg-name> \
  --server <server-name> \
  --name <db-name> \
  --file scripts/migrations/20260129_AddItemNameColumns.sql
```

---

## How to Rollback

If you need to revert this migration:

### Using Entity Framework
```bash
dotnet ef database update 20260126081837_InitialCreate
```

### Using SQL Script
```bash
sqlcmd -S <server> -d <database> -i scripts/migrations/20260129_RollbackItemNameColumns.sql
```

---

## Testing

After applying the migration, verify:

1. ✅ Column exists in ServiceScopeItem:
```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ServiceScopeItem' AND COLUMN_NAME = 'ItemName';
```

2. ✅ Column exists in ServiceOutputItem:
```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ServiceOutputItem' AND COLUMN_NAME = 'ItemName';
```

3. ✅ Import functionality works:
- Test service import via API endpoint
- Verify no `DbUpdateException` errors occur
- Check that ItemName values are properly saved

---

## Impact Assessment

### Breaking Changes
❌ None - This is an additive change only

### Data Migration Required
❌ No existing data migration needed (new columns have default values)

### Downtime Required
❌ No downtime required (can be applied online)

### Application Restart Required
✅ Yes - Application must be restarted after migration to use updated model

---

## Related Issues

- Resolves: SQL Error 207 "Invalid column name 'ItemName'"
- Affects: `ImportOrchestrationService.ImportScopeAsync()` 
- Affects: `ImportOrchestrationService.ImportOutputsAsync()`

---

## Compatibility

- **EF Core Version:** 8.0.11
- **SQL Server:** 2019+
- **Azure SQL:** Compatible
- **Backward Compatible:** ✅ Yes (with rollback)
