<#
.SYNOPSIS
    Starts the frontend development server.
.DESCRIPTION
    Launches the Vite development server for the React frontend application.
.PARAMETER Port
    Port number for the dev server (default: 5173)
.PARAMETER Host
    Host to bind to (default: localhost)
.PARAMETER Open
    Open browser automatically
.EXAMPLE
    .\start-frontend.ps1
    .\start-frontend.ps1 -Port 3000 -Open
#>

param(
    [int]$Port = 5173,
    [string]$Host = "localhost",
    [switch]$Open
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$FrontendPath = Join-Path $ProjectRoot "src/frontend"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Frontend Dev Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if frontend directory exists
if (-not (Test-Path $FrontendPath)) {
    Write-Host "Error: Frontend directory not found at $FrontendPath" -ForegroundColor Red
    exit 1
}

# Change to frontend directory
Push-Location $FrontendPath

# Check for node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm ci
}

# Check for .env.local
if (-not (Test-Path ".env.local")) {
    if (Test-Path ".env.example") {
        Write-Host "Creating .env.local from template..." -ForegroundColor Yellow
        Copy-Item ".env.example" ".env.local"
    }
    else {
        Write-Host "Warning: No .env.local file found" -ForegroundColor Yellow
    }
}

# Build command arguments
$npmArgs = @("run", "dev", "--", "--port", $Port, "--host", $Host)
if ($Open) {
    $npmArgs += "--open"
}

Write-Host "Starting Vite dev server..." -ForegroundColor Green
Write-Host "  URL: http://${Host}:${Port}" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

try {
    npm @npmArgs
}
finally {
    Pop-Location
}
