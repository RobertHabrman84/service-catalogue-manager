# 🔧 ServicePrerequisite Database Fix - README

**Version:** 2.9.10  
**Date:** 2026-01-29  
**Type:** Critical Hotfix

---

## 🎯 Quick Summary

Tato oprava řeší kritickou chybu při importu služeb způsobenou chybějícími sloupci v tabulce `ServicePrerequisite`.

**Error Fixed:**
```
Invalid column name 'Description'
Invalid column name 'PrerequisiteName'  
Invalid column name 'RequirementLevelId'
```

---

## 📦 What's Included

1. **db_structure.sql** - Aktualizované databázové schema (v root složce)
2. **HOTFIX_ServicePrerequisite_v2.9.10.sql** - SQL skript pro upgrade existujících databází
3. **CHANGELOG-v2.9.10.md** - Detailní seznam změn

---

## 🚀 How to Apply

### Option A: New Database Installation (Recommended for Development)

**Pro nové instalace - použijte aktualizovaný db_structure.sql:**

```powershell
# 1. Připojte se k SQL Serveru
sqlcmd -S localhost -U sa -P YourPassword

# 2. Vytvořte databázi (pokud neexistuje)
CREATE DATABASE ServiceCatalogueManager;
GO

# 3. Spusťte aktualizovaný schema skript
sqlcmd -S localhost -d ServiceCatalogueManager -i db_structure.sql
```

**Výhody:**
- ✅ Čisté schema s všemi sloupci
- ✅ Žádná migrace dat
- ✅ Vhodné pro dev/test prostředí

---

### Option B: Upgrade Existing Database (Recommended for Production)

**Pro existující databáze - použijte HOTFIX skript:**

```powershell
# Aplikace hotfixu na existující databázi
sqlcmd -S localhost -d ServiceCatalogueManager -i HOTFIX_ServicePrerequisite_v2.9.10.sql
```

**Výhody:**
- ✅ Zachová existující data
- ✅ Bezpečné pro produkci
- ✅ Idempotentní (lze spustit vícekrát)
- ✅ Detailní logging

**Co skript udělá:**
1. Zkontroluje, zda sloupce neexistují
2. Přidá pouze chybějící sloupce
3. Nastaví DEFAULT hodnoty pro NOT NULL sloupce
4. Vytvoří foreign key a indexy
5. Provede verifikaci

---

### Option C: Manual Update (For Custom Scenarios)

Pokud potřebujete manuální kontrolu, můžete použít jednotlivé SQL příkazy:

```sql
-- Přidání sloupců
ALTER TABLE ServicePrerequisite ADD PrerequisiteName NVARCHAR(MAX) NOT NULL DEFAULT 'Unknown';
ALTER TABLE ServicePrerequisite ADD Description NVARCHAR(MAX) NULL;
ALTER TABLE ServicePrerequisite ADD RequirementLevelID INT NULL;
ALTER TABLE ServicePrerequisite ADD CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
ALTER TABLE ServicePrerequisite ADD CreatedBy NVARCHAR(MAX) NULL;
ALTER TABLE ServicePrerequisite ADD ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE();
ALTER TABLE ServicePrerequisite ADD ModifiedBy NVARCHAR(MAX) NULL;

-- Přidání foreign key
ALTER TABLE ServicePrerequisite 
    ADD CONSTRAINT FK_ServicePrerequisite_LU_RequirementLevel 
    FOREIGN KEY (RequirementLevelID) REFERENCES LU_RequirementLevel(RequirementLevelID);

-- Přidání indexu
CREATE INDEX IX_ServicePrerequisite_RequirementLevel ON ServicePrerequisite(RequirementLevelID);
```

---

## ✅ Verification

### Krok 1: Zkontrolujte sloupce

```sql
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ServicePrerequisite'
ORDER BY ORDINAL_POSITION;
```

**Očekávaný výsledek: 13 sloupců**

| Column Name | Data Type | Nullable |
|-------------|-----------|----------|
| PrerequisiteID | int | NO |
| ServiceID | int | NO |
| PrerequisiteCategoryID | int | NO |
| PrerequisiteName | nvarchar | NO |
| PrerequisiteDescription | nvarchar | NO |
| Description | nvarchar | YES |
| RequirementLevelID | int | YES |
| SortOrder | int | NO |
| CreatedDate | datetime2 | NO |
| CreatedBy | nvarchar | YES |
| ModifiedDate | datetime2 | NO |
| ModifiedBy | nvarchar | YES |

### Krok 2: Zkontrolujte foreign keys

```sql
SELECT 
    fk.name AS ConstraintName,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'ServicePrerequisite';
```

**Očekávaný výsledek:**
- FK_ServicePrerequisite_ServiceCatalogItem (ServiceID → ServiceCatalogItem)
- FK_ServicePrerequisite_LU_PrerequisiteCategory (PrerequisiteCategoryID → LU_PrerequisiteCategory)
- FK_ServicePrerequisite_LU_RequirementLevel (RequirementLevelID → LU_RequirementLevel) ← **NOVÝ**

### Krok 3: Test importu

1. Spusťte aplikaci
2. Importujte testovací službu:
   ```powershell
   # Použijte příklad z examples složky
   curl -X POST http://localhost:7071/api/services/import `
        -H "Content-Type: application/json" `
        -d @"examples/Application Landing Zone Design.json"
   ```
3. Ověřte, že import proběhl úspěšně (HTTP 200/201)

---

## 🔍 Troubleshooting

### Problem: "Invalid column name" error persists

**Řešení:**
1. Ověřte, že jste aplikovali hotfix na správnou databázi
2. Zkontrolujte connection string v appsettings.json
3. Restartujte aplikaci

### Problem: Foreign key constraint fails

**Příčina:** Tabulka `LU_RequirementLevel` neexistuje

**Řešení:**
```sql
-- Zkontrolujte existenci tabulky
SELECT * FROM sys.tables WHERE name = 'LU_RequirementLevel';

-- Pokud neexistuje, spusťte celý db_structure.sql
```

### Problem: "Column already exists" error

**Příčina:** Sloupec byl již přidán dříve

**Řešení:** Hotfix skript je idempotentní - zkontroluje existenci před přidáním. Pokud používáte manuální SQL, přidejte IF NOT EXISTS kontrolu.

---

## 📊 What Changed

### Database Schema Changes:

**Added to ServicePrerequisite table:**
- 4 audit columns (CreatedDate, CreatedBy, ModifiedDate, ModifiedBy)
- 3 business columns (PrerequisiteName, Description, RequirementLevelID)
- 1 foreign key constraint
- 1 index

**Total:** +6 columns, +1 FK, +1 index

### Code Impact: **NONE**

C# kód již tyto sloupce očekával. Oprava pouze synchronizuje databázi s kódem.

---

## ⚠️ Important Notes

### Before Applying:

1. **Backup your database!**
   ```sql
   BACKUP DATABASE ServiceCatalogueManager 
   TO DISK = 'C:\Backups\ServiceCatalogueManager_Before_v2.9.10.bak';
   ```

2. **Schedule maintenance window** (if production)
   - Estimated downtime: <5 minutes
   - Rollback time: <2 minutes (if needed)

3. **Test in non-production first**

### After Applying:

1. Verify all columns exist (see Verification section)
2. Test import functionality
3. Check application logs
4. Monitor performance (should be same or better)

---

## 🔄 Rollback

If you need to rollback (not recommended):

```sql
-- Backup first!
BACKUP DATABASE ServiceCatalogueManager TO DISK = 'rollback_backup.bak';

-- Remove new columns (WARNING: loses audit data)
ALTER TABLE ServicePrerequisite DROP CONSTRAINT FK_ServicePrerequisite_LU_RequirementLevel;
DROP INDEX IX_ServicePrerequisite_RequirementLevel ON ServicePrerequisite;
ALTER TABLE ServicePrerequisite DROP COLUMN RequirementLevelID;
ALTER TABLE ServicePrerequisite DROP COLUMN Description;
ALTER TABLE ServicePrerequisite DROP COLUMN PrerequisiteName;
ALTER TABLE ServicePrerequisite DROP COLUMN ModifiedBy;
ALTER TABLE ServicePrerequisite DROP COLUMN ModifiedDate;
ALTER TABLE ServicePrerequisite DROP COLUMN CreatedBy;
ALTER TABLE ServicePrerequisite DROP COLUMN CreatedDate;
```

**Better option:** Restore from backup

```sql
USE master;
ALTER DATABASE ServiceCatalogueManager SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE ServiceCatalogueManager FROM DISK = 'backup.bak' WITH REPLACE;
ALTER DATABASE ServiceCatalogueManager SET MULTI_USER;
```

---

## 📞 Support

If you encounter issues:

1. **Check logs:**
   - Application logs in console/file
   - SQL Server error log
   - HOTFIX script output

2. **Verify database state:**
   - Run verification queries above
   - Check connection string
   - Verify SQL Server version compatibility

3. **Common solutions:**
   - Restart application
   - Check permissions (user needs ALTER TABLE rights)
   - Verify database exists and is online

---

## 📚 Additional Resources

- **CHANGELOG-v2.9.10.md** - Detailed change list
- **db_structure.sql** - Complete database schema
- **Error logs** - Check console output for details

---

## ✅ Success Criteria

Your fix is successful when:

- ✅ All 13 columns exist in ServicePrerequisite table
- ✅ Foreign key FK_ServicePrerequisite_LU_RequirementLevel exists
- ✅ Index IX_ServicePrerequisite_RequirementLevel exists
- ✅ Import service works without "Invalid column name" errors
- ✅ Existing data is preserved (if upgrading)

---

**That's it! Your database is now ready for Service Catalogue Manager v2.9.10** 🎉

For questions or issues, please review the troubleshooting section or contact your development team.
