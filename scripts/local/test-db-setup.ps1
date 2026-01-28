#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Test Database Setup
# ============================================================================
# Test skript pro ověření správného vytvoření databáze
# ============================================================================

param(
    [switch]$UseDocker = $false
)

$ErrorActionPreference = "Continue"

Write-Host "🧪 Testing Database Setup" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BACKEND_DIR = Join-Path $SCRIPT_DIR "src\backend\ServiceCatalogueManager.Api"

# Test připojení k databázi
function Test-DatabaseConnection {
    param([string]$ConnectionString)
    
    try {
        Write-Host "ℹ️  Testing database connection..." -ForegroundColor Cyan
        
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT 1"
        $result = $command.ExecuteScalar()
        
        $connection.Close()
        
        if ($result -eq 1) {
            Write-Host "✅ Database connection successful" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Database connection test failed" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Database connection failed: $_" -ForegroundColor Red
        return $false
    }
}

# Test existence tabulek
function Test-TablesExist {
    param([string]$ConnectionString)
    
    try {
        Write-Host "ℹ️  Checking database tables..." -ForegroundColor Cyan
        
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
        $tableCount = $command.ExecuteScalar()
        
        Write-Host "📊 Tables found: $tableCount" -ForegroundColor Yellow
        
        # Zkontrolovat konkrétní tabulky
        $command.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
        $reader = $command.ExecuteReader()
        
        Write-Host "ℹ️  Table list:" -ForegroundColor Cyan
        while ($reader.Read()) {
            Write-Host "   - $($reader["TABLE_NAME"])" -ForegroundColor Gray
        }
        $reader.Close()
        
        $connection.Close()
        
        return $tableCount -gt 0
    } catch {
        Write-Host "❌ Table check failed: $_" -ForegroundColor Red
        return $false
    }
}

# Test EF Core migrace
function Test-EfMigrations {
    Write-Host "ℹ️  Testing EF Core migrations..." -ForegroundColor Cyan
    
    try {
        Push-Location $BACKEND_DIR
        
        # Zkontrolovat jestli jsou EF Core tools dostupné
        $efAvailable = $null -ne (Get-Command "dotnet-ef" -ErrorAction SilentlyContinue)
        if (-not $efAvailable) {
            Write-Host "ℹ️  Installing EF Core tools..." -ForegroundColor Cyan
            dotnet tool install --global dotnet-ef 2>$null | Out-Null
        }
        
        # Zkontrolovat status migrací
        Write-Host "ℹ️  Checking migration status..." -ForegroundColor Cyan
        dotnet ef migrations list --project . --startup-project . --no-build 2>&1 | Out-String
        
        Pop-Location
        
        Write-Host "✅ EF Core migrations check complete" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "⚠️  EF Core migrations check failed: $_" -ForegroundColor Yellow
        return $false
    }
}

# Hlavní test
function Run-Tests {
    Write-Host ""
    Write-Host "🚀 Starting database tests..." -ForegroundColor Green
    Write-Host ""
    
    # Zvolit správnou connection string
    if ($UseDocker) {
        Write-Host "📦 Using Docker SQL Server configuration" -ForegroundColor Cyan
        $connectionString = "Server=localhost,1433;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True"
        $configFile = Join-Path $BACKEND_DIR "local.settings.docker.json"
    } else {
        Write-Host "💾 Using SQLite configuration" -ForegroundColor Cyan
        $connectionString = "Data Source=ServiceCatalogueManager.db"
        $configFile = Join-Path $BACKEND_DIR "local.settings.sqlite.json"
    }
    
    Write-Host "ℹ️  Configuration: $configFile" -ForegroundColor Gray
    Write-Host "ℹ️  Connection: $($connectionString.Replace($connectionString.Split(';')[-1], '***'))" -ForegroundColor Gray
    Write-Host ""
    
    # Test 1: Připojení
    $connectionTest = Test-DatabaseConnection -ConnectionString $connectionString
    
    if ($connectionTest) {
        # Test 2: Tabulky
        $tablesTest = Test-TablesExist -ConnectionString $connectionString
        
        if ($tablesTest) {
            Write-Host ""
            Write-Host "✅ Všechny testy úspěšně dokončeny!" -ForegroundColor Green
            Write-Host "   Databáze je správně vytvořena a obsahuje tabulky." -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "⚠️  Databáze existuje, ale neobsahuje tabulky." -ForegroundColor Yellow
            Write-Host "   Je potřeba spustit migrace nebo schéma." -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "❌ Připojení k databázi selhalo!" -ForegroundColor Red
        Write-Host "   Zkontrolujte, zda je databáze správně vytvořena." -ForegroundColor Red
    }
    
    # Test 3: EF Core migrace
    Write-Host ""
    Write-Host "ℹ️  Kontrola EF Core migrací..." -ForegroundColor Cyan
    Test-EfMigrations
}

# Spustit testy
Run-Tests

Write-Host ""
Write-Host "🎯 Testování dokončeno!" -ForegroundColor Cyan
Write-Host ""
if ($UseDocker) {
    Write-Host "💡 Pro test Docker konfigurace použijte:" -ForegroundColor Gray
    Write-Host "   .\test-db-setup.ps1 -UseDocker" -ForegroundColor White
} else {
    Write-Host "💡 Pro test SQLite konfigurace použijte:" -ForegroundColor Gray
    Write-Host "   .\test-db-setup.ps1" -ForegroundColor White
}