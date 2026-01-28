#!/usr/bin/env pwsh
# ============================================================================
# Test nové implementace db_structure.sql
# ============================================================================

param(
    [switch]$UseDocker = $true,
    [switch]$RecreateDb = $true
)

Write-Host "🧪 TEST NOVÉ IMPLEMENTACE DB_STRUCTURE.SQL" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Zastavit případný běžící container
docker stop scm-sqlserver 2>$null | Out-Null
docker rm scm-sqlserver 2>$null | Out-Null

Write-Host "📋 Parametry testu:" -ForegroundColor Yellow
Write-Host "  - UseDocker: $UseDocker" -ForegroundColor Gray
Write-Host "  - RecreateDb: $RecreateDb" -ForegroundColor Gray
Write-Host ""

# Spustit nový skript
Write-Host "🚀 Spouštím start-all-fixed-v2.ps1 s novou implementací..." -ForegroundColor Green

$startTime = Get-Date

# Spustit skript v novém okně a čekat na výsledek
$process = Start-Process -FilePath "pwsh" -ArgumentList "-File", "./start-all-fixed-v2.ps1", "-UseDocker:$UseDocker", "-RecreateDb:$RecreateDb", "-DbOnly" -PassThru -Wait

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host ""
Write-Host "⏱️  Test dokončen za $([Math]::Round($duration, 1)) sekund" -ForegroundColor Cyan
Write-Host ""

# Kontrola výsledků
Write-Host "🔍 Kontrola výsledků:" -ForegroundColor Yellow

# Zkontrolovat zda container běží
try {
    $container = docker ps --filter "name=scm-sqlserver" --format "{{.Names}}"
    if ($container -eq "scm-sqlserver") {
        Write-Host "✅ SQL Server container běží" -ForegroundColor Green
    } else {
        Write-Host "❌ SQL Server container neběží" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Chyba při kontrole containeru: $_" -ForegroundColor Red
}

# Zkontrolovat databázi a tabulky
try {
    Write-Host ""
    Write-Host "📊 Kontrola databáze a tabulek:" -ForegroundColor Yellow
    
    # Počet tabulek v databázi
    $tableCount = docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0" -h -1 2>$null
    
    if ($tableCount -match '\d+') {
        $count = [int]$tableCount.Trim()
        Write-Host "✅ Počet uživatelských tabulek: $count" -ForegroundColor Green
        
        if ($count -ge 42) {
            Write-Host "✅ Struktura databáze obsahuje očekávaných 42+ tabulek" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Databáze obsahuje pouze $count tabulek (očekáváno 42+)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Nepodařilo se zjistit počet tabulek" -ForegroundColor Yellow
    }
    
    # Zkontrolovat konkrétní tabulky
    $testTables = @("ServiceCatalog", "ServiceCategory", "ServiceStatus", "ServicePriority")
    Write-Host ""
    Write-Host "🔍 Kontrola konkrétních tabulek:" -ForegroundColor Yellow
    
    foreach ($table in $testTables) {
        try {
            $result = docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT TOP 1 1 FROM [$table]" -h -1 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Tabulka $table existuje" -ForegroundColor Green
            } else {
                Write-Host "❌ Tabulka $table neexistuje" -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ Tabulka $table neexistuje (chyba)" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ Chyba při kontrole databáze: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Souhrn testu:" -ForegroundColor Cyan
Write-Host "  Nová implementace používá db_structure.sql pro vytvoření kompletní databázové struktury." -ForegroundColor Gray
Write-Host "  Oproti EF Core migracím, které vytvoří pouze základní tabulky." -ForegroundColor Gray
Write-Host ""

# Vyčistit
Write-Host "🧹 Čištění prostředí..." -ForegroundColor Yellow
docker stop scm-sqlserver 2>$null | Out-Null
docker rm scm-sqlserver 2>$null | Out-Null

Write-Host ""
Write-Host "✅ Test dokončen" -ForegroundColor Green