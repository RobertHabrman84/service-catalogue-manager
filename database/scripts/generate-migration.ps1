<#
.SYNOPSIS
    Generates a new EF Core migration.
.DESCRIPTION
    Creates a new migration file with proper naming convention.
.PARAMETER Name
    Migration name (e.g., "AddNewFeature")
.PARAMETER Description
    Brief description for the migration
.PARAMETER GenerateSql
    Also generate SQL script
.EXAMPLE
    .\generate-migration.ps1 -Name "AddUserPreferences"
    .\generate-migration.ps1 -Name "AddAuditLog" -GenerateSql
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$Description = "",
    [switch]$GenerateSql
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$BackendPath = Join-Path $ProjectRoot "src/backend/ServiceCatalogueManager.Api"
$MigrationsPath = Join-Path $ProjectRoot "database/migrations"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Generate Migration: $Name" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Validate name
if ($Name -notmatch '^[A-Za-z][A-Za-z0-9]*$') {
    Write-Host "Error: Migration name must be alphanumeric and start with a letter" -ForegroundColor Red
    exit 1
}

Push-Location $BackendPath

# Get current version
Write-Host "Checking existing migrations..." -ForegroundColor Yellow
$existingMigrations = Get-ChildItem -Path $MigrationsPath -Filter "V*.sql" | Sort-Object Name -Descending
$lastMigration = $existingMigrations | Select-Object -First 1

if ($lastMigration) {
    $versionMatch = $lastMigration.Name -match 'V(\d+)\.(\d+)\.(\d+)'
    if ($versionMatch) {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        $patch = [int]$Matches[3] + 1
    }
    else {
        $major = 1; $minor = 0; $patch = 0
    }
}
else {
    $major = 1; $minor = 0; $patch = 0
}

$newVersion = "V$major.$minor.$patch"
$migrationFileName = "${newVersion}__${Name}.sql"

Write-Host "  Last version: $($lastMigration.Name)" -ForegroundColor Gray
Write-Host "  New version: $migrationFileName" -ForegroundColor Green
Write-Host ""

# Generate EF Core migration
Write-Host "Generating EF Core migration..." -ForegroundColor Yellow
dotnet ef migrations add $Name

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to generate migration!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "  ✓ EF Core migration created" -ForegroundColor Green

# Generate SQL script if requested
if ($GenerateSql) {
    Write-Host ""
    Write-Host "Generating SQL script..." -ForegroundColor Yellow
    
    $sqlPath = Join-Path $MigrationsPath $migrationFileName
    
    # Get previous migration name
    $previousMigration = dotnet ef migrations list --json 2>$null | ConvertFrom-Json | Select-Object -Last 2 | Select-Object -First 1
    
    if ($previousMigration) {
        dotnet ef migrations script $previousMigration.Name $Name -o $sqlPath
    }
    else {
        dotnet ef migrations script -o $sqlPath
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ SQL script created: $migrationFileName" -ForegroundColor Green
        
        # Add header to SQL file
        $sqlContent = Get-Content $sqlPath -Raw
        $header = @"
-- =============================================================================
-- SERVICE CATALOGUE MANAGER - MIGRATION
-- File: $migrationFileName
-- Description: $Description
-- Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
-- =============================================================================

"@
        Set-Content -Path $sqlPath -Value ($header + $sqlContent)
    }
}

Pop-Location

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Migration Generated!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Migration: $Name" -ForegroundColor Cyan
Write-Host "Version: $newVersion" -ForegroundColor Cyan
if ($GenerateSql) {
    Write-Host "SQL File: $migrationFileName" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the generated migration" -ForegroundColor Gray
Write-Host "  2. Test locally: dotnet ef database update" -ForegroundColor Gray
Write-Host "  3. Commit changes" -ForegroundColor Gray
Write-Host ""
