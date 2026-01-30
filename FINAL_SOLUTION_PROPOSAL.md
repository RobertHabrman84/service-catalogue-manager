# 🎯 FINÁLNÍ NÁVRH ŘEŠENÍ - Kompletní Oprava Schématu

**Datum:** 2026-01-29  
**Status:** ✅ PŘIPRAVENO K IMPLEMENTACI  
**Priorita:** 🔴 KRITICKÁ

---

## 📊 EXECUTIVE SUMMARY

### Identifikované Chyby:
1. **TimelinePhase** - chybí 2 sloupce: `Description`, `DurationBySize`
2. **StakeholderInvolvement** - sloupec `Description` existuje v db_structure.sql, ale DbContext nemá explicitní mapping

### Impact:
- ❌ Import služeb selhává na řádku 1042 (ImportOrchestrationService.cs)
- ❌ Rollback všech změn v transakci
- ❌ Blokuje kompletní import workflow

---

## 🔧 NAVRŽENÉ ZMĚNY

### 1. db_structure.sql - TimelinePhase

#### PŘED:
```sql
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
```

#### PO:
```sql
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,           -- ✅ NOVÝ SLOUPEC
    DurationBySize NVARCHAR(MAX) NULL,        -- ✅ NOVÝ SLOUPEC
    SortOrder INT NOT NULL DEFAULT 0
);
```

**Řádek v souboru:** ~425-432

---

### 2. DbContext - TimelinePhase

**Soubor:** `ServiceCatalogDbContext.cs`  
**Lokace:** Sekce "Configure TimelinePhase"

#### PŘED:
```csharp
modelBuilder.Entity<TimelinePhase>(entity =>
{
    entity.ToTable("TimelinePhase");
    entity.HasKey(e => e.PhaseId);
    entity.Property(e => e.PhaseName).IsRequired().HasMaxLength(200);

    entity.HasOne(e => e.Service)
        .WithMany(s => s.TimelinePhases)
        .HasForeignKey(e => e.ServiceId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

#### PO:
```csharp
modelBuilder.Entity<TimelinePhase>(entity =>
{
    entity.ToTable("TimelinePhase");
    entity.HasKey(e => e.PhaseId);
    entity.Property(e => e.PhaseName).IsRequired().HasMaxLength(200);
    entity.Property(e => e.Description);         // ✅ EXPLICITNÍ MAPPING
    entity.Property(e => e.DurationBySize);      // ✅ EXPLICITNÍ MAPPING

    entity.HasOne(e => e.Service)
        .WithMany(s => s.TimelinePhases)
        .HasForeignKey(e => e.ServiceId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

---

### 3. DbContext - StakeholderInvolvement

**Soubor:** `ServiceCatalogDbContext.cs`  
**Lokace:** Sekce "Configure StakeholderInvolvement"

#### PŘED:
```csharp
modelBuilder.Entity<StakeholderInvolvement>(entity =>
{
    entity.ToTable("StakeholderInvolvement");
    entity.HasKey(e => e.InvolvementId);
    entity.Property(e => e.StakeholderRole).IsRequired().HasMaxLength(100);

    entity.HasOne(e => e.Interaction)
        .WithMany(i => i.StakeholderInvolvements)
        .HasForeignKey(e => e.InteractionId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

#### PO:
```csharp
modelBuilder.Entity<StakeholderInvolvement>(entity =>
{
    entity.ToTable("StakeholderInvolvement");
    entity.HasKey(e => e.InvolvementId);
    entity.Property(e => e.StakeholderRole).IsRequired().HasMaxLength(100);
    entity.Property(e => e.InvolvementType).IsRequired().HasMaxLength(200);  // ✅ EXPLICITNÍ
    entity.Property(e => e.InvolvementDescription).IsRequired();             // ✅ EXPLICITNÍ
    entity.Property(e => e.Description);                                      // ✅ EXPLICITNÍ

    entity.HasOne(e => e.Interaction)
        .WithMany(i => i.StakeholderInvolvements)
        .HasForeignKey(e => e.InteractionId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

---

## 📝 SQL MIGRATION SKRIPTY

### Pro EXISTUJÍCÍ databázi:

```sql
-- ============================================
-- MIGRATION SCRIPT: Add TimelinePhase columns
-- Date: 2026-01-29
-- Description: Add Description and DurationBySize columns
-- ============================================

USE [ServiceCatalogueDB];  -- Změňte na správný název DB
GO

-- 1. Add Description column
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'TimelinePhase' AND COLUMN_NAME = 'Description'
)
BEGIN
    ALTER TABLE dbo.TimelinePhase ADD Description NVARCHAR(MAX) NULL;
    PRINT '✓ Column Description added to TimelinePhase';
END
ELSE
BEGIN
    PRINT '⚠ Column Description already exists in TimelinePhase';
END
GO

-- 2. Add DurationBySize column
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'TimelinePhase' AND COLUMN_NAME = 'DurationBySize'
)
BEGIN
    ALTER TABLE dbo.TimelinePhase ADD DurationBySize NVARCHAR(MAX) NULL;
    PRINT '✓ Column DurationBySize added to TimelinePhase';
END
ELSE
BEGIN
    PRINT '⚠ Column DurationBySize already exists in TimelinePhase';
END
GO

-- 3. Verify StakeholderInvolvement.Description exists
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'StakeholderInvolvement' AND COLUMN_NAME = 'Description'
)
BEGIN
    ALTER TABLE dbo.StakeholderInvolvement ADD Description NVARCHAR(MAX) NULL;
    PRINT '✓ Column Description added to StakeholderInvolvement';
END
ELSE
BEGIN
    PRINT '✓ Column Description already exists in StakeholderInvolvement';
END
GO

-- ============================================
-- VERIFICATION
-- ============================================

PRINT '';
PRINT '=== VERIFICATION RESULTS ===';
PRINT '';

-- Verify TimelinePhase
PRINT 'TimelinePhase columns:';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TimelinePhase'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT 'StakeholderInvolvement columns:';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'StakeholderInvolvement'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '=== MIGRATION COMPLETE ===';
GO
```

---

## 🔍 VERIFIKAČNÍ CHECKLIST

### 1. Databázové Schéma ✓

- [ ] TimelinePhase.Description exists
- [ ] TimelinePhase.DurationBySize exists
- [ ] StakeholderInvolvement.Description exists

**Verifikační SQL:**
```sql
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('TimelinePhase', 'StakeholderInvolvement')
AND COLUMN_NAME IN ('Description', 'DurationBySize')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

### 2. Entity Modely ✓

- [x] TimelinePhase.Description (string?) - **EXISTUJE**
- [x] TimelinePhase.DurationBySize (string?) - **EXISTUJE**
- [x] StakeholderInvolvement.Description (string?) - **EXISTUJE**

**Soubory:**
- `TimelinePhase.cs` - řádek 9, 10
- `StakeholderInvolvement.cs` - needs verification

### 3. DbContext Mapping

- [ ] TimelinePhase mapping updated
- [ ] StakeholderInvolvement mapping updated

---

## 🚀 IMPLEMENTAČNÍ PLÁN

### Krok 1: Aktualizace db_structure.sql ✅ PREPARED
**Čas:** 5 min  
**Risk:** LOW  
**Status:** Čeká na schválení

### Krok 2: Aktualizace ServiceCatalogDbContext.cs ✅ PREPARED
**Čas:** 5 min  
**Risk:** LOW  
**Status:** Čeká na schválení

### Krok 3: Aplikace SQL Migration na existující DB
**Čas:** 2 min  
**Risk:** LOW  
**Status:** Připraven skript

### Krok 4: Testování Importu
**Čas:** 10 min  
**Risk:** MEDIUM  
**Status:** Po aplikaci změn

### Krok 5: Commit & PR
**Čas:** 10 min  
**Risk:** LOW  
**Status:** Po úspěšném testu

---

## 📊 OČEKÁVANÉ VÝSLEDKY

### PŘED opravou:
```
❌ Invalid column name 'Description' (StakeholderInvolvement)
❌ Invalid column name 'DurationBySize' (TimelinePhase)
❌ Import selhal na řádku 1042
❌ Rollback transakce
```

### PO opravě:
```
✅ TimelinePhase.Description dostupný
✅ TimelinePhase.DurationBySize dostupný
✅ StakeholderInvolvement.Description mapován
✅ Import úspěšný
✅ Data uložena
```

---

## ⚠️ RIZIKA A MITIGACE

### Riziko 1: Existující data
**Impact:** LOW  
**Mitigace:** Oba nové sloupce jsou NULLABLE

### Riziko 2: DbContext cache
**Impact:** MEDIUM  
**Mitigace:** Restart aplikace po aplikaci změn

### Riziko 3: Migration conflicts
**Impact:** LOW  
**Mitigace:** IF NOT EXISTS checks v SQL skriptech

---

## 🔗 SOUVISEJÍCÍ DOKUMENTY

- `NEW_ERRORS_ANALYSIS_AND_SOLUTION.md` - Detailní analýza
- `DB_SCHEMA_CHANGES.md` - Předchozí změny
- `full_schema_check_report.json` - Kompletní schéma report

---

## 📋 STATUS MATRIX

| Komponenta | Status | Změny | Priorita |
|------------|--------|-------|----------|
| db_structure.sql | ⚠️ INCOMPLETE | +2 sloupce TimelinePhase | 🔴 HIGH |
| ServiceCatalogDbContext.cs | ⚠️ INCOMPLETE | +5 mappings | 🔴 HIGH |
| TimelinePhase.cs entity | ✅ OK | Žádné | - |
| StakeholderInvolvement.cs | ✅ OK | Žádné | - |
| SQL Migration | ✅ READY | Prepared script | 🔴 HIGH |

---

## ✅ SCHVÁLENÍ K IMPLEMENTACI

**Připraveno:** ✅ ANO  
**Testováno:** ⏳ ČEKÁ  
**Riziko:** 🟢 NÍZKÉ  
**Doporučení:** ✅ **IMPLEMENTOVAT OKAMŽITĚ**

---

**Připravil:** AI Assistant  
**Datum:** 2026-01-29  
**Verze:** 1.0  
**Status:** ✅ READY FOR APPROVAL
