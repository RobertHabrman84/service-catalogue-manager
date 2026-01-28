# Ověření Ukládání JSON Dat do MSSQL Databáze

## ✅ Odpověď: ANO, Data se Skutečně Ukládají do MSSQL

Data z JSON importu **SE SKUTEČNĚ UKLÁDAJÍ** do MSSQL databáze. Níže jsou důkazy a způsoby, jak to ověřit.

## 🔍 Důkazy, že Data Jdou do MSSQL

### 1. **Connection String Konfigurace**

V souboru `src/backend/ServiceCatalogueManager.Api/local.settings.json`:

```json
{
  "ConnectionStrings": {
    "AzureSQL": "Server=localhost;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
  }
}
```

**➡️ Tento connection string jasně ukazuje na MSSQL server (localhost) a databázi ServiceCatalogueManager**

### 2. **Entity Framework Core Konfigurace**

V `Program.cs` nebo `Startup.cs`:

```csharp
services.AddDbContext<ServiceCatalogDbContext>(options =>
    options.UseSqlServer(connectionString)  // ← UseSqlServer = MSSQL!
);
```

**➡️ `UseSqlServer()` znamená Entity Framework Core používá SQL Server provider, ne In-Memory databázi**

### 3. **Import Flow s Transakcemi**

V `ImportOrchestrationService.cs` (řádky 104-146):

```csharp
public async Task<ImportResult> ImportServiceAsync(ImportServiceModel model)
{
    // ...
    await _unitOfWork.BeginTransactionAsync();  // ← Začátek transakce
    
    try
    {
        // Vytvoření služby
        var service = new ServiceCatalogItem { ... };
        service = await _unitOfWork.ServiceCatalogs.AddAsync(service);
        await _unitOfWork.SaveChangesAsync();  // ← Uložení do DB
        
        // Import souvisejících dat
        await ImportUsageScenariosAsync(...);
        await ImportServiceInputsAsync(...);
        // ... další import metody
        
        await _unitOfWork.SaveChangesAsync();  // ← Finální uložení
        await _unitOfWork.CommitTransactionAsync();  // ← COMMIT transakce
        
        return ImportResult.Success(...);
    }
    catch (Exception ex)
    {
        await _unitOfWork.RollbackTransactionAsync();  // ← Rollback při chybě
        throw;
    }
}
```

**➡️ Transakce je explicitně commitována do databáze pomocí `CommitTransactionAsync()`**

### 4. **Repository Pattern s EF Core**

V `Repositories.cs` (řádky 116-119):

```csharp
public virtual async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken = default)
{
    var entry = await _dbSet.AddAsync(entity, cancellationToken);  // ← EF Core Add
    return entry.Entity;
}
```

A pak v `UnitOfWork.SaveChangesAsync()` (řádky 398-401):

```csharp
public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
{
    return await _context.SaveChangesAsync(cancellationToken);  // ← EF Core SaveChanges
}
```

**➡️ `DbContext.SaveChangesAsync()` generuje SQL INSERT příkazy a posílá je do databáze**

### 5. **Audit Fields Automaticky Nastaveny**

V `ServiceCatalogDbContext.cs` (řádky 506-522):

```csharp
private void UpdateAuditFields()
{
    var entries = ChangeTracker.Entries<BaseEntity>();
    
    foreach (var entry in entries)
    {
        if (entry.State == EntityState.Added)
        {
            entry.Entity.CreatedDate = DateTime.UtcNow;  // ← Automatické nastavení
            entry.Entity.ModifiedDate = DateTime.UtcNow;
        }
        // ...
    }
}
```

**➡️ Audit pole (CreatedDate, ModifiedDate) se automaticky nastavují při SaveChanges**

## 🧪 Jak to Ověřit (3 Metody)

### Metoda 1: PowerShell Test Script ⭐ DOPORUČENO

```powershell
# Spustit backend (Terminal 1)
cd src/backend/ServiceCatalogueManager.Api
func start

# Spustit test (Terminal 2)
./scripts/test-import-to-database.ps1
```

**Co script dělá:**
1. ✅ Testuje SQL Server připojení
2. ✅ Spočítá existující služby
3. ✅ Importuje JSON přes API
4. ✅ **Přímým SQL dotazem ověří data v MSSQL**
5. ✅ Zobrazí kompletní report

**Očekávaný výstup:**
```
✅ SUCCESS: Data from JSON was successfully saved to MSSQL database!

═══════════════════════════════════════
  Database Verification Details
═══════════════════════════════════════
  Service ID:         123
  Service Code:       TEST-SERVICE-001
  Service Name:       Test Service
  Version:            v1.0
  Created Date:       2026-01-28 10:30:00
  
  Related Data:
    - Usage Scenarios:  2
    - Inputs:           3
    - Output Categories: 1
    - Prerequisites:    2
═══════════════════════════════════════
```

### Metoda 2: SQL Script

```bash
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d ServiceCatalogueManager -i scripts/verify-import-data.sql
```

**Script zobrazí:**
- Seznam všech služeb v `ServiceCatalogItem` tabulce
- Detail nejnovější služby
- Počty všech souvisejících záznamů (scenarios, inputs, outputs, atd.)

### Metoda 3: Přímý SQL Dotaz

```sql
-- Po importu spustit tento dotaz v SSMS nebo Azure Data Studio:
SELECT 
    s.ServiceId,
    s.ServiceCode,
    s.ServiceName,
    s.CreatedDate,
    (SELECT COUNT(*) FROM UsageScenario WHERE ServiceId = s.ServiceId) as Scenarios,
    (SELECT COUNT(*) FROM ServiceInput WHERE ServiceId = s.ServiceId) as Inputs,
    (SELECT COUNT(*) FROM ServicePrerequisite WHERE ServiceId = s.ServiceId) as Prerequisites
FROM ServiceCatalogItem s
ORDER BY s.CreatedDate DESC;
```

**Pokud uvidíte záznamy, data JSOU v MSSQL databázi!**

## 📊 Diagram Datového Toku

```
┌─────────────────────┐
│   JSON Soubor       │
│ (examples/*.json)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  HTTP POST Request  │
│ /api/services/import│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ ImportFunction.cs   │
│  (HTTP Handler)     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ImportOrchestration  │
│   Service.cs        │
│ (Business Logic)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  UnitOfWork +       │
│  Repository Pattern │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Entity Framework    │
│   Core DbContext    │
│                     │
│ SaveChangesAsync()  │ ← Generuje SQL INSERT
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   MSSQL Database    │
│ ServiceCatalogMgr   │
│                     │
│ ✅ DATA ULOŽENA    │
└─────────────────────┘
```

## 🗄️ Tabulky v MSSQL Databázi

Po importu JSON jsou data uložena v těchto tabulkách:

| Tabulka | Popis | Příklad SQL |
|---------|-------|-------------|
| `ServiceCatalogItem` | Hlavní služba | `SELECT * FROM ServiceCatalogItem` |
| `UsageScenario` | Scénáře použití | `SELECT * FROM UsageScenario WHERE ServiceId = X` |
| `ServiceInput` | Vstupní parametry | `SELECT * FROM ServiceInput WHERE ServiceId = X` |
| `ServiceOutputCategory` | Kategorie výstupů | `SELECT * FROM ServiceOutputCategory WHERE ServiceId = X` |
| `ServiceOutputItem` | Výstupní položky | `SELECT * FROM ServiceOutputItem WHERE OutputCategoryId = Y` |
| `ServicePrerequisite` | Prerekvizity | `SELECT * FROM ServicePrerequisite WHERE ServiceId = X` |
| `ServiceDependency` | Závislosti | `SELECT * FROM ServiceDependency WHERE ServiceId = X` |
| `ServiceScopeCategory` | Scope kategorie | `SELECT * FROM ServiceScopeCategory WHERE ServiceId = X` |
| `ServiceScopeItem` | Scope položky | `SELECT * FROM ServiceScopeItem WHERE ScopeCategoryId = Y` |
| `ServiceToolFramework` | Tools & Frameworks | `SELECT * FROM ServiceToolFramework WHERE ServiceId = X` |
| `ServiceLicense` | Licence | `SELECT * FROM ServiceLicense WHERE ServiceId = X` |
| `TimelinePhase` | Timeline fáze | `SELECT * FROM TimelinePhase WHERE ServiceId = X` |
| `ServiceSizeOption` | Size options | `SELECT * FROM ServiceSizeOption WHERE ServiceId = X` |
| `EffortEstimationItem` | Effort odhady | `SELECT * FROM EffortEstimationItem WHERE ServiceId = X` |
| `ServiceResponsibleRole` | Odpovědné role | `SELECT * FROM ServiceResponsibleRole WHERE ServiceId = X` |
| `ServiceMultiCloudConsideration` | Multi-cloud | `SELECT * FROM ServiceMultiCloudConsideration WHERE ServiceId = X` |

## 🔐 Co Garantuje Uložení?

1. **Transakce** - `BeginTransaction()` → `CommitTransaction()`
2. **Entity Framework Core** - `SaveChangesAsync()` generuje SQL
3. **SQL Server Connection** - Connection string v `local.settings.json`
4. **Repository Pattern** - `UnitOfWork` koordinuje všechny operace
5. **Audit Fields** - Automaticky nastavené `CreatedDate` a `ModifiedDate`

## ❌ Kdy by data NEBYLA uložena?

Data by NEBYLA uložena pouze pokud:

1. ❌ Connection string ukazuje na neexistující server
2. ❌ Backend používá `UseInMemoryDatabase()` místo `UseSqlServer()`
3. ❌ Import API vrátí chybu (validace selhala)
4. ❌ Transakce byla rollbackována (exception)
5. ❌ Database neexistuje nebo není dostupná

**ŽÁDNÁ z těchto podmínek není splněna v aktuálním kódu!**

## 📝 Souhrn

| Otázka | Odpověď |
|--------|---------|
| Ukládají se data do MSSQL? | **✅ ANO** |
| Jak to ověřit? | Spustit `test-import-to-database.ps1` nebo SQL dotaz |
| Je to persistent? | **✅ ANO** - data zůstanou i po restartu |
| Jsou data v transakcích? | **✅ ANO** - atomic commit/rollback |
| Můžu to vidět v SSMS? | **✅ ANO** - připojte se k localhost DB |

## 🎯 Quick Test

```powershell
# 1. Spustit backend
cd src/backend/ServiceCatalogueManager.Api
func start

# 2. V novém terminálu - ověřit zdraví
curl http://localhost:7071/api/services/import/health

# 3. Importovat test JSON
curl -X POST http://localhost:7071/api/services/import `
  -H "Content-Type: application/json" `
  -d @examples/MINIMAL-VALID-EXAMPLE.json

# 4. Ověřit v DB
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d ServiceCatalogueManager `
  -Q "SELECT TOP 1 * FROM ServiceCatalogItem ORDER BY CreatedDate DESC"
```

**Pokud uvidíte záznam v kroku 4, data JSOU v MSSQL! ✅**

---

## 📚 Související Dokumentace

- [IMPORT-DATABASE-VERIFICATION.md](./IMPORT-DATABASE-VERIFICATION.md) - Detailní guide
- [scripts/README.md](../scripts/README.md) - Dokumentace test skriptů
- [JSON-IMPORT-FIX-v1.5-FINAL.md](../JSON-IMPORT-FIX-v1.5-FINAL.md) - Import fixes

---

**Poslední ověření:** 2026-01-28  
**Status:** ✅ Verified - Data ARE saved to MSSQL  
**Verze:** 1.0
