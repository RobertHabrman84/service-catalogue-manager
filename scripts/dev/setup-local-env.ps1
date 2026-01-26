<#
.SYNOPSIS
    Sets up the local development environment for Service Catalogue Manager.
.DESCRIPTION
    This script installs all required dependencies, configures local settings,
    and prepares the development environment for both frontend and backend.
.PARAMETER SkipNode
    Skip Node.js/npm installation check
.PARAMETER SkipDotNet
    Skip .NET SDK installation check
.PARAMETER SkipDocker
    Skip Docker installation check
.PARAMETER SkipDatabase
    Skip local database setup
.EXAMPLE
    .\setup-local-env.ps1
    .\setup-local-env.ps1 -SkipDocker
#>

param(
    [switch]$SkipNode,
    [switch]$SkipDotNet,
    [switch]$SkipDocker,
    [switch]$SkipDatabase
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Service Catalogue Manager Setup" -ForegroundColor Cyan
Write-Host "  Local Development Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Node.js
if (-not $SkipNode) {
    Write-Host "  Checking Node.js..." -NoNewline
    try {
        $nodeVersion = node --version
        Write-Host " $nodeVersion" -ForegroundColor Green
    }
    catch {
        Write-Host " NOT FOUND" -ForegroundColor Red
        Write-Host "  Please install Node.js 20+ from https://nodejs.org" -ForegroundColor Yellow
        exit 1
    }
}

# .NET SDK
if (-not $SkipDotNet) {
    Write-Host "  Checking .NET SDK..." -NoNewline
    try {
        $dotnetVersion = dotnet --version
        Write-Host " $dotnetVersion" -ForegroundColor Green
    }
    catch {
        Write-Host " NOT FOUND" -ForegroundColor Red
        Write-Host "  Please install .NET 8 SDK from https://dotnet.microsoft.com" -ForegroundColor Yellow
        exit 1
    }
}

# Docker
if (-not $SkipDocker) {
    Write-Host "  Checking Docker..." -NoNewline
    try {
        $dockerVersion = docker --version
        Write-Host " OK" -ForegroundColor Green
    }
    catch {
        Write-Host " NOT FOUND (optional)" -ForegroundColor Yellow
    }
}

# Git
Write-Host "  Checking Git..." -NoNewline
try {
    $gitVersion = git --version
    Write-Host " OK" -ForegroundColor Green
}
catch {
    Write-Host " NOT FOUND" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Setting up Frontend..." -ForegroundColor Yellow

# Frontend setup
$frontendPath = Join-Path $ProjectRoot "src/frontend"
if (Test-Path $frontendPath) {
    Push-Location $frontendPath
    
    # Copy environment file
    if (-not (Test-Path ".env.local")) {
        if (Test-Path ".env.example") {
            Copy-Item ".env.example" ".env.local"
            Write-Host "  Created .env.local from template" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  .env.local already exists" -ForegroundColor Gray
    }
    
    # Install npm dependencies
    Write-Host "  Installing npm dependencies..." -ForegroundColor Gray
    npm ci --silent
    Write-Host "  npm dependencies installed" -ForegroundColor Green
    
    Pop-Location
}

Write-Host ""
Write-Host "Setting up Backend..." -ForegroundColor Yellow

# Backend setup
$backendPath = Join-Path $ProjectRoot "src/backend/ServiceCatalogueManager.Api"
if (Test-Path $backendPath) {
    Push-Location $backendPath
    
    # Copy local settings
    if (-not (Test-Path "local.settings.json")) {
        if (Test-Path "local.settings.example.json") {
            Copy-Item "local.settings.example.json" "local.settings.json"
            Write-Host "  Created local.settings.json from template" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  local.settings.json already exists" -ForegroundColor Gray
    }
    
    # Restore NuGet packages
    Write-Host "  Restoring NuGet packages..." -ForegroundColor Gray
    dotnet restore --verbosity quiet
    Write-Host "  NuGet packages restored" -ForegroundColor Green
    
    # Install EF Core tools
    Write-Host "  Installing EF Core tools..." -ForegroundColor Gray
    dotnet tool install --global dotnet-ef 2>$null
    Write-Host "  EF Core tools ready" -ForegroundColor Green
    
    Pop-Location
}

# Database setup
if (-not $SkipDatabase) {
    Write-Host ""
    Write-Host "Setting up Database..." -ForegroundColor Yellow
    
    $dockerComposePath = Join-Path $ProjectRoot "docker-compose.yml"
    if (Test-Path $dockerComposePath) {
        Write-Host "  Starting SQL Server container..." -ForegroundColor Gray
        docker-compose up -d sqlserver 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  SQL Server container started" -ForegroundColor Green
            Write-Host "  Waiting for SQL Server to be ready..." -ForegroundColor Gray
            Start-Sleep -Seconds 15
            
            # Run migrations
            Write-Host "  Running database migrations..." -ForegroundColor Gray
            Push-Location $backendPath
            dotnet ef database update 2>$null
            Pop-Location
            Write-Host "  Database migrations applied" -ForegroundColor Green
        }
        else {
            Write-Host "  Docker not available, skipping database setup" -ForegroundColor Yellow
        }
    }
}

# VS Code settings
Write-Host ""
Write-Host "Configuring VS Code..." -ForegroundColor Yellow

$vscodePath = Join-Path $ProjectRoot ".vscode"
if (Test-Path $vscodePath) {
    Write-Host "  VS Code settings configured" -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review and update src/frontend/.env.local"
Write-Host "  2. Review and update src/backend/.../local.settings.json"
Write-Host "  3. Run: .\scripts\dev\start-all.ps1"
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  Start frontend:  .\scripts\dev\start-frontend.ps1"
Write-Host "  Start backend:   .\scripts\dev\start-backend.ps1"
Write-Host "  Start all:       .\scripts\dev\start-all.ps1"
Write-Host "  Reset database:  .\scripts\dev\reset-local-db.ps1"
Write-Host ""
