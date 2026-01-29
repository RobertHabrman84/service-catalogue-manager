# Changelog - Version 2.9.10

**Release Date:** 2026-01-29  
**Type:** Critical Hotfix

---

## 🔴 Critical Bug Fix

### Fixed: Import Service Failure - Invalid Column Names

**Issue:** Import služby selhával s chybou `Invalid column name` pro tabulku `ServicePrerequisite`.

**Error Message:**
```
Microsoft.Data.SqlClient.SqlException (0x80131904): 
Invalid column name 'Description'.
Invalid column name 'PrerequisiteName'.
Invalid column name 'RequirementLevelId'.
```

**Root Cause:**  
Databázové schema v `db_structure.sql` neobsahovalo všechny sloupce, které C# entita `ServicePrerequisite` očekávala. Vznikl nesoulad mezi kódem a databází.

---

## 🔧 Changes Made

### 1. Database Schema Update (`db_structure.sql`)

Rozšířena tabulka `ServicePrerequisite` o následující sloupce:

#### Přidané sloupce:

**Business sloupce:**
- ✅ `PrerequisiteName` (NVARCHAR(MAX) NOT NULL) - název prerequisite
- ✅ `Description` (NVARCHAR(MAX) NULL) - dodatečný popis
- ✅ `RequirementLevelID` (INT NULL) - úroveň požadavku s FK na `LU_RequirementLevel`

**Audit sloupce:**
- ✅ `CreatedDate` (DATETIME2 NOT NULL DEFAULT GETUTCDATE())
- ✅ `CreatedBy` (NVARCHAR(MAX) NULL)
- ✅ `ModifiedDate` (DATETIME2 NOT NULL DEFAULT GETUTCDATE())
- ✅ `ModifiedBy` (NVARCHAR(MAX) NULL)

#### Přidané constraints a indexy:

- ✅ `FK_ServicePrerequisite_LU_RequirementLevel` - Foreign key na `LU_RequirementLevel`
- ✅ `IX_ServicePrerequisite_RequirementLevel` - Index na `RequirementLevelID`

### 2. SQL Hotfix Script

Vytvořen nový soubor: `HOTFIX_ServicePrerequisite_v2.9.10.sql`

**Účel:**  
Pro existující databáze, které již mají tabulku `ServicePrerequisite`, tento skript bezpečně přidá chybějící sloupce bez ztráty dat.

**Features:**
- ✅ Kontrola existence sloupců před přidáním
- ✅ Bezpečná aktualizace NOT NULL sloupců s DEFAULT hodnotami
- ✅ Automatická migrace existujících dat
- ✅ Detailní logging každého kroku
- ✅ Verifikace na konci skriptu

---

## 📊 Technical Details

### Before (v2.9.9):
```sql
CREATE TABLE dbo.ServicePrerequisite (
    PrerequisiteID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL,
    PrerequisiteCategoryID INT NOT NULL,
    PrerequisiteDescription NVARCHAR(MAX) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
```

### After (v2.9.10):
```sql
CREATE TABLE dbo.ServicePrerequisite (
    PrerequisiteID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL,
    PrerequisiteCategoryID INT NOT NULL,
    PrerequisiteName NVARCHAR(MAX) NOT NULL,
    PrerequisiteDescription NVARCHAR(MAX) NOT NULL DEFAULT '',
    Description NVARCHAR(MAX) NULL,
    RequirementLevelID INT NULL REFERENCES LU_RequirementLevel,
    SortOrder INT NOT NULL DEFAULT 0,
    -- Audit fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(MAX) NULL,
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(MAX) NULL
);
```

---

## 🚀 Deployment Instructions

### For New Installations:

1. Use the updated `db_structure.sql` to create the database
2. The schema already includes all required columns

### For Existing Installations:

**Option 1: Recreate database (Development only)**
```powershell
# Drop and recreate using updated schema
sqlcmd -S localhost -d master -Q "DROP DATABASE ServiceCatalogueManager"
sqlcmd -S localhost -d master -i db_structure.sql
```

**Option 2: Apply Hotfix (Production safe)**
```powershell
# Apply hotfix to existing database
sqlcmd -S localhost -d ServiceCatalogueManager -i HOTFIX_ServicePrerequisite_v2.9.10.sql
```

**Option 3: Manual SQL (for custom setups)**
```sql
-- See HOTFIX_ServicePrerequisite_v2.9.10.sql for detailed commands
```

---

## ✅ Verification

After applying the fix, verify the changes:

```sql
-- Check columns
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ServicePrerequisite'
ORDER BY ORDINAL_POSITION;

-- Expected result: 13 columns including all audit and business fields
```

**Expected columns (13 total):**
1. PrerequisiteID
2. ServiceID
3. PrerequisiteCategoryID
4. PrerequisiteName ✨ NEW
5. PrerequisiteDescription
6. Description ✨ NEW
7. RequirementLevelID ✨ NEW
8. SortOrder
9. CreatedDate ✨ NEW
10. CreatedBy ✨ NEW
11. ModifiedDate ✨ NEW
12. ModifiedBy ✨ NEW

---

## 🧪 Testing

### Test Import Functionality:

1. Start the application
2. Try importing a service from JSON (e.g., `examples/Application Landing Zone Design.json`)
3. Verify that:
   - ✅ Import completes without errors
   - ✅ Prerequisites are saved correctly
   - ✅ Audit fields are populated
   - ✅ RequirementLevel is assigned

### Test Query:
```sql
SELECT 
    p.PrerequisiteID,
    p.PrerequisiteName,
    p.PrerequisiteDescription,
    p.Description,
    rl.LevelName AS RequirementLevel,
    p.CreatedDate,
    p.ModifiedDate
FROM ServicePrerequisite p
LEFT JOIN LU_RequirementLevel rl ON p.RequirementLevelID = rl.RequirementLevelID
WHERE p.ServiceID = 1;
```

---

## 📝 Impact Assessment

### Breaking Changes: **NONE** ✅
- Only adding new columns
- All changes are backward compatible
- Existing queries will continue to work

### Data Migration: **AUTOMATIC** ✅
- Existing rows get default values for new columns
- No manual data migration required

### Performance Impact: **MINIMAL** ✅
- New index on RequirementLevelID improves query performance
- Default values prevent NULL checking overhead

---

## 🔄 Rollback Plan

If needed, rollback can be performed by:

1. Removing the new columns (not recommended)
2. Restoring from backup before upgrade (recommended)

**Rollback SQL (use with caution):**
```sql
-- Not recommended - will lose audit trail data
ALTER TABLE ServicePrerequisite DROP COLUMN CreatedDate;
ALTER TABLE ServicePrerequisite DROP COLUMN CreatedBy;
ALTER TABLE ServicePrerequisite DROP COLUMN ModifiedDate;
ALTER TABLE ServicePrerequisite DROP COLUMN ModifiedBy;
ALTER TABLE ServicePrerequisite DROP COLUMN PrerequisiteName;
ALTER TABLE ServicePrerequisite DROP COLUMN Description;
ALTER TABLE ServicePrerequisite DROP CONSTRAINT FK_ServicePrerequisite_LU_RequirementLevel;
ALTER TABLE ServicePrerequisite DROP COLUMN RequirementLevelID;
```

---

## 📚 Related Files

- `db_structure.sql` - Updated base schema
- `HOTFIX_ServicePrerequisite_v2.9.10.sql` - Migration script
- `src/backend/ServiceCatalogueManager.Api/Data/Entities/ServicePrerequisite.cs` - Entity definition
- `src/backend/ServiceCatalogueManager.Api/Services/Import/ImportOrchestrationService.cs` - Import logic

---

## 👥 Contributors

- Claude (AI Assistant)
- Analysis based on error logs provided

---

## 📞 Support

If you encounter any issues:
1. Check the verification queries above
2. Review the error logs
3. Ensure the hotfix was applied correctly
4. Contact development team

---

**Version:** 2.9.10  
**Previous Version:** 2.9.9  
**Next Version:** TBD
