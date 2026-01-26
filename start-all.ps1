#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - START ALL
# ============================================================================
# Version: 3.3.0
# Description: Starts Docker DB, builds and runs backend and frontend
# Based on: START-ALL-V14.ps1 (working version)
# ============================================================================

param(
    [switch]$SkipBuild = $false,
    [switch]$SkipFrontend = $false,
    [switch]$SkipBackend = $false,
    [switch]$SkipDb = $false,
    [switch]$CleanBuild = $false,
    [switch]$BackendOnly = $false,
    [switch]$FrontendOnly = $false,
    [switch]$DbOnly = $false,
    [switch]$RecreateDb = $false,
    [switch]$SeedData = $false,
    [switch]$Help = $false
)

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# ============================================================================
# CONFIGURATION
# ============================================================================

$SCRIPT_DIR = $PSScriptRoot
$BACKEND_DIR = Join-Path $SCRIPT_DIR "src\backend\ServiceCatalogueManager.Api"
$FRONTEND_DIR = Join-Path $SCRIPT_DIR "src\frontend"
$DB_SETUP_SCRIPT = Join-Path $SCRIPT_DIR "database\scripts\setup-db.ps1"
$DB_MIGRATION_SCRIPT = Join-Path $SCRIPT_DIR "database\scripts\run-migrations.ps1"

$BACKEND_PORT = 7071
$FRONTEND_PORT = 3000
$DB_PORT = 1433
$DB_CONTAINER = "scm-sqlserver"
$SA_PASSWORD = "YourStrong@Passw0rd"
$DB_NAME = "ServiceCatalogueManager"

# Colors
$COLOR_SUCCESS = "Green"
$COLOR_INFO = "Cyan"
$COLOR_WARNING = "Yellow"
$COLOR_ERROR = "Red"
$COLOR_HEADER = "Magenta"

# ============================================================================
# FUNCTIONS
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor $COLOR_HEADER
    Write-Host " $Message" -ForegroundColor $COLOR_HEADER
    Write-Host ("=" * 80) -ForegroundColor $COLOR_HEADER
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $COLOR_SUCCESS
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $COLOR_INFO
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $COLOR_WARNING
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $COLOR_ERROR
}

function Show-Help {
    Write-Header "SERVICE CATALOGUE MANAGER - START SCRIPT v3.0.0"
    
    Write-Host "USAGE:" -ForegroundColor $COLOR_INFO
    Write-Host "  .\start-all.ps1 [OPTIONS]"
    Write-Host ""
    
    Write-Host "OPTIONS:" -ForegroundColor $COLOR_INFO
    Write-Host "  -DbOnly           Start only the database"
    Write-Host "  -BackendOnly      Start database + backend API"
    Write-Host "  -FrontendOnly     Start only the frontend"
    Write-Host "  -SkipDb           Skip database startup"
    Write-Host "  -SkipBuild        Skip the build step"
    Write-Host "  -CleanBuild       Clean before building"
    Write-Host "  -RecreateDb       Recreate database (drops existing)"
    Write-Host "  -SeedData         Seed database with sample data"
    Write-Host "  -Help             Show this help message"
    Write-Host ""
    
    Write-Host "EXAMPLES:" -ForegroundColor $COLOR_INFO
    Write-Host "  .\start-all.ps1                    # Start DB + Backend + Frontend"
    Write-Host "  .\start-all.ps1 -DbOnly            # Start only database"
    Write-Host "  .\start-all.ps1 -BackendOnly       # Start DB + Backend"
    Write-Host "  .\start-all.ps1 -RecreateDb        # Recreate DB from scratch"
    Write-Host ""
    
    Write-Host "ENDPOINTS:" -ForegroundColor $COLOR_INFO
    Write-Host "  Database:     Server=localhost,1433;Database=$DB_NAME"
    Write-Host "  Backend API:  http://localhost:$BACKEND_PORT/api"
    Write-Host "  Frontend:     http://localhost:$FRONTEND_PORT"
    Write-Host ""
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-DockerRunning {
    try {
        docker info 2>&1 | Out-Null
        return $?
    } catch {
        return $false
    }
}

function Start-Database {
    Write-Header "STARTING DATABASE"
    
    # Check Docker
    if (-not (Test-Command "docker")) {
        Write-ErrorMessage "Docker is not installed!"
        Write-Warning "Please install Docker Desktop: https://www.docker.com/products/docker-desktop"
        exit 1
    }
    
    if (-not (Test-DockerRunning)) {
        Write-ErrorMessage "Docker is not running!"
        Write-Warning "Please start Docker Desktop"
        exit 1
    }
    
    Write-Success "Docker is available"
    
    # Check if container exists and is running
    try {
        $container = docker ps --filter "name=$DB_CONTAINER" --format "{{.Names}}" 2>$null
        if ($container -eq $DB_CONTAINER) {
            Write-Info "SQL Server container is already running"
            Write-Success "Database: localhost,$DB_PORT"
            return
        }
    } catch {}
    
    # Stop and remove old container if exists
    Write-Info "Preparing fresh SQL Server container..."
    docker stop $DB_CONTAINER 2>$null | Out-Null
    docker rm $DB_CONTAINER 2>$null | Out-Null
    
    # Start new container
    Write-Info "Starting SQL Server 2022..."
    docker run -d `
        --name $DB_CONTAINER `
        -e "ACCEPT_EULA=Y" `
        -e "SA_PASSWORD=$SA_PASSWORD" `
        -e "MSSQL_PID=Developer" `
        -p "${DB_PORT}:1433" `
        mcr.microsoft.com/mssql/server:2022-latest | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Failed to start SQL Server container"
        exit 1
    }
    
    Write-Success "SQL Server container started"
    Write-Info "Waiting 15 seconds for SQL Server initialization..."
    Start-Sleep -Seconds 15
    
    # Create/Reset database
    Write-Info "Setting up database..."
    
    $resetDbScript = @"
IF EXISTS (SELECT name FROM sys.databases WHERE name = '$DB_NAME')
BEGIN
    ALTER DATABASE $DB_NAME SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE $DB_NAME;
END

CREATE DATABASE $DB_NAME;
GO
"@
    
    try {
        docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd `
            -S localhost -U sa -P $SA_PASSWORD `
            -C -Q $resetDbScript 2>$null | Out-Null
        Write-Success "Database created: $DB_NAME"
    } catch {
        Write-Warning "Database setup had issues (may be OK)"
    }
    
    # Run migrations if script exists
    if (Test-Path $DB_MIGRATION_SCRIPT) {
        Write-Info "Running database migrations..."
        try {
            & $DB_MIGRATION_SCRIPT -Environment "Development" 2>&1 | Out-Null
            Write-Success "Database migrations completed"

    # Seed database if requested
    if ($SeedData) {
        Write-Host ""
        Write-Info "Seeding database with sample data..."
        $seedScript = Join-Path $SCRIPT_DIR "database\scripts\seed-database.ps1"
        
        if (Test-Path $seedScript) {
            try {
                & $seedScript
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Database seeded successfully"
                } else {
                    Write-Warning "Seed script completed with warnings"
                }
            } catch {
                Write-Warning "Seed script encountered errors: $_"
            }
        } else {
            Write-Warning "Seed script not found: $seedScript"
        }
    }
        } catch {
            Write-Warning "Migration script encountered issues"
        }
    }
    
    Write-Host ""
    Write-Success "Database is ready!"
    Write-Info "Connection: Server=localhost,$DB_PORT;Database=$DB_NAME;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
}

function Test-Prerequisites {
    Write-Header "CHECKING PREREQUISITES"
    
    # .NET SDK
    Write-Info "Checking .NET SDK..."
    if (Test-Command "dotnet") {
        $dotnetVersion = dotnet --version
        Write-Success ".NET SDK v$dotnetVersion"
    } else {
        Write-ErrorMessage ".NET SDK not found!"
        Write-Warning "Install from: https://dotnet.microsoft.com/download"
        exit 1
    }
    
    # Azure Functions Core Tools
    Write-Info "Checking Azure Functions Core Tools..."
    if (Test-Command "func") {
        $funcVersion = func --version
        Write-Success "Azure Functions Core Tools v$funcVersion"
    } else {
        Write-ErrorMessage "Azure Functions Core Tools not found!"
        Write-Warning "Install from: https://docs.microsoft.com/azure/azure-functions/functions-run-local"
        exit 1
    }
    
    # Node.js
    if (-not $BackendOnly -and -not $DbOnly) {
        Write-Info "Checking Node.js..."
        if (Test-Command "node") {
            $nodeVersion = node --version
            Write-Success "Node.js $nodeVersion"
        } else {
            Write-ErrorMessage "Node.js not found!"
            Write-Warning "Install from: https://nodejs.org/"
            exit 1
        }
    }
    
    Write-Success "All required prerequisites satisfied!"
}

function Build-Backend {
    Write-Header "BUILDING BACKEND API"
    
    Push-Location $BACKEND_DIR
    
    try {
        if ($CleanBuild) {
            Write-Info "Cleaning previous build..."
            dotnet clean --configuration Release --nologo -v q
            Write-Success "Clean complete"
        }
        
        Write-Info "Restoring NuGet packages..."
        dotnet restore --nologo -v q
        Write-Success "Packages restored"
        
        Write-Info "Building backend..."
        dotnet build --configuration Release --no-restore --nologo -v q
        
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Backend build failed!"
            exit 1
        }
        
        Write-Success "Backend built successfully"
    } finally {
        Pop-Location
    }
}

function Build-Frontend {
    Write-Header "BUILDING FRONTEND"
    
    Push-Location $FRONTEND_DIR
    
    try {
        # Check for node_modules
        if (-not (Test-Path "node_modules")) {
            Write-Info "Installing dependencies..."
            npm install --silent
            Write-Success "Dependencies installed"
        } else {
            Write-Info "Dependencies already installed"
        }
        
        if ($CleanBuild) {
            Write-Info "Cleaning previous build..."
            if (Test-Path ".next") {
                Remove-Item -Recurse -Force ".next"
            }
            Write-Success "Clean complete"
        }
        
        Write-Success "Frontend ready"
    } finally {
        Pop-Location
    }
}

function Start-Backend {
    Write-Header "STARTING BACKEND API"
    
    Push-Location $BACKEND_DIR
    
    try {
        Write-Info "Starting Azure Functions..."
        Write-Info "Backend will be available at: http://localhost:$BACKEND_PORT"
        Write-Info "Press Ctrl+C to stop"
        Write-Host ""
        
        func start --port $BACKEND_PORT
    } finally {
        Pop-Location
    }
}

function Start-Frontend {
    Write-Header "STARTING FRONTEND"
    
    Push-Location $FRONTEND_DIR
    
    try {
        Write-Info "Starting Vite development server..."
        Write-Info "Frontend will be available at: http://localhost:$FRONTEND_PORT"
        Write-Info "Press Ctrl+C to stop"
        Write-Host ""
        
        $env:PORT = $FRONTEND_PORT
        # Use npx to ensure vite is found in node_modules/.bin/
        npx vite
    } finally {
        Pop-Location
    }
}

function Start-All {
    Write-Header "STARTING ALL SERVICES"
    
    Write-Info "Starting services in parallel..."
    
    # Start backend in background
    $backendJob = Start-Job -ScriptBlock {
        param($dir, $port)
        Set-Location $dir
        func start --port $port
    } -ArgumentList $BACKEND_DIR, $BACKEND_PORT
    
    Write-Success "Backend starting (Job ID: $($backendJob.Id))"
    
    # Wait a bit for backend to start
    Start-Sleep -Seconds 3
    
    # Start frontend in foreground
    Push-Location $FRONTEND_DIR
    try {
        Write-Info "Starting frontend..."
        Write-Host ""
        $env:PORT = $FRONTEND_PORT
        # Use npx to ensure vite is found in node_modules/.bin/
        npx vite
    } finally {
        Pop-Location
        Stop-Job $backendJob -ErrorAction SilentlyContinue
        Remove-Job $backendJob -ErrorAction SilentlyContinue
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

try {
    if ($Help) {
        Show-Help
        exit 0
    }
    
    Write-Header "SERVICE CATALOGUE MANAGER v3.3.0"
    
    # Handle mode flags
    if ($DbOnly) {
        Test-Prerequisites
        Start-Database
        Write-Host ""
        Write-Success "Database is running!"
        Write-Info "Connection String:"
        Write-Host "Server=localhost,$DB_PORT;Database=$DB_NAME;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
        Write-Host ""
        Write-Info "Connect with:"
        Write-Host "docker exec -it $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $DB_NAME" -ForegroundColor White
        exit 0
    }
    
    if ($FrontendOnly) {
        $SkipDb = $true
        $SkipBackend = $true
    }
    
    if ($BackendOnly) {
        $SkipFrontend = $true
    }
    
    # Check prerequisites
    Test-Prerequisites
    
    # Start database
    if (-not $SkipDb -and -not $FrontendOnly) {
        Start-Database
    }
    
    # Build phase
    if (-not $SkipBuild) {
        if (-not $SkipBackend -and -not $FrontendOnly) {
            Build-Backend
        }
        
        if (-not $SkipFrontend -and -not $BackendOnly) {
            Build-Frontend
        }
    }
    
    # Start phase
    Write-Host ""
    Write-Info "All services ready to start!"
    Write-Host ""
    
    if ($BackendOnly) {
        Start-Backend
    } elseif ($FrontendOnly) {
        Start-Frontend
    } else {
        Start-All
    }
    
} catch {
    Write-Host ""
    Write-ErrorMessage "An error occurred: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
