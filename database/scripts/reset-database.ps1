<#
.SYNOPSIS
    Resets the database to a clean state.
.DESCRIPTION
    Drops all data, re-runs migrations, and optionally seeds the database.
.PARAMETER Environment
    Target environment
.PARAMETER SkipSeed
    Skip seeding after reset
.PARAMETER SkipConfirmation
    Skip confirmation prompt
.PARAMETER DatabaseName
    Database name to reset
.EXAMPLE
    .\reset-database.ps1 -Environment Development
    .\reset-database.ps1 -SkipConfirmation
#>

param(
    [ValidateSet("Development", "Test")]
    [string]$Environment = "Development",
    [switch]$SkipSeed,
    [switch]$SkipConfirmation,
    [string]$DatabaseName = "ServiceCatalogueDb"
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Database Reset - $Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Safety check - never reset production
if ($Environment -eq "Production" -or $Environment -eq "Staging") {
    Write-Host "ERROR: Cannot reset $Environment database!" -ForegroundColor Red
    exit 1
}

# Confirmation
if (-not $SkipConfirmation) {
    Write-Host "WARNING: This will DELETE ALL DATA in '$DatabaseName'!" -ForegroundColor Red
    $confirm = Read-Host "Type 'yes' to continue"
    if ($confirm -ne "yes") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "Step 1: Dropping database..." -ForegroundColor Yellow

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$BackendPath = Join-Path $ProjectRoot "src/backend/ServiceCatalogueManager.Api"

Push-Location $BackendPath

try {
    dotnet ef database drop --force 2>&1 | Out-Null
    Write-Host "  ✓ Database dropped" -ForegroundColor Green
}
catch {
    Write-Host "  Database did not exist" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Step 2: Running migrations..." -ForegroundColor Yellow

dotnet ef database update
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Migrations applied" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Migration failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# Seed database
if (-not $SkipSeed) {
    Write-Host ""
    Write-Host "Step 3: Seeding database..." -ForegroundColor Yellow
    
    & "$ScriptRoot/seed-database.ps1" -Environment $Environment
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Database Reset Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Database: $DatabaseName" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "Seeded: $(-not $SkipSeed)" -ForegroundColor Cyan
Write-Host ""
