# 🔧 HOTFIX - CloudProviderCapability

## ❗ Rychlá oprava pro běžící databáze

Pokud jste již spustili původní `db_structure.sql` a viděli tuto chybu:

```
Msg 4902: Cannot find the object "dbo.CloudProviderCapabilities"
```

---

## 🎯 PROBLÉM

Původní SQL skript používal **špatný název tabulky**:
- ❌ `CloudProviderCapabilities` (množné číslo) 
- ✅ `CloudProviderCapability` (jednotné číslo)

---

## ⚡ ŘEŠENÍ

### VARIANTA A: Máte JIŽ SPUŠTĚNOU databázi
Spusťte tento hotfix:

```sql
sqlcmd -S <server> -d <database> -i HOTFIX_CloudProviderCapability.sql
```

**Výstup:**
```
Applying CloudProviderCapability hotfix...
✓ Added audit columns to CloudProviderCapability
============================================
✓✓✓ HOTFIX APPLIED SUCCESSFULLY! ✓✓✓
============================================
```

### VARIANTA B: Nová instalace
Použijte **nový ZIP** - obsahuje opravenou verzi `db_structure.sql`

```bash
# Rozbalte nový ZIP
unzip service-catalogue-manager-fixed.zip
cd service-catalogue-manager

# Spusťte opravený skript
sqlcmd -S <server> -d <database> -i db_structure.sql
```

---

## ✅ OVĚŘENÍ

Po aplikaci hotfixu spusťte:

```sql
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'CloudProviderCapability'
  AND COLUMN_NAME IN ('CreatedBy', 'CreatedDate', 'ModifiedBy', 'ModifiedDate');
```

**Očekávaný výstup:**
```
CreatedBy
CreatedDate
ModifiedBy
ModifiedDate
```

---

## 📊 CO BYLO OPRAVENO

| Soubor | Změna |
|--------|-------|
| `db_structure.sql` | CloudProviderCapabilities → CloudProviderCapability |
| `VERIFY_DATABASE_FIXES.sql` | CloudProviderCapabilities → CloudProviderCapability |
| Všechny README | Aktualizována dokumentace |
| **NOVÝ:** `HOTFIX_CloudProviderCapability.sql` | Samostatný patch soubor |

---

## 🚀 CO DĚLAT

### Pokud jste NEVIDĚLI chybu:
✅ **NIC** - vše funguje správně

### Pokud jste VIDĚLI chybu:
1. Spusťte `HOTFIX_CloudProviderCapability.sql`
2. Nebo použijte nový ZIP s opraveným `db_structure.sql`

---

## 📞 VÝSLEDEK

Po aplikaci hotfixu:
```
✅ Všech 30 tabulek má audit sloupce
✅ CloudProviderCapability opravena
✅ Import služeb bude fungovat
```

---

**Status**: ✅ OPRAVENO v ZIP verzi  
**Datum**: 2026-01-29  
