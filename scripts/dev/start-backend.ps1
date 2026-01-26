<#
.SYNOPSIS
    Starts the backend Azure Functions locally.
.DESCRIPTION
    Launches the Azure Functions Core Tools to run the backend API locally.
.PARAMETER Port
    Port number for the Functions host (default: 7071)
.PARAMETER EnableCors
    Enable CORS for local development
.PARAMETER Verbose
    Enable verbose logging
.EXAMPLE
    .\start-backend.ps1
    .\start-backend.ps1 -Port 7072 -Verbose
#>

param(
    [int]$Port = 7071,
    [switch]$EnableCors,
    [switch]$VerboseLogging
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$BackendPath = Join-Path $ProjectRoot "src/backend/ServiceCatalogueManager.Api"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Backend (Azure Functions)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if backend directory exists
if (-not (Test-Path $BackendPath)) {
    Write-Host "Error: Backend directory not found at $BackendPath" -ForegroundColor Red
    exit 1
}

# Change to backend directory
Push-Location $BackendPath

# Check for local.settings.json
if (-not (Test-Path "local.settings.json")) {
    if (Test-Path "local.settings.example.json") {
        Write-Host "Creating local.settings.json from template..." -ForegroundColor Yellow
        Copy-Item "local.settings.example.json" "local.settings.json"
    }
    else {
        Write-Host "Error: local.settings.json not found" -ForegroundColor Red
        Pop-Location
        exit 1
    }
}

# Check for Azure Functions Core Tools
Write-Host "Checking Azure Functions Core Tools..." -ForegroundColor Gray
try {
    $funcVersion = func --version
    Write-Host "  Version: $funcVersion" -ForegroundColor Green
}
catch {
    Write-Host "Error: Azure Functions Core Tools not installed" -ForegroundColor Red
    Write-Host "Install with: npm install -g azure-functions-core-tools@4" -ForegroundColor Yellow
    Pop-Location
    exit 1
}

# Restore and build
Write-Host "Building project..." -ForegroundColor Gray
dotnet build --configuration Debug --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "Build successful" -ForegroundColor Green

# Build command arguments
$funcArgs = @("start", "--port", $Port)
if ($EnableCors) {
    $funcArgs += "--cors", "*"
}
if ($VerboseLogging) {
    $funcArgs += "--verbose"
}

Write-Host ""
Write-Host "Starting Azure Functions host..." -ForegroundColor Green
Write-Host "  URL: http://localhost:${Port}" -ForegroundColor Cyan
Write-Host "  Health: http://localhost:${Port}/api/health" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

try {
    func @funcArgs
}
finally {
    Pop-Location
}
