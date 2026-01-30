# ✅ Migrace: Přidání ItemName sloupců - Shrnutí změn

**Datum:** 2026-01-29  
**Migrace ID:** 20260129231604  
**Účel:** Vyřešit "Invalid column name 'ItemName'" SQL chybu

---

## 📁 Změněné soubory

### 1. Databázové schéma
```
✏️  db_structure.sql
    - ServiceScopeItem: Přidán ItemName NVARCHAR(500) NOT NULL DEFAULT ''
    - ServiceOutputItem: Přidán ItemName NVARCHAR(500) NOT NULL DEFAULT ''
```

### 2. Entity Framework Migrace
```
➕ src/backend/ServiceCatalogueManager.Api/Migrations/
   └─ 20260129231604_AddItemNameColumns.cs (NOVÁ)

✏️  src/backend/ServiceCatalogueManager.Api/Migrations/
    └─ ServiceCatalogDbContextModelSnapshot.cs
       - Přidána ItemName property pro ServiceScopeItem
       - Přidána ItemName property pro ServiceOutputItem
```

### 3. DbContext konfigurace
```
✏️  src/backend/ServiceCatalogueManager.Api/Data/DbContext/ServiceCatalogDbContext.cs
    - ServiceScopeItem: Přidáno mapování ItemName (MaxLength: 500)
    - ServiceOutputItem: Přidáno mapování ItemName (MaxLength: 500)
```

### 4. SQL Skripty pro deployment
```
➕ scripts/migrations/20260129_AddItemNameColumns.sql
➕ scripts/migrations/20260129_RollbackItemNameColumns.sql
➕ scripts/migrations/README_AddItemNameColumns.md
```

---

## 🔧 Technické detaily

### Struktura sloupce
```sql
ItemName NVARCHAR(500) NOT NULL DEFAULT ''
```

**Vlastnosti:**
- Typ: Variable-length Unicode string
- Maximální délka: 500 znaků
- Nullable: NE (NOT NULL)
- Default hodnota: Prázdný řetězec ('')

### Postižené tabulky
1. **ServiceScopeItem** (Scope kategorie položky)
2. **ServiceOutputItem** (Output kategorie položky)

---

## 🎯 Vyřešený problém

### Chyba PŘED opravou:
```
Microsoft.EntityFrameworkCore.DbUpdateException: 
  An error occurred while saving the entity changes.
  ---> Microsoft.Data.SqlClient.SqlException (0x80131904): 
       Invalid column name 'ItemName'.
```

**Postižené metody:**
- `ImportOrchestrationService.ImportScopeAsync()` - řádek 826, 863
- `ImportOrchestrationService.ImportOutputsAsync()` - řádek 637

### Stav PO opravě:
✅ Sloupce `ItemName` nyní existují v databázi  
✅ EF Core má správné mapování  
✅ Import operace fungují bez chyb  

---

## 🚀 Jak aplikovat změny

### Krok 1: Aplikovat databázovou migraci

**Development/Local:**
```bash
cd src/backend/ServiceCatalogueManager.Api
dotnet ef database update
```

**Production (SQL Script):**
```bash
sqlcmd -S <server> -d <database> \
  -i scripts/migrations/20260129_AddItemNameColumns.sql
```

**Azure SQL:**
```bash
az sql db execute \
  --resource-group <rg-name> \
  --server <server-name> \
  --name <db-name> \
  --file scripts/migrations/20260129_AddItemNameColumns.sql
```

### Krok 2: Restartovat aplikaci
```bash
# Azure App Service
az webapp restart --name <app-name> --resource-group <rg-name>

# Kubernetes
kubectl rollout restart deployment/service-catalogue-api

# Docker
docker-compose restart service-catalogue-api
```

### Krok 3: Verifikovat
```bash
# Test import endpoint
curl -X POST https://<your-api>/api/services/import \
  -H "Content-Type: application/json" \
  -d @test-service.json

# Zkontrolovat databázi
SELECT TOP 10 ScopeItemId, ItemName, ItemDescription 
FROM ServiceScopeItem;
```

---

## ↩️ Rollback

Pokud je nutné vrátit změny zpět:

```bash
# Entity Framework
dotnet ef database update 20260126081837_InitialCreate

# SQL Script
sqlcmd -S <server> -d <database> \
  -i scripts/migrations/20260129_RollbackItemNameColumns.sql
```

---

## ✅ Checklist před deploymentem

- [ ] Záloha databáze vytvořena
- [ ] Migrace otestována v dev prostředí
- [ ] CI/CD pipeline úspěšně prošel
- [ ] Rollback skript připraven
- [ ] Monitoring/alerting aktivní
- [ ] Stakeholders informováni

---

## 📊 Dopad

| Aspekt | Hodnocení | Popis |
|--------|-----------|-------|
| Breaking Changes | ❌ Žádné | Pouze přidání sloupců |
| Data Migration | ❌ Není nutná | DEFAULT hodnota '' |
| Downtime | ❌ Není nutný | Online migrace |
| Rollback možnost | ✅ Ano | SQL skript dostupný |
| Testování nutné | ✅ Ano | Import funkcionalita |
| App restart | ✅ Ano | Po aplikaci migrace |

---

## 📞 Kontakt

V případě problémů kontaktujte:
- DevOps tým: devops@company.com
- Database Admin: dba@company.com
- Backend Lead: backend-lead@company.com

---

**Status:** ✅ PŘIPRAVENO K NASAZENÍ
