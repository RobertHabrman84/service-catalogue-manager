<#
.SYNOPSIS
    Builds the frontend application for production.
.DESCRIPTION
    Runs the Vite production build for the React frontend.
.PARAMETER OutputPath
    Output directory for the build (default: dist)
.PARAMETER Analyze
    Run bundle analyzer after build
.PARAMETER SourceMaps
    Generate source maps (default: false for production)
.EXAMPLE
    .\build-frontend.ps1
    .\build-frontend.ps1 -Analyze
    .\build-frontend.ps1 -OutputPath "./build"
#>

param(
    [string]$OutputPath = "dist",
    [switch]$Analyze,
    [switch]$SourceMaps
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$FrontendPath = Join-Path $ProjectRoot "src/frontend"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building Frontend for Production" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check frontend directory
if (-not (Test-Path $FrontendPath)) {
    Write-Host "Error: Frontend directory not found" -ForegroundColor Red
    exit 1
}

Push-Location $FrontendPath

# Clean previous build
$distPath = Join-Path $FrontendPath $OutputPath
if (Test-Path $distPath) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $distPath
}

# Check node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm ci
}

# Set environment
$env:NODE_ENV = "production"
if ($SourceMaps) {
    $env:VITE_BUILD_SOURCEMAPS = "true"
}

# Type checking
Write-Host ""
Write-Host "Running TypeScript type check..." -ForegroundColor Yellow
npm run type-check
if ($LASTEXITCODE -ne 0) {
    Write-Host "Type check failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  Type check passed" -ForegroundColor Green

# Linting
Write-Host ""
Write-Host "Running ESLint..." -ForegroundColor Yellow
npm run lint
if ($LASTEXITCODE -ne 0) {
    Write-Host "Linting failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  Linting passed" -ForegroundColor Green

# Build
Write-Host ""
Write-Host "Building production bundle..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Bundle analysis
if ($Analyze) {
    Write-Host ""
    Write-Host "Running bundle analysis..." -ForegroundColor Yellow
    npx vite-bundle-visualizer
}

# Build info
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output: $distPath" -ForegroundColor Cyan

# Size report
Write-Host ""
Write-Host "Bundle Size:" -ForegroundColor Yellow
$files = Get-ChildItem -Path $distPath -Recurse -File
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum
Write-Host "  Total: $([math]::Round($totalSize / 1KB, 2)) KB" -ForegroundColor White

$jsFiles = $files | Where-Object { $_.Extension -eq ".js" }
$jsSize = ($jsFiles | Measure-Object -Property Length -Sum).Sum
Write-Host "  JS:    $([math]::Round($jsSize / 1KB, 2)) KB" -ForegroundColor Gray

$cssFiles = $files | Where-Object { $_.Extension -eq ".css" }
$cssSize = ($cssFiles | Measure-Object -Property Length -Sum).Sum
Write-Host "  CSS:   $([math]::Round($cssSize / 1KB, 2)) KB" -ForegroundColor Gray

Pop-Location
Write-Host ""
