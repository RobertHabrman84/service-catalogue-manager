# CHANGELOG - ServiceOutputItem Fix

## Datum: 2026-01-29 17:20

### 🔴 Chyba identifikována
```
Invalid column name 'ItemName'
Table: ServiceOutputItem
```

### ✅ Oprava provedena

#### Přidán sloupec do ServiceOutputItem:
```sql
ALTER TABLE dbo.ServiceOutputItem 
ADD ItemName NVARCHAR(200) NOT NULL DEFAULT '';
```

### 📊 Stav oprav

| Tabulka | Sloupec | Status |
|---------|---------|--------|
| ServiceInput | InputName | ✅ Opraveno |
| ServiceInput | Description | ✅ Opraveno |
| ServiceInput | ExampleValue | ✅ Opraveno |
| ServiceInput | Audit columns | ✅ Opraveno |
| ServiceOutputItem | **ItemName** | ✅ **NOVĚ OPRAVENO** |
| ServiceOutputItem | Audit columns | ✅ Opraveno |
| UsageScenario | Audit columns | ✅ Opraveno |
| 27 dalších tabulek | Audit columns | ✅ Opraveno |

### 🚀 Další kroky

1. **Stáhněte nový ZIP**
2. **Spusťte db_structure.sql** (celý soubor nebo jen ALTER TABLE sekci)
3. **Otestujte import** znovu

### 📝 Poznámka

Pokud se objeví další chyba "Invalid column name", okamžitě ji opravíme stejným způsobem.

---

**Verze**: 1.2 (ItemName hotfix)  
**Build status**: ✅ Kompiluje  
**DB update**: ✅ SQL skript připraven  
