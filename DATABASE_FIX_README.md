# Database Schema Fix - 2026-01-29

## Problém

Databázové schéma neodpovídalo C# entity modelům, což způsobovalo chybu při importu služeb:

```
Invalid column name 'CreatedBy'.
Invalid column name 'CreatedDate'.
Invalid column name 'Description'.
Invalid column name 'ExampleValue'.
Invalid column name 'InputName'.
Invalid column name 'ModifiedBy'.
Invalid column name 'ModifiedDate'.
```

## Příčina

Entity v C# kódu dědí z `BaseEntity`, která obsahuje audit sloupce:
- `CreatedBy`
- `CreatedDate` 
- `ModifiedBy`
- `ModifiedDate`

Databázové tabulky tyto sloupce neměly, protože původní migrace byla vytvořena před zavedením `BaseEntity`.

## Řešení

Rozšířen soubor **db_structure.sql** o ALTER TABLE příkazy, které přidávají chybějící sloupce.

### Přidané sloupce do ServiceInput:
- `InputName NVARCHAR(200)` - název vstupního pole
- `Description NVARCHAR(MAX)` - popis vstupu
- `ExampleValue NVARCHAR(MAX)` - příklad hodnoty
- `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate` - audit sloupce

### Přidané audit sloupce do 29 tabulek:

1. UsageScenario
2. ServiceDependency
3. ServiceScopeCategory
4. ServiceScopeItem
5. ServicePrerequisite
6. CloudProviderCapability
7. ServiceToolFramework
8. ServiceLicense
9. ServiceInteraction
10. CustomerRequirement
11. AccessRequirement
12. StakeholderInvolvement
13. ServiceOutputCategory
14. ServiceOutputItem
15. TimelinePhase
16. PhaseDurationBySize
17. ServiceSizeOption
18. SizingCriteria
19. SizingCriteriaValue
20. SizingParameter
21. SizingParameterValue
22. EffortEstimationItem
23. TechnicalComplexityAddition
24. ScopeDependency
25. SizingExample
26. SizingExampleCharacteristic
27. ServiceResponsibleRole
28. ServiceTeamAllocation
29. ServiceMultiCloudConsideration

## Jak aplikovat opravu

### Varianta A: Nová databáze
Spusťte kompletní `db_structure.sql` - obsahuje jak CREATE TABLE, tak ALTER TABLE příkazy.

```sql
sqlcmd -S <server> -d <database> -i db_structure.sql
```

### Varianta B: Existující databáze
Spusťte pouze ALTER TABLE část (od řádku 766):

```sql
-- Extrahujte ALTER TABLE sekci z db_structure.sql
-- nebo použijte samostatný skript níže
```

### Samostatný SQL skript pro opravu:

```sql
-- Spusťte tento skript na existující databázi
USE YourDatabaseName;
GO

-- Spusťte obsah od řádku 766 z db_structure.sql
-- (všechny IF NOT EXISTS a ALTER TABLE příkazy)
```

## Ověření opravy

Po aplikaci skriptu ověřte, že sloupce byly přidány:

```sql
-- Kontrola ServiceInput
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ServiceInput'
ORDER BY ORDINAL_POSITION;

-- Mělo by zobrazit:
-- InputId, ServiceId, ParameterName, ParameterDescription, 
-- RequirementLevelId, DataType, DefaultValue, SortOrder,
-- InputName, Description, ExampleValue,
-- CreatedBy, CreatedDate, ModifiedBy, ModifiedDate

-- Kontrola UsageScenario  
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'UsageScenario'
ORDER BY ORDINAL_POSITION;

-- Mělo by zobrazit:
-- ScenarioId, ServiceId, ScenarioNumber, ScenarioTitle,
-- ScenarioDescription, SortOrder,
-- CreatedBy, CreatedDate, ModifiedBy, ModifiedDate
```

## Testování

Po aplikaci opravy otestujte import služby:

```bash
# API endpoint
POST /api/services/import/validate
POST /api/services/import

# Měl by projít bez chyby "Invalid column name"
```

## Souborová struktura

```
/
├── db_structure.sql           ← ROZŠÍŘENÝ soubor (obsahuje ALTER TABLE)
├── DATABASE_FIX_README.md     ← Tento dokument
├── src/
│   └── backend/
│       └── ServiceCatalogueManager.Api/
│           ├── Data/
│           │   └── Entities/
│           │       ├── BaseEntity.cs      ← Definice audit polí
│           │       ├── ServiceInput.cs    ← Používá BaseEntity
│           │       └── UsageScenario.cs   ← Používá BaseEntity
│           └── Migrations/
│               └── 20260126081837_InitialCreate.cs
```

## Poznámky

- **POZOR**: ALTER TABLE příkazy používají `IF NOT EXISTS`, takže je bezpečné je spustit vícekrát
- Všechny nové sloupce mají DEFAULT hodnoty, takže nevyžadují data migration pro existující řádky
- `CreatedDate` a `ModifiedDate` se automaticky nastaví na `GETUTCDATE()` pro existující data
- `InputName` má DEFAULT hodnotu prázdný řetězec `''`

## Kontakt

Pro otázky kontaktujte vývojový tým.
