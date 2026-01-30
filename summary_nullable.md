# ✅ DB Structure - Všechny sloupce NULLABLE s DEFAULT hodnotami

## 🔄 Provedené změny

### Hlavní změny:
1. **Všechny textové sloupce (NVARCHAR)** → `NULL DEFAULT ''`
2. **Všechny číselné sloupce (INT, DECIMAL)** → `NULL DEFAULT 0` 
3. **Všechny boolean sloupce (BIT)** → `NULL DEFAULT 0`
4. **Všechny datetime sloupce (DATETIME2)** → `NULL DEFAULT GETUTCDATE()`

### Výjimky (ponechány NOT NULL):
- **PRIMARY KEY** sloupce (např. ServiceID, PhaseID)
- **IDENTITY** sloupce
- **FOREIGN KEY** sloupce (např. ServiceID, CategoryID)
- Sloupce s explicitním DEFAULT (např. `Version NVARCHAR(20) NOT NULL DEFAULT 'v1.0'`)

## 📋 Příklady změn:

### ❌ PŘED:
```sql
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NOT NULL,
    PhaseName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    DurationBySize NVARCHAR(MAX) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
```

### ✅ PO:
```sql
CREATE TABLE dbo.TimelinePhase (
    PhaseID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID) ON DELETE CASCADE,
    PhaseNumber INT NULL DEFAULT 0,
    PhaseName NVARCHAR(200) NULL DEFAULT '',
    Description NVARCHAR(MAX) NULL DEFAULT '',
    DurationBySize NVARCHAR(MAX) NULL DEFAULT '',
    SortOrder INT NOT NULL DEFAULT 0
);
```

## 📊 Ovlivněné tabulky:

### Lookup tabulky:
- ✅ LU_ServiceCategory
- ✅ LU_SizeOption
- ✅ LU_CloudProvider
- ✅ LU_DependencyType
- ✅ LU_PrerequisiteCategory
- ✅ LU_LicenseType (TypeCode, TypeName, Description → NULL)
- ✅ LU_ToolCategory
- ✅ LU_ScopeType
- ✅ LU_InteractionLevel
- ✅ LU_RequirementLevel
- ✅ LU_Role
- ✅ LU_EffortCategory

### Hlavní tabulky:
- ✅ ServiceCatalogItem (ServiceCode, ServiceName → NULL)
- ✅ UsageScenario (ScenarioNumber, ScenarioTitle, ScenarioDescription → NULL)
- ✅ ServiceDependency (všechny description sloupce → NULL)
- ✅ ServiceScopeCategory (CategoryNumber, CategoryName → NULL)
- ✅ ServiceScopeItem (ItemName, ItemDescription → NULL)
- ✅ ServicePrerequisite (všechny name/description → NULL)
- ✅ CloudProviderCapability
- ✅ ServiceToolFramework (ToolName → NULL)
- ✅ ServiceLicense (LicenseDescription → NULL, CloudProviderID → NULL DEFAULT 0)
- ✅ ServiceInteraction (InteractionDescription → NULL)
- ✅ CustomerRequirement (RequirementDescription → NULL)
- ✅ AccessRequirement (AccessDescription, RequirementDescription → NULL)
- ✅ StakeholderInvolvement (StakeholderRole, InvolvementDescription → NULL)
- ✅ ServiceInput (InputName, ParameterName, ParameterDescription → NULL)
- ✅ ServiceOutputCategory (CategoryName → NULL)
- ✅ ServiceOutputItem (ItemName, ItemDescription → NULL)
- ✅ TimelinePhase (PhaseNumber, PhaseName, Description, DurationBySize → NULL)
- ✅ PhaseDurationBySize
- ✅ ServiceSizeOption (všechny popisné sloupce → NULL)
- ✅ SizingCriteria (CriteriaName → NULL)
- ✅ SizingCriteriaValue (CriteriaValue → NULL)
- ✅ SizingParameter (ParameterName → NULL)
- ✅ SizingParameterValue (ValueCondition → NULL)
- ✅ EffortEstimationItem (ScopeArea → NULL)
- ✅ TechnicalComplexityAddition (AdditionName, Condition → NULL)
- ✅ ScopeDependency (ScopeArea, RequiredAreas → NULL)
- ✅ SizingExample (ExampleTitle, Scenario → NULL)
- ✅ SizingExampleCharacteristic (CharacteristicDescription → NULL)
- ✅ ServiceResponsibleRole (Responsibility → NULL)
- ✅ ServiceTeamAllocation (všechny role alokace → NULL)
- ✅ ServiceMultiCloudConsideration (ConsiderationTitle, ConsiderationDescription → NULL)

## 🎯 Výsledek:

### Import nyní přijme:
- ✅ NULL hodnoty
- ✅ Prázdné řetězce ('')
- ✅ Jakékoliv platné hodnoty
- ✅ Chybějící pole v JSON (použije se DEFAULT)

### Chyby, které zmizí:
- ❌ "Invalid column name 'Description'" → ✅ Vyřešeno
- ❌ "Invalid column name 'DurationBySize'" → ✅ Vyřešeno
- ❌ "Cannot insert NULL into NOT NULL column" → ✅ Vyřešeno
- ❌ SqlNullValueException → ✅ Vyřešeno

## 📦 Soubory:

- **Aktuální:** `/home/user/webapp/db_structure.sql`
- **Záloha:** `/home/user/webapp/db_structure.sql.backup`
- **Velikost:** 56K (1318 řádků)

## ⚠️ Poznámky:

1. **Foreign keys** zůstaly NOT NULL (např. ServiceID, CategoryID) - nutné pro integritu dat
2. **UNIQUE constraints** ponechány (např. ServiceCode, TypeCode)
3. **DEFAULT hodnoty** automaticky vyplní chybějící data při importu
4. **Audit sloupce** (CreatedDate, ModifiedDate) mají DEFAULT GETUTCDATE()

---

**Status:** ✅ HOTOVO - Import přijme jakákoliv data
