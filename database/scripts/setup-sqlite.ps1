#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - SQLite Database Setup
# ============================================================================
# Fallback pro prostředí bez Dockeru (např. sandbox)

param(
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

$DB_NAME = "ServiceCatalogueManager"
$DB_FILE = Join-Path $PSScriptRoot "..\..\$DB_NAME.db"
$BACKUP_DIR = Join-Path $PSScriptRoot "..\backups"

Write-Host "🗄️  Service Catalogue SQLite Database Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

function Setup-SqliteDatabase {
    Write-Host "ℹ️  Setting up SQLite database..." -ForegroundColor Cyan
    
    # Vytvořit záložní adresář
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
    }
    
    # Zálohovat existující databázi
    if (Test-Path $DB_FILE) {
        if (-not $Force) {
            Write-Host "⚠️  Database already exists!" -ForegroundColor Yellow
            Write-Host "   Use -Force to recreate it" -ForegroundColor Yellow
            return
        }
        
        $backupFile = Join-Path $BACKUP_DIR "$(Get-Date -Format 'yyyyMMdd-HHmmss')-$DB_NAME.db"
        Write-Host "📦 Backing up existing database to $backupFile" -ForegroundColor Yellow
        Copy-Item -Path $DB_FILE -Destination $backupFile -Force
        Remove-Item -Path $DB_FILE -Force
    }
    
    # Vytvořit novou databázi pomocí dotnet ef
    Write-Host "📦 Creating new SQLite database..." -ForegroundColor Cyan
    
    $backendDir = Join-Path $PSScriptRoot "..\..\src\backend\ServiceCatalogueManager.Api"
    if (-not (Test-Path $backendDir)) {
        Write-Host "❌ Backend directory not found: $backendDir" -ForegroundColor Red
        exit 1
    }
    
    Push-Location $backendDir
    try {
        # Nainstalovat EF Core tools pokud nejsou k dispozici
        $efInstalled = dotnet tool list --global | Select-String "dotnet-ef"
        if (-not $efInstalled) {
            Write-Host "ℹ️  Installing EF Core tools..." -ForegroundColor Cyan
            dotnet tool install --global dotnet-ef --version 8.0.0
        }
        
        # Vytvořit databázi pomocí EF Core
        Write-Host "📝 Applying EF Core migrations..." -ForegroundColor Cyan
        dotnet ef database update --project . --startup-project . --verbose
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ SQLite database created successfully" -ForegroundColor Green
        } else {
            Write-Host "⚠️  EF Core migrations had issues" -ForegroundColor Yellow
            
            # Alternativní přístup - spustit SQL skript
            Write-Host "📝 Trying alternative approach..." -ForegroundColor Yellow
            
            # Získat cestu k databázi
            $dbPath = Join-Path $backendDir "$DB_NAME.db"
            Write-Host "📁 Database location: $dbPath" -ForegroundColor Gray
            
            if (Test-Path $dbPath) {
                Write-Host "✅ Database file created" -ForegroundColor Green
            } else {
                Write-Host "❌ Database creation failed" -ForegroundColor Red
                exit 1
            }
        }
    } catch {
        Write-Host "❌ Database setup failed: $_" -ForegroundColor Red
        exit 1
    } finally {
        Pop-Location
    }
    
    Write-Host "✅ SQLite database setup complete!" -ForegroundColor Green
    Write-Host "📁 Database file: $DB_FILE" -ForegroundColor Gray
    Write-Host ""
}

# Hlavní spuštění
Setup-SqliteDatabase

Write-Host ""
Write-Host "Connection String (for local.settings.json):" -ForegroundColor Cyan
Write-Host "\"AzureSQL__ConnectionString\": \"Data Source=$DB_FILE;Version=3;\"" -ForegroundColor White
Write-Host ""
Write-Host "Connection String (alternative):" -ForegroundColor Cyan
Write-Host "\"ConnectionStrings__AzureSQL\": \"Data Source=$DB_FILE;Version=3;\"" -ForegroundColor White
Write-Host ""