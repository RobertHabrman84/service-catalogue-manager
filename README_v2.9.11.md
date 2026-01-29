# Service Catalogue Manager - v2.9.11 Release

## 🎯 Verze 2.9.11 - Database Schema Enhancement Release

**Datum vydání:** 2026-01-29  
**Typ:** Kritická oprava + Schema rozšíření

---

## 🔴 HLAVNÍ ZMĚNA - ServiceDependency Schema Enhancement

### Problém (v2.9.10)
Import selháva s chybami neplatných sloupců:
```
Invalid column name 'DependencyDescription'
Invalid column name 'DependencyName'
Invalid column name 'DependentServiceCode'
```

### Řešení (v2.9.11)
**Rozšířeno SQL schema** namísto použití Ignore direktiv.

#### Nové sloupce v `ServiceDependency`:
| Sloupec | Typ | Popis |
|---------|-----|-------|
| `DependencyName` | NVARCHAR(200) NULL | Friendly název závislosti |
| `DependencyDescription` | NVARCHAR(MAX) NULL | Detailní popis |
| `DependentServiceCode` | NVARCHAR(50) NULL | Kód služby pro lookup |

---

## 📦 Obsah balíčku

```
service-catalogue-manager-v2_9_11/
├── src/
│   └── backend/
│       └── ServiceCatalogueManager.Api/
│           ├── Data/
│           │   ├── DbContext/
│           │   │   └── ServiceCatalogDbContext.cs ✅ UPRAVENO
│           │   └── Entities/
│           │       ├── ServiceDependency.cs ✓ Beze změny
│           │       ├── ServiceEntities.Part1.cs ✓ CloudProviderId (v2.9.10)
│           │       └── ServicePrerequisite.cs ✓ (v2.9.10)
│           └── Services/
│               └── Import/
│                   ├── ToolsHelper.cs ✓ (v2.9.10)
│                   └── CategoryHelper.cs ✓ (v2.9.10)
├── db_structure.sql ✅ UPRAVENO (ServiceDependency rozšířeno)
├── MIGRATION_ServiceDependency_v2.9.11.sql ✅ NOVÝ
├── HOTFIX_ServicePrerequisite_v2.9.10.sql ✓ (z v2.9.10)
├── CHANGELOG_v2.9.11.md ✅ NOVÝ
└── README_v2.9.11.md ✅ TENTO SOUBOR
```

---

## 🚀 Instalace a nasazení

### Krok 1: Záloha databáze (DOPORUČENO)
```sql
BACKUP DATABASE [ServiceCatalogueDB] 
TO DISK = 'C:\Backup\ServiceCatalogueDB_before_v2.9.11.bak'
WITH INIT, COMPRESSION;
```

### Krok 2A: NOVÁ databáze
```sql
-- Použijte aktualizovaný db_structure.sql
-- Všechny změny jsou již zahrnuty
sqlcmd -S localhost -d master -i db_structure.sql
```

### Krok 2B: EXISTUJÍCÍ databáze
```sql
-- 1. ServicePrerequisite migrace (pokud ještě nebyla provedena)
sqlcmd -S localhost -d ServiceCatalogueDB -i HOTFIX_ServicePrerequisite_v2.9.10.sql

-- 2. ServiceDependency migrace (NOVÉ v2.9.11)
sqlcmd -S localhost -d ServiceCatalogueDB -i MIGRATION_ServiceDependency_v2.9.11.sql
```

### Krok 3: Nasazení kódu
1. Zastavit aplikační službu
2. Nahradit soubory z `service-catalogue-manager-v2_9_11.zip`
3. Rebuild:
   ```bash
   dotnet build --configuration Release
   ```
4. Spustit službu

### Krok 4: Ověření
```sql
-- Ověřit strukturu ServiceDependency
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ServiceDependency'
ORDER BY ORDINAL_POSITION;

-- Očekávaný výstup by měl obsahovat:
-- DependencyName, DependencyDescription, DependentServiceCode
```

---

## 📊 Shrnutí všech oprav v2.9.11

### Nové v2.9.11 (3 změny)
| # | Změna | Soubor | Popis |
|---|-------|--------|-------|
| 1 | SQL schema | db_structure.sql | +3 sloupce do ServiceDependency |
| 2 | DbContext | ServiceCatalogDbContext.cs | Odstraněny Ignore direktivy |
| 3 | Migrace | MIGRATION_...sql | Skript pro existující DB |

### Převzato z v2.9.10 (21 oprav)
| Kategorie | Počet | Status |
|-----------|-------|--------|
| Schema mapping (.ToTable) | 10 | ✅ |
| Column mapping (PK) | 2 | ✅ |
| ServiceLicense fix | 4 | ✅ |
| Duplicate key protection | 2 | ✅ |
| ServicePrerequisite | 6 | ✅ |

**CELKEM OPRAV: 24**

---

## ✅ Testovací checklist

Po nasazení ověřte:

- [ ] Import služby úspěšně projde
- [ ] ServiceDependency má všechny sloupce:
  - [ ] DependencyName
  - [ ] DependencyDescription
  - [ ] DependentServiceCode
  - [ ] DependentServiceID (původní)
  - [ ] DependentServiceName (původní)
- [ ] Žádné `Invalid column name` chyby
- [ ] Duplicate key errors jsou ošetřeny (ToolsHelper, CategoryHelper)
- [ ] ServiceLicense podporuje CloudProviderId
- [ ] ServiceToolFramework správně mapuje ToolId
- [ ] TechnicalComplexityAddition správně mapuje AdditionId

---

## 🔧 Technické detaily

### DbContext změny
**PŘED (v2.9.10):**
```csharp
entity.Ignore(e => e.DependencyName);
entity.Ignore(e => e.DependencyDescription);
entity.Ignore(e => e.DependentServiceCode);
entity.Ignore(e => e.DependentOnServiceCode);
```

**PO (v2.9.11):**
```csharp
// Odstraněno - sloupce nyní existují v SQL
// Pouze column mapping pro RelatedServiceId:
entity.Property(e => e.RelatedServiceId).HasColumnName("DependentServiceID");
```

### SQL změny
```sql
-- Nové sloupce v ServiceDependency
DependencyName NVARCHAR(200) NULL
DependencyDescription NVARCHAR(MAX) NULL
DependentServiceCode NVARCHAR(50) NULL
```

---

## ⚠️ Breaking Changes
**ŽÁDNÉ**

Všechny změny jsou **zpětně kompatibilní**:
- Nové sloupce jsou NULL (nepovinné)
- Existující data nejsou dotčena
- API zůstává beze změny

---

## 📝 Známé problémy

### Calculator Entity (neblokující)
16 Calculator entit existuje v C# ale **chybí v db_structure.sql**:
- ServicePricingConfig, ServiceRoleRate, ServiceBaseEffort, atd.
- LU_EffortCategory

**Status:** Import funguje normálně i bez těchto tabulek.  
**Plán:** Bude součástí budoucí verze pokud jsou potřeba.

---

## 🆘 Podpora

### Rollback postup (v případě problémů)
```sql
-- 1. Obnovit databázi ze zálohy
RESTORE DATABASE [ServiceCatalogueDB] 
FROM DISK = 'C:\Backup\ServiceCatalogueDB_before_v2.9.11.bak'
WITH REPLACE;

-- 2. Nasadit předchozí verzi kódu
```

### Kontakt
V případě problémů kontaktujte vývojový tým.

---

## 📋 Verze historie

- **v2.9.11** (2026-01-29) - ServiceDependency schema enhancement
- **v2.9.10** (2026-01-29) - Initial fixes (schema mapping, duplicate key, prerequisites)
- **v2.9.9** - Předchozí verze

---

**🎉 Úspěšné nasazení!**
