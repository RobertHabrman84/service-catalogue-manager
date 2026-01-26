#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Database Seeding
# ============================================================================

param(
    [switch]$Dev = $false,
    [switch]$Test = $false,
    [switch]$All = $false
)

$ErrorActionPreference = "Stop"

$DB_NAME = "ServiceCatalogueDB"
$SA_PASSWORD = "YourStrong!Passw0rd"
$SERVER = "localhost,1433"
$SEEDS_DIR = Join-Path $PSScriptRoot "..\seeds"

Write-Host "🌱 Service Catalogue Database Seeding" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if SQL Server is running
Write-Host "ℹ️  Checking SQL Server connection..." -ForegroundColor Cyan
try {
    $testQuery = "SELECT 1"
    sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -Q $testQuery -h -1 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Connection failed"
    }
    Write-Host "✅ SQL Server is running" -ForegroundColor Green
} catch {
    Write-Host "❌ SQL Server is not accessible!" -ForegroundColor Red
    Write-Host "   Make sure database is running" -ForegroundColor Yellow
    exit 1
}

# Check if database exists
Write-Host "ℹ️  Checking database..." -ForegroundColor Cyan
$checkDbQuery = "SELECT COUNT(*) FROM sys.databases WHERE name = '$DB_NAME'"
$dbExists = sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -Q $checkDbQuery -h -1 2>&1
$dbExists = $dbExists.Trim()

if ($dbExists -ne "1") {
    Write-Host "❌ Database $DB_NAME does not exist!" -ForegroundColor Red
    Write-Host "   Run setup-db.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Database found" -ForegroundColor Green

# Seed lookup data (always)
Write-Host ""
Write-Host "📝 Seeding lookup data..." -ForegroundColor Cyan
$lookupFile = Join-Path $SEEDS_DIR "01_lookup_data.sql"

if (Test-Path $lookupFile) {
    try {
        sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DB_NAME -i $lookupFile -b
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Lookup data seeded" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Lookup data may already exist (this is OK)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Lookup data seeding had issues (may already exist)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Lookup data file not found: $lookupFile" -ForegroundColor Yellow
}

# Seed dev sample data
if ($Dev -or $All) {
    Write-Host ""
    Write-Host "📝 Seeding development sample data..." -ForegroundColor Cyan
    $devFile = Join-Path $SEEDS_DIR "02_sample_services_dev.sql"
    
    if (Test-Path $devFile) {
        try {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DB_NAME -i $devFile -b
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Development data seeded" -ForegroundColor Green
            }
        } catch {
            Write-Host "⚠️  Development data seeding had issues: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Development data file not found: $devFile" -ForegroundColor Yellow
    }
}

# Seed test data
if ($Test -or $All) {
    Write-Host ""
    Write-Host "📝 Seeding test data..." -ForegroundColor Cyan
    $testFile = Join-Path $SEEDS_DIR "03_test_data.sql"
    
    if (Test-Path $testFile) {
        try {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DB_NAME -i $testFile -b
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Test data seeded" -ForegroundColor Green
            }
        } catch {
            Write-Host "⚠️  Test data seeding had issues: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Test data file not found: $testFile" -ForegroundColor Yellow
    }
}

# Verify data
Write-Host ""
Write-Host "ℹ️  Verifying seeded data..." -ForegroundColor Cyan
$countQuery = @"
SELECT 
    'ServiceCatalogItem' as TableName, COUNT(*) as RowCount 
FROM dbo.ServiceCatalogItem
UNION ALL
SELECT 'LU_RequirementLevel', COUNT(*) FROM dbo.LU_RequirementLevel
UNION ALL
SELECT 'LU_SizeOption', COUNT(*) FROM dbo.LU_SizeOption
UNION ALL
SELECT 'LU_CloudProvider', COUNT(*) FROM dbo.LU_CloudProvider
"@

sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DB_NAME -Q $countQuery

Write-Host ""
Write-Host "✅ Database seeding complete!" -ForegroundColor Green
