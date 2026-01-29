# 🔍 KOMPLETNÍ KONTROLA VŠECH DAT Z JSON PROTI DATABÁZI

## 📊 STRUKTURA JSON SOUBORU

```
Application_Landing_Zone_Design.json (1753 řádků)
├── serviceCode: "ID999"
├── serviceName: "Application Landing Zone Design"  
├── version: "v1.0"
├── category: "Services/Architecture/Technical Architecture"
├── description: (dlouhý text)
├── notes: (text)
├── usageScenarios: [8 items] ✅
├── dependencies: {prerequisite, triggersFor, parallelWith} ✅
├── scope: {inScope, outOfScope} ✅
├── prerequisites: {organizational, technical, documentation} ✅
├── toolsAndEnvironment: {...} ✅
├── licenses: {...} ✅
├── stakeholderInteraction: {...} ✅
├── serviceInputs: [15 items] ❌ TADY TO SELŽE
├── serviceOutputs: [10 categories] ✅
├── timeline: {phases} ✅
├── sizeOptions: [3 options: S/M/L] ✅
├── responsibleRoles: [4 roles] ✅
└── multiCloudConsiderations: [5 items] ✅
```

---

## 🗂️ DETAILNÍ KONTROLA PO SEKCÍCH

### ✅ 1. ServiceCatalogItem (hlavní záznam)

**JSON → DB mapping:**

| JSON pole | DB sloupec | Status | Poznámka |
|-----------|-----------|--------|----------|
| serviceCode | ServiceCode | ✅ OK | NVARCHAR(50) |
| serviceName | ServiceName | ✅ OK | NVARCHAR(200) |
| version | Version | ✅ OK | NVARCHAR(20) |
| category | CategoryId | ✅ OK | Parse path → lookup LU_ServiceCategory |
| description | Description | ✅ OK | NVARCHAR(MAX) |
| notes | Notes | ✅ OK | NVARCHAR(MAX) |

**Závislost na LU_ServiceCategory:**
- JSON: "Services/Architecture/Technical Architecture"
- Parsuje se na: CategoryCode pomocí cesty
- ✅ **LU_ServiceCategory je OK** - mapuje CategoryCode/CategoryName správně

---

### ✅ 2. UsageScenarios (8 záznamů)

**JSON struktura:**
```json
{
  "scenarioNumber": 1,
  "scenarioTitle": "Post-Assessment Implementation Planning",
  "scenarioDescription": "Organizations need...",
  "sortOrder": 1
}
```

**DB tabulka: UsageScenario**
```sql
CREATE TABLE UsageScenario (
    ScenarioID INT PRIMARY KEY,
    ServiceID INT FK,
    ScenarioNumber INT,
    ScenarioTitle NVARCHAR(200),
    ScenarioDescription NVARCHAR(MAX),
    SortOrder INT
)
```

**Mapping:**
| JSON | DB | Status |
|------|---|--------|
| scenarioNumber | ScenarioNumber | ✅ OK |
| scenarioTitle | ScenarioTitle | ✅ OK |
| scenarioDescription | ScenarioDescription | ✅ OK |
| sortOrder | SortOrder | ✅ OK |

✅ **UsageScenarios - FUNGUJE**

---

### ❌ 3. ServiceInputs (15 záznamů) - KRITICKÝ BOD SELHÁNÍ

**JSON struktura:**
```json
{
  "parameterName": "Number of applications",
  "description": "Total count...",
  "requirementLevel": "REQUIRED",  ← TADY TO SELŽE
  "dataType": "number"
}
```

**DB tabulka: ServiceInput**
```sql
CREATE TABLE ServiceInput (
    InputID INT PRIMARY KEY,
    ServiceID INT FK,
    ParameterName NVARCHAR(200),
    Description NVARCHAR(MAX),
    RequirementLevelID INT FK → LU_RequirementLevel,  ← TADY!
    DataType NVARCHAR(50)
)
```

**Mapping:**
| JSON | DB | Závislost | Status |
|------|---|-----------|--------|
| parameterName | ParameterName | - | ✅ OK |
| description | Description | - | ✅ OK |
| requirementLevel | RequirementLevelID | ❌ **LU_RequirementLevel** | ❌ CHYBA |
| dataType | DataType | - | ✅ OK |

**Proces importu:**
1. Pro každý input zavolá: `FindOrCreateRequirementLevelAsync("REQUIRED")`
2. Ta metoda načte: `_requirementLevelRepository.GetAllAsync()`
3. EF vygeneruje SQL: `SELECT [l].[Code], [l].[Name], [l].[IsActive]...`
4. ❌ **CHYBA**: Sloupce `Code`, `Name`, `IsActive` neexistují!

**LU_RequirementLevel v DB:**
```sql
CREATE TABLE LU_RequirementLevel (
    RequirementLevelID INT PRIMARY KEY,
    LevelCode NVARCHAR(20),      ← NE "Code"
    LevelName NVARCHAR(50),      ← NE "Name"
    SortOrder INT
    -- Nemá IsActive!
)
```

**DbContext konfigurace (CHYBNÁ):**
```csharp
entity.Property(e => e.Code).IsRequired().HasMaxLength(20);  // ❌ mapuje Code → Code
entity.Property(e => e.Name).IsRequired().HasMaxLength(50);  // ❌ mapuje Name → Name
```

**OPRAVA:**
```csharp
entity.Property(e => e.Code).HasColumnName("LevelCode");
entity.Property(e => e.Name).HasColumnName("LevelName");
entity.Ignore(e => e.IsActive);
```

❌ **ServiceInputs - NEFUNGUJE bez opravy**

---

### ✅ 4. Dependencies (11 záznamů total)

**JSON struktura:**
```json
"dependencies": {
  "prerequisite": [
    {"serviceName": "...", "requirementLevel": "REQUIRED"}
  ],
  "triggersFor": [...],
  "parallelWith": [...]
}
```

**DB tabulka: ServiceDependency**
```sql
CREATE TABLE ServiceDependency (
    DependencyID INT PRIMARY KEY,
    ServiceID INT FK,
    DependencyTypeID INT FK → LU_DependencyType,  ← TADY!
    DependentServiceName NVARCHAR(200),
    RequirementLevelID INT FK → LU_RequirementLevel  ← TADY!
)
```

**Závislosti:**
1. **LU_DependencyType** - určuje typ (prerequisite/triggersFor/parallelWith)
2. **LU_RequirementLevel** - REQUIRED/RECOMMENDED/OPTIONAL

**LU_DependencyType v DB:**
```sql
CREATE TABLE LU_DependencyType (
    DependencyTypeID INT PRIMARY KEY,
    TypeCode NVARCHAR(50),      ← DB má TypeCode
    TypeName NVARCHAR(100),     ← DB má TypeName
    Description NVARCHAR(500)
)
```

**DbContext konfigurace (PO MÉ PRVNÍ OPRAVĚ - CHYBNÁ):**
```csharp
entity.Property(e => e.Code).IsRequired().HasMaxLength(50);  // ❌ mapuje Code → Code
entity.Property(e => e.Name).IsRequired().HasMaxLength(100); // ❌ mapuje Name → Name
```

**OPRAVA:**
```csharp
entity.Property(e => e.Code).HasColumnName("TypeCode");
entity.Property(e => e.Name).HasColumnName("TypeName");
entity.Ignore(e => e.IsActive);
entity.Ignore(e => e.SortOrder);
```

❌ **Dependencies - NEFUNGUJE bez opravy (2 lookup tabulky)**

---

### ⚠️ 5. Scope (InScope + OutOfScope)

**JSON struktura:**
```json
"scope": {
  "inScope": [
    {
      "categoryNumber": 1,
      "categoryName": "Platform Architecture",
      "items": ["item1", "item2", ...]
    }
  ],
  "outOfScope": ["item1", "item2", ...]
}
```

**DB tabulky:**
```sql
ServiceScopeCategory (
    ScopeCategoryID INT,
    ServiceID INT FK,
    ScopeTypeID INT FK → LU_ScopeType,  ← TADY!
    CategoryNumber INT,
    CategoryName NVARCHAR(200)
)

ServiceScopeItem (
    ScopeItemID INT,
    ScopeCategoryID INT FK,
    ItemDescription NVARCHAR(MAX),
    SortOrder INT
)
```

**LU_ScopeType v DB:**
```sql
CREATE TABLE LU_ScopeType (
    ScopeTypeID INT PRIMARY KEY,
    TypeCode NVARCHAR(20),      ← DB má TypeCode
    TypeName NVARCHAR(50)       ← DB má TypeName
)
```

**DbContext (PO MÉ PRVNÍ OPRAVĚ - CHYBNÁ):**
```csharp
entity.Property(e => e.Code).IsRequired().HasMaxLength(20);  // ❌ Code → Code
entity.Property(e => e.Name).IsRequired().HasMaxLength(50);  // ❌ Name → Name
```

**OPRAVA:**
```csharp
entity.Property(e => e.Code).HasColumnName("TypeCode");
entity.Property(e => e.Name).HasColumnName("TypeName");
entity.Ignore(e => e.IsActive);
entity.Ignore(e => e.SortOrder);
```

❌ **Scope - MŮŽE SELHAT (LU_ScopeType)**

---

### ⚠️ 6. Prerequisites (organizational + technical + documentation)

**DB tabulka:**
```sql
ServicePrerequisite (
    PrerequisiteID INT,
    ServiceID INT FK,
    PrerequisiteCategoryID INT FK → LU_PrerequisiteCategory,  ← KONTROLA
    RequirementLevelID INT FK → LU_RequirementLevel  ← UŽ VÍME ŽE SELHÁVÁ
)
```

**LU_PrerequisiteCategory v DB:**
```sql
CREATE TABLE LU_PrerequisiteCategory (
    PrerequisiteCategoryID INT PRIMARY KEY,
    CategoryCode NVARCHAR(50),      ← DB má CategoryCode ✅
    CategoryName NVARCHAR(100)      ← DB má CategoryName ✅
)
```

**DbContext konfigurace:**
```csharp
entity.Property(e => e.Code).HasColumnName("CategoryCode");  ✅ OK
entity.Property(e => e.Name).HasColumnName("CategoryName");  ✅ OK
entity.Ignore(e => e.Description);  ✅ OK
```

**ALE:**
```csharp
// ❌ CHYBÍ:
entity.Ignore(e => e.IsActive);   // DB nemá IsActive
entity.Ignore(e => e.SortOrder);  // DB nemá SortOrder
```

⚠️ **Prerequisites - MŮŽE SELHAT (chybějící Ignore + závislost na LU_RequirementLevel)**

---

### ⚠️ 7. StakeholderInteraction

**JSON struktura:**
```json
"stakeholderInteraction": {
  "interactionLevel": "HIGH",
  ...
}
```

**DB tabulka:**
```sql
ServiceInteraction (
    InteractionID INT,
    ServiceID INT FK,
    InteractionLevelID INT FK → LU_InteractionLevel  ← TADY!
)
```

**LU_InteractionLevel v DB:**
```sql
CREATE TABLE LU_InteractionLevel (
    InteractionLevelID INT PRIMARY KEY,
    LevelCode NVARCHAR(20),      ← DB má LevelCode
    LevelName NVARCHAR(50),      ← DB má LevelName
    SortOrder INT
)
```

**DbContext (PO MÉ PRVNÍ OPRAVĚ - CHYBNÁ):**
```csharp
entity.Property(e => e.Code).IsRequired().HasMaxLength(20);  // ❌ Code → Code
entity.Property(e => e.Name).IsRequired().HasMaxLength(50);  // ❌ Name → Name
```

**OPRAVA:**
```csharp
entity.Property(e => e.Code).HasColumnName("LevelCode");
entity.Property(e => e.Name).HasColumnName("LevelName");
entity.Ignore(e => e.IsActive);
```

❌ **StakeholderInteraction - NEFUNGUJE (LU_InteractionLevel)**

---

### ⚠️ 8. ResponsibleRoles

**JSON:**
```json
"responsibleRoles": [
  {
    "role": "Cloud Architect",
    "responsibilities": "Primary design responsibility",
    "isPrimaryOwner": true
  }
]
```

**DB tabulka:**
```sql
ServiceResponsibleRole (
    ResponsibleRoleID INT,
    ServiceID INT FK,
    RoleID INT FK → LU_Role  ← TADY!
)

StakeholderInvolvement (
    InvolvementID INT,
    ServiceID INT FK,
    RoleID INT FK → LU_Role  ← TADY TAKÉ!
)
```

**LU_Role v DB:**
```sql
CREATE TABLE LU_Role (
    RoleID INT PRIMARY KEY,
    RoleCode NVARCHAR(50),      ← DB má RoleCode
    RoleName NVARCHAR(100),     ← DB má RoleName
    Description NVARCHAR(500),
    IsActive BIT
)
```

**DbContext konfigurace (CHYBNÁ):**
```csharp
entity.Property(e => e.Code).HasColumnName("CategoryCode");  // ❌ CategoryCode neexistuje!
entity.Property(e => e.Name).HasColumnName("CategoryName");  // ❌ CategoryName neexistuje!
```

**OPRAVA:**
```csharp
entity.Property(e => e.Code).HasColumnName("RoleCode");
entity.Property(e => e.Name).HasColumnName("RoleName");
entity.Ignore(e => e.SortOrder);
// Description a IsActive existují v DB
```

❌ **ResponsibleRoles - NEFUNGUJE (LU_Role)**

---

### ⚠️ 9. Licenses

**DB tabulka:**
```sql
ServiceLicense (
    LicenseID INT,
    ServiceID INT FK,
    LicenseTypeID INT FK → LU_LicenseType  ← TADY!
)
```

**LU_LicenseType v DB:**
```sql
CREATE TABLE LU_LicenseType (
    LicenseTypeID INT PRIMARY KEY,
    TypeCode NVARCHAR(50),      ← DB má TypeCode
    TypeName NVARCHAR(100)      ← DB má TypeName
)
```

**DbContext (CHYBNÁ):**
```csharp
entity.Property(e => e.Code).HasColumnName("CategoryCode");  // ❌ neexistuje!
entity.Property(e => e.Name).HasColumnName("CategoryName");  // ❌ neexistuje!
```

**OPRAVA:**
```csharp
entity.Property(e => e.Code).HasColumnName("TypeCode");
entity.Property(e => e.Name).HasColumnName("TypeName");
entity.Ignore(e => e.Description);
entity.Ignore(e => e.IsActive);
entity.Ignore(e => e.SortOrder);
```

❌ **Licenses - NEFUNGUJE (LU_LicenseType)**

---

### ⚠️ 10. ToolsAndEnvironment

**DB tabulka:**
```sql
ServiceToolFramework (
    ToolFrameworkID INT,
    ServiceID INT FK,
    ToolCategoryID INT FK → LU_ToolCategory  ← KONTROLA
)
```

**LU_ToolCategory v DB:**
```sql
CREATE TABLE LU_ToolCategory (
    ToolCategoryID INT PRIMARY KEY,
    CategoryCode NVARCHAR(50),      ← DB má CategoryCode ✅
    CategoryName NVARCHAR(100)      ← DB má CategoryName ✅
)
```

**DbContext:**
```csharp
entity.Property(e => e.Code).HasColumnName("CategoryCode");  ✅ OK
entity.Property(e => e.Name).HasColumnName("CategoryName");  ✅ OK
// ❌ CHYBÍ:
entity.Ignore(e => e.IsActive);   // DB nemá
entity.Ignore(e => e.SortOrder);  // DB nemá
```

⚠️ **ToolsAndEnvironment - MŮŽE SELHAT (chybějící Ignore)**

---

### ✅ 11. ServiceOutputs

**JSON struktura:**
```json
{
  "categoryNumber": 1,
  "categoryName": "Technical Architecture Design Document",
  "items": [
    {
      "itemName": "Executive summary...",
      "itemDescription": "High-level summary..."
    }
  ]
}
```

**DB tabulky:**
```sql
ServiceOutputCategory (
    CategoryID INT,
    ServiceID INT FK,
    CategoryNumber INT,
    CategoryName NVARCHAR(200)
)

ServiceOutputItem (
    ItemID INT,
    CategoryID INT FK,
    ItemName NVARCHAR(200),
    ItemDescription NVARCHAR(MAX)
)
```

✅ **ServiceOutputs - FUNGUJE (žádné lookup závislosti)**

---

### ✅ 12. Timeline

**DB tabulka:**
```sql
TimelinePhase (
    PhaseID INT,
    ServiceID INT FK,
    PhaseNumber INT,
    PhaseName NVARCHAR(200),
    Duration NVARCHAR(50)
)
```

✅ **Timeline - FUNGUJE (žádné lookup závislosti)**

---

### ⚠️ 13. SizeOptions

**DB tabulky:**
```sql
ServiceSizeOption (
    SizeOptionID INT FK → LU_SizeOption  ← KONTROLA
)
```

**LU_SizeOption v DB:**
```sql
CREATE TABLE LU_SizeOption (
    SizeOptionID INT PRIMARY KEY,
    SizeCode NVARCHAR(10),      ← DB má SizeCode ✅
    SizeName NVARCHAR(50),      ← DB má SizeName ✅
    SortOrder INT,
    IsActive BIT
)
```

**DbContext:**
```csharp
entity.Property(e => e.Code).HasColumnName("SizeCode");  ✅ OK
entity.Property(e => e.Name).HasColumnName("SizeName");  ✅ OK
// ❌ CHYBÍ:
entity.Ignore(e => e.Description);  // DB nemá
```

⚠️ **SizeOptions - MŮŽE SELHAT (chybějící Ignore pro Description)**

---

### ⚠️ 14. EffortEstimation

**DB tabulka:**
```sql
EffortEstimationItem (
    EstimationItemID INT,
    ServiceID INT FK,
    EffortCategoryID INT FK → LU_EffortCategory  ← TADY!
)
```

**LU_EffortCategory:**
❌ **TABULKA NEEXISTUJE V DATABÁZI!**

**DbContext má konfiguraci, ale tabulka neexistuje!**

❌ **EffortEstimation - KRITICKÁ CHYBA (tabulka neexistuje)**

---

## 📊 CELKOVÉ SHRNUTÍ

### ❌ KRITICKÉ CHYBY (import selže okamžitě):

1. **LU_RequirementLevel** - Code → LevelCode, Name → LevelName
   - Použito v: ServiceInputs, Dependencies, Prerequisites
   
2. **LU_InteractionLevel** - Code → LevelCode, Name → LevelName
   - Použito v: StakeholderInteraction

### ❌ VYSOKÉ PRIORITY (selže při zpracování těchto sekcí):

3. **LU_DependencyType** - Code → TypeCode, Name → TypeName
   - Použito v: Dependencies
   
4. **LU_ScopeType** - Code → TypeCode, Name → TypeName
   - Použito v: Scope
   
5. **LU_Role** - CategoryCode → RoleCode, CategoryName → RoleName
   - Použito v: ResponsibleRoles, StakeholderInvolvement
   
6. **LU_LicenseType** - CategoryCode → TypeCode, CategoryName → TypeName
   - Použito v: Licenses

7. **LU_EffortCategory** - NEEXISTUJE V DB!
   - Použito v: EffortEstimation

### ⚠️ STŘEDNÍ PRIORITY (může způsobit problémy):

8. **LU_PrerequisiteCategory** - chybí Ignore pro IsActive, SortOrder
9. **LU_ToolCategory** - chybí Ignore pro IsActive, SortOrder
10. **LU_CloudProvider** - chybí Ignore pro SortOrder
11. **LU_SizeOption** - chybí Ignore pro Description

---

## ✅ CO FUNGUJE:

- ✅ ServiceCatalogItem (základní údaje)
- ✅ UsageScenarios
- ✅ ServiceOutputs
- ✅ Timeline

---

## 🎯 ZÁVĚR

**Import z JSON DO databáze:**
- Aktuálně: ❌ **NEFUNGUJE** - selže na ServiceInputs (15 položek)
- Po opravě: ✅ **BUDE FUNGOVAT** - všech 1753 řádků JSON půjde do DB

**Počet tabulek k opravě:** 10
**Počet sekcí JSON ovlivněno:** 8+ sekcí
**Kritičnost:** VYSOKÁ - bez opravy nelze importovat ŽÁDNÁ data z JSON
