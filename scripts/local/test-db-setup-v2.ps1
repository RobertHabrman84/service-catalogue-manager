#!/usr/bin/env pwsh
# Test Database Setup - V2
# Testuje připojení k databázi a kontroluje existenci tabulek

param(
    [switch]$UseDocker = $false,
    [string]$DatabaseName = "ServiceCatalogueManager"
)

Write-Host "🧪 Testing Database Setup" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

if ($UseDocker) {
    Write-Host "ℹ️  Testing Docker SQL Server connection..." -ForegroundColor Cyan
    $containerName = "scm-sqlserver"
    $saPassword = "YourStrong@Passw0rd"
    
    # Check if container is running
    $containerStatus = docker ps --filter "name=$containerName" --format "{{.Status}}" 2>$null
    if (-not $containerStatus) {
        Write-Host "❌ Docker container '$containerName' is not running!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Docker container is running: $containerStatus" -ForegroundColor Green
    
    # Test connection
    Write-Host "ℹ️  Testing SQL Server connection..." -ForegroundColor Cyan
    try {
        docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q "SELECT 1" -h -1 2>&1 | Out-Null
        Write-Host "✅ SQL Server connection successful" -ForegroundColor Green
    } catch {
        Write-Host "❌ SQL Server connection failed: $_" -ForegroundColor Red
        exit 1
    }
    
    # Check database
    Write-Host "ℹ️  Checking database '$DatabaseName'..." -ForegroundColor Cyan
    $dbCheck = docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q "SELECT COUNT(*) FROM sys.databases WHERE name = '$DatabaseName'" -h -1 2>&1
    $dbExists = ($dbCheck | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
    
    if ($dbExists -eq "1") {
        Write-Host "✅ Database '$DatabaseName' exists" -ForegroundColor Green
        
        # Check tables
        Write-Host "ℹ️  Checking tables in database '$DatabaseName'..." -ForegroundColor Cyan
        $tableQuery = "SELECT COUNT(*) FROM [$DatabaseName].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
        $tableCount = docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q $tableQuery -h -1 2>&1
        $tableCount = ($tableCount | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
        
        Write-Host "✅ Tables found: $tableCount" -ForegroundColor Green
        
        if ([int]$tableCount -gt 0) {
            Write-Host "✅ Database setup is working correctly!" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "⚠️  Database exists but no tables found" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "❌ Database '$DatabaseName' does not exist!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ℹ️  Testing SQLite setup..." -ForegroundColor Cyan
    
    # Check if SQLite file exists
    $sqliteFile = "ServiceCatalogueManager.db"
    if (Test-Path $sqliteFile) {
        Write-Host "✅ SQLite database file exists: $sqliteFile" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "⚠️  SQLite database file not found: $sqliteFile" -ForegroundColor Yellow
        exit 1
    }
}