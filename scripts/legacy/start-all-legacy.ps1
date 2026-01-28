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
    [switch]$SkipHealthCheck = $false,
    [int]$HealthCheckTimeout = 30,
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
    Write-Host "  -DbOnly                  Start only the database"
    Write-Host "  -BackendOnly             Start database + backend API"
    Write-Host "  -FrontendOnly            Start only the frontend"
    Write-Host "  -SkipDb                  Skip database startup"
    Write-Host "  -SkipBuild               Skip the build step"
    Write-Host "  -CleanBuild              Clean before building"
    Write-Host "  -RecreateDb              Recreate database (drops existing)"
    Write-Host "  -SeedData                Seed database with sample data"
    Write-Host "  -SkipHealthCheck         Skip backend health check (not recommended)"
    Write-Host "  -HealthCheckTimeout <s>  Health check timeout in seconds (default: 120)"
    Write-Host "  -Help                    Show this help message"
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

function Test-DatabaseConnection {
    param(
        [string]$Server = "localhost",
        [int]$Port = 1433,
        [string]$Database = "ServiceCatalogueManager",
        [string]$User = "sa",
        [string]$Password = "YourStrong@Passw0rd",
        [int]$TimeoutSeconds = 10
    )
    
    try {
        $connectionString = "Server=$Server,$Port;Database=$Database;User Id=$User;Password=$Password;TrustServerCertificate=True;Connection Timeout=$TimeoutSeconds;"
        $query = "SELECT 1"
        
        # Použijeme sqlcmd pokud je k dispozici
        if (Test-Command "sqlcmd") {
            $result = sqlcmd -S "$Server,$Port" -U $User -P $Password -d $Database -Q $query -b -o 2>$null
            return $LASTEXITCODE -eq 0
        }
        
        # Alternativně použijeme docker exec
        $containerExists = docker ps --filter "name=$DB_CONTAINER" --format "{{.Names}}" 2>$null
        if ($containerExists -eq $DB_CONTAINER) {
            $testScript = "SELECT 1 as TestResult"
            $result = docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd `
                -S localhost -U $User -P $Password -d $Database `
                -C -Q $testScript -h -1 -W 2>$null
            return $LASTEXITCODE -eq 0 -and ($result -and $result.Contains("1"))
        }
        
        return $false
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
            
            # Test database connection and create if needed
            $testDbScript = "SELECT name FROM sys.databases WHERE name = '$DB_NAME'"
            $dbExists = docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd `
                -S localhost -U sa -P $SA_PASSWORD -C -Q $testDbScript -h -1 -W 2>$null
            
            if (-not $dbExists -or -not $dbExists.Contains($DB_NAME)) {
                Write-Info "Database does not exist, creating..."
                Create-Database
            }
            
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
    Write-Info "Waiting 20 seconds for SQL Server initialization..."
    Start-Sleep -Seconds 20
    
    # Create database
    Create-Database
}

function Create-Database {
    Write-Info "Setting up database..."
    
    # Create database with proper setup
    $createDbScript = @"
USE master;
GO

-- Drop database if exists and recreate
IF EXISTS (SELECT name FROM sys.databases WHERE name = '$DB_NAME')
BEGIN
    ALTER DATABASE $DB_NAME SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE $DB_NAME;
END
GO

CREATE DATABASE $DB_NAME
    COLLATE Czech_CI_AS;
GO

-- Ensure SA user has proper access
USE $DB_NAME;
GO
EXEC sp_changedbowner 'sa';
GO

-- Create migration history table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = '__EFMigrationsHistory')
BEGIN
    CREATE TABLE [dbo].[__EFMigrationsHistory](
        [MigrationId] [nvarchar](150) NOT NULL,
        [ProductVersion] [nvarchar](32) NOT NULL,
     CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
    (
        [MigrationId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
END
GO
"@
    
    try {
        docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd `
            -S localhost -U sa -P $SA_PASSWORD `
            -C -Q $createDbScript -b 2>$null | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Database created: $DB_NAME"
        } else {
            Write-Warning "Database creation had issues"
        }
    } catch {
        Write-Warning "Database setup error: $_"
    }
    
    # Wait for database to be fully ready
    Write-Info "Waiting for database to be fully ready..."
    Start-Sleep -Seconds 5
    
    # Run EF Core migrations
    Run-EFCoreMigrations
    
    Write-Host ""
    Write-Success "Database is ready!"
    Write-Info "Connection: Server=localhost,$DB_PORT;Database=$DB_NAME;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
}

function Run-EFCoreMigrations {
    Write-Info "Running EF Core migrations..."
    
    Push-Location $BACKEND_DIR
    try {
        # Check if EF Core tools are available
        $efInstalled = dotnet tool list --global | Select-String "dotnet-ef"
        if (-not $efInstalled) {
            Write-Info "Installing EF Core tools..."
            dotnet tool install --global dotnet-ef --version 8.0.0
        }
        
        # Update database using EF Core
        Write-Info "Applying EF Core migrations..."
        dotnet ef database update --project . --startup-project . --verbose
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "EF Core migrations applied successfully"
        } else {
            Write-Warning "EF Core migrations had issues, trying alternative approach..."
            
            # Alternative: use script migrations
            $migrationScript = Join-Path $SCRIPT_DIR "temp-migration.sql"
            dotnet ef migrations script --project . --startup-project . --output $migrationScript
            
            if (Test-Path $migrationScript) {
                Write-Info "Running migration script..."
                docker exec -i $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd `
                    -S localhost -U sa -P $SA_PASSWORD -C -d $DB_NAME `
                    -i $migrationScript 2>$null | Out-Null
                
                Remove-Item $migrationScript -Force -ErrorAction SilentlyContinue
                Write-Success "Migration script executed"
            }
        }
    } catch {
        Write-Warning "EF Core migrations failed: $_"
        Write-Warning "Database may still work with existing schema"
    } finally {
        Pop-Location
    }
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
        [int]$TimeoutSeconds = 30
    )
    
    Write-Host ""
    Write-Info "Waiting for backend health check on http://localhost:$Port..."
    Write-Host "  Timeout: $TimeoutSeconds seconds" -ForegroundColor Gray
    Write-Host ""
    
    $startTime = Get-Date
    $timeout = (Get-Date).AddSeconds($TimeoutSeconds)
    $attempt = 0
    $maxAttempts = [Math]::Ceiling($TimeoutSeconds / 2)
    
    # Priority order: health endpoint first, then fallbacks
    $endpoints = @(
        @{Path="/api/health"; IsHealth=$true},
        @{Path="/api/health/detailed"; IsHealth=$true},
        @{Path="/api"; IsHealth=$false},
        @{Path="/"; IsHealth=$false}
    )
    
    while ((Get-Date) -lt $timeout) {
        $attempt++
        $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
        
        # Progress indicator
        Write-Host "`r  Attempt $attempt/$maxAttempts... [" -NoNewline -ForegroundColor Gray
        Write-Host "${elapsed}s" -NoNewline -ForegroundColor Cyan
        Write-Host "]" -NoNewline -ForegroundColor Gray
        
        foreach ($ep in $endpoints) {
            try {
                $uri = "http://localhost:$Port$($ep.Path)"
                $response = Invoke-WebRequest -Uri $uri -Method GET -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
                
                # Success!
                Write-Host ""  # New line after progress
                Write-Host ""
                Write-Success "Backend is HEALTHY!"
                Write-Host "  Endpoint: $uri" -ForegroundColor Gray
                Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Gray
                Write-Host "  Response time: ${elapsed}s" -ForegroundColor Gray
                
                # Try to parse JSON health response
                if ($ep.IsHealth -and $response.Content) {
                    try {
                        $healthData = $response.Content | ConvertFrom-Json
                        if ($healthData.status) {
                            Write-Host "  Health Status: $($healthData.status)" -ForegroundColor Green
                        }
                        if ($healthData.timestamp) {
                            Write-Host "  Timestamp: $($healthData.timestamp)" -ForegroundColor Gray
                        }
                    } catch {
                        # JSON parsing failed, ignore
                    }
                }
                
                return $true
                
            } catch [System.Net.WebException] {
                # Check if we got any HTTP response (even error codes)
                if ($_.Exception.Response) {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                    if ($statusCode -ge 200 -and $statusCode -lt 600) {
                        # Any HTTP response means server is listening
                        Write-Host ""  # New line
                        Write-Host ""
                        Write-Success "Backend is responding! (HTTP $statusCode)"
                        Write-Host "  Endpoint: $uri" -ForegroundColor Gray
                        Write-Host "  Response time: ${elapsed}s" -ForegroundColor Gray
                        return $true
                    }
                }
            } catch {
                # Connection refused, timeout, etc. - continue
            }
        }
        
        # Calculate exponential backoff: 1s, 2s, 3s, 4s, 5s (max)
        $sleepTime = [Math]::Min(5, $attempt)
        Start-Sleep -Seconds $sleepTime
    }
    
    # Timeout reached
    Write-Host ""  # New line after progress
    Write-Host ""
    Write-Warning "Backend health check TIMEOUT after $TimeoutSeconds seconds"
    Write-Warning "Backend may still be starting. Check backend window for errors."
    Write-Host ""
    Write-Host "To diagnose:" -ForegroundColor Cyan
    Write-Host "  1. Check backend window for compilation errors" -ForegroundColor Gray
    Write-Host "  2. Try manual health check:" -ForegroundColor Gray
    Write-Host "     Invoke-WebRequest http://localhost:$Port/api/health" -ForegroundColor White
    Write-Host "  3. Check port availability:" -ForegroundColor Gray
    Write-Host "     netstat -ano | findstr :$Port" -ForegroundColor White
    Write-Host ""
    Write-Warning "Frontend will start anyway, but may not work correctly."
    Write-Host ""
    Write-Host "Press Enter to continue or Ctrl+C to abort..." -ForegroundColor Yellow
    Read-Host
    
    return $false
}

function Start-All {
    Write-Header "STARTING ALL SERVICES"
    
    Write-Info "Starting services in separate windows..."
    Write-Host ""
    
    # Start backend in new window
    Start-Backend
    
    # Wait for backend to be ready before starting frontend
    if ($script:SkipHealthCheck) {
        Write-Warning "Skipping backend health check (not recommended)"
        Write-Info "Waiting 5 seconds before starting frontend..."
        Start-Sleep -Seconds 5
    } else {
        $backendReady = Wait-ForBackend -Port $BACKEND_PORT -TimeoutSeconds $script:HealthCheckTimeout
        
        if ($backendReady) {
            Write-Host ""
            Write-Info "Backend is ready, now starting frontend..."
        } else {
            Write-Host ""
            Write-Warning "Starting frontend anyway..."
        }
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
