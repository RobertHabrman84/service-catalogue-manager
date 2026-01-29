# Analýza a oprava chyby importu služeb

## 📋 Souhrn problému

**Datum:** 29. ledna 2026  
**Verze:** service-catalogue-manager v2.9.0  
**Závažnost:** CRITICAL - aplikace nefungovala při importu služeb

## 🔍 Identifikované chyby

### Chyba v logu:
```
[2026-01-29T14:05:18.316Z] Microsoft.Data.SqlClient.SqlException (0x80131904): 
Invalid column name 'TypeCode'.
Invalid column name 'IsActive'.
Invalid column name 'TypeName'.
```

### Místo výskytu:
- **Funkce:** `ImportOrchestrationService.ImportServiceInputsAsync()`
- **Řádek:** Line 178 v `FindOrCreateRequirementLevelAsync()`
- **Proces:** Import služby ID999

## 🔬 Root Cause Analysis

### Příčina:
Nesoulad mezi **databázovou migrací** a **Entity Framework konfigurací** v `ServiceCatalogDbContext.cs`

### Detailní vysvětlení:

1. **Databázová migrace** (`20260126081837_InitialCreate.cs`) vytvořila tabulky se sloupci:
   ```sql
   CREATE TABLE LU_RequirementLevel (
       RequirementLevelId INT PRIMARY KEY,
       Code NVARCHAR(20),          -- ✅ Správný název
       Name NVARCHAR(50),          -- ✅ Správný název
       Description NVARCHAR(MAX),
       SortOrder INT,
       IsActive BIT
   )
   ```

2. **DbContext konfigurace** (`ServiceCatalogDbContext.cs`) ale mapovala:
   ```csharp
   entity.Property(e => e.Code).HasColumnName("TypeCode");  // ❌ Špatně!
   entity.Property(e => e.Name).HasColumnName("TypeName");  // ❌ Špatně!
   ```

3. **Entity Framework** pak generoval SQL dotazy:
   ```sql
   SELECT [l].[RequirementLevelId], 
          [l].[TypeCode],    -- ❌ Neexistuje v DB
          [l].[IsActive],    
          [l].[TypeName],    -- ❌ Neexistuje v DB
          [l].[SortOrder]
   FROM [LU_RequirementLevel] AS [l]
   ```

## 🎯 Postižené tabulky

Následující lookup tabulky měly chybnou konfiguraci:

1. ❌ **LU_DependencyType** - `Code → TypeCode`, `Name → TypeName`
2. ❌ **LU_ScopeType** - `Code → TypeCode`, `Name → TypeName`
3. ❌ **LU_InteractionLevel** - `Code → TypeCode`, `Name → TypeName`
4. ❌ **LU_RequirementLevel** - `Code → TypeCode`, `Name → TypeName` **(zde aplikace selhala)**

Ostatní lookup tabulky byly v pořádku:
- ✅ LU_ServiceCategory - `Code → CategoryCode`, `Name → CategoryName`
- ✅ LU_SizeOption - `Code → SizeCode`, `Name → SizeName`
- ✅ LU_CloudProvider - `Code → ProviderCode`, `Name → ProviderName`
- ✅ LU_PrerequisiteCategory - `Code → CategoryCode`, `Name → CategoryName`
- ✅ LU_LicenseType - `Code → CategoryCode`, `Name → CategoryName`
- ✅ LU_ToolCategory - `Code → CategoryCode`, `Name → CategoryName`
- ✅ LU_Role - `Code → CategoryCode`, `Name → CategoryName`
- ✅ LU_EffortCategory - `Code → CategoryCode`, `Name → CategoryName`

**Poznámka:** Tyto tabulky jsou OK, protože v migraci mají skutečně sloupce `CategoryCode`, `SizeCode` atd.

## ✅ Implementovaná oprava

### Opravený soubor:
`ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs`

### Změny:

#### 1. LU_DependencyType (řádky ~473-481)
```csharp
// PŘED:
entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("TypeCode");
entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("TypeName");

// PO:
entity.Property(e => e.Code).IsRequired().HasMaxLength(50);
entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
```

#### 2. LU_ScopeType (řádky ~513-521)
```csharp
// PŘED:
entity.Property(e => e.Code).IsRequired().HasMaxLength(20).HasColumnName("TypeCode");
entity.Property(e => e.Name).IsRequired().HasMaxLength(50).HasColumnName("TypeName");

// PO:
entity.Property(e => e.Code).IsRequired().HasMaxLength(20);
entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
```

#### 3. LU_InteractionLevel (řádky ~523-531)
```csharp
// PŘED:
entity.Property(e => e.Code).IsRequired().HasMaxLength(20).HasColumnName("TypeCode");
entity.Property(e => e.Name).IsRequired().HasMaxLength(50).HasColumnName("TypeName");

// PO:
entity.Property(e => e.Code).IsRequired().HasMaxLength(20);
entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
```

#### 4. LU_RequirementLevel (řádky ~533-541)
```csharp
// PŘED:
entity.Property(e => e.Code).IsRequired().HasMaxLength(20).HasColumnName("TypeCode");
entity.Property(e => e.Name).IsRequired().HasMaxLength(50).HasColumnName("TypeName");

// PO:
entity.Property(e => e.Code).IsRequired().HasMaxLength(20);
entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
```

## 🧪 Ověření opravy

### Co bylo změněno:
- Odstraněno `.HasColumnName("TypeCode")` z 4 tabulek
- Odstraněno `.HasColumnName("TypeName")` z 4 tabulek

### Co zůstalo nezměněno:
- Properties `IsActive` a `SortOrder` - tyto jsou v DB a EF je automaticky namapuje
- Property `Description` - zůstává ignorována pomocí `.Ignore(e => e.Description)`
- Všechny ostatní lookup tabulky

### Očekávaný výsledek:
Entity Framework nyní správně mapuje:
- `Code` → sloupec `Code` v databázi
- `Name` → sloupec `Name` v databázi
- `IsActive` → sloupec `IsActive` v databázi (automaticky)
- `SortOrder` → sloupec `SortOrder` v databázi (automaticky)

## 📝 Poznámky

### Proč migrace nebyla nutná:
Databáze měla od začátku správné názvy sloupců (`Code`, `Name`). Problém byl pouze v runtime konfiguraci Entity Framework.

### Proč to fungovalo pro jiné tabulky:
Tabulky jako `LU_ServiceCategory` používaly `HasColumnName("CategoryCode")` a v databázi byl skutečně sloupec `CategoryCode` (ne `Code`), takže tam nebyl konflikt.

## 🚀 Doporučené další kroky

1. ✅ Zkompilovat projekt
2. ✅ Spustit aplikaci
3. ✅ Otestovat import služby
4. ⚠️ Zvážit konzistentnější názvovou konvenci pro lookup tabulky v budoucnu
5. ⚠️ Přidat automatizované testy pro import workflow

## 📊 Impact Assessment

### Severity: HIGH
- Aplikace byla kompletně nefunkční pro import služeb
- Ovlivněna kritická funkcionalita

### Risk: LOW
- Oprava je jednoduchá a nevyžaduje změny databáze
- Žádný dopad na existující data
- Nezasahuje do jiných částí systému

### Testing Effort: MEDIUM
- Nutno otestovat import pro všechny typy služeb
- Ověřit, že ostatní lookup tabulky stále fungují
