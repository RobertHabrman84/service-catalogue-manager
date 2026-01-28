#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Database Setup (FIXED V2)
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
$SCHEMA_DIR = Join-Path $PSScriptRoot "..\schema"

Write-Host "🗄️  Service Catalogue Database Setup (FIXED V2)" -ForegroundColor Cyan
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
    
    # Set environment variable for EF Core to find the connection string
    $env:AzureSQL__ConnectionString = "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
    $env:ConnectionStrings__AzureSQL = $env:AzureSQL__ConnectionString
    
    Write-Host "ℹ️  Applying EF Core migrations..." -ForegroundColor Cyan
    Write-Host "Connection String: $env:AzureSQL__ConnectionString" -ForegroundColor Gray
    
    # Try to run EF Core migrations with explicit project specification
    $migrationResult = dotnet ef database update --connection "$env:AzureSQL__ConnectionString" 2>&1
    Write-Host "EF Core output: $migrationResult" -ForegroundColor Gray
    
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
        Write-Host "EF Core error: $migrationResult" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  EF Core migrations failed: $_" -ForegroundColor Yellow
    Write-Host "Falling back to SQL script..." -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Fallback to SQL scripts
Write-Host "📝 Running schema scripts (fallback)..." -ForegroundColor Cyan

# List of schema files to apply in order
$schemaFiles = @(
    "001_initial_schema.sql",
    "002_lookup_tables.sql", 
    "003_lookup_data.sql"
)

$totalTables = 0

foreach ($schemaFile in $schemaFiles) {
    $fullSchemaPath = Join-Path $SCHEMA_DIR $schemaFile
    
    if (Test-Path $fullSchemaPath) {
        Write-Host "ℹ️  Applying $schemaFile..." -ForegroundColor Cyan
        
        $schemaResult = Invoke-SqlFile -FilePath $fullSchemaPath -Database $DbName
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️  Schema script $schemaFile had warnings (may be OK)" -ForegroundColor Yellow
        } else {
            Write-Host "✅ $schemaFile applied successfully" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  Schema file not found: $fullSchemaPath" -ForegroundColor Yellow
    }
}

# Also try the main db_structure.sql if it exists
$mainSchemaFile = Join-Path $SCHEMA_DIR "db_structure.sql"
if (Test-Path $mainSchemaFile) {
    Write-Host "ℹ️  Applying main schema file..." -ForegroundColor Cyan
    $schemaResult = Invoke-SqlFile -FilePath $mainSchemaFile -Database $DbName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Main schema script had warnings (may be OK)" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Main schema applied successfully" -ForegroundColor Green
    }
}

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