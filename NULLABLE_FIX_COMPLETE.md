# ✅ DB Structure - OPRAVENO - Všechny sloupce NULLABLE

## 🔧 Oprava provedena:

### Problém:
```
Msg 102, Level 15, State 1, Server 7fd092758721, Line 60
Incorrect syntax near '\'.
```

### Příčina:
- Escaped apostrofy `\'` místo správných `'`
- Python regex vložil escape sekvence

### Řešení:
- Nahrazeno `\'` → `'` v celém souboru
- SQL Server nyní akceptuje syntaxi

## 📋 Aktuální stav:

### Příklad opravy:
```sql
-- ❌ PŘED (nefunkční):
TypeCode NVARCHAR(50) NULL DEFAULT \'\' UNIQUE

-- ✅ PO (funkční):
TypeCode NVARCHAR(50) NULL DEFAULT '' UNIQUE
```

## 📊 Výsledné změny:

### Všechny sloupce jsou nyní:
1. **NVARCHAR** → `NULL DEFAULT ''`
2. **INT/DECIMAL** → `NULL DEFAULT 0`
3. **BIT** → `NULL DEFAULT 0`
4. **DATETIME2** → `NULL DEFAULT GETUTCDATE()`

### Výjimky (ponechány NOT NULL):
- PRIMARY KEY sloupce
- IDENTITY sloupce  
- FOREIGN KEY sloupce
- Sloupce s explicitním DEFAULT

## 🎯 Výsledek:

Import nyní přijme:
- ✅ NULL hodnoty
- ✅ Prázdné řetězce
- ✅ Jakékoliv platné hodnoty
- ✅ Chybějící pole v JSON

## 📦 Soubory ke stažení:

- **Aktualizovaný (OPRAVENÝ):** `/home/user/webapp/db_structure.sql`
- **Záloha (původní):** `/home/user/webapp/db_structure.sql.backup`
- **Velikost:** 58K (1318 řádků)

## ✅ Status:

**HOTOVO** - SQL syntaxe opravena, soubor připraven k nasazení na SQL Server.

---

**Příkaz k nasazení:**
```bash
sqlcmd -S scm-sqlserver -d ServiceCatalog -i db_structure.sql
```
