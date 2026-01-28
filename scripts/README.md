# Test a Verifikační Skripty pro Import

Tato složka obsahuje skripty pro testování a ověřování importu JSON dat do MSSQL databáze.

## 📋 Dostupné Skripty

### 1. `test-import-to-database.ps1` (PowerShell)
**Komplexní test script pro Windows/PowerShell**

Provádí end-to-end test importu:
- ✅ Testuje připojení k SQL Server
- ✅ Importuje JSON přes API
- ✅ Ověřuje data v databázi
- ✅ Zobrazuje detailní report

**Použití:**
```powershell
# Základní použití (s výchozími hodnotami)
./scripts/test-import-to-database.ps1

# S vlastním JSON souborem
./scripts/test-import-to-database.ps1 -JsonFile "examples/Application_Landing_Zone_Design_PERFECT.json"

# S vlastní API URL
./scripts/test-import-to-database.ps1 -ApiUrl "http://localhost:8080/api"

# S vlastním connection stringem
./scripts/test-import-to-database.ps1 -ConnectionString "Server=myserver;Database=mydb;..."
```

### 2. `test-import-to-database.sh` (Bash)
**Komplexní test script pro Linux/macOS**

Stejná funkcionalita jako PowerShell verze, ale pro Unix systémy.

**Požadavky:**
- `sqlcmd` (SQL Server command-line tools)
- `curl` (HTTP client)
- `jq` (optional, pro lepší JSON parsing)

**Použití:**
```bash
# Základní použití
./scripts/test-import-to-database.sh

# S vlastním JSON souborem
./scripts/test-import-to-database.sh examples/Application_Landing_Zone_Design_PERFECT.json

# S vlastní API URL
./scripts/test-import-to-database.sh examples/MINIMAL-VALID-EXAMPLE.json http://localhost:8080/api

# S vlastním DB connection (pomocí environment variables)
export DB_SERVER="myserver"
export DB_NAME="mydb"
export DB_USER="myuser"
export DB_PASSWORD="mypassword"
./scripts/test-import-to-database.sh
```

### 3. `verify-import-data.sql` (SQL Script)
**SQL script pro manuální verifikaci dat**

Zobrazuje:
- Seznam všech služeb
- Detail nejnovější služby
- Počty souvisejících záznamů
- Vzorová data

**Použití:**
```bash
# Pomocí sqlcmd (Windows/Linux)
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d ServiceCatalogueManager -i scripts/verify-import-data.sql

# Pomocí Azure Data Studio
# 1. Otevřete Azure Data Studio
# 2. Připojte se k databázi ServiceCatalogueManager
# 3. Otevřete scripts/verify-import-data.sql
# 4. Spusťte (F5)

# Pomocí SQL Server Management Studio
# 1. Otevřete SSMS
# 2. Připojte se k serveru
# 3. File → Open → scripts/verify-import-data.sql
# 4. Execute (F5)
```

## 🚀 Rychlý Start

### Scénář 1: První Test (Windows)

```powershell
# 1. Spustit backend API (Terminal 1)
cd src/backend/ServiceCatalogueManager.Api
func start

# 2. Spustit test (Terminal 2)
./scripts/test-import-to-database.ps1
```

### Scénář 2: První Test (Linux/macOS)

```bash
# 1. Spustit backend API (Terminal 1)
cd src/backend/ServiceCatalogueManager.Api
func start

# 2. Spustit test (Terminal 2)
./scripts/test-import-to-database.sh
```

### Scénář 3: Manuální Ověření SQL

```bash
# Po importu služby, ověřte v databázi
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d ServiceCatalogueManager -i scripts/verify-import-data.sql
```

## 📊 Očekávané Výstupy

### Úspěšný Import

```
========================================
JSON Import to MSSQL Database Test
========================================

[1/5] Testing SQL Server connection...
✓ SQL Server connected successfully

[2/5] Checking current database state...
✓ Current services in database: 5

[3/5] Importing service from JSON...
✓ Import successful!

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
  
  Related Data:
    - Usage Scenarios:  2
    - Inputs:           3
    - Output Categories: 1
═══════════════════════════════════════

✅ SUCCESS: Data from JSON was successfully saved to MSSQL database!
```

### Neúspěšný Import

```
[3/5] Importing service from JSON...
✗ Import failed
  Error: Service with code TEST-SERVICE-001 already exists

❌ Import failed - cannot verify database
```

## 🔧 Troubleshooting

### Problem: "Cannot connect to SQL Server"

**Řešení:**
```bash
# Ověřte, že SQL Server běží
docker ps | grep mssql

# Zkuste se připojit přímo
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd'

# Zkontrolujte connection string v local.settings.json
cat src/backend/ServiceCatalogueManager.Api/local.settings.json | grep ConnectionString
```

### Problem: "API endpoint not responding"

**Řešení:**
```bash
# Zkontrolujte, že backend běží
curl http://localhost:7071/api/services/import/health

# Očekávaný výstup:
# {"status":"healthy","service":"Service Catalogue Import API","timestamp":"..."}
```

### Problem: "sqlcmd: command not found" (Linux)

**Řešení:**
```bash
# Ubuntu/Debian
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo apt-get install mssql-tools unixodbc-dev

# Přidat do PATH
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

# macOS
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew install mssql-tools
```

### Problem: "Import succeeds but no data in database"

**Možné příčiny:**
1. Backend používá In-Memory database místo MSSQL
2. Transakce nebyla commitována
3. Špatný connection string

**Ověření:**
```bash
# 1. Zkontrolujte connection string
cat src/backend/ServiceCatalogueManager.Api/local.settings.json

# 2. Zkontrolujte logy backendu
# Měli byste vidět:
# "Committing transaction..."
# "Transaction committed successfully"

# 3. Ověřte Program.cs - mělo by být UseSqlServer, ne UseInMemoryDatabase
grep -r "UseSqlServer\|UseInMemoryDatabase" src/backend/
```

## 📚 Související Dokumentace

- [IMPORT-DATABASE-VERIFICATION.md](../docs/IMPORT-DATABASE-VERIFICATION.md) - Detailní dokumentace o tom, jak import funguje
- [JSON-IMPORT-FIX-v1.5-FINAL.md](../JSON-IMPORT-FIX-v1.5-FINAL.md) - Historie oprav importu
- [examples/README.md](../examples/README.md) - Příklady JSON souborů

## 💡 Tipy

1. **Vždy používejte test skripty před produkcí** - Ověřte, že import funguje lokálně
2. **Zapněte detailní logging** - Pomůže při debugging
3. **Ověřte SQL příkazy** - Použijte SQL Server Profiler nebo EF Core logging
4. **Testujte s minimálním JSON** - Začněte s `MINIMAL-VALID-EXAMPLE.json`
5. **Používejte transakce** - Import už je transactional, ale ověřte commit/rollback

## 🎯 Checklist pro Ověření

- [ ] SQL Server je dostupný a běží
- [ ] Database `ServiceCatalogueManager` existuje
- [ ] Connection string v `local.settings.json` je správný
- [ ] Backend API běží na portu 7071
- [ ] Health check endpoint odpovídá (200 OK)
- [ ] Test script úspěšně importuje JSON
- [ ] Data jsou viditelná v SQL databázi
- [ ] Související záznamy (scenarios, inputs, atd.) existují

---

**Poslední aktualizace:** 2026-01-28  
**Verze:** 1.0
