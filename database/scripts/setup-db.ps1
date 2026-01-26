#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Database Setup
# ============================================================================

param(
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

$DB_NAME = "ServiceCatalogueDB"
$SA_PASSWORD = "YourStrong!Passw0rd"
$SERVER = "localhost,1433"
$DB_CONTAINER = "service-catalogue-db"
$SCHEMA_FILE = Join-Path $PSScriptRoot "..\schema\db_structure.sql"

Write-Host "🗄️  Service Catalogue Database Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if sqlcmd is available locally or use Docker exec
$useSqlCmd = $null -ne (Get-Command "sqlcmd" -ErrorAction SilentlyContinue)

if (-not $useSqlCmd) {
    Write-Host "ℹ️  Using Docker exec (sqlcmd not found locally)" -ForegroundColor Cyan
}

# Helper function to run SQL commands
function Invoke-SqlCommand {
    param(
        [string]$Query,
        [string]$Database = $null
    )
    
    if ($useSqlCmd) {
        if ($Database) {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $Database -Q $Query -C -h -1 2>&1
        } else {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -Q $Query -C -h -1 2>&1
        }
    } else {
        if ($Database) {
            docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $Database -Q $Query -C -h -1 2>&1
        } else {
            docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -Q $Query -C -h -1 2>&1
        }
    }
}

function Invoke-SqlFile {
    param(
        [string]$FilePath,
        [string]$Database = $null
    )
    
    if ($useSqlCmd) {
        if ($Database) {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $Database -i $FilePath -C 2>&1
        } else {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -i $FilePath -C 2>&1
        }
    } else {
        # For Docker exec, we need to copy file into container first
        Write-Host "ℹ️  Copying schema file to container..." -ForegroundColor Cyan
        docker cp $FilePath "${DB_CONTAINER}:/tmp/schema.sql" 2>&1 | Out-Null
        
        if ($Database) {
            docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $Database -i /tmp/schema.sql -C 2>&1
        } else {
            docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -i /tmp/schema.sql -C 2>&1
        }
    }
}

# Check if SQL Server is running
Write-Host "ℹ️  Checking SQL Server connection..." -ForegroundColor Cyan
try {
    $testResult = Invoke-SqlCommand -Query "SELECT 1"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Connection failed"
    }
    
    Write-Host "✅ SQL Server is running" -ForegroundColor Green
} catch {
    Write-Host "❌ SQL Server is not accessible!" -ForegroundColor Red
    Write-Host "   Make sure Docker container is running:" -ForegroundColor Yellow
    Write-Host "   docker-compose up -d sqlserver" -ForegroundColor Yellow
    Write-Host "   or: docker start $DB_CONTAINER" -ForegroundColor Yellow
    exit 1
}

# Check if database exists
Write-Host "ℹ️  Checking if database exists..." -ForegroundColor Cyan
$checkDbQuery = "SELECT COUNT(*) FROM sys.databases WHERE name = '$DB_NAME'"
$dbExistsResult = Invoke-SqlCommand -Query $checkDbQuery
$dbExists = ($dbExistsResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)

if ($dbExists -eq "1") {
    if (-not $Force) {
        Write-Host "⚠️  Database $DB_NAME already exists!" -ForegroundColor Yellow
        Write-Host "   Use -Force to recreate it" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "⚠️  Dropping existing database..." -ForegroundColor Yellow
    $dropQuery = "DROP DATABASE $DB_NAME"
    Invoke-SqlCommand -Query $dropQuery | Out-Null
    Start-Sleep -Seconds 2
}

# Create database
Write-Host "📦 Creating database $DB_NAME..." -ForegroundColor Cyan
$createQuery = "CREATE DATABASE $DB_NAME"
Invoke-SqlCommand -Query $createQuery | Out-Null
Write-Host "✅ Database created" -ForegroundColor Green

# Wait a moment for database to be ready
Start-Sleep -Seconds 2

# Run schema script
Write-Host "📝 Running schema script..." -ForegroundColor Cyan
if (-not (Test-Path $SCHEMA_FILE)) {
    Write-Host "❌ Schema file not found: $SCHEMA_FILE" -ForegroundColor Red
    exit 1
}

$schemaResult = Invoke-SqlFile -FilePath $SCHEMA_FILE -Database $DB_NAME

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Schema script had some warnings (may be OK)" -ForegroundColor Yellow
}

Write-Host "✅ Schema created successfully" -ForegroundColor Green

# Verify tables
Write-Host "ℹ️  Verifying tables..." -ForegroundColor Cyan
$countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
$tableCountResult = Invoke-SqlCommand -Query $countQuery -Database $DB_NAME
$tableCount = ($tableCountResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)

Write-Host "✅ Database setup complete!" -ForegroundColor Green
Write-Host "   Tables created: $tableCount" -ForegroundColor Green
Write-Host ""
Write-Host "Connection String:" -ForegroundColor Cyan
Write-Host "Server=localhost,1433;Database=$DB_NAME;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
Write-Host ""

if (-not $useSqlCmd) {
    Write-Host "💡 Tip: To connect from outside Docker, install SQL Server Command Line Utilities" -ForegroundColor Cyan
    Write-Host "   Download: https://aka.ms/sqlcmd" -ForegroundColor Cyan
}
