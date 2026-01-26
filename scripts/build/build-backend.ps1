<#
.SYNOPSIS
    Builds the backend Azure Functions application.
.DESCRIPTION
    Builds and publishes the .NET backend for deployment.
.PARAMETER Configuration
    Build configuration (default: Release)
.PARAMETER OutputPath
    Output directory for the build
.PARAMETER Runtime
    Target runtime identifier (default: win-x64)
.PARAMETER SelfContained
    Create self-contained deployment
.EXAMPLE
    .\build-backend.ps1
    .\build-backend.ps1 -Configuration Debug
    .\build-backend.ps1 -Runtime linux-x64
#>

param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    [string]$OutputPath = "",
    [string]$Runtime = "win-x64",
    [switch]$SelfContained
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$BackendPath = Join-Path $ProjectRoot "src/backend/ServiceCatalogueManager.Api"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building Backend for $Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check backend directory
if (-not (Test-Path $BackendPath)) {
    Write-Host "Error: Backend directory not found" -ForegroundColor Red
    exit 1
}

# Set output path
if ([string]::IsNullOrEmpty($OutputPath)) {
    $OutputPath = Join-Path $ProjectRoot "artifacts/backend"
}

# Clean previous build
if (Test-Path $OutputPath) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $OutputPath
}

Push-Location $BackendPath

# Restore packages
Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Restore failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  Packages restored" -ForegroundColor Green

# Build
Write-Host ""
Write-Host "Building project..." -ForegroundColor Yellow
dotnet build --configuration $Configuration --no-restore --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  Build successful" -ForegroundColor Green

# Run tests
Write-Host ""
Write-Host "Running unit tests..." -ForegroundColor Yellow
$testsPath = Join-Path $ProjectRoot "src/backend/ServiceCatalogueManager.Api.Tests"
if (Test-Path $testsPath) {
    dotnet test $testsPath --configuration $Configuration --no-build --verbosity quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Tests failed!" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Write-Host "  Tests passed" -ForegroundColor Green
}
else {
    Write-Host "  No test project found" -ForegroundColor Gray
}

# Publish
Write-Host ""
Write-Host "Publishing application..." -ForegroundColor Yellow

$publishArgs = @(
    "publish",
    "--configuration", $Configuration,
    "--output", $OutputPath,
    "--runtime", $Runtime,
    "--no-build"
)

if ($SelfContained) {
    $publishArgs += "--self-contained", "true"
}
else {
    $publishArgs += "--self-contained", "false"
}

dotnet @publishArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Publish failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# Build summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration: $Configuration" -ForegroundColor Cyan
Write-Host "Runtime:       $Runtime" -ForegroundColor Cyan
Write-Host "Self-Contained: $SelfContained" -ForegroundColor Cyan
Write-Host "Output:        $OutputPath" -ForegroundColor Cyan
Write-Host ""

# Output size
$outputSize = (Get-ChildItem -Path $OutputPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
Write-Host "Output Size: $([math]::Round($outputSize / 1MB, 2)) MB" -ForegroundColor White
Write-Host ""
