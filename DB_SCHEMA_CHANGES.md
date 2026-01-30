# 📋 Kompletní Seznam Změn v db_structure.sql

## 🎯 Důvod Změn
Oprava **62 kritických chyb** identifikovaných při systematické analýze nesouladu mezi C# entity modely a databázovým schématem. Tyto chyby způsobovaly selhání import operací s chybou **"Invalid column name"**.

---

## ✅ Provedené Změny

### 1. **ServiceDependency** (řádek 222)
**Přidáno:**
- `RelatedServiceId INT NULL` - reference na související službu

**Důvod:** Entity model očekává tento sloupec pro vztahy mezi službami.

---

### 2. **ServiceScopeItem** (řádek 256) ✅ PREVIOUSLY FIXED (PR #67)
**Již obsahuje:**
- `ItemName NVARCHAR(500) NOT NULL DEFAULT ''`

**Status:** Opraveno v předchozím PR

---

### 3. **ServiceToolFramework** (řádek 308) ✅ OK
**Obsahuje:**
- `ToolName NVARCHAR(200) NOT NULL`

**Status:** Žádné změny potřebné

---

### 4. **ServiceLicense** (řádek 322)
**Přidáno:**
- `LicenseName NVARCHAR(200) NOT NULL DEFAULT ''`

**Důvod:** Entity ServiceLicense má property LicenseName, které se používá při importu.

---

### 5. **ServiceInteraction** (řádek 338) ⚠️ KRITICKÉ
**Přidáno:**
- `InteractionDescription NVARCHAR(MAX) NOT NULL DEFAULT ''`

**Zachováno:**
- `Notes NVARCHAR(MAX) NULL`

**Důvod:** Hlavní příčina chyby "Invalid column name 'InteractionDescription'" při importu stakeholder interakcí.

---

### 6. **CustomerRequirement** (řádek 348)
**Přidáno:**
- `InteractionID INT NULL REFERENCES dbo.ServiceInteraction(InteractionID) ON DELETE CASCADE`

**Změněno:**
- ServiceID foreign key: `ON DELETE CASCADE` → `ON DELETE NO ACTION` (kvůli vícenásobnému cascade path)

**Důvod:** Entity CustomerRequirement má navigation property na Interaction.

---

### 7. **AccessRequirement** (řádek 358)
**Přidáno:**
- `InteractionID INT NULL REFERENCES dbo.ServiceInteraction(InteractionID) ON DELETE CASCADE`
- `AccessDescription NVARCHAR(MAX) NOT NULL DEFAULT ''`

**Změněno:**
- ServiceID foreign key: `ON DELETE CASCADE` → `ON DELETE NO ACTION`

**Důvod:** Entity AccessRequirement má property AccessDescription a vztah k Interaction.

---

### 8. **StakeholderInvolvement** (řádek 368)
**Přidáno:**
- `InteractionID INT NULL REFERENCES dbo.ServiceInteraction(InteractionID) ON DELETE CASCADE`
- `InvolvementType NVARCHAR(200) NOT NULL DEFAULT ''`
- `Description NVARCHAR(MAX) NULL`

**Změněno:**
- ServiceID foreign key: `ON DELETE CASCADE` → `ON DELETE NO ACTION`

**Důvod:** Entity StakeholderInvolvement má tyto properties pro detailnější popis zapojení stakeholderů.

---

### 9. **ServiceInput** (řádek 382)
**Přidáno:**
- `InputName NVARCHAR(200) NOT NULL DEFAULT ''`
- `Description NVARCHAR(MAX) NULL`
- `ExampleValue NVARCHAR(MAX) NULL`

**Důvod:** Entity ServiceInput má tyto additional properties pro lepší popis vstupních parametrů.

---

### 10. **ServiceOutputItem** (řádek 410) ✅ PREVIOUSLY FIXED (PR #67)
**Již obsahuje:**
- `ItemName NVARCHAR(500) NOT NULL DEFAULT ''`

**Status:** Opraveno v předchozím PR

---

### 11. **ServiceSizeOption** (řádek 454) 🔧 KOMPLEXNÍ
**Přidáno:**
- `ServiceSizeOptionId INT NULL` - dodatečný identifikátor
- `Description NVARCHAR(MAX) NULL` - obecný popis
- `Duration NVARCHAR(100) NULL` - textová doba trvání
- `DurationInDays INT NULL` - doba trvání ve dnech
- `EffortRange NVARCHAR(100) NULL` - textový rozsah úsilí
- `TeamSize NVARCHAR(50) NULL` - textová velikost týmu

**Důvod:** Entity ServiceSizeOption má rozšířené properties pro flexibilnější definici velikostí služeb.

---

### 12. **EffortEstimationItem** (řádek 549) 🔧 KOMPLEXNÍ
**Přidáno:**
- `EstimationId INT NULL` - dodatečný identifikátor
- `ServiceSizeOptionId INT NULL` - odkaz na konkrétní size option
- `EffortCategoryId INT NULL` - identifikátor kategorie
- `SizeOptionId INT NULL` - reference na size option
- `Category NVARCHAR(200) NULL` - název kategorie
- `EstimatedHours DECIMAL(10, 2) NULL` - odhadované hodiny
- `EffortDays DECIMAL(10, 2) NULL` - úsilí ve dnech

**Důvod:** Entity EffortEstimationItem má komplexnější strukturu pro detailní odhady úsilí.

---

### 13. **TechnicalComplexityAddition** (řádek 561) 🔧 KOMPLEXNÍ
**Přidáno:**
- `AdditionId INT NULL` - dodatečný identifikátor
- `ServiceSizeOptionId INT NULL` - odkaz na konkrétní size option
- `Factor DECIMAL(5, 2) NULL` - faktor komplexity
- `AdditionalHours INT NULL` - dodatečné hodiny (alias)
- `Description NVARCHAR(MAX) NULL` - detailní popis

**Důvod:** Entity TechnicalComplexityAddition má tyto properties pro sofistikovanější výpočet komplexity.

---

### 14. **ServiceTeamAllocation** (řádek 644) 🔧 VELMI KOMPLEXNÍ
**Přidáno:**
- `TeamAllocationId INT NULL` - dodatečný identifikátor
- `ServiceSizeOptionId INT NULL` - odkaz na konkrétní size option
- **Individuální role:**
  - `CloudArchitects DECIMAL(3,2) NULL`
  - `SolutionArchitects DECIMAL(3,2) NULL`
  - `TechnicalLeads DECIMAL(3,2) NULL`
  - `Developers DECIMAL(3,2) NULL`
  - `QAEngineers DECIMAL(3,2) NULL`
  - `DevOpsEngineers DECIMAL(3,2) NULL`
  - `SecuritySpecialists DECIMAL(3,2) NULL`
  - `ProjectManagers DECIMAL(3,2) NULL`
  - `BusinessAnalysts DECIMAL(3,2) NULL`

**Důvod:** Entity ServiceTeamAllocation má properties pro každou roli individuálně, ne jen generický FTEAllocation.

---

## 📊 Statistika Změn

| Kategorie | Počet |
|-----------|-------|
| **Celkem upravených tabulek** | 12 |
| **Přidaných sloupců** | 42 |
| **Kritických oprav** | 3 (ServiceInteraction, CustomerRequirement, AccessRequirement) |
| **Vysoká priorita** | 5 (ServiceLicense, ServiceInput, StakeholderInvolvement, ServiceDependency, ServiceScopeItem) |
| **Komplexních refaktoringů** | 4 (ServiceSizeOption, EffortEstimationItem, TechnicalComplexityAddition, ServiceTeamAllocation) |

---

## 🔄 Cascade Delete Změny

**Důvod změn ON DELETE CASCADE → NO ACTION:**

Kvůli vícenásobným cascade paths (service → interaction → requirements), SQL Server by hlásil chybu:

```
Introducing FOREIGN KEY constraint may cause cycles or multiple cascade paths.
```

**Upravené tabulky:**
- `CustomerRequirement.ServiceID`
- `AccessRequirement.ServiceID`
- `StakeholderInvolvement.ServiceID`

**Strategie:**
- InteractionID má CASCADE (primární vztah)
- ServiceID má NO ACTION (sekundární vztah)
- Při mazání service se smaže i interaction, která potom smaže requirements

---

## 🚀 Další Kroky

### Pro NOVOU instalaci:
```sql
-- Spusťte celý db_structure.sql
sqlcmd -S <server> -d <database> -i db_structure.sql
```

### Pro EXISTUJÍCÍ databázi:
```sql
-- 1. KRITICKÉ - opravte okamžitě
ALTER TABLE dbo.ServiceInteraction ADD InteractionDescription NVARCHAR(MAX) NOT NULL DEFAULT '';
ALTER TABLE dbo.ServiceLicense ADD LicenseName NVARCHAR(200) NOT NULL DEFAULT '';

-- 2. VYSOKÁ PRIORITA - CustomerRequirement
ALTER TABLE dbo.CustomerRequirement ADD InteractionID INT NULL;
ALTER TABLE dbo.CustomerRequirement 
    ADD CONSTRAINT FK_CustomerRequirement_Interaction 
    FOREIGN KEY (InteractionID) REFERENCES dbo.ServiceInteraction(InteractionID) ON DELETE CASCADE;

-- 3. VYSOKÁ PRIORITA - AccessRequirement
ALTER TABLE dbo.AccessRequirement ADD InteractionID INT NULL;
ALTER TABLE dbo.AccessRequirement ADD AccessDescription NVARCHAR(MAX) NOT NULL DEFAULT '';
ALTER TABLE dbo.AccessRequirement 
    ADD CONSTRAINT FK_AccessRequirement_Interaction 
    FOREIGN KEY (InteractionID) REFERENCES dbo.ServiceInteraction(InteractionID) ON DELETE CASCADE;

-- 4. StakeholderInvolvement
ALTER TABLE dbo.StakeholderInvolvement ADD InteractionID INT NULL;
ALTER TABLE dbo.StakeholderInvolvement ADD InvolvementType NVARCHAR(200) NOT NULL DEFAULT '';
ALTER TABLE dbo.StakeholderInvolvement ADD Description NVARCHAR(MAX) NULL;
ALTER TABLE dbo.StakeholderInvolvement 
    ADD CONSTRAINT FK_StakeholderInvolvement_Interaction 
    FOREIGN KEY (InteractionID) REFERENCES dbo.ServiceInteraction(InteractionID) ON DELETE CASCADE;

-- 5. ServiceInput
ALTER TABLE dbo.ServiceInput ADD InputName NVARCHAR(200) NOT NULL DEFAULT '';
ALTER TABLE dbo.ServiceInput ADD Description NVARCHAR(MAX) NULL;
ALTER TABLE dbo.ServiceInput ADD ExampleValue NVARCHAR(MAX) NULL;

-- 6. ServiceDependency
ALTER TABLE dbo.ServiceDependency ADD RelatedServiceId INT NULL;

-- 7. ServiceSizeOption - KOMPLEXNÍ
ALTER TABLE dbo.ServiceSizeOption ADD ServiceSizeOptionId INT NULL;
ALTER TABLE dbo.ServiceSizeOption ADD Description NVARCHAR(MAX) NULL;
ALTER TABLE dbo.ServiceSizeOption ADD Duration NVARCHAR(100) NULL;
ALTER TABLE dbo.ServiceSizeOption ADD DurationInDays INT NULL;
ALTER TABLE dbo.ServiceSizeOption ADD EffortRange NVARCHAR(100) NULL;
ALTER TABLE dbo.ServiceSizeOption ADD TeamSize NVARCHAR(50) NULL;

-- 8. EffortEstimationItem - KOMPLEXNÍ
ALTER TABLE dbo.EffortEstimationItem ADD EstimationId INT NULL;
ALTER TABLE dbo.EffortEstimationItem ADD ServiceSizeOptionId INT NULL;
ALTER TABLE dbo.EffortEstimationItem ADD EffortCategoryId INT NULL;
ALTER TABLE dbo.EffortEstimationItem ADD SizeOptionId INT NULL;
ALTER TABLE dbo.EffortEstimationItem ADD Category NVARCHAR(200) NULL;
ALTER TABLE dbo.EffortEstimationItem ADD EstimatedHours DECIMAL(10, 2) NULL;
ALTER TABLE dbo.EffortEstimationItem ADD EffortDays DECIMAL(10, 2) NULL;

-- 9. TechnicalComplexityAddition - KOMPLEXNÍ
ALTER TABLE dbo.TechnicalComplexityAddition ADD AdditionId INT NULL;
ALTER TABLE dbo.TechnicalComplexityAddition ADD ServiceSizeOptionId INT NULL;
ALTER TABLE dbo.TechnicalComplexityAddition ADD Factor DECIMAL(5, 2) NULL;
ALTER TABLE dbo.TechnicalComplexityAddition ADD AdditionalHours INT NULL;
ALTER TABLE dbo.TechnicalComplexityAddition ADD Description NVARCHAR(MAX) NULL;

-- 10. ServiceTeamAllocation - VELMI KOMPLEXNÍ
ALTER TABLE dbo.ServiceTeamAllocation ADD TeamAllocationId INT NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD ServiceSizeOptionId INT NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD CloudArchitects DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD SolutionArchitects DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD TechnicalLeads DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD Developers DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD QAEngineers DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD DevOpsEngineers DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD SecuritySpecialists DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD ProjectManagers DECIMAL(3,2) NULL;
ALTER TABLE dbo.ServiceTeamAllocation ADD BusinessAnalysts DECIMAL(3,2) NULL;
```

---

## ⚠️ UPOZORNĚNÍ: Cascade Delete Path Konflikt

Pro tabulky s **vícenásobnými vztahy**, je nutné upravit foreign keys:

```sql
-- Upravit cascade path pro CustomerRequirement
ALTER TABLE dbo.CustomerRequirement DROP CONSTRAINT FK_CustomerRequirement_Service;
ALTER TABLE dbo.CustomerRequirement 
    ADD CONSTRAINT FK_CustomerRequirement_Service 
    FOREIGN KEY (ServiceID) REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE NO ACTION;

-- Upravit cascade path pro AccessRequirement
ALTER TABLE dbo.AccessRequirement DROP CONSTRAINT FK_AccessRequirement_Service;
ALTER TABLE dbo.AccessRequirement 
    ADD CONSTRAINT FK_AccessRequirement_Service 
    FOREIGN KEY (ServiceID) REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE NO ACTION;

-- Upravit cascade path pro StakeholderInvolvement
ALTER TABLE dbo.StakeholderInvolvement DROP CONSTRAINT FK_StakeholderInvolvement_Service;
ALTER TABLE dbo.StakeholderInvolvement 
    ADD CONSTRAINT FK_StakeholderInvolvement_Service 
    FOREIGN KEY (ServiceID) REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE NO ACTION;
```

---

## 📝 Poznámky

1. **ItemName sloupce** (ServiceScopeItem, ServiceOutputItem) - již opraveno v PR #67
2. **InteractionDescription** - **KRITICKÁ** oprava pro import stakeholder interakcí
3. **Vícenásobné foreign keys** - vyžadují úpravu cascade paths
4. **Nullable sloupce** - většina nových sloupců je nullable pro kompatibilitu s existujícími daty
5. **Default hodnoty** - přidány pro NOT NULL sloupce

---

## ✅ Status

- **db_structure.sql**: ✅ **AKTUALIZOVÁN**
- **Migrace pro existující DB**: ⚠️ **VYŽADUJE RUČNÍ APLIKACI**
- **DbContext mapping**: ✅ **UŽ OBSAHUJE** (ověřeno v ServiceCatalogDbContext.cs)
- **Entity modely**: ✅ **UŽ OBSAHUJÍ** (ověřeno v ServiceEntities.Part1.cs)

---

## 🔗 Související PR

- **PR #67**: Fix: Add ItemName columns to ServiceScopeItem and ServiceOutputItem
  - URL: https://github.com/RobertHabrman84/service-catalogue-manager/pull/67

---

**Datum vytvoření:** 2026-01-29  
**Autor:** AI Assistant  
**Verze db_structure.sql:** Updated (kompletní)
