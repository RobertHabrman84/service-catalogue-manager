#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - START ALL (NO EF CORE)
# ============================================================================
# Version: 4.1.0
# Description: Starts DB with db_structure.sql ONLY - NO EF Core migrations
# PouÅ¾Ã­vÃ¡ VÃHRADNÄš db_structure.sql pro vytvoÅ™enÃ­ kompletnÃ­ databÃ¡zovÃ© struktury
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
    [switch]$UseSQLite = $false,  # SQLite pouze explicitnÄ›
    [switch]$UseDocker = $true,  # Docker jako vÃ½chozÃ­ pro kompletnÃ­ strukturu
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
$DB_SETUP_SCRIPT = Join-Path $SCRIPT_DIR "database\scripts\setup-db-fixed-v2.ps1"
$DB_SQLITE_SCRIPT = Join-Path $SCRIPT_DIR "database\scripts\setup-sqlite.ps1"

$BACKEND_PORT = 7071
$FRONTEND_PORT = 3000
$DB_PORT = 1433
$DB_CONTAINER = "scm-sqlserver"
$SA_PASSWORD = "YourStrong@Passw0rd"
$DB_NAME = "ServiceCatalogueManager"

$script:DatabaseTableCount = $null

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
    Write-Host "$Message" -ForegroundColor $COLOR_SUCCESS
}

function Write-Info {
    param([string]$Message)
    Write-Host "â„¹ï¸  $Message" -ForegroundColor $COLOR_INFO
}

function Write-Warning {
    param([string]$Message)
    Write-Host "âš ï¸  $Message" -ForegroundColor $COLOR_WARNING
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "âŒ $Message" -ForegroundColor $COLOR_ERROR
}

function Show-Help {
    Write-Header "SERVICE CATALOGUE MANAGER - START SCRIPT v4.1.0 (NO EF CORE)"
    
    Write-Host "USAGE:" -ForegroundColor $COLOR_INFO
    Write-Host "  .\start-all.ps1 [OPTIONS]"
    Write-Host ""
    
    Write-Host "POPIS:" -ForegroundColor $COLOR_INFO
    Write-Host "  Tento skript spustÃ­ kompletnÃ­ Service Catalogue Manager VÃHRADNÄš s db_structure.sql."
    Write-Host "  NEPOUÅ½ÃVÃ Å½ÃDNÃ‰ EF Core migrace - pouze SQL skripty pro vytvoÅ™enÃ­ databÃ¡ze."
    Write-Host "  PouÅ¾Ã­vÃ¡ kompletnÃ­ strukturu 42 tabulek vÄetnÄ› 11 lookup tabulek z db_structure.sql."
    Write-Host ""
    
    Write-Host "MOÅ½NOSTI:" -ForegroundColor $COLOR_INFO
    Write-Host "  -SkipBuild         PÅ™eskoÄit build aplikacÃ­"
    Write-Host "  -SkipFrontend      PÅ™eskoÄit frontend"
    Write-Host "  -SkipBackend       PÅ™eskoÄit backend" 
    Write-Host "  -SkipDb            PÅ™eskoÄit databÃ¡zi"
    Write-Host "  -CleanBuild        VyÄistit a buildovat znovu"
    Write-Host "  -BackendOnly       Pouze backend"
    Write-Host "  -FrontendOnly      Pouze frontend"
    Write-Host "  -DbOnly            Pouze databÃ¡ze"
    Write-Host "  -UseSQLite         PouÅ¾Ã­t SQLite (vÃ½chozÃ­ je Docker)"
    Write-Host "  -UseDocker         PouÅ¾Ã­t Docker SQL Server (vÃ½chozÃ­)"
    Write-Host "  -RecreateDb        Znovu vytvoÅ™it databÃ¡zi"
    Write-Host "  -SeedData          Naplnit testovacÃ­mi daty"
    Write-Host "  -SkipHealthCheck   PÅ™eskoÄit kontrolu zdravÃ­"
    Write-Host "  -HealthCheckTimeout Nastavit timeout pro kontrolu zdravÃ­ (v sekundÃ¡ch)"
    Write-Host "  -Help              Zobrazit tuto nÃ¡povÄ›du"
    Write-Host ""
    
    Write-Host "PÅ˜ÃKLADY:" -ForegroundColor $COLOR_INFO
    Write-Host "  # StandardnÃ­ spuÅ¡tÄ›nÃ­ s Dockerem a kompletnÃ­ strukturou"
    Write-Host "  .\start-all.ps1 -UseDocker -RecreateDb"
    Write-Host ""
    Write-Host "  # Pouze databÃ¡ze s kompletnÃ­ strukturou"
    Write-Host "  .\start-all.ps1 -UseDocker -RecreateDb -DbOnly"
    Write-Host ""
    Write-Host "  # SQLite pro sandbox reÅ¾im"
    Write-Host "  .\start-all.ps1 -UseSQLite -RecreateDb"
    Write-Host ""
    
    Write-Host "DÅ®LEÅ½ITÃ‰:" -ForegroundColor $COLOR_WARNING
    Write-Host "  Tento skript NIKDY nepouÅ¾Ã­vÃ¡ EF Core migrace!"
    Write-Host "  VÅ¾dy pouÅ¾Ã­vÃ¡ pouze SQL skripty (db_structure.sql) pro vytvoÅ™enÃ­ databÃ¡ze."
    Write-Host "  Pro Docker je vyÅ¾adovÃ¡n SQL Server container s kompletnÃ­ strukturou."
    Write-Host ""
    exit 0
}

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Resolve-Executable {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [string[]]$Fallbacks = @()
    )

    $candidates = @($Command) + $Fallbacks
    foreach ($candidate in $candidates) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($cmd) {
            if ($cmd.Path) { return $cmd.Path }
            if ($cmd.Source) { return $cmd.Source }
        }
    }
    return $null
}

function Test-DockerAvailable {
    try {
        docker info 2>$null | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-BackendConnection {
    param(
        [int]$Port = 7071,
        [int]$TimeoutSeconds = 10
    )
    
    try {
        $uri = "http://localhost:$Port/api/health"
        $response = Invoke-WebRequest -Uri $uri -Method GET -TimeoutSec $TimeoutSeconds -UseBasicParsing -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Start-Database {
    Write-Header "STARTING DATABASE (NO EF CORE - PURE SQL)"
    
    Write-Info "  PouÅ¾Ã­vÃ¡ se VÃHRADNÄš SQL skripty - Å¾Ã¡dnÃ© EF Core migrace!"
    
    # Rozhodnout se mezi Docker a SQLite
    if ($UseDocker -and (Test-DockerAvailable)) {
        Start-DockerDatabase
    } else {
        Start-SqliteDatabase
    }
}

function Start-DockerDatabase {
    Write-Info "Docker detected, starting SQL Server container..."
    
    # Check Docker
    if (-not (Test-Command "docker")) {
        Write-Warning "Docker is not installed! Using SQLite fallback..."
        Start-SqliteDatabase
        return
    }
    
    if (-not (Test-DockerAvailable)) {
        Write-Warning "Docker is not running! Using SQLite fallback..."
        Start-SqliteDatabase
        return
    }
    
    Write-Success "Docker is available"
    
    # Check if container exists and is running
    try {
        $container = docker ps --filter "name=$DB_CONTAINER" --format "{{.Names}}" 2>$null
        if ($container -eq $DB_CONTAINER) {
            Write-Info "SQL Server container is already running"
            Write-Success "Database: localhost,$DB_PORT"
            # Setup database if not exists
            Setup-DockerDatabase
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
    Write-Info "Waiting 25 seconds for SQL Server initialization..."
    Start-Sleep -Seconds 25
    
    # Setup database
    Setup-DockerDatabase
}

function Setup-DockerDatabase {
    Write-Info "Setting up database schema using PURE SQL (NO EF CORE)..."
    Write-Info "Using db_structure.sql for complete database structure (42 tables)"
    
    # Use Docker configuration for backend
    $dockerConfig = Join-Path $BACKEND_DIR "local.settings.docker.json"
    $targetConfig = Join-Path $BACKEND_DIR "local.settings.json"
    
    if (Test-Path $dockerConfig) {
        Write-Info "Using Docker configuration for backend..."
        Copy-Item -Path $dockerConfig -Destination $targetConfig -Force
        Write-Success "Backend configuration updated for Docker"
    }
    
    # PouÅ¾Ã­t vÃ½hradnÄ› setup-db-fixed-v2.ps1 - Å¾Ã¡dnÃ© EF Core migrace!
    $setupScript = Join-Path $SCRIPT_DIR "database\scripts\setup-db-fixed-v2.ps1"
    if (Test-Path $setupScript) {
        Write-Info "Running database setup script with db_structure.sql (NO EF CORE!)..."
        Write-Info "This will create all 42 tables including 11 lookup tables from db_structure.sql"
        Write-Info "NO ENTITY FRAMEWORK MIGRATIONS ARE USED - PURE SQL ONLY!"
        
        $setupParams = @{
            DbName        = $DB_NAME
            ContainerName = $DB_CONTAINER
            NoEFCore      = $true
        }
        if ($RecreateDb) {
            $setupParams.Force = $true
        }

        & $setupScript @setupParams
        $setupExitCode = $LASTEXITCODE
        
        if ($setupExitCode -ne 0) {
            Write-ErrorMessage "Database setup FAILED using db_structure.sql!"
            Write-ErrorMessage "Check the logs above for SQL errors."
            exit 1
        }

        Write-Info "Verifying database structure..."
        $tableCount = Verify-DatabaseStructure

        if ($tableCount -lt 0) {
            Write-ErrorMessage "Database verification failed - unable to determine table count."
            exit 1
        }

        if ($tableCount -lt 40) {
            Write-ErrorMessage "Database verification failed - expected at least 40 tables, found $tableCount."
            exit 1
        }

        $script:DatabaseTableCount = $tableCount
        Write-Success "Database setup complete using db_structure.sql - NO EF CORE USED!"
    } else {
        Write-ErrorMessage "CRITICAL: Database setup script not found: $setupScript"
        Write-ErrorMessage "Database CANNOT be initialized without setup-db-fixed-v2.ps1"
        Write-ErrorMessage "This script REQUIRES db_structure.sql implementation!"
        exit 1
    }
}

function Verify-DatabaseStructure {
    Write-Info "Verifying that database tables were created successfully..."
    
    $tableCount = -1
    $checkQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE'"
    
    try {
        $resultLines = @()
        if (Test-Command "sqlcmd") {
            $resultLines = sqlcmd -S "localhost,1433" -U sa -P $SA_PASSWORD -Q $checkQuery -h -1 2>$null
        } else {
            $resultLines = docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -Q $checkQuery -h -1 2>$null
        }
        
        if ($null -eq $resultLines) {
            $resultLines = @()
        } elseif ($resultLines -isnot [array]) {
            $resultLines = @($resultLines)
        }
        
        $numericLine = $resultLines |
            ForEach-Object { $_.ToString().Trim() } |
            Where-Object { $_ -match '^\d+$' } |
            Select-Object -First 1
        
        $tableCount = 0
        if (-not [int]::TryParse($numericLine, [ref]$tableCount)) {
            $joinedResult = ($resultLines | ForEach-Object { $_.ToString() }) -join " "
            $match = [regex]::Match($joinedResult, "\d+")
            if ($match.Success) {
                [void][int]::TryParse($match.Value, [ref]$tableCount)
            }
        }
        
    } catch {
        Write-Warning "Could not verify table count: $($_.Exception.Message)"
        return -1
    }

    if ($tableCount -ge 40) {
        Write-Success "SUCCESS: $tableCount tables found in database!"
        Write-Success "Database structure verified - db_structure.sql applied correctly!"
    } else {
        Write-Warning "WARNING: Only $tableCount tables found (expected 42+)"
        Write-Warning "Database structure may be incomplete."
    }

    return $tableCount
}

function Start-SqliteDatabase {
    Write-Info "Using SQLite database (sandbox mode) - NO EF CORE..."
    Write-Info "SQLite pouÅ¾Ã­vÃ¡ alternativnÃ­ pÅ™Ã­stup bez db_structure.sql"
    
    # Spustit SQLite setup skript
    if (Test-Path $DB_SQLITE_SCRIPT) {
        Write-Info "Setting up SQLite database (NO EF CORE)..."
        & $DB_SQLITE_SCRIPT -Force:$RecreateDb
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "SQLite database setup complete (NO EF CORE USED)!"
        } else {
            Write-ErrorMessage "SQLite setup FAILED!"
            exit 1
        }
    } else {
        Write-ErrorMessage "CRITICAL: SQLite setup script not found: $DB_SQLITE_SCRIPT"
        Write-ErrorMessage "Database CANNOT be initialized!"
        exit 1
    }
    
    # ZkopÃ­rovat SQLite config do local.settings.json
    $sqliteConfig = Join-Path $BACKEND_DIR "local.settings.sqlite.json"
    $targetConfig = Join-Path $BACKEND_DIR "local.settings.json"
    
    if (Test-Path $sqliteConfig) {
        Write-Info "Using SQLite configuration..."
        Copy-Item -Path $sqliteConfig -Destination $targetConfig -Force
        Write-Success "Configuration updated for SQLite"
    }
}

function Test-Prerequisites {
    Write-Header "CHECKING PREREQUISITES (NO EF CORE VERIFICATION)"
    
    # .NET SDK
    Write-Info "Checking .NET SDK..."
    if (Test-Command "dotnet") {
        $dotnetVersion = dotnet --version
        Write-Success ".NET SDK v$dotnetVersion"
    } else {
        Write-ErrorMessage ".NET SDK not found!"
        exit 1
    }
    
    # Functions Core Tools
    Write-Info "Checking Azure Functions Core Tools..."
    if (Test-Command "func") {
        Write-Success "Functions Core Tools available"
    } else {
        Write-Warning "Functions Core Tools not found"
    }
    
    # Node.js
    Write-Info "Checking Node.js..."
    if (Test-Command "node") {
        $nodeVersion = node --version
        Write-Success "Node.js $nodeVersion"
    } else {
        Write-ErrorMessage "Node.js not found!"
        exit 1
    }
    
    # npm
    Write-Info "Checking npm..."
    if (Test-Command "npm") {
        $npmVersion = npm --version
        Write-Success "npm v$npmVersion"
    } else {
        Write-ErrorMessage "npm not found!"
        exit 1
    }
    
    # Docker (volitelnÃ©)
    if ($UseDocker) {
        Write-Info "Checking Docker (optional)..."
        if (Test-DockerAvailable) {
            Write-Success "Docker is available"
        } else {
            Write-Warning "Docker not available - will use SQLite fallback"
        }
    }
    
    Write-Success "All prerequisites checked!"
}

function Build-Backend {
    Write-Header "BUILDING BACKEND"
    
    if (-not (Test-Path $BACKEND_DIR)) {
        Write-ErrorMessage "Backend directory not found: $BACKEND_DIR"
        exit 1
    }
    
    Write-Info "Building backend..."
    Push-Location $BACKEND_DIR
    try {
        if ($CleanBuild) {
            Write-Info "Cleaning previous build..."
            dotnet clean --verbosity quiet
        }
        
        dotnet build --verbosity quiet
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Backend build failed!"
            exit 1
        }
        
        Write-Success "Backend build complete!"
    } finally {
        Pop-Location
    }
}

function Build-Frontend {
    Write-Header "BUILDING FRONTEND"
    
    if (-not (Test-Path $FRONTEND_DIR)) {
        Write-ErrorMessage "Frontend directory not found: $FRONTEND_DIR"
        exit 1
    }
    
    Write-Info "Installing frontend dependencies..."
    Push-Location $FRONTEND_DIR
    try {
        npm install --silent
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "npm install had issues, continuing..."
        }
        
        Write-Success "Frontend dependencies installed!"
    } finally {
        Pop-Location
    }
}

function Start-Backend {
    Write-Header "STARTING BACKEND"
    
    Push-Location $BACKEND_DIR
    try {
        Write-Info "Starting Azure Functions backend..."
        Write-Info "Backend will be available at: http://localhost:$BACKEND_PORT"
        
        $funcPath = Resolve-Executable -Command "func" -Fallbacks @("func.cmd", "func.exe")
        if (-not $funcPath) {
            Write-ErrorMessage "Azure Functions Core Tools (func) not found!"
            Write-Warning "Install via: npm install -g azure-functions-core-tools@4"
            exit 1
        }
        
        $arguments = @("start", "--port", $BACKEND_PORT)
        $backendProcess = Start-Process -FilePath $funcPath -ArgumentList $arguments -WorkingDirectory $BACKEND_DIR -PassThru
        
        if ($backendProcess) {
            $script:BackendProcessId = $backendProcess.Id
            Write-Success "Backend process started!"
            Write-Info "Backend PID: $($backendProcess.Id)"
        } else {
            Write-Warning "Backend process may not have started correctly. Check logs."
        }
    } finally {
        Pop-Location
    }
}

function Start-Frontend {
    Write-Header "STARTING FRONTEND"
    
    Push-Location $FRONTEND_DIR
    try {
        Write-Info "Starting React frontend..."
        Write-Info "Frontend will be available at: http://localhost:$FRONTEND_PORT"
        
        $npmPath = Resolve-Executable -Command "npm.cmd" -Fallbacks @("npm", "npx.cmd", "npx")
        if (-not $npmPath) {
            Write-ErrorMessage "npm executable not found!"
            Write-Warning "Install Node.js from https://nodejs.org/ and ensure npm is on PATH."
            exit 1
        }
        
        $arguments = @("run", "dev", "--", "--port", $FRONTEND_PORT)
        $frontendProcess = Start-Process -FilePath $npmPath -ArgumentList $arguments -WorkingDirectory $FRONTEND_DIR -PassThru
        
        if ($frontendProcess) {
            $script:FrontendProcessId = $frontendProcess.Id
            Write-Success "Frontend process started!"
            Write-Info "Frontend PID: $($frontendProcess.Id)"
        } else {
            Write-Warning "Frontend process may not have started correctly. Check logs."
        }
    } finally {
        Pop-Location
    }
}

function Start-All {
    Write-Header "STARTING ALL SERVICES (NO EF CORE MODE)"
    
    Write-Info "ðŸš€ SpouÅ¡tÃ­m Service Catalogue Manager v reÅ¾imu BEZ EF Core migracÃ­!"
    Write-Info "DatabÃ¡ze bude vytvoÅ™ena POUZE pomocÃ­ db_structure.sql"
    Write-Host ""
    
    # Start services based on parameters
    if ($DbOnly) {
        Start-Database
        return
    }
    
    if ($BackendOnly) {
        if (-not $SkipDb) { Start-Database }
        if (-not $SkipBuild) { Build-Backend }
        Start-Backend
        return
    }
    
    if ($FrontendOnly) {
        if (-not $SkipBuild) { Build-Frontend }
        Start-Frontend
        return
    }
    
    # Default: start everything
    if (-not $SkipDb) { Start-Database }
    if (-not $SkipBuild) { 
        Build-Backend 
        Build-Frontend 
    }
    if (-not $SkipBackend) { Start-Backend }
    if (-not $SkipFrontend) { Start-Frontend }
    
    Write-Header "ALL SERVICES STARTED SUCCESSFULLY!"
    Write-Success "Service Catalogue Manager bÄ›Å¾Ã­ BEZ EF Core migracÃ­!"
    Write-Success "DatabÃ¡ze pouÅ¾Ã­vÃ¡ kompletnÃ­ strukturu z db_structure.sql"
    Write-Success "Backend: http://localhost:$BACKEND_PORT"
    if ($script:BackendProcessId) {
        Write-Info "Backend PID: $script:BackendProcessId"
    }
    Write-Success "Frontend: http://localhost:$FRONTEND_PORT"
    if ($script:FrontendProcessId) {
        Write-Info "Frontend PID: $script:FrontendProcessId"
    }
    Write-Success "Database: localhost,$DB_PORT (SQL Server)"
    if ($script:DatabaseTableCount) {
        Write-Info "CelkovÃ½ poÄet tabulek: $script:DatabaseTableCount"
    }
    Write-Host ""
    Write-Info "Pro zastavenÃ­ vÅ¡ech sluÅ¾eb pouÅ¾ijte: Ctrl+C"
    Write-Host ""
    
    # Health check
    if (-not $SkipHealthCheck) {
        Write-Info "na inicializaci sluÅ¾eb..."
        Start-Sleep -Seconds 5
        
        Write-Info "Kontroluji zdravÃ­ backendu..."
        $retries = 0
        $maxRetries = $HealthCheckTimeout
        
        while ($retries -lt $maxRetries) {
            if (Test-BackendConnection -Port $BACKEND_PORT -TimeoutSeconds 2) {
                Write-Success "Backend je zdravÃ½! âœ…"
                break
            }
            $retries++
            Write-Info "Pokus $retries/$maxRetries - ÄekÃ¡m 1 sekundu..."
            Start-Sleep -Seconds 1
        }
        
        if ($retries -ge $maxRetries) {
            Write-Warning "Backend neodpovÃ­dÃ¡ po $maxRetries pokusech"
            Write-Warning "Zkuste otevÅ™Ã­t: http://localhost:$BACKEND_PORT/api/health"
        }
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Show help if requested
if ($Help) {
    Show-Help
}

# Check for parameter conflicts
if ($UseSQLite -and $UseDocker) {
    Write-ErrorMessage "Chyba: NemÅ¯Å¾ete pouÅ¾Ã­t souÄasnÄ› -UseSQLite a -UseDocker"
    exit 1
}

# Show startup header
Write-Header "SERVICE CATALOGUE MANAGER - STARTUP v4.1.0 (NO EF CORE)"
Write-Info "POUÅ½ÃVÃ VÃHRADNÄš db_structure.sql - Å½ÃDNÃ‰ EF CORE MIGRACE!"
Write-Info "Verze: 4.1.0 - KompletnÃ­ odstranÄ›nÃ­ EF Core migracÃ­"
Write-Host ""

# Execute based on parameters
if ($DbOnly) {
    Start-Database
} elseif ($BackendOnly) {
    Test-Prerequisites
    if (-not $SkipDb) { Start-Database }
    if (-not $SkipBuild) { Build-Backend }
    if (-not $SkipBackend) { Start-Backend }
} elseif ($FrontendOnly) {
    Test-Prerequisites
    if (-not $SkipBuild) { Build-Frontend }
    if (-not $SkipFrontend) { Start-Frontend }
} else {
    Test-Prerequisites
    Start-All
}
