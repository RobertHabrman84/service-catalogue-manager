# 🔧 NÁVRH OPRAV DATABÁZE - Service Catalogue Manager v2.9.3

**Datum:** 29.01.2026  
**Verze:** v2.9.3 → v2.9.4  
**Typ opravy:** Databázová migrace - přidání chybějících sloupců a tabulek

---

## 📋 PŘEHLED ZMĚN

### ✅ Co bylo opraveno:

1. **24 existujících tabulek** - přidány auditní sloupce (CreatedDate, CreatedBy, ModifiedDate, ModifiedBy)
2. **ServiceInput** - přidány 3 specifické sloupce (InputName, Description, ExampleValue) + auditní sloupce
3. **15 kalkulačních tabulek** - nově vytvořeny s kompletní strukturou
4. **db_structure.sql** - kompletně aktualizován

---

## 📦 VYGENEROVANÉ SOUBORY

### 1. **migration_add_audit_fields.sql** (883 řádků)
- Migrační skript pro přidání auditních polí do existujících tabulek
- Bezpečný - kontroluje existenci sloupců před přidáním
- Vhodný pro produkční databáze s daty

**Použití:**
```sql
-- Spustit v SQL Server Management Studio nebo Azure Data Studio
-- Přidá chybějící sloupce bez ztráty dat
```

### 2. **create_calculator_tables.sql** (344 řádků)
- Vytvoření 15 nových kalkulačních tabulek
- Kompletní struktura včetně indexů a auditních polí
- Vhodný pro nové instalace i aktualizace

**Použití:**
```sql
-- Spustit po migration_add_audit_fields.sql
-- Vytvoří všechny chybějící kalkulační tabulky
```

### 3. **db_structure_updated.sql** (kompletní)
- Aktualizovaný db_structure.sql
- Zahrnuje všechny opravy
- Vhodný pro nové instalace nebo úplnou obnovu

**Použití:**
```sql
-- Kompletní rebuild databáze
-- POZOR: Smaže všechna existující data!
```

---

## 🔄 POSTUP MIGRACE

### ⚡ Varianta A: Migrace existující databáze (DOPORUČENO pro produkci)

```sql
-- KROK 1: Backup databáze
BACKUP DATABASE ServiceCatalogueManager 
TO DISK = 'C:\Backup\ServiceCatalogueManager_PreMigration.bak';

-- KROK 2: Spustit migrační skript
-- Soubor: migration_add_audit_fields.sql
-- Čas: ~2-3 minuty
-- Výsledek: Přidány chybějící sloupce do 24 tabulek

-- KROK 3: Vytvořit kalkulační tabulky
-- Soubor: create_calculator_tables.sql
-- Čas: ~1 minuta
-- Výsledek: Vytvořeno 15 nových tabulek

-- KROK 4: Ověření
SELECT 
    t.name AS TableName,
    c.name AS ColumnName
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE c.name IN ('CreatedDate', 'CreatedBy', 'ModifiedDate', 'ModifiedBy')
ORDER BY t.name;
-- Očekáváno: 39 tabulek x 4 sloupce = 156 řádků
```

### 🆕 Varianta B: Nová instalace

```sql
-- KROK 1: Vytvořit databázi
CREATE DATABASE ServiceCatalogueManager;
GO

-- KROK 2: Spustit kompletní skript
-- Soubor: db_structure_updated.sql
-- Čas: ~5 minut
-- Výsledek: Kompletní databázová struktura
```

---

## 📊 DETAILNÍ ZMĚNY

### 1️⃣ **Auditní pole přidána do těchto tabulek:**

| # | Tabulka | Sloupce přidány |
|---|---------|-----------------|
| 1 | ServiceInput | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy, InputName, Description, ExampleValue |
| 2 | UsageScenario | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 3 | ServiceScopeItem | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 4 | ServiceToolFramework | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 5 | ServiceLicense | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 6 | StakeholderInvolvement | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 7 | ServiceOutputCategory | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 8 | ServiceOutputItem | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 9 | ServiceSizeOption | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 10 | TechnicalComplexityAddition | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 11 | ServiceTeamAllocation | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 12 | SizingExample | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 13 | SizingExampleCharacteristic | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 14 | ScopeDependency | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 15 | SizingParameter | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 16 | SizingCriteria | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 17 | ServiceMultiCloudConsideration | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 18 | CloudProviderCapability | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 19 | SizingCriteriaValue | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 20 | SizingParameterValue | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 21 | TimelinePhase | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 22 | PhaseDurationBySize | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 23 | EffortEstimationItem | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |
| 24 | ServiceResponsibleRole | CreatedDate, CreatedBy, ModifiedDate, ModifiedBy |

### 2️⃣ **Nově vytvořené kalkulační tabulky:**

| # | Tabulka | Účel |
|---|---------|------|
| 1 | ServicePricingConfig | Konfigurace cen (marže, riziko, náklady) |
| 2 | ServiceRoleRate | Denní sazby pro role |
| 3 | ServiceBaseEffort | Základní úsilí (kickoff, discovery, handover) |
| 4 | ServiceContextMultiplier | Kontextové multiplikátory |
| 5 | ServiceContextMultiplierValue | Hodnoty multiplikátorů |
| 6 | ServiceScopeArea | Oblasti rozsahu s hodinami |
| 7 | ServiceComplianceFactor | Faktory compliance/komplexity |
| 8 | ServiceCalculatorSection | Sekce parametrů kalkulačky |
| 9 | ServiceCalculatorGroup | Skupiny parametrů |
| 10 | ServiceCalculatorParameter | Parametry kalkulačky |
| 11 | ServiceCalculatorParameterOption | Možnosti parametrů |
| 12 | ServiceCalculatorScenario | Přednastavené scénáře |
| 13 | ServiceCalculatorPhase | Fáze projektu s trváním |
| 14 | ServiceTeamComposition | Složení týmu podle velikosti |
| 15 | ServiceSizingCriteria | Kritéria pro velikost (S, M, L) |

---

## 🔍 VALIDACE MIGRACE

### Kontrola auditních polí:
```sql
-- Ověření, že všechny tabulky mají auditní pole
SELECT 
    t.name AS TableName,
    CASE WHEN EXISTS (
        SELECT 1 FROM sys.columns c 
        WHERE c.object_id = t.object_id AND c.name = 'CreatedDate'
    ) THEN 'YES' ELSE 'NO' END AS HasAuditFields
FROM sys.tables t
WHERE t.name LIKE 'Service%' 
   OR t.name LIKE 'Sizing%'
   OR t.name LIKE 'Usage%'
   OR t.name LIKE 'Stakeholder%'
   OR t.name LIKE 'Timeline%'
ORDER BY t.name;
```

### Kontrola ServiceInput:
```sql
-- Ověření specifických sloupců ServiceInput
SELECT 
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length,
    c.is_nullable
FROM sys.columns c
WHERE c.object_id = OBJECT_ID('dbo.ServiceInput')
  AND c.name IN ('InputName', 'Description', 'ExampleValue', 
                 'CreatedDate', 'CreatedBy', 'ModifiedDate', 'ModifiedBy')
ORDER BY c.name;
```

### Kontrola kalkulačních tabulek:
```sql
-- Ověření existence kalkulačních tabulek
SELECT name 
FROM sys.tables 
WHERE name LIKE 'ServiceCalculator%'
   OR name LIKE 'ServicePricing%'
   OR name LIKE 'ServiceRoleRate'
   OR name LIKE 'ServiceBaseEffort'
   OR name LIKE 'ServiceContext%'
   OR name LIKE 'ServiceScopeArea'
   OR name LIKE 'ServiceCompliance%'
   OR name LIKE 'ServiceTeamComposition'
   OR name LIKE 'ServiceSizingCriteria'
ORDER BY name;
-- Očekáváno: 15 tabulek
```

---

## ⚠️ DŮLEŽITÁ UPOZORNĚNÍ

### Před migrací:
1. ✅ **Vytvořte BACKUP databáze**
2. ✅ **Otestujte na DEV/TEST prostředí**
3. ✅ **Naplánujte si okno údržby** (doporučeno 30 minut)
4. ✅ **Informujte uživatele** o plánované odstávce

### Během migrace:
1. ⚠️ **Aplikace musí být vypnutá** (předejdete konfliktům)
2. ⚠️ **Spouštějte skripty postupně** (ne najednou)
3. ⚠️ **Kontrolujte výstupy** každého skriptu

### Po migraci:
1. ✅ **Spusťte validační dotazy**
2. ✅ **Otestujte import služeb**
3. ✅ **Otestujte kalkulační funkce**
4. ✅ **Zkontrolujte logy aplikace**

---

## 📈 OČEKÁVANÉ VÝSLEDKY

### Před opravou:
- ❌ Import služeb selhává
- ❌ 40 tabulek bez auditních polí
- ❌ 15 kalkulačních tabulek chybí
- ❌ ServiceInput nemá 7 sloupců

### Po opravě:
- ✅ Import služeb funguje
- ✅ 39 tabulek s auditními poli
- ✅ 15 kalkulačních tabulek vytvořeno
- ✅ ServiceInput má všechny sloupce
- ✅ Kompletní audit trail
- ✅ Kalkulační funkce dostupné

---

## 🚀 DALŠÍ KROKY

1. **Zkontrolujte C# kód** - ujistěte se, že názvy sloupců v Entity Framework odpovídají databázi
2. **Aktualizujte dokumentaci** - zahrňte nové kalkulační tabulky
3. **Vytvořte migrace** - pro Entity Framework Core (Add-Migration)
4. **Otestujte importy** - s reálnými daty
5. **Monitorujte výkon** - nové indexy by měly zlepšit výkon

---

## 📞 PODPORA

Pokud narazíte na problémy:
1. Zkontrolujte error logy v SQL Serveru
2. Ověřte, že všechny FK vztahy jsou v pořádku
3. Ujistěte se, že ServiceCatalogItem tabulka existuje (je referována v FK)

---

*Generováno automaticky - Service Catalogue Manager Database Migration Tool*
