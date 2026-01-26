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
    
    $logFile = Join-Path $SCRIPT_DIR "logs\backend-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    $logsDir = Join-Path $SCRIPT_DIR "logs"
    
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
    
    Write-Info "Starting Azure Functions in new window..."
    Write-Info "Backend will be available at: http://localhost:$BACKEND_PORT"
    Write-Info "Logs: $logFile"
    Write-Host ""
    
    # Create startup script for backend
    # Find func.cmd location in parent process before creating script
    $funcCommand = $null
    $funcLocations = @(
        "$env:APPDATA\npm\func.cmd",
        "$env:ProgramFiles\nodejs\func.cmd",
        "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\Azure Functions Core Tools\func.cmd"
    )
    
    foreach ($loc in $funcLocations) {
        if (Test-Path $loc) {
            $funcCommand = $loc
            break
        }
    }
    
    if (-not $funcCommand) {
        # Try Get-Command as last resort
        $cmd = Get-Command func -ErrorAction SilentlyContinue
        if ($cmd) {
            $funcCommand = $cmd.Source
        } else {
            Write-Error "Azure Functions Core Tools (func) not found!"
            Write-Warning "Please install it: npm install -g azure-functions-core-tools@4"
            return
        }
    }
    
    Write-Info "func.cmd found at: $funcCommand"
    
    # Create backend startup script with absolute path to func
    $backendScript = @"
`$ErrorActionPreference = 'Continue'
`$Host.UI.RawUI.WindowTitle = 'Backend API - Port $BACKEND_PORT'

Set-Location '$BACKEND_DIR'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'BACKEND API STARTING' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'Port: $BACKEND_PORT' -ForegroundColor Yellow
Write-Host 'Directory: $BACKEND_DIR' -ForegroundColor Yellow
Write-Host 'Log File: $logFile' -ForegroundColor Yellow
Write-Host 'func Command: $funcCommand' -ForegroundColor Green
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

# Use absolute path to func.cmd
& '$funcCommand' start --port $BACKEND_PORT 2>&1 | Tee-Object -FilePath '$logFile'
"@
    
    $tempScript = Join-Path $env:TEMP "start-backend-$(Get-Date -Format 'yyyyMMddHHmmss').ps1"
    $backendScript | Out-File -FilePath $tempScript -Encoding UTF8
    
    Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $tempScript
    
    Write-Success "Backend started in new window"
}

function Start-Frontend {
    Write-Header "STARTING FRONTEND"
    
    # CRITICAL: Ensure dependencies are installed before starting
    Push-Location $FRONTEND_DIR
    try {
        if (-not (Test-Path "node_modules")) {
            Write-Warning "Frontend dependencies not found!"
            Write-Info "Installing dependencies (this may take a few minutes)..."
            npm install
            Write-Success "Dependencies installed"
        } elseif (-not (Test-Path "node_modules\vite")) {
            Write-Warning "Vite not found in node_modules!"
            Write-Info "Reinstalling dependencies..."
            npm install
            Write-Success "Dependencies reinstalled"
        } else {
            Write-Success "Frontend dependencies verified"
        }
    } finally {
        Pop-Location
    }
    
    $logFile = Join-Path $SCRIPT_DIR "logs\frontend-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    $logsDir = Join-Path $SCRIPT_DIR "logs"
    
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
    
    Write-Info "Starting Vite development server in new window..."
    Write-Info "Frontend will be available at: http://localhost:$FRONTEND_PORT"
    Write-Info "Logs: $logFile"
    Write-Host ""
    
    # Create startup script for frontend
    $frontendScript = @"
`$ErrorActionPreference = 'Continue'
`$Host.UI.RawUI.WindowTitle = 'Frontend - Port $FRONTEND_PORT'
`$env:PORT = '$FRONTEND_PORT'
Set-Location '$FRONTEND_DIR'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'FRONTEND STARTING' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'Port: $FRONTEND_PORT' -ForegroundColor Yellow
Write-Host 'Directory: $FRONTEND_DIR' -ForegroundColor Yellow
Write-Host 'Log File: $logFile' -ForegroundColor Yellow
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

# Double-check node_modules in the new window
if (-not (Test-Path 'node_modules')) {
    Write-Host 'ERROR: node_modules not found!' -ForegroundColor Red
    Write-Host 'Please run: npm install' -ForegroundColor Yellow
    Write-Host 'Press any key to exit...'
    `$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

# Clean Vite cache to avoid stale dependency optimization issues
Write-Host 'Cleaning Vite cache...' -ForegroundColor Yellow
if (Test-Path 'node_modules\.vite') {
    Remove-Item -Recurse -Force 'node_modules\.vite' -ErrorAction SilentlyContinue
    Write-Host 'Vite cache cleared' -ForegroundColor Green
}

# Use npm run dev which properly resolves vite from node_modules
npm run dev 2>&1 | Tee-Object -FilePath '$logFile'
"@
    
    $tempScript = Join-Path $env:TEMP "start-frontend-$(Get-Date -Format 'yyyyMMddHHmmss').ps1"
    $frontendScript | Out-File -FilePath $tempScript -Encoding UTF8
    
    Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $tempScript
    
    Write-Success "Frontend started in new window"
}

function Wait-ForBackend {
    param(
        [int]$Port = 7071,
        [int]$TimeoutSeconds = 120,
        [int]$RetryIntervalSeconds = 2
    )
    
    Write-Info "Waiting for backend to be ready on http://localhost:$Port..."
    
    $startTime = Get-Date
    $timeout = (Get-Date).AddSeconds($TimeoutSeconds)
    $attempt = 0
    $endpoints = @("/", "/api")
    
    while ((Get-Date) -lt $timeout) {
        $attempt++
        
        foreach ($endpoint in $endpoints) {
            try {
                $uri = "http://localhost:$Port$endpoint"
                $response = Invoke-WebRequest -Uri $uri -Method GET -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
                
                # Accept any response (200, 404, etc.) - it means the server is listening
                $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
                Write-Success "Backend is ready! ($uri responded with $($response.StatusCode), took $elapsed seconds, $attempt attempts)"
                return $true
            } catch [System.Net.WebException] {
                # Try to parse the exception
                if ($_.Exception.Response) {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                    if ($statusCode -ge 200 -and $statusCode -lt 600) {
                        # Any HTTP response means server is listening
                        $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
                        Write-Success "Backend is ready! (responded with $statusCode, took $elapsed seconds)"
                        return $true
                    }
                }
                # Connection refused or timeout - backend not ready yet
            } catch {
                # Other errors - backend not ready yet
            }
        }
        
        # Backend not ready yet, continue waiting
        if ($attempt % 5 -eq 0) {
            $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
            Write-Host "  Still waiting... ($elapsed seconds elapsed, attempt $attempt)" -ForegroundColor Gray
        }
        
        Start-Sleep -Seconds $RetryIntervalSeconds
    }
    
    Write-Warning "Backend did not respond within $TimeoutSeconds seconds"
    Write-Warning "Check backend window for errors"
    Write-Warning "Frontend will start anyway, but backend may not be fully ready"
    return $false
}

function Start-All {
    Write-Header "STARTING ALL SERVICES"
    
    Write-Info "Starting services in separate windows..."
    Write-Host ""
    
    # Start backend in new window
    Start-Backend
    
    # Wait for backend to be ready before starting frontend
    Write-Host ""
    $backendReady = Wait-ForBackend -Port $BACKEND_PORT -TimeoutSeconds 120
    
    if ($backendReady) {
        Write-Host ""
        Write-Info "Backend is ready, now starting frontend..."
    } else {
        Write-Host ""
        Write-Warning "Starting frontend anyway..."
    }
    
    Write-Host ""
    
    # Start frontend in new window
    Start-Frontend
    
    Write-Host ""
    Write-Success "All services started!"
    Write-Host ""
    Write-Info "Backend: http://localhost:$BACKEND_PORT"
    Write-Info "Frontend: http://localhost:$FRONTEND_PORT"
    Write-Info "Logs: $(Join-Path $SCRIPT_DIR 'logs')"
    Write-Host ""
    Write-Warning "Keep this window open. Close service windows to stop services."
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
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
