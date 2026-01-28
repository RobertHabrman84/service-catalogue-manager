# Ověření Importu JSON do MSSQL Databáze

## 📋 Přehled

Tento dokument popisuje, jak ověřit, že data z JSON importu se skutečně ukládají do MSSQL databáze.

## 🔍 Jak Import Funguje

### 1. Import Flow (Tok dat)

```
JSON Soubor
    ↓
ImportFunction.cs (HTTP endpoint)
    ↓
ImportOrchestrationService.cs (Business logic)
    ↓
UnitOfWork + Repository Pattern
    ↓
Entity Framework Core DbContext
    ↓
MSSQL Database (ServiceCatalogueManager)
```

### 2. Klíčové Komponenty

#### a) **ImportFunction.cs** (`/api/services/import`)
- HTTP endpoint pro příjem JSON dat
- Deserializuje JSON do `ImportServiceModel`
- Volá `IImportOrchestrationService.ImportServiceAsync()`

#### b) **ImportOrchestrationService.cs**
- Validuje data pomocí `IImportValidationService`
- Vytváří databázovou transakci
- Mapuje JSON model na Entity (`ServiceCatalogItem`, `UsageScenario`, atd.)
- Volá repository pro uložení

#### c) **UnitOfWork & Repository**
- `UnitOfWork` koordinuje všechny operace
- `Repository<T>` poskytuje CRUD operace
- Entity Framework Core DbSet pro každou tabulku

#### d) **ServiceCatalogDbContext**
- Entity Framework Core context
- Connection string: `local.settings.json` → `ConnectionStrings.AzureSQL`
- SaveChangesAsync() → ukládá do MSSQL

### 3. Connection String

V souboru `src/backend/ServiceCatalogueManager.Api/local.settings.json`:

```json
{
  "ConnectionStrings": {
    "AzureSQL": "Server=localhost;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
  }
}
```

## ✅ Jak Ověřit Uložení Dat

### Metoda 1: PowerShell Test Script (Doporučeno)

Spusťte komplexní test, který:
1. Zkontroluje připojení k databázi
2. Importuje testovací JSON
3. Ověří data v databázi

```powershell
# Spustit Azure Functions API (v prvním terminálu)
cd src/backend/ServiceCatalogueManager.Api
func start

# Spustit test script (v druhém terminálu)
./scripts/test-import-to-database.ps1
```

#### Co tento skript dělá:

1. **Test SQL Connection** - ověří připojení k MSSQL
2. **Count Initial Services** - spočítá existující služby
3. **Import JSON** - zavolá API endpoint `/api/services/import`
4. **Wait for Transaction** - počká na dokončení transakce
5. **Verify in Database** - přímým SQL dotazem ověří data

#### Očekávaný výstup:

```
========================================
JSON Import to MSSQL Database Test
========================================

[1/5] Testing SQL Server connection...
✓ SQL Server connected successfully
  Version: Microsoft SQL Server 2022...

[2/5] Checking current database state...
✓ Current services in database: 5

[3/5] Importing service from JSON...
  Reading JSON file: examples/MINIMAL-VALID-EXAMPLE.json
  Service Code: TEST-SERVICE-001
  Service Name: Test Service
  Posting to: http://localhost:7071/api/services/import
✓ Import successful!
  Service ID: 123

[4/5] Waiting for transaction to complete...
✓ Ready to verify

[5/5] Verifying data in database...
✓ Service found in database!

═══════════════════════════════════════
  Database Verification Details
═══════════════════════════════════════
  Service ID:         123
  Service Code:       TEST-SERVICE-001
  Service Name:       Test Service
  Version:            v1.0
  Created Date:       2026-01-28 10:30:00
  Description:        This is a test service...

  Related Data:
    - Usage Scenarios:  2
    - Inputs:           3
    - Output Categories: 1
    - Prerequisites:    2
    - Dependencies:     0
    - Scope Categories: 1
═══════════════════════════════════════

✅ SUCCESS: Data from JSON was successfully saved to MSSQL database!

  Total services now in database: 6
  New services added: 1
```

### Metoda 2: Přímý SQL Dotaz

Spusťte SQL script pro ověření dat:

```bash
# Pomocí sqlcmd
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d ServiceCatalogueManager -i scripts/verify-import-data.sql

# Nebo pomocí Azure Data Studio / SQL Server Management Studio
# Otevřete a spusťte: scripts/verify-import-data.sql
```

#### Co tento script dělá:

1. Zobrazí všechny služby v tabulce `ServiceCatalogItem`
2. Pro nejnovější službu zobrazí počty všech souvisejících záznamů
3. Ukáže vzorová data (usage scenarios, inputs, prerequisites)
4. Vytiskne celkový souhrn databáze

### Metoda 3: Ruční SQL Dotazy

Připojte se k databázi a spusťte:

```sql
-- 1. Zobrazit všechny importované služby
SELECT 
    ServiceId,
    ServiceCode,
    ServiceName,
    Version,
    CreatedDate
FROM ServiceCatalogItem
ORDER BY CreatedDate DESC;

-- 2. Zobrazit konkrétní službu s detaily
DECLARE @ServiceCode NVARCHAR(50) = 'YOUR-SERVICE-CODE';

SELECT s.*, c.CategoryName
FROM ServiceCatalogItem s
LEFT JOIN LU_ServiceCategory c ON s.CategoryId = c.CategoryId
WHERE s.ServiceCode = @ServiceCode;

-- 3. Ověřit související data
SELECT 
    (SELECT COUNT(*) FROM UsageScenario WHERE ServiceId = s.ServiceId) as UsageScenarios,
    (SELECT COUNT(*) FROM ServiceInput WHERE ServiceId = s.ServiceId) as Inputs,
    (SELECT COUNT(*) FROM ServiceOutputCategory WHERE ServiceId = s.ServiceId) as OutputCategories,
    (SELECT COUNT(*) FROM ServicePrerequisite WHERE ServiceId = s.ServiceId) as Prerequisites,
    (SELECT COUNT(*) FROM ServiceDependency WHERE ServiceId = s.ServiceId) as Dependencies,
    (SELECT COUNT(*) FROM ServiceToolFramework WHERE ServiceId = s.ServiceId) as Tools
FROM ServiceCatalogItem s
WHERE s.ServiceCode = @ServiceCode;
```

### Metoda 4: Entity Framework Core Logging

Zapněte EF Core logging pro sledování SQL příkazů:

V `Program.cs` nebo `Startup.cs`:

```csharp
builder.Services.AddDbContext<ServiceCatalogDbContext>(options =>
{
    options.UseSqlServer(connectionString)
           .EnableSensitiveDataLogging()
           .LogTo(Console.WriteLine, LogLevel.Information);
});
```

Pak uvidíte v konzoli všechny SQL příkazy:

```
Executed DbCommand (5ms) [Parameters=[@p0='TEST-001', @p1='Test Service', ...], CommandType='Text', CommandTimeout='30']
INSERT INTO [ServiceCatalogItem] ([ServiceCode], [ServiceName], ...)
VALUES (@p0, @p1, ...);
SELECT [ServiceId] FROM [ServiceCatalogItem] WHERE @@ROWCOUNT = 1 AND [ServiceId] = scope_identity();
```

## 🧪 Test Scénáře

### Test 1: Minimální Import

Použijte `examples/MINIMAL-VALID-EXAMPLE.json`:

```bash
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @examples/MINIMAL-VALID-EXAMPLE.json
```

Očekávaný výsledek:
- Status: 200 OK
- Response: `{ "success": true, "serviceId": 123, "serviceCode": "TEST-SERVICE-001" }`
- V databázi: Nový záznam v `ServiceCatalogItem`

### Test 2: Kompletní Import

Použijte `examples/Application_Landing_Zone_Design_PERFECT.json`:

```bash
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @examples/Application_Landing_Zone_Design_PERFECT.json
```

Očekávaný výsledek:
- Status: 200 OK
- V databázi: Služba + všechny související entity (scenarios, inputs, outputs, atd.)

### Test 3: Duplikát (měl by selhat)

Zkuste importovat stejný `serviceCode` dvakrát:

```bash
# První import - úspěšný
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @examples/MINIMAL-VALID-EXAMPLE.json

# Druhý import - měl by selhat
curl -X POST http://localhost:7071/api/services/import \
  -H "Content-Type: application/json" \
  -d @examples/MINIMAL-VALID-EXAMPLE.json
```

Očekávaný výsledek druhého volání:
- Status: 400 Bad Request
- Response: `{ "success": false, "message": "Service with code TEST-SERVICE-001 already exists" }`

## 🐛 Troubleshooting

### Problem: "Cannot connect to SQL Server"

**Řešení:**
1. Zkontrolujte, zda SQL Server běží: `docker ps` nebo Services
2. Ověřte connection string v `local.settings.json`
3. Zkuste se připojit pomocí `sqlcmd`:
   ```bash
   sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd'
   ```

### Problem: "Database does not exist"

**Řešení:**
1. Spusťte migrace:
   ```bash
   cd src/backend/ServiceCatalogueManager.Api
   dotnet ef database update
   ```

### Problem: "Import succeeds but no data in database"

**Možné příčiny:**
1. **In-Memory Database** - Zkontrolujte Program.cs, zda nepoužíváte `UseInMemoryDatabase()`
2. **Transakce nebyla commitována** - Zkontrolujte logy, zda vidíte `CommitTransactionAsync`
3. **Špatný connection string** - Ověřte v `local.settings.json`

**Ověření:**
```csharp
// V ImportOrchestrationService.cs
_logger.LogInformation("Committing transaction...");
await _unitOfWork.CommitTransactionAsync();
_logger.LogInformation("Transaction committed successfully");
```

### Problem: "Service saved but related data missing"

**Možné příčiny:**
1. Import metoda pro související data selhala
2. Transakce byla rollbackována

**Řešení:**
Zapněte detailní logging:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "ServiceCatalogueManager.Api.Services.Import": "Debug"
    }
  }
}
```

## 📊 Datové Struktury

### Hlavní Tabulky

| Tabulka | Popis | Vztah |
|---------|-------|-------|
| `ServiceCatalogItem` | Hlavní služba | 1:N s ostatními |
| `UsageScenario` | Scénáře použití | N:1 (ServiceId) |
| `ServiceInput` | Vstupní parametry | N:1 (ServiceId) |
| `ServiceOutputCategory` | Kategorie výstupů | N:1 (ServiceId) |
| `ServiceOutputItem` | Výstupní položky | N:1 (OutputCategoryId) |
| `ServicePrerequisite` | Prerekvizity | N:1 (ServiceId) |
| `ServiceDependency` | Závislosti | N:1 (ServiceId) |
| `ServiceScopeCategory` | Kategorie rozsahu | N:1 (ServiceId) |
| `ServiceToolFramework` | Nástroje a frameworky | N:1 (ServiceId) |

## 🎯 Shrnutí

**Data Z JSON SE UKLÁDAJÍ do MSSQL**, pokud:

✅ Connection string v `local.settings.json` ukazuje na MSSQL  
✅ Entity Framework Core používá `UseSqlServer()` (ne `UseInMemoryDatabase()`)  
✅ Migrace byly spuštěny (`dotnet ef database update`)  
✅ Import API volání vrátí `success: true`  
✅ Transakce byla commitována (`CommitTransactionAsync()`)  

**Ověřte pomocí:**
1. PowerShell test script: `./scripts/test-import-to-database.ps1`
2. SQL script: `scripts/verify-import-data.sql`
3. Přímé SQL dotazy v SSMS/Azure Data Studio

---

**Poslední aktualizace:** 2026-01-28  
**Verze:** 1.0
