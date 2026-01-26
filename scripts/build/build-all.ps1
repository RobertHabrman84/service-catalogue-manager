<#
.SYNOPSIS
    Builds all components of the Service Catalogue Manager.
.DESCRIPTION
    Builds frontend, backend, and creates deployment artifacts.
.PARAMETER Configuration
    Build configuration (default: Release)
.PARAMETER OutputPath
    Base output directory for artifacts
.PARAMETER SkipFrontend
    Skip frontend build
.PARAMETER SkipBackend
    Skip backend build
.PARAMETER CreateZip
    Create ZIP archives of builds
.EXAMPLE
    .\build-all.ps1
    .\build-all.ps1 -Configuration Debug
    .\build-all.ps1 -CreateZip
#>

param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    [string]$OutputPath = "",
    [switch]$SkipFrontend,
    [switch]$SkipBackend,
    [switch]$CreateZip
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)

# Set output path
if ([string]::IsNullOrEmpty($OutputPath)) {
    $OutputPath = Join-Path $ProjectRoot "artifacts"
}

$startTime = Get-Date

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Service Catalogue Manager" -ForegroundColor Cyan
Write-Host "  Full Build - $Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output: $OutputPath" -ForegroundColor Gray
Write-Host ""

# Clean artifacts directory
if (Test-Path $OutputPath) {
    Write-Host "Cleaning artifacts directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $OutputPath
}
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

$results = @{
    Frontend = @{ Status = "Skipped"; Duration = 0 }
    Backend = @{ Status = "Skipped"; Duration = 0 }
}

# Build Frontend
if (-not $SkipFrontend) {
    Write-Host ""
    Write-Host "┌─────────────────────────────────────┐" -ForegroundColor Blue
    Write-Host "│  Building Frontend                  │" -ForegroundColor Blue
    Write-Host "└─────────────────────────────────────┘" -ForegroundColor Blue
    
    $frontendStart = Get-Date
    $frontendOutput = Join-Path $OutputPath "frontend"
    
    try {
        & "$ScriptRoot/build-frontend.ps1" -OutputPath "dist"
        
        # Copy to artifacts
        $frontendDist = Join-Path $ProjectRoot "src/frontend/dist"
        if (Test-Path $frontendDist) {
            Copy-Item -Path $frontendDist -Destination $frontendOutput -Recurse
        }
        
        $results.Frontend.Status = "Success"
    }
    catch {
        $results.Frontend.Status = "Failed"
        Write-Host "Frontend build failed: $_" -ForegroundColor Red
    }
    
    $results.Frontend.Duration = ((Get-Date) - $frontendStart).TotalSeconds
}

# Build Backend
if (-not $SkipBackend) {
    Write-Host ""
    Write-Host "┌─────────────────────────────────────┐" -ForegroundColor Blue
    Write-Host "│  Building Backend                   │" -ForegroundColor Blue
    Write-Host "└─────────────────────────────────────┘" -ForegroundColor Blue
    
    $backendStart = Get-Date
    $backendOutput = Join-Path $OutputPath "backend"
    
    try {
        & "$ScriptRoot/build-backend.ps1" -Configuration $Configuration -OutputPath $backendOutput
        $results.Backend.Status = "Success"
    }
    catch {
        $results.Backend.Status = "Failed"
        Write-Host "Backend build failed: $_" -ForegroundColor Red
    }
    
    $results.Backend.Duration = ((Get-Date) - $backendStart).TotalSeconds
}

# Create ZIP archives
if ($CreateZip) {
    Write-Host ""
    Write-Host "Creating ZIP archives..." -ForegroundColor Yellow
    
    $frontendOutput = Join-Path $OutputPath "frontend"
    $backendOutput = Join-Path $OutputPath "backend"
    
    if (Test-Path $frontendOutput) {
        $frontendZip = Join-Path $OutputPath "frontend.zip"
        Compress-Archive -Path "$frontendOutput/*" -DestinationPath $frontendZip -Force
        Write-Host "  Created: frontend.zip" -ForegroundColor Green
    }
    
    if (Test-Path $backendOutput) {
        $backendZip = Join-Path $OutputPath "backend.zip"
        Compress-Archive -Path "$backendOutput/*" -DestinationPath $backendZip -Force
        Write-Host "  Created: backend.zip" -ForegroundColor Green
    }
}

# Build summary
$totalDuration = ((Get-Date) - $startTime).TotalSeconds

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$tableFormat = "{0,-15} {1,-10} {2,10}"
Write-Host ($tableFormat -f "Component", "Status", "Duration") -ForegroundColor Cyan
Write-Host ("-" * 40) -ForegroundColor Gray

foreach ($component in @("Frontend", "Backend")) {
    $result = $results[$component]
    $statusColor = switch ($result.Status) {
        "Success" { "Green" }
        "Failed" { "Red" }
        default { "Gray" }
    }
    $duration = if ($result.Duration -gt 0) { "$([math]::Round($result.Duration, 1))s" } else { "-" }
    
    Write-Host ($tableFormat -f $component, $result.Status, $duration) -ForegroundColor $statusColor
}

Write-Host ("-" * 40) -ForegroundColor Gray
Write-Host ($tableFormat -f "Total", "", "$([math]::Round($totalDuration, 1))s") -ForegroundColor Cyan

# Output location
Write-Host ""
Write-Host "Artifacts: $OutputPath" -ForegroundColor Cyan

# List artifacts
Write-Host ""
Write-Host "Files:" -ForegroundColor Yellow
Get-ChildItem -Path $OutputPath -Recurse -File | 
    Select-Object -First 20 | 
    ForEach-Object {
        $relativePath = $_.FullName.Replace($OutputPath, "").TrimStart("\", "/")
        $size = [math]::Round($_.Length / 1KB, 1)
        Write-Host "  $relativePath ($size KB)" -ForegroundColor Gray
    }

# Check for failures
$failed = $results.Values | Where-Object { $_.Status -eq "Failed" }
if ($failed) {
    Write-Host ""
    Write-Host "Build completed with errors!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host ""
