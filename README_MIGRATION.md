# 📦 Database Migration Package - v2.9.4

Tento balíček obsahuje všechny potřebné soubory pro opravu databázové struktury Service Catalogue Manager.

## 📁 OBSAH BALÍČKU

```
database-migration-v2.9.4/
├── README.md                           # Tento soubor
├── ANALYZA_CHYB_KOMPLETNI.md          # Detailní analýza problémů
├── NAVRHOPRAV_DATABASE.md              # Komplexní návrh oprav
├── migration_add_audit_fields.sql      # Migrační skript (883 řádků)
├── create_calculator_tables.sql        # Skript pro kalkulační tabulky (344 řádků)
├── db_structure_updated.sql            # Kompletní aktualizovaný DB skript
└── validation_queries.sql              # SQL dotazy pro validaci
```

## 🎯 CO TENTO BALÍČEK ŘEŠÍ

### ❌ Problémy PŘED opravou:
- Import služeb selhává s chybou "Invalid column name 'CreatedBy'"
- 40 tabulek nemá auditní pole (CreatedDate, CreatedBy, ModifiedDate, ModifiedBy)
- ServiceInput chybí 3 specifické sloupce (InputName, Description, ExampleValue)
- 15 kalkulačních tabulek vůbec neexistuje

### ✅ Stav PO opravě:
- Import služeb funguje bez chyb
- Všechny tabulky mají kompletní auditní pole
- ServiceInput má všechny požadované sloupce
- Kalkulační funkce jsou plně funkční

## 🚀 RYCHLÝ START

### Pro EXISTUJÍCÍ databázi (s daty):

```sql
-- 1. BACKUP!
BACKUP DATABASE ServiceCatalogueManager 
TO DISK = 'C:\Backup\SCM_PreMigration.bak';

-- 2. Zastavit aplikaci

-- 3. Spustit migrace
-- Otevřít: migration_add_audit_fields.sql
-- Spustit v SQL Server Management Studio

-- 4. Vytvořit kalkulační tabulky
-- Otevřít: create_calculator_tables.sql
-- Spustit v SQL Server Management Studio

-- 5. Validovat
-- Otevřít: validation_queries.sql
-- Spustit kontrolní dotazy

-- 6. Spustit aplikaci
```

### Pro NOVOU databázi (bez dat):

```sql
-- 1. Vytvořit databázi
CREATE DATABASE ServiceCatalogueManager;
GO

-- 2. Spustit kompletní skript
-- Otevřít: db_structure_updated.sql
-- Spustit v SQL Server Management Studio
-- Čas: ~5 minut
```

## 📋 KONTROLNÍ SEZNAM

Před spuštěním migrace:
- [ ] Vytvořen backup databáze
- [ ] Aplikace je zastavena
- [ ] Máte admin přístup k SQL Serveru
- [ ] Otestováno na DEV/TEST prostředí
- [ ] Naplánováno okno údržby

Během migrace:
- [ ] Sledovat výstupy SQL skriptů
- [ ] Kontrolovat chybové hlášky
- [ ] Poznamenat si čas začátku

Po migraci:
- [ ] Spuštěny validační dotazy (všechny prošly)
- [ ] Otestován import služby
- [ ] Aplikace se spustila bez chyb
- [ ] Zkontrolovány logy aplikace

## ⏱️ ČASOVÝ ODHAD

| Aktivita | Čas |
|----------|-----|
| Backup databáze | 2-5 min |
| migration_add_audit_fields.sql | 2-3 min |
| create_calculator_tables.sql | 1 min |
| Validace | 1 min |
| **CELKEM** | **6-10 min** |

## 🔍 VALIDACE ÚSPĚŠNÉ MIGRACE

Po spuštění migrace byste měli vidět:

```sql
-- Počet tabulek s auditními poli
SELECT COUNT(DISTINCT t.name) 
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE c.name = 'CreatedDate';
-- Výsledek: 39 tabulek
```

```sql
-- ServiceInput má všechny sloupce
SELECT COUNT(*) 
FROM sys.columns 
WHERE object_id = OBJECT_ID('dbo.ServiceInput');
-- Výsledek: 15 sloupců
```

```sql
-- Kalkulační tabulky existují
SELECT COUNT(*) 
FROM sys.tables 
WHERE name LIKE 'ServiceCalculator%'
   OR name IN ('ServicePricingConfig', 'ServiceRoleRate', 
               'ServiceBaseEffort', 'ServiceContextMultiplier',
               'ServiceContextMultiplierValue', 'ServiceScopeArea',
               'ServiceComplianceFactor', 'ServiceTeamComposition',
               'ServiceSizingCriteria');
-- Výsledek: 15 tabulek
```

## ⚠️ MOŽNÉ PROBLÉMY A ŘEŠENÍ

### Problém 1: "There is already an object named..."
**Řešení:** Tabulka již existuje. Přeskočte tento CREATE TABLE a pokračujte dál.

### Problém 2: "The ALTER TABLE statement conflicted with the FOREIGN KEY constraint"
**Řešení:** Ujistěte se, že ServiceCatalogItem tabulka existuje a má data.

### Problém 3: "Column names in each table must be unique"
**Řešení:** Sloupec již existuje. To je OK - znamená to, že migrace již byla provedena.

### Problém 4: Import stále selhává
**Řešení:** 
1. Zkontrolujte, že všechny skripty proběhly úspěšně
2. Restartujte aplikaci
3. Zkontrolujte connection string
4. Spusťte validační dotazy

## 📞 TECHNICKÁ PODPORA

Pokud migrace selhala:
1. Obnovte z backupu
2. Zkontrolujte error logy
3. Ověřte SQL Server verzi (podporováno: 2016+)
4. Ujistěte se, že máte dostatečná oprávnění

## 📊 DETAILNÍ ZMĚNY

### ServiceInput - Nová struktura:
```sql
InputID INT IDENTITY(1,1) PRIMARY KEY
ServiceID INT NOT NULL
InputName NVARCHAR(200) NOT NULL          -- ✅ NOVÝ
ParameterName NVARCHAR(200) NOT NULL
ParameterDescription NVARCHAR(MAX) NOT NULL
Description NVARCHAR(MAX) NULL             -- ✅ NOVÝ
RequirementLevelID INT NOT NULL
DataType NVARCHAR(50) NULL
DefaultValue NVARCHAR(500) NULL
ExampleValue NVARCHAR(MAX) NULL            -- ✅ NOVÝ
SortOrder INT NOT NULL
CreatedDate DATETIME2 NOT NULL             -- ✅ NOVÝ
CreatedBy NVARCHAR(200) NULL               -- ✅ NOVÝ
ModifiedDate DATETIME2 NOT NULL            -- ✅ NOVÝ
ModifiedBy NVARCHAR(200) NULL              -- ✅ NOVÝ
```

### Nové kalkulační tabulky:
- ServicePricingConfig
- ServiceRoleRate
- ServiceBaseEffort
- ServiceContextMultiplier
- ServiceContextMultiplierValue
- ServiceScopeArea
- ServiceComplianceFactor
- ServiceCalculatorSection
- ServiceCalculatorGroup
- ServiceCalculatorParameter
- ServiceCalculatorParameterOption
- ServiceCalculatorScenario
- ServiceCalculatorPhase
- ServiceTeamComposition
- ServiceSizingCriteria

## 🎓 CO DÁLE?

Po úspěšné migraci:
1. Otestujte import služby z JSON
2. Vyzkoušejte kalkulační funkce
3. Zkontrolujte, že auditní pole se plní automaticky
4. Aktualizujte dokumentaci pro tým

## 📄 LICENCE

Tento migrační balíček je součástí Service Catalogue Manager projektu.

---

**Verze:** 2.9.4  
**Datum:** 2026-01-29  
**Autor:** Database Migration Tool  
**Status:** ✅ Připraveno k nasazení
