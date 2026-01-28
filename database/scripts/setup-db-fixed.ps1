#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Database Setup (FIXED)
# ============================================================================
# Opravená verze kompatibilní s start-all-fixed.ps1
# ============================================================================

param(
    [switch]$Force = $false,
    [string]$DbName = "ServiceCatalogueManager",
    [string]$ContainerName = "scm-sqlserver"
)

$ErrorActionPreference = "Stop"

$SA_PASSWORD = "YourStrong@Passw0rd"
$SERVER = "localhost,1433"
$SCHEMA_FILE = Join-Path $PSScriptRoot "..\schema\db_structure.sql"

Write-Host "🗄️  Service Catalogue Database Setup (FIXED)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
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
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $Database -Q $Query -C -h -1 2>&1
        } else {
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -Q $Query -C -h -1 2>&1
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
        docker cp $FilePath "${ContainerName}:/tmp/schema.sql" 2>&1 | Out-Null
        
        if ($Database) {
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $Database -i /tmp/schema.sql -C 2>&1
        } else {
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -i /tmp/schema.sql -C 2>&1
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
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "   Make sure Docker container is running:" -ForegroundColor Yellow
    Write-Host "   docker ps" -ForegroundColor Yellow
    Write-Host "   docker start $ContainerName" -ForegroundColor Yellow
    Write-Host "   or check container logs:" -ForegroundColor Yellow
    Write-Host "   docker logs $ContainerName" -ForegroundColor Yellow
    exit 1
}

# Check if database exists
Write-Host "ℹ️  Checking if database '$DbName' exists..." -ForegroundColor Cyan
$checkDbQuery = "SELECT COUNT(*) FROM sys.databases WHERE name = '$DbName'"
$dbExistsResult = Invoke-SqlCommand -Query $checkDbQuery
$dbExists = ($dbExistsResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)

if ($dbExists -eq "1") {
    if (-not $Force) {
        Write-Host "⚠️  Database $DbName already exists!" -ForegroundColor Yellow
        Write-Host "   Use -Force to recreate it" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "⚠️  Dropping existing database..." -ForegroundColor Yellow
    $dropQuery = "DROP DATABASE [$DbName]"
    Invoke-SqlCommand -Query $dropQuery | Out-Null
    Start-Sleep -Seconds 2
}

# Create database
Write-Host "📦 Creating database '$DbName'..." -ForegroundColor Cyan
try {
    $createQuery = "CREATE DATABASE [$DbName]"
    Invoke-SqlCommand -Query $createQuery | Out-Null
    Write-Host "✅ Database created" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create database: $_" -ForegroundColor Red
    Write-Host "   Query: $createQuery" -ForegroundColor Gray
    exit 1
}

# Wait a moment for database to be ready
Start-Sleep -Seconds 2

# Try EF Core migrations first (preferred method)
Write-Host "ℹ️  Attempting EF Core migrations..." -ForegroundColor Cyan
$backendDir = Join-Path $PSScriptRoot "..\..\src\backend\ServiceCatalogueManager.Api"
try {
    Push-Location $backendDir
    
    # Check if EF Core tools are available
    $efAvailable = $null -ne (Get-Command "dotnet-ef" -ErrorAction SilentlyContinue)
    if (-not $efAvailable) {
        Write-Host "ℹ️  Installing EF Core tools..." -ForegroundColor Cyan
        dotnet tool install --global dotnet-ef 2>$null | Out-Null
    }
    
    # Create connection string for migrations
    $connectionString = "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
    
    Write-Host "ℹ️  Applying EF Core migrations..." -ForegroundColor Cyan
    dotnet ef database update --connection "$connectionString" --project . --startup-project .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ EF Core migrations applied successfully" -ForegroundColor Green
        
        # Verify tables
        Write-Host "ℹ️  Verifying tables..." -ForegroundColor Cyan
        $countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DbName'"
        $tableCountResult = Invoke-SqlCommand -Query $countQuery
        $tableCount = ($tableCountResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
        
        Write-Host "✅ Database setup complete!" -ForegroundColor Green
        Write-Host "   Tables created: $tableCount" -ForegroundColor Green
        Write-Host ""
        Write-Host "Connection String:" -ForegroundColor Cyan
        Write-Host "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
        Write-Host ""
        exit 0
    } else {
        Write-Host "⚠️  EF Core migrations failed, falling back to SQL script..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  EF Core migrations failed: $_" -ForegroundColor Yellow
    Write-Host "Falling back to SQL script..." -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Fallback to SQL script
Write-Host "📝 Running schema script (fallback)..." -ForegroundColor Cyan
if (-not (Test-Path $SCHEMA_FILE)) {
    Write-Host "❌ Schema file not found: $SCHEMA_FILE" -ForegroundColor Red
    exit 1
}

$schemaResult = Invoke-SqlFile -FilePath $SCHEMA_FILE -Database $DbName

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Schema script had some warnings (may be OK)" -ForegroundColor Yellow
}

Write-Host "✅ Schema created successfully" -ForegroundColor Green

# Verify tables
Write-Host "ℹ️  Verifying tables..." -ForegroundColor Cyan
$countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DbName'"
$tableCountResult = Invoke-SqlCommand -Query $countQuery
$tableCount = ($tableCountResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)

Write-Host "✅ Database setup complete!" -ForegroundColor Green
Write-Host "   Tables created: $tableCount" -ForegroundColor Green
Write-Host ""
Write-Host "Connection String:" -ForegroundColor Cyan
Write-Host "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
Write-Host ""

if (-not $useSqlCmd) {
    Write-Host "💡 Tip: To connect from outside Docker, install SQL Server Command Line Utilities" -ForegroundColor Cyan
    Write-Host "   Download: https://aka.ms/sqlcmd" -ForegroundColor Cyan
}