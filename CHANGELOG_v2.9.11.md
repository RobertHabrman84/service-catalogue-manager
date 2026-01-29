# CHANGELOG - Service Catalogue Manager v2.9.11

## Version 2.9.11 - 2026-01-29

### 🔴 KRITICKÉ OPRAVY - ServiceDependency Schema Enhancement

#### Problém
Import selháva s chybami:
- `Invalid column name 'DependencyDescription'`
- `Invalid column name 'DependencyName'`
- `Invalid column name 'DependentServiceCode'`

#### Řešení
**Rozšířeno SQL schema** místo použití Ignore v DbContext:

**Nové sloupce v `ServiceDependency` tabulce:**
1. `DependencyName` NVARCHAR(200) NULL - Friendly name for the dependency
2. `DependencyDescription` NVARCHAR(MAX) NULL - Detailed description  
3. `DependentServiceCode` NVARCHAR(50) NULL - Service code for lookup/reference

**Soubory změněny:**
- `db_structure.sql` - Přidány 3 sloupce do ServiceDependency
- `ServiceCatalogDbContext.cs` - Odstraněny Ignore direktivy
- **NOVÝ:** `MIGRATION_ServiceDependency_v2.9.11.sql` - Migrační skript

### ✅ PŘEDCHOZÍ OPRAVY (z v2.9.10)

#### Database Schema Mapping (13 problémů)
1. **ServiceToolFramework**
   - ✅ .ToTable("ServiceToolFramework")
   - ✅ Column mapping: ToolId → ToolFrameworkID

2. **ServiceLicense**
   - ✅ Přidán CloudProviderId property
   - ✅ .ToTable("ServiceLicense")
   - ✅ Column mapping: LicenseName → LicenseDescription
   - ✅ Ignore Description property

3. **TechnicalComplexityAddition**
   - ✅ .ToTable("TechnicalComplexityAddition")
   - ✅ Column mapping: AdditionId → ComplexityAdditionID

4. **10 dalších entit**
   - ✅ CloudProviderCapability
   - ✅ ScopeDependency
   - ✅ SizingCriteria
   - ✅ SizingCriteriaValue
   - ✅ SizingParameter
   - ✅ SizingParameterValue
   - ✅ SizingExampleCharacteristic

#### Duplicate Key Protection (2 opravy)
5. **ToolsHelper.cs**
   - ✅ Session cache: Dictionary<string, LU_ToolCategory>
   - ✅ Try-catch pro DbUpdateException
   - ✅ Reload z databáze při race condition

6. **CategoryHelper.cs**
   - ✅ Session cache: Dictionary<string, LU_ServiceCategory>
   - ✅ Try-catch pro DbUpdateException
   - ✅ Reload z databáze při race condition

#### ServicePrerequisite Schema (6 sloupců)
7. **db_structure.sql & migrační skript**
   - ✅ PrerequisiteName
   - ✅ PrerequisiteDescription
   - ✅ RequirementLevelId
   - ✅ CreatedDate, CreatedBy, ModifiedDate, ModifiedBy

---

## Migrační instrukce

### Pro NOVÉ databáze:
```sql
-- Použijte aktualizovaný db_structure.sql
-- Všechny změny jsou již zahrnuty
```

### Pro EXISTUJÍCÍ databáze:
```sql
-- 1. Spusťte ServicePrerequisite migraci (z v2.9.10)
EXEC sp_executesql @sql = '...HOTFIX_ServicePrerequisite_v2.9.10.sql';

-- 2. Spusťte ServiceDependency migraci (NOVÉ v v2.9.11)
EXEC sp_executesql @sql = '...MIGRATION_ServiceDependency_v2.9.11.sql';
```

### Nasazení kódu:
1. Nahradit soubory z `service-catalogue-manager-v2_9_11.zip`
2. Rebuild aplikace
3. Restart služby

---

## Celková statistika oprav

### v2.9.11 (AKTUÁLNÍ)
- ServiceDependency schema: **3 nové sloupce**
- DbContext cleanup: **Odstraněny 4 Ignore**

### v2.9.10
- Schema mapping: **13 problémů**
- Duplicate key: **2 opravy**
- Missing columns: **6 sloupců**

### CELKEM v2.9.11
- **Opravených problémů: 24**
- **Upravených souborů: 6**
- **Migračních skriptů: 2**

---

## Testování

### Očekávané chování po nasazení:
✅ Import projde bez `Invalid column name` errors  
✅ ServiceDependency podporuje všechny properties z C# entity  
✅ Duplicate key errors jsou ošetřeny  
✅ Všechny entity se správně mapují na SQL tabulky  

### Test scenario:
1. Import služby s dependencies
2. Ověřit uložení DependencyName, DependencyDescription, DependentServiceCode
3. Ověřit funkci DependentServiceID mapping

---

## Breaking Changes
**ŽÁDNÉ** - Všechny změny jsou zpětně kompatibilní.
- Nové sloupce jsou NULL
- Column mapping je transparentní
- Existující data zůstávají nezměněna

---

## Known Issues
⚠️ **16 Calculator entit** chybí v db_structure.sql (neblokující):
- 15 Calculator tables (ServicePricingConfig, ServiceRoleRate, atd.)
- 1 Lookup table (LU_EffortCategory)

**Status:** Import funguje i bez těchto tabulek.  
**Řešení:** Bude součástí budoucího releasu pokud jsou potřeba.
