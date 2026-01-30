# 🔍 ANALÝZA NOVÝCH CHYB - TimelinePhase & StakeholderInvolvement

**Datum:** 2026-01-29  
**Status:** 🔴 KRITICKÉ CHYBY  
**Priorita:** IMMEDIATE FIX REQUIRED

---

## 📋 SHRNUTÍ CHYB

### Chyba 1: Invalid column name 'Description' (StakeholderInvolvement)
```
INSERT ([CreatedBy], [CreatedDate], [Description], [InteractionId], [InvolvementDescription]...)
```
**Error Number:** 207, State: 1, Class: 16  
**Lokace:** ImportOrchestrationService.cs:line 1042

### Chyba 2: Invalid column name 'DurationBySize' (TimelinePhase)
```
INSERT INTO [TimelinePhase] ([CreatedBy], [CreatedDate], [Description], [DurationBySize], [ModifiedBy]...)
```
**Error Number:** 207, State: 1, Class: 16  
**Lokace:** ImportOrchestrationService.cs:line 1042

---

## 🔎 ROOT CAUSE ANALYSIS

### Problém: DbContext NEMAPUJE tyto sloupce

#### 1. TimelinePhase
**Entity má properties:**
- ✅ `PhaseId`
- ✅ `ServiceId`
- ✅ `PhaseNumber`
- ✅ `PhaseName`
- ❌ `Description` (string? - NULLABLE)
- ❌ `DurationBySize` (string? - NULLABLE)
- ✅ `SortOrder`

**DbContext mapuje POUZE:**
```csharp
entity.ToTable("TimelinePhase");
entity.HasKey(e => e.PhaseId);
entity.Property(e => e.PhaseName).IsRequired().HasMaxLength(200);
// ❌ Description NENÍ mapována
// ❌ DurationBySize NENÍ mapována
```

**db_structure.sql má:**
```sql
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
-- ❌ Description CHYBÍ
-- ❌ DurationBySize CHYBÍ
```

---

#### 2. StakeholderInvolvement
**Entity má properties:**
- ✅ `InvolvementId`
- ✅ `InteractionId`
- ✅ `ServiceId`
- ✅ `StakeholderRole`
- ✅ `InvolvementType`
- ✅ `InvolvementDescription`
- ❌ `Description` (string? - NULLABLE)
- ✅ `SortOrder`

**DbContext mapuje:**
```csharp
entity.ToTable("StakeholderInvolvement");
entity.HasKey(e => e.InvolvementId);
entity.Property(e => e.StakeholderRole).IsRequired().HasMaxLength(100);
// ❌ Description NENÍ explicitně mapována
// ✅ InvolvementType - bude mapována automaticky (EF convention)
```

**db_structure.sql má:**
```sql
CREATE TABLE dbo.StakeholderInvolvement (
    InvolvementID INT IDENTITY(1,1) PRIMARY KEY,
    InteractionID INT NULL,
    ServiceID INT NOT NULL,
    StakeholderRole NVARCHAR(200) NOT NULL,
    InvolvementType NVARCHAR(200) NOT NULL DEFAULT '',
    InvolvementDescription NVARCHAR(MAX) NOT NULL,
    Description NVARCHAR(MAX) NULL,  -- ✅ JIŽ EXISTUJE
    SortOrder INT NOT NULL DEFAULT 0
);
```

---

## ✅ ŘEŠENÍ

### Řešení A: Aktualizovat db_structure.sql (DOPORUČENO)

#### 1. TimelinePhase - přidat chybějící sloupce

**PŘED:**
```sql
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
```

**PO:**
```sql
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,           -- ✅ PŘIDÁNO
    DurationBySize NVARCHAR(MAX) NULL,        -- ✅ PŘIDÁNO
    SortOrder INT NOT NULL DEFAULT 0
);
```

#### 2. StakeholderInvolvement - ŽÁDNÉ ZMĚNY POTŘEBNÉ
✅ db_structure.sql již obsahuje sloupec `Description`

---

### Řešení B: Aktualizovat DbContext mapping

#### 1. TimelinePhase - přidat explicitní mapping

**PŘED:**
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

**PO:**
```csharp
modelBuilder.Entity<TimelinePhase>(entity =>
{
    entity.ToTable("TimelinePhase");
    entity.HasKey(e => e.PhaseId);
    entity.Property(e => e.PhaseName).IsRequired().HasMaxLength(200);
    entity.Property(e => e.Description);         // ✅ PŘIDÁNO
    entity.Property(e => e.DurationBySize);      // ✅ PŘIDÁNO

    entity.HasOne(e => e.Service)
        .WithMany(s => s.TimelinePhases)
        .HasForeignKey(e => e.ServiceId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

#### 2. StakeholderInvolvement - přidat explicitní mapping

**PŘED:**
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

**PO:**
```csharp
modelBuilder.Entity<StakeholderInvolvement>(entity =>
{
    entity.ToTable("StakeholderInvolvement");
    entity.HasKey(e => e.InvolvementId);
    entity.Property(e => e.StakeholderRole).IsRequired().HasMaxLength(100);
    entity.Property(e => e.InvolvementType).IsRequired().HasMaxLength(200);  // ✅ PŘIDÁNO
    entity.Property(e => e.InvolvementDescription).IsRequired();             // ✅ PŘIDÁNO
    entity.Property(e => e.Description);                                      // ✅ PŘIDÁNO

    entity.HasOne(e => e.Interaction)
        .WithMany(i => i.StakeholderInvolvements)
        .HasForeignKey(e => e.InteractionId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

---

## 🚀 DOPORUČENÝ POSTUP

### Priorita: ŘEŠENÍ A + ŘEŠENÍ B SOUČASNĚ

1. ✅ **Aktualizovat db_structure.sql** - přidat chybějící sloupce do TimelinePhase
2. ✅ **Aktualizovat DbContext** - přidat explicitní mapping pro obě tabulky
3. ✅ **Pro existující DB** - vytvořit ALTER TABLE skripty

---

## 📝 SQL MIGRATION SKRIPTY

### Pro EXISTUJÍCÍ databázi:

```sql
-- 1. TimelinePhase - přidat chybějící sloupce
ALTER TABLE dbo.TimelinePhase ADD Description NVARCHAR(MAX) NULL;
ALTER TABLE dbo.TimelinePhase ADD DurationBySize NVARCHAR(MAX) NULL;
```

### StakeholderInvolvement:
```sql
-- ✅ ŽÁDNÁ ZMĚNA POTŘEBNÁ - sloupec Description již existuje
-- Ověření:
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'StakeholderInvolvement' AND COLUMN_NAME = 'Description';
```

---

## ⚠️ DŮLEŽITÉ POZNÁMKY

### 1. StakeholderInvolvement - Možný problém s existující DB

**Pokud db_structure.sql byl již použit, ale sloupec Description chybí:**
- db_structure.sql obsahuje Description ✅
- Existující DB možná NEOBSAHUJE Description ❌
- **Řešení:** Aplikovat ALTER TABLE i pro StakeholderInvolvement

```sql
-- Ověření existence sloupce
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'StakeholderInvolvement' AND COLUMN_NAME = 'Description'
)
BEGIN
    ALTER TABLE dbo.StakeholderInvolvement ADD Description NVARCHAR(MAX) NULL;
    PRINT 'Column Description added to StakeholderInvolvement';
END
ELSE
BEGIN
    PRINT 'Column Description already exists in StakeholderInvolvement';
END
```

### 2. TimelinePhase - Definitivně chybí

```sql
-- TimelinePhase - URČITĚ potřebuje přidání
ALTER TABLE dbo.TimelinePhase ADD Description NVARCHAR(MAX) NULL;
ALTER TABLE dbo.TimelinePhase ADD DurationBySize NVARCHAR(MAX) NULL;
```

---

## 📊 VERIFIKACE

### Po aplikaci změn:

```sql
-- 1. Ověřit TimelinePhase
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TimelinePhase'
ORDER BY ORDINAL_POSITION;

-- 2. Ověřit StakeholderInvolvement
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'StakeholderInvolvement'
ORDER BY ORDINAL_POSITION;
```

**Očekávané výsledky TimelinePhase:**
- PhaseID (int, NOT NULL)
- ServiceID (int, NOT NULL)
- PhaseNumber (int, NOT NULL)
- PhaseName (nvarchar(200), NOT NULL)
- **Description (nvarchar(max), NULL)** ← NOVÝ
- **DurationBySize (nvarchar(max), NULL)** ← NOVÝ
- SortOrder (int, NOT NULL)

**Očekávané výsledky StakeholderInvolvement:**
- InvolvementID (int, NOT NULL)
- InteractionID (int, NULL)
- ServiceID (int, NOT NULL)
- StakeholderRole (nvarchar(200), NOT NULL)
- InvolvementType (nvarchar(200), NOT NULL)
- InvolvementDescription (nvarchar(max), NOT NULL)
- **Description (nvarchar(max), NULL)** ← MĚLO BY EXISTOVAT
- SortOrder (int, NOT NULL)

---

## 🎯 AKCNÍ PLÁN

1. [x] **Analýza chyb** - DOKONČENO
2. [ ] **Aktualizace db_structure.sql** - ČEKÁ NA SCHVÁLENÍ
3. [ ] **Aktualizace DbContext** - ČEKÁ NA SCHVÁLENÍ
4. [ ] **Vytvoření migration skriptů** - PŘIPRAVENO
5. [ ] **Testování** - PO APLIKACI

---

## 📌 STATUS

- **TimelinePhase:** 🔴 KRITICKÉ - 2 sloupce chybí v DB schématu
- **StakeholderInvolvement:** 🟡 MOŽNÝ PROBLÉM - sloupec v db_structure.sql existuje, ale možná chybí v runtime DB
- **DbContext mapping:** 🔴 NEÚPLNÝ - obě tabulky potřebují explicitní mapping

---

**Poslední aktualizace:** 2026-01-29  
**Připraveno k implementaci:** ✅ ANO  
**Čeká na schválení:** ✅ ANO
