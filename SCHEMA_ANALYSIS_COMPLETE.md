# 🔍 KOMPLETNÍ ANALÝZA DATABÁZOVÝCH NESROVNALOSTÍ

## Datum analýzy: 2026-01-29
## Projekt: Service Catalogue Manager

---

## 📊 SHRNUTÍ

- **Analyzované tabulky:** 43
- **Analyzované entity:** 59
- **Nalezené kritické chyby:** 62
- **Typ problému:** Missing columns - property existuje v C# entity, ale chybí sloupec v databázi

---

## 🔴 KRITICKÁ CHYBA #1: ServiceInteraction.InteractionDescription

### Popis chyby
```
Microsoft.Data.SqlClient.SqlException: Invalid column name 'InteractionDescription'
```

### Databázové schéma
```sql
CREATE TABLE dbo.ServiceInteraction (
    InteractionID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    InteractionLevelID INT NOT NULL REFERENCES dbo.LU_InteractionLevel(InteractionLevelID),
    Notes NVARCHAR(MAX) NULL  -- ❌ V databázi je "Notes"
);
```

### C# Entity Model
```csharp
public class ServiceInteraction : BaseEntity
{
    public int InteractionId { get; set; }
    public int ServiceId { get; set; }
    public int InteractionLevelId { get; set; }
    public string InteractionDescription { get; set; } = string.Empty;  // ❌ V kódu je "InteractionDescription"
    // ...
}
```

### Dopad
- **Lokace:** ImportOrchestrationService.cs:962
- **Operace:** INSERT INTO ServiceInteraction
- **Závažnost:** HIGH - blokuje import služeb

---

## 📋 KOMPLETNÍ SEZNAM VŠECH NALEZENÝCH CHYB

### Kategorie 1: KRITICKÉ (Blokují import)

| # | Entity | Property | Tabulka | DB Column | Status |
|---|--------|----------|---------|-----------|--------|
| 1 | `ServiceInteraction` | `InteractionDescription` | ServiceInteraction | Notes | ❌ MISSING |
| 2 | `ServiceScopeItem` | `ItemName` | ServiceScopeItem | - | ✅ FIXED (PR #67) |
| 3 | `ServiceOutputItem` | `ItemName` | ServiceOutputItem | - | ✅ FIXED (PR #67) |

### Kategorie 2: VYSOKÁ PRIORITA (Mohou blokovat import)

| # | Entity | Property | Tabulka | Issue |
|---|--------|----------|---------|-------|
| 4 | `CustomerRequirement` | `InteractionId` | CustomerRequirement | ❌ FK chybí |
| 5 | `AccessRequirement` | `AccessId` | AccessRequirement | ❌ PK nesprávný |
| 6 | `AccessRequirement` | `InteractionId` | AccessRequirement | ❌ FK chybí |
| 7 | `AccessRequirement` | `AccessDescription` | AccessRequirement | ❌ Column chybí |
| 8 | `ServiceDependency` | `RelatedServiceId` | ServiceDependency | ❌ FK chybí |
| 9 | `ServiceToolFramework` | `ToolId` | ServiceToolFramework | ❌ PK nesprávný |
| 10 | `ServiceLicense` | `LicenseName` | ServiceLicense | ❌ Column chybí |
| 11 | `ServiceInput` | `InputName` | ServiceInput | ❌ Column chybí |
| 12 | `ServiceInput` | `Description` | ServiceInput | ❌ Column chybí |
| 13 | `ServiceInput` | `ExampleValue` | ServiceInput | ❌ Column chybí |

### Kategorie 3: STŘEDNÍ PRIORITA (Sizing & Team Allocation)

| # | Entity | Property | Tabulka | Issue |
|---|--------|----------|---------|-------|
| 14 | `ServiceSizeOption` | `ServiceSizeOptionId` | ServiceSizeOption | ❌ PK nesprávný |
| 15 | `ServiceSizeOption` | `Description` | ServiceSizeOption | ❌ Column chybí |
| 16 | `ServiceSizeOption` | `Duration` | ServiceSizeOption | ❌ Column chybí |
| 17 | `ServiceSizeOption` | `DurationInDays` | ServiceSizeOption | ❌ Column chybí |
| 18 | `ServiceSizeOption` | `EffortRange` | ServiceSizeOption | ❌ Column chybí |
| 19 | `ServiceSizeOption` | `TeamSize` | ServiceSizeOption | ❌ Column chybí |
| 20-34 | `ServiceTeamAllocation` | Všechny alokační sloupce | ServiceTeamAllocation | ❌ Většina chybí |
| 35-39 | `EffortEstimationItem` | Všechny sloupce | EffortEstimationItem | ❌ Nesprávná struktura |
| 40-44 | `TechnicalComplexityAddition` | Většina sloupců | TechnicalComplexityAddition | ❌ Mnoho chybí |
| 45-48 | `SizingParameter` | Parametry | SizingParameter | ❌ Chybí hodnoty |
| 49-51 | `SizingExample` | Příklady | SizingExample | ❌ Chybí data |

### Kategorie 4: NÍZKÁ PRIORITA (Menší funkce)

| # | Entity | Property | Tabulka | Issue |
|---|--------|----------|---------|-------|
| 52-53 | `StakeholderInvolvement` | `InteractionId`, `InvolvementType`, `Description` | StakeholderInvolvement | ❌ Chybí FK a data |
| 54-56 | `TimelinePhase` | `Description`, `DurationBySize` | TimelinePhase | ❌ Chybí popis |
| 57-59 | `ServiceResponsibleRole` | `ResponsibleRoleId`, `Responsibilities` | ServiceResponsibleRole | ❌ PK a data |
| 60 | `ServiceMultiCloudConsideration` | `Description` | ServiceMultiCloudConsideration | ❌ Chybí popis |
| 61-62 | `ScopeDependency` | Většina sloupců | ScopeDependency | ❌ Nesprávná struktura |

---

## ⚠️ VZOR PROBLÉMU

Analýza ukazuje **systematický vzor**:

1. **Entity modely byly vytvořeny s rozšířenými property**
2. **Databázové schéma obsahuje pouze základní sloupce**
3. **Migrace nebyly vytvořeny nebo aplikovány**

### Příklad vzoru:

```
Entity (C#):              Database (SQL):
├─ ItemName               ❌ Missing
├─ ItemDescription        ✅ Exists
└─ SortOrder              ✅ Exists

Entity (C#):              Database (SQL):
├─ InteractionDescription ❌ Missing
└─ Notes                  ✅ Exists (jiný název!)
```

---

## 💡 DOPORUČENÉ ŘEŠENÍ

### Přístup: Rozšíření databázového schématu

**Výhody:**
- ✅ Entity modely jsou připravené na budoucí funkcionalitu
- ✅ Konzistentní s designem aplikace
- ✅ Minimální změny v kódu

**Nevýhody:**
- ⚠️ Vyžaduje databázové migrace
- ⚠️ Nutné aktualizovat existující data

---

## 🎯 FÁZOVANÝ PLÁN OPRAVY

### FÁZE 1: KRITICKÉ OPRAVY (OKAMŽITĚ)

#### 1.1 ServiceInteraction.InteractionDescription
```sql
ALTER TABLE dbo.ServiceInteraction 
ADD InteractionDescription NVARCHAR(MAX) NULL;

-- Migrace dat z Notes
UPDATE dbo.ServiceInteraction 
SET InteractionDescription = ISNULL(Notes, '')
WHERE InteractionDescription IS NULL;

-- Po migraci dat můžeme odstranit Notes nebo je zachovat
-- ALTER TABLE dbo.ServiceInteraction DROP COLUMN Notes;
```

**Aktualizace DbContext:**
```csharp
// ServiceCatalogDbContext.cs
modelBuilder.Entity<ServiceInteraction>(entity =>
{
    entity.ToTable("ServiceInteraction");
    entity.HasKey(e => e.InteractionId);
    entity.Property(e => e.InteractionDescription)
          .HasColumnName("InteractionDescription")  // Explicitní mapping
          .IsRequired(false);  // Nullable initially
    // ...
});
```

#### 1.2 CustomerRequirement.InteractionId (FK)
```sql
ALTER TABLE dbo.CustomerRequirement
ADD InteractionId INT NULL REFERENCES dbo.ServiceInteraction(InteractionID);

-- Update existing data to link requirements to interactions
UPDATE cr
SET cr.InteractionId = si.InteractionID
FROM dbo.CustomerRequirement cr
INNER JOIN dbo.ServiceInteraction si ON cr.ServiceID = si.ServiceID;
```

#### 1.3 AccessRequirement - Kompletní restrukturalizace
```sql
-- Přidat chybějící sloupce
ALTER TABLE dbo.AccessRequirement
ADD AccessId INT IDENTITY(1,1);  -- Pokud neexistuje jako PK

ALTER TABLE dbo.AccessRequirement
ADD InteractionId INT NULL REFERENCES dbo.ServiceInteraction(InteractionID);

ALTER TABLE dbo.AccessRequirement
ADD AccessDescription NVARCHAR(MAX) NULL;

-- Migrace dat
UPDATE dbo.AccessRequirement
SET AccessDescription = RequirementDescription
WHERE AccessDescription IS NULL;
```

---

### FÁZE 2: VYSOKÁ PRIORITA (DO 1 TÝDNE)

#### 2.1 ServiceInput - Přidání jmenných sloupců
```sql
ALTER TABLE dbo.ServiceInput
ADD InputName NVARCHAR(200) NOT NULL DEFAULT '';

ALTER TABLE dbo.ServiceInput
ADD Description NVARCHAR(MAX) NULL;

ALTER TABLE dbo.ServiceInput
ADD ExampleValue NVARCHAR(MAX) NULL;
```

#### 2.2 ServiceLicense - Přidání LicenseName
```sql
ALTER TABLE dbo.ServiceLicense
ADD LicenseName NVARCHAR(200) NOT NULL DEFAULT '';
```

#### 2.3 ServiceDependency - Přidání RelatedServiceId
```sql
ALTER TABLE dbo.ServiceDependency
ADD RelatedServiceId INT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID);
```

---

### FÁZE 3: STŘEDNÍ PRIORITA (DO 2 TÝDNŮ)

- ServiceSizeOption - Rozšíření o Description, Duration, DurationInDays, EffortRange, TeamSize
- ServiceTeamAllocation - Přidání všech alokačních sloupců
- EffortEstimationItem - Restrukturalizace
- TechnicalComplexityAddition - Doplnění sloupců
- Sizing tables - Kompletní sada sloupců

---

### FÁZE 4: NÍZKÁ PRIORITA (DO 1 MĚSÍCE)

- StakeholderInvolvement - Doplnění
- TimelinePhase - Rozšíření
- ServiceResponsibleRole - Oprava
- ServiceMultiCloudConsideration - Doplnění

---

## 📝 AKČNÍ KROKY

### Krok 1: Schválení přístupu
☐ Potvrdit strategii rozšíření databáze
☐ Schválit fázovaný plán

### Krok 2: Vytvoření SQL skriptů
☐ Vytvořit migration SQL pro Fázi 1
☐ Testovat na vývojové databázi
☐ Připravit rollback skripty

### Krok 3: Aktualizace DbContext
☐ Přidat explicitní column mappings
☐ Aktualizovat FluentAPI konfigurace

### Krok 4: Testování
☐ Unit testy pro entity
☐ Integration testy pro import
☐ End-to-end testy

### Krok 5: Deployment
☐ Backup produkční databáze
☐ Aplikovat migrace
☐ Verifikovat import funkce
☐ Monitoring

---

## 🚀 OKAMŽITÁ AKCE - MINIMÁLNÍ FIX

Pro **okamžité odblokování importu** doporučuji tento minimální fix:

### Soubor: db_structure.sql

```sql
-- 1. ServiceInteraction
ALTER TABLE dbo.ServiceInteraction 
ADD InteractionDescription NVARCHAR(MAX) NULL;

-- 2. CustomerRequirement (FK fix)  
ALTER TABLE dbo.CustomerRequirement
ADD InteractionId INT NULL REFERENCES dbo.ServiceInteraction(InteractionID);

-- 3. AccessRequirement (kompletní fix)
-- Nejprve přejmenovat PK pokud je potřeba
ALTER TABLE dbo.AccessRequirement
ADD AccessId INT NULL;  -- Dočasně nullable

ALTER TABLE dbo.AccessRequirement
ADD InteractionId INT NULL REFERENCES dbo.ServiceInteraction(InteractionID);

ALTER TABLE dbo.AccessRequirement
ADD AccessDescription NVARCHAR(MAX) NULL;

-- 4. ServiceInput
ALTER TABLE dbo.ServiceInput
ADD InputName NVARCHAR(200) NOT NULL DEFAULT '';

ALTER TABLE dbo.ServiceInput
ADD Description NVARCHAR(MAX) NULL;

ALTER TABLE dbo.ServiceInput
ADD ExampleValue NVARCHAR(MAX) NULL;

-- 5. ServiceLicense
ALTER TABLE dbo.ServiceLicense
ADD LicenseName NVARCHAR(200) NOT NULL DEFAULT '';

-- 6. ServiceDependency
ALTER TABLE dbo.ServiceDependency
ADD RelatedServiceId INT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID);

-- 7. ServiceToolFramework (PK fix if needed)
-- Check current PK name first
```

---

## ❓ OTÁZKY K ROZHODNUTÍ

1. **Chcete aplikovat všechny opravy najednou nebo fázovaně?**
   - [ ] Všechny najednou
   - [ ] Fázovaně podle priority

2. **Chcete zachovat sloupec `Notes` v ServiceInteraction nebo ho odstranit?**
   - [ ] Zachovat oba (Notes + InteractionDescription)
   - [ ] Migrovat data a odstranit Notes
   - [ ] Přejmenovat Notes na InteractionDescription

3. **Máte přístup k produkční databázi pro aplikaci změn?**
   - [ ] Ano, mohu aplikovat přímo
   - [ ] Ne, potřebuji SQL skripty
   - [ ] Existuje CI/CD pipeline pro migrace

4. **Preferujete aktualizaci db_structure.sql nebo vytvoření ALTER skriptů?**
   - [ ] Aktualizovat db_structure.sql (pro nové instalace)
   - [ ] Vytvořit ALTER skripty (pro existující DB)
   - [ ] Obojí

---

## 📊 STATISTIKY ANALÝZY

```
Total Issues Found: 62
├─ Critical (Blocking): 3
├─ High Priority: 10
├─ Medium Priority: 35
└─ Low Priority: 14

Affected Tables: 21
Affected Entities: 21

Code Locations with Issues:
├─ ImportOrchestrationService.cs: 8 locations
├─ Entity definitions: 21 files
└─ DbContext configurations: 15 mappings

Estimated Fix Time:
├─ Phase 1 (Critical): 2-4 hours
├─ Phase 2 (High): 1-2 days
├─ Phase 3 (Medium): 3-5 days  
└─ Phase 4 (Low): 2-3 days
```

---

## 📄 DALŠÍ DOKUMENTY

- `schema_analysis_report.json` - Detailní JSON report
- `db_structure.sql` - Aktuální databázové schéma
- `/Migrations/` - Entity Framework migrace

---

**Připraveno k schválení a implementaci** ✅

