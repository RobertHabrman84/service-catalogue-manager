<#
.SYNOPSIS
    Resets the local development database.
.DESCRIPTION
    Drops and recreates the local database, applies migrations, and seeds sample data.
.PARAMETER SkipSeed
    Skip seeding sample data
.PARAMETER SkipConfirmation
    Skip confirmation prompt (for CI/automation)
.PARAMETER DatabaseName
    Name of the database (default: ServiceCatalogueDb)
.EXAMPLE
    .\reset-local-db.ps1
    .\reset-local-db.ps1 -SkipSeed
    .\reset-local-db.ps1 -SkipConfirmation
#>

param(
    [switch]$SkipSeed,
    [switch]$SkipConfirmation,
    [string]$DatabaseName = "ServiceCatalogueDb"
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$BackendPath = Join-Path $ProjectRoot "src/backend/ServiceCatalogueManager.Api"
$DatabasePath = Join-Path $ProjectRoot "database"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Reset Local Database" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Confirmation
if (-not $SkipConfirmation) {
    Write-Host "WARNING: This will delete all data in '$DatabaseName'!" -ForegroundColor Red
    $confirm = Read-Host "Are you sure you want to continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Cancelled" -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

# Check Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    Write-Host "  Docker is running" -ForegroundColor Green
}
catch {
    Write-Host "  Error: Docker is not running" -ForegroundColor Red
    exit 1
}

# Ensure SQL Server container is running
Write-Host ""
Write-Host "Starting SQL Server container..." -ForegroundColor Yellow
Push-Location $ProjectRoot
docker-compose up -d sqlserver
Pop-Location

Write-Host "  Waiting for SQL Server to be ready..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Get connection string from local.settings.json
$localSettingsPath = Join-Path $BackendPath "local.settings.json"
if (Test-Path $localSettingsPath) {
    $settings = Get-Content $localSettingsPath | ConvertFrom-Json
    $connectionString = $settings.Values.SqlConnectionString
}
else {
    # Default local connection string
    $connectionString = "Server=localhost,1433;Database=$DatabaseName;User Id=sa;Password=YourStrong@Password123;TrustServerCertificate=True"
}

# Drop database using EF Core
Write-Host ""
Write-Host "Dropping existing database..." -ForegroundColor Yellow
Push-Location $BackendPath

try {
    dotnet ef database drop --force 2>&1 | Out-Null
    Write-Host "  Database dropped" -ForegroundColor Green
}
catch {
    Write-Host "  Database did not exist or could not be dropped" -ForegroundColor Gray
}

# Apply migrations
Write-Host ""
Write-Host "Applying migrations..." -ForegroundColor Yellow
dotnet ef database update
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Migration failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  Migrations applied" -ForegroundColor Green

Pop-Location

# Seed data
if (-not $SkipSeed) {
    Write-Host ""
    Write-Host "Seeding sample data..." -ForegroundColor Yellow
    
    $seedFiles = @(
        "seeds/01_lookup_data.sql",
        "seeds/02_sample_services_dev.sql"
    )
    
    foreach ($seedFile in $seedFiles) {
        $seedPath = Join-Path $DatabasePath $seedFile
        if (Test-Path $seedPath) {
            Write-Host "  Running $seedFile..." -ForegroundColor Gray
            
            # Use sqlcmd or docker exec to run SQL
            $sqlContent = Get-Content $seedPath -Raw
            docker exec -i service-catalogue-manager-sqlserver-1 /opt/mssql-tools/bin/sqlcmd `
                -S localhost -U sa -P "YourStrong@Password123" `
                -d $DatabaseName -Q "$sqlContent" 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    Applied successfully" -ForegroundColor Green
            }
            else {
                Write-Host "    Warning: May have partial success" -ForegroundColor Yellow
            }
        }
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Database Reset Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Database: $DatabaseName" -ForegroundColor Cyan
Write-Host "Server:   localhost:1433" -ForegroundColor Cyan
Write-Host "User:     sa" -ForegroundColor Cyan
Write-Host ""
Write-Host "Connection String:" -ForegroundColor Gray
Write-Host $connectionString -ForegroundColor Gray
Write-Host ""
