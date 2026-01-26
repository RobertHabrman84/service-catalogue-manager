<#
.SYNOPSIS
    Generates TypeScript API client from OpenAPI specification.
.DESCRIPTION
    Uses OpenAPI Generator to create a TypeScript client for the backend API.
.PARAMETER ApiUrl
    URL of the running API (default: http://localhost:7071)
.PARAMETER OutputPath
    Output directory for generated client
.PARAMETER Generator
    OpenAPI generator to use (default: typescript-fetch)
.EXAMPLE
    .\generate-api-client.ps1
    .\generate-api-client.ps1 -ApiUrl "https://api.example.com"
#>

param(
    [string]$ApiUrl = "http://localhost:7071",
    [string]$OutputPath = "",
    [ValidateSet("typescript-fetch", "typescript-axios")]
    [string]$Generator = "typescript-fetch"
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)

# Set output path
if ([string]::IsNullOrEmpty($OutputPath)) {
    $OutputPath = Join-Path $ProjectRoot "src/frontend/src/api/generated"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Generate API Client" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API URL:    $ApiUrl" -ForegroundColor Gray
Write-Host "Output:     $OutputPath" -ForegroundColor Gray
Write-Host "Generator:  $Generator" -ForegroundColor Gray
Write-Host ""

# Check for OpenAPI Generator
Write-Host "Checking OpenAPI Generator..." -ForegroundColor Yellow
$hasNpx = $null -ne (Get-Command npx -ErrorAction SilentlyContinue)
$hasJava = $null -ne (Get-Command java -ErrorAction SilentlyContinue)

if (-not $hasNpx) {
    Write-Host "Error: npx not found. Please install Node.js" -ForegroundColor Red
    exit 1
}

# Fetch OpenAPI specification
$specUrl = "$ApiUrl/api/openapi.json"
$specPath = Join-Path $env:TEMP "openapi-spec.json"

Write-Host "Fetching OpenAPI specification..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $specUrl -OutFile $specPath -UseBasicParsing
    Write-Host "  Specification downloaded" -ForegroundColor Green
}
catch {
    Write-Host "  Warning: Could not fetch from API" -ForegroundColor Yellow
    
    # Try to use local spec file
    $localSpec = Join-Path $ProjectRoot "docs/api/openapi.json"
    if (Test-Path $localSpec) {
        Copy-Item $localSpec $specPath
        Write-Host "  Using local specification" -ForegroundColor Green
    }
    else {
        Write-Host "Error: No OpenAPI specification found" -ForegroundColor Red
        exit 1
    }
}

# Clean output directory
if (Test-Path $OutputPath) {
    Write-Host ""
    Write-Host "Cleaning previous generated code..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $OutputPath
}
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Generate client
Write-Host ""
Write-Host "Generating API client..." -ForegroundColor Yellow

$generatorArgs = @(
    "@openapitools/openapi-generator-cli",
    "generate",
    "-i", $specPath,
    "-g", $Generator,
    "-o", $OutputPath,
    "--additional-properties=supportsES6=true,typescriptThreePlus=true,withInterfaces=true"
)

npx @generatorArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "Generation failed!" -ForegroundColor Red
    exit 1
}

# Create index.ts barrel file
$indexPath = Join-Path $OutputPath "index.ts"
$indexContent = @"
// Auto-generated API client
// Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
// API URL: $ApiUrl

export * from './api';
export * from './configuration';
export * from './models';
"@
Set-Content -Path $indexPath -Value $indexContent

# Clean up temp file
Remove-Item -Path $specPath -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Generation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output: $OutputPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage in your code:" -ForegroundColor Yellow
Write-Host '  import { ServiceCatalogApi } from "@/api/generated";' -ForegroundColor Gray
Write-Host ""

# List generated files
Write-Host "Generated files:" -ForegroundColor Yellow
Get-ChildItem -Path $OutputPath -File | ForEach-Object {
    Write-Host "  $($_.Name)" -ForegroundColor Gray
}
Write-Host ""
