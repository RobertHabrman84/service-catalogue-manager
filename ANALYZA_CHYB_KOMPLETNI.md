# 🔍 KOMPLETNÍ ANALÝZA CHYB - Service Catalogue Manager v2.9.3

**Datum analýzy:** 29.01.2026  
**Verze projektu:** v2.9.3  
**Typ problému:** Nesoulad mezi Entity Framework modely a databázovou strukturou

---

## 📊 CELKOVÝ PŘEHLED

| Kategorie | Počet | Status |
|-----------|-------|--------|
| **Entity dědící z BaseEntity** | 40 | ✅ V kódu OK |
| **Tabulky s chybějícími auditními poli** | 40 | ❌ V DB chybí |
| **Tabulky neexistující v db_structure.sql** | 15 | ❌ Úplně chybí |
| **ServiceInput - specifické chyby** | 3 vlastnosti | ❌ Chybí v DB |

---

## 🔴 KRITICKÝ PROBLÉM #1: ServiceInput - Chybějící vlastnosti

### C# Entity vlastnosti (ServiceInput.cs):
```csharp
public class ServiceInput : BaseEntity, ISortable
{
    public int InputId { get; set; }
    public int ServiceId { get; set; }
    public string InputName { get; set; }              // ❌ CHYBÍ V DB
    public string ParameterName { get; set; }          // ✅ V DB
    public string ParameterDescription { get; set; }   // ✅ V DB
    public string? Description { get; set; }           // ❌ CHYBÍ V DB
    public int RequirementLevelId { get; set; }        // ✅ V DB
    public string? DataType { get; set; }              // ✅ V DB
    public string? DefaultValue { get; set; }          // ✅ V DB
    public string? ExampleValue { get; set; }          // ❌ CHYBÍ V DB
    public int SortOrder { get; set; }                 // ✅ V DB
    
    // Z BaseEntity:
    public DateTime CreatedDate { get; set; }          // ❌ CHYBÍ V DB
    public string? CreatedBy { get; set; }             // ❌ CHYBÍ V DB
    public DateTime ModifiedDate { get; set; }         // ❌ CHYBÍ V DB
    public string? ModifiedBy { get; set; }            // ❌ CHYBÍ V DB
}
```

### Aktuální DB struktura (db_structure.sql):
```sql
CREATE TABLE dbo.ServiceInput (
    InputID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL REFERENCES dbo.ServiceCatalogItem(ServiceID),
    ParameterName NVARCHAR(200) NOT NULL,
    ParameterDescription NVARCHAR(MAX) NOT NULL,
    RequirementLevelID INT NOT NULL REFERENCES dbo.LU_RequirementLevel(RequirementLevelID),
    DataType NVARCHAR(50) NULL,
    DefaultValue NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);
```

### Chybějící sloupce v ServiceInput:
1. ❌ `InputName` NVARCHAR(200) NOT NULL
2. ❌ `Description` NVARCHAR(MAX) NULL
3. ❌ `ExampleValue` NVARCHAR(MAX) NULL
4. ❌ `CreatedDate` DATETIME2 NOT NULL
5. ❌ `CreatedBy` NVARCHAR(200) NULL
6. ❌ `ModifiedDate` DATETIME2 NOT NULL
7. ❌ `ModifiedBy` NVARCHAR(200) NULL

---

## 🔴 KRITICKÝ PROBLÉM #2: Chybějící auditní pole (40 tabulek)

Všechny následující tabulky **dědí z BaseEntity** v C# kódu, ale **nemají auditní sloupce** v databázi:

### 📋 Existující tabulky bez auditních polí (25 tabulek):

1. **ServiceInput** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
2. **UsageScenario** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
3. **ServiceScopeItem** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
4. **ServiceToolFramework** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
5. **ServiceLicense** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
6. **StakeholderInvolvement** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
7. **ServiceOutputCategory** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
8. **ServiceOutputItem** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
9. **ServiceSizeOption** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
10. **TechnicalComplexityAddition** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
11. **ServiceTeamAllocation** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
12. **SizingExample** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
13. **SizingExampleCharacteristic** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
14. **ScopeDependency** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
15. **SizingParameter** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
16. **SizingCriteria** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
17. **ServiceMultiCloudConsideration** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
18. **CloudProviderCapability** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
19. **SizingCriteriaValue** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
20. **SizingParameterValue** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
21. **TimelinePhase** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
22. **PhaseDurationBySize** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
23. **EffortEstimationItem** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
24. **ServiceResponsibleRole** - chybí CreatedDate, CreatedBy, ModifiedDate, ModifiedBy

### 📋 Tabulky úplně chybějící v db_structure.sql (15 tabulek):

25. **EffortEstimation** - tabulka neexistuje v SQL skriptu
26. **ServicePricingConfig** - tabulka neexistuje v SQL skriptu
27. **ServiceRoleRate** - tabulka neexistuje v SQL skriptu
28. **ServiceBaseEffort** - tabulka neexistuje v SQL skriptu
29. **ServiceContextMultiplier** - tabulka neexistuje v SQL skriptu
30. **ServiceContextMultiplierValue** - tabulka neexistuje v SQL skriptu
31. **ServiceScopeArea** - tabulka neexistuje v SQL skriptu
32. **ServiceComplianceFactor** - tabulka neexistuje v SQL skriptu
33. **ServiceCalculatorSection** - tabulka neexistuje v SQL skriptu
34. **ServiceCalculatorGroup** - tabulka neexistuje v SQL skriptu
35. **ServiceCalculatorParameter** - tabulka neexistuje v SQL skriptu
36. **ServiceCalculatorParameterOption** - tabulka neexistuje v SQL skriptu
37. **ServiceCalculatorScenario** - tabulka neexistuje v SQL skriptu
38. **ServiceCalculatorPhase** - tabulka neexistuje v SQL skriptu
39. **ServiceTeamComposition** - tabulka neexistuje v SQL skriptu
40. **ServiceSizingCriteria** - tabulka neexistuje v SQL skriptu

---

## 💥 DOPAD NA FUNKČNOST

### ❌ Co nefunguje:
1. **Import služeb** - selhává při ukládání ServiceInput
2. **Vytváření nových záznamů** - pro všechny výše uvedené entity
3. **Aktualizace záznamů** - auditní pole nejsou sledována
4. **Kalkulační funkce** - 15 tabulek vůbec neexistuje

### ✅ Co funguje:
1. Načítání existujících dat (pokud neobsahují auditní pole)
2. Validace importu (kontroluje pouze logiku, ne DB strukturu)
3. Tabulky, které NEDĚDÍ z BaseEntity

---

## 🔧 DOPORUČENÉ ŘEŠENÍ

### Varianta A: Aktualizace databáze (DOPORUČENO)

Přidat chybějící sloupce do existujících tabulek a vytvořit chybějící tabulky.

**Výhody:**
- ✅ Zachová auditní funkcionalitu
- ✅ Kód zůstane beze změn
- ✅ Kompatibilní s budoucími verzemi

**Nevýhody:**
- ⚠️ Vyžaduje DB migraci
- ⚠️ Může ovlivnit existující data

### Varianta B: Úprava C# entit

Odstranit dědění z BaseEntity u problematických tříd.

**Výhody:**
- ✅ Rychlá oprava
- ✅ Žádné změny v DB

**Nevýhody:**
- ❌ Ztráta auditní funkcionality
- ❌ Nesoulad s architekturou
- ❌ Technický dluh

---

## 📝 PRIORITY OPRAV

### 🔴 KRITICKÉ (blokují import):
1. ServiceInput - přidat 7 chybějících sloupců
2. UsageScenario - přidat 4 auditní sloupce
3. ServiceOutputCategory - přidat 4 auditní sloupce

### 🟡 VYSOKÉ (omezují funkcionalitu):
4-24. Všechny ostatní existující tabulky - přidat auditní sloupce

### 🟢 STŘEDNÍ (chybějící funkce):
25-40. Vytvořit 15 chybějících kalkulačních tabulek

---

## 📌 ZÁVĚR

**Hlavní příčina:** Databázová struktura (db_structure.sql) nebyla aktualizována při změně C# entit na dědění z BaseEntity.

**Řešení:** Kompletní synchronizace databázového schématu s Entity Framework modely.

**Časová náročnost:** 
- Kritické opravy: ~2 hodiny
- Kompletní oprava: ~4-6 hodin
- Testování: ~2 hodiny

---

*Analýza vygenerována automaticky z projektu service-catalogue-manager-v2.9.3*
