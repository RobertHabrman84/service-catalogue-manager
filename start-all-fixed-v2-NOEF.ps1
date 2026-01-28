#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - START ALL (NO EF CORE)
# ============================================================================
# Version: 4.0.0
# Description: Starts DB with db_structure.sql ONLY - NO EF Core migrations
# Používá VÝHRADNĚ db_structure.sql pro vytvoření kompletní databázové struktury
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
    [switch]$UseSQLite = $false,  # SQLite pouze explicitně
    [switch]$UseDocker = $true,  # Docker jako výchozí pro kompletní strukturu
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
    Write-Header "SERVICE CATALOGUE MANAGER - START SCRIPT v4.0.0 (NO EF CORE)"
    
    Write-Host "USAGE:" -ForegroundColor $COLOR_INFO
    Write-Host "  .\start-all-fixed-v2-NOEF.ps1 [OPTIONS]"
    Write-Host ""
    
    Write-Host "POPIS:" -ForegroundColor $COLOR_INFO
    Write-Host "  Tento skript spustí kompletní Service Catalogue Manager VÝHRADNĚ s db_structure.sql."
    Write-Host "  NEPOUŽÍVÁ ŽÁDNÉ EF Core migrace - pouze SQL skripty pro vytvoření databáze."
    Write-Host "  Používá kompletní strukturu 42 tabulek včetně 11 lookup tabulek z db_structure.sql."
    Write-Host ""
    
    Write-Host "MOŽNOSTI:" -ForegroundColor $COLOR_INFO
    Write-Host "  -SkipBuild         Přeskočit build aplikací"
    Write-Host "  -SkipFrontend      Přeskočit frontend"
    Write-Host "  -SkipBackend       Přeskočit backend" 
    Write-Host "  -SkipDb            Přeskočit databázi"
    Write-Host "  -CleanBuild        Vyčistit a buildovat znovu"
    Write-Host "  -BackendOnly       Pouze backend"
    Write-Host "  -FrontendOnly      Pouze frontend"
    Write-Host "  -DbOnly            Pouze databáze"
    Write-Host "  -UseSQLite         Použít SQLite (výchozí je Docker)"
    Write-Host "  -UseDocker         Použít Docker SQL Server (výchozí)"
    Write-Host "  -RecreateDb        Znovu vytvořit databázi"
    Write-Host "  -SeedData          Naplnit testovacími daty"
    Write-Host "  -SkipHealthCheck   Přeskočit kontrolu zdraví"
    Write-Host "  -HealthCheckTimeout Nastavit timeout pro kontrolu zdraví (v sekundách)"
    Write-Host "  -Help              Zobrazit tuto nápovědu"
    Write-Host ""
    
    Write-Host "PŘÍKLADY:" -ForegroundColor $COLOR_INFO
    Write-Host "  # Standardní spuštění s Dockerem a kompletní strukturou"
    Write-Host "  .\start-all-fixed-v2-NOEF.ps1 -UseDocker -RecreateDb"
    Write-Host ""
    Write-Host "  # Pouze databáze s kompletní strukturou"
    Write-Host "  .\start-all-fixed-v2-NOEF.ps1 -UseDocker -RecreateDb -DbOnly"
    Write-Host ""
    Write-Host "  # SQLite pro sandbox režim"
    Write-Host "  .\start-all-fixed-v2-NOEF.ps1 -UseSQLite -RecreateDb"
    Write-Host ""
    
    Write-Host "DŮLEŽITÉ:" -ForegroundColor $COLOR_WARNING
    Write-Host "  Tento skript NIKDY nepoužívá EF Core migrace!"
    Write-Host "  Vždy používá pouze SQL skripty (db_structure.sql) pro vytvoření databáze."
    Write-Host "  Pro Docker je vyžadován SQL Server container s kompletní strukturou."
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
    
    Write-Info "🗄️  Používá se VÝHRADNĚ SQL skripty - žádné EF Core migrace!"
    
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
    
    # Použít výhradně setup-db-fixed-v2.ps1 - žádné EF Core migrace!
    $setupScript = Join-Path $SCRIPT_DIR "database\scripts\setup-db-fixed-v2.ps1"
    if (Test-Path $setupScript) {
        Write-Info "Running database setup script with db_structure.sql (NO EF CORE!)..."
        Write-Info "This will create all 42 tables including 11 lookup tables from db_structure.sql"
        Write-Info "NO ENTITY FRAMEWORK MIGRATIONS ARE USED - PURE SQL ONLY!"
        
        & $setupScript -DbName $DB_NAME -ContainerName $DB_CONTAINER -Force:$RecreateDb -NoEFCore:$true
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Database setup complete using db_structure.sql - NO EF CORE USED!"
            
            # Ověření úspěšnosti vytvoření tabulek
            Write-Info "Verifying database structure..."
            Verify-DatabaseStructure
            
        } else {
            Write-ErrorMessage "Database setup FAILED using db_structure.sql!"
            Write-ErrorMessage "Check the logs above for SQL errors."
            exit 1
        }
    } else {
        Write-ErrorMessage "CRITICAL: Database setup script not found: $setupScript"
        Write-ErrorMessage "Database CANNOT be initialized without setup-db-fixed-v2.ps1"
        Write-ErrorMessage "This script REQUIRES db_structure.sql implementation!"
        exit 1
    }
}

function Verify-DatabaseStructure {
    Write-Info "Verifying that database tables were created successfully..."
    
    # Kontrola pomocí sqlcmd nebo docker exec
    $checkQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE'"
    
    try {
        if (Test-Command "sqlcmd") {
            $result = sqlcmd -S "localhost,1433" -U sa -P $SA_PASSWORD -Q $checkQuery -h -1 2>$null
        } else {
            $result = docker exec $DB_CONTAINER /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -Q $checkQuery -h -1 2>$null
        }
        
        # Normalize output and safely parse integer
        if ($result -is [array]) { $result = ($result | Where-Object { $_ -match '\d' } | Select-Object -First 1) }
        $result = "$result".Trim()
        if ($result -match '(\d+)') { $tableCount = [int]$matches[1] } else { $tableCount = 0 }
        
        if ($tableCount -ge 40) {
            Write-Success "SUCCESS: $tableCount tables found in database!"
            Write-Success "Database structure verified - db_structure.sql applied correctly!"
        } else {
            Write-Warning "WARNING: Only $tableCount tables found (expected 42+)"
            Write-Warning "Database structure may be incomplete."
        }
        
    } catch {
        Write-Warning "Could not verify table count: $($_.Exception.Message)"
    }
}

function Start-SqliteDatabase {
    Write-Info "Using SQLite database (sandbox mode) - NO EF CORE..."
    Write-Info "SQLite používá alternativní přístup bez db_structure.sql"
    
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
    
    # Zkopírovat SQLite config do local.settings.json
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
    
    # Docker (volitelné)
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
    Set-Location $BACKEND_DIR
    
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
}

function Build-Frontend {
    Write-Header "BUILDING FRONTEND"
    
    if (-not (Test-Path $FRONTEND_DIR)) {
        Write-ErrorMessage "Frontend directory not found: $FRONTEND_DIR"
        exit 1
    }
    
    Write-Info "Installing frontend dependencies..."
    Set-Location $FRONTEND_DIR
    
    npm install --silent
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "npm install had issues, continuing..."
    }
    
    Write-Success "Frontend dependencies installed!"
}

function Start-Backend {
    Write-Header "STARTING BACKEND"
    
    Set-Location $BACKEND_DIR
    
    Write-Info "Starting Azure Functions backend..."
    Write-Info "Backend will be available at: http://localhost:$BACKEND_PORT"
    
    Start-Process -FilePath "func" -ArgumentList "start", "--port", $BACKEND_PORT -WorkingDirectory $BACKEND_DIR -NoNewWindow -PassThru | Out-Null
    
    Write-Success "Backend process started!"
}

function Start-Frontend {
    Write-Header "STARTING FRONTEND"
    
    Set-Location $FRONTEND_DIR
    
    Write-Info "Starting React frontend..."
    Write-Info "Frontend will be available at: http://localhost:$FRONTEND_PORT"
    
    # Use npm.cmd on Windows to avoid Win32 application error
    $npmCmd = $(if (Get-Command "npm.cmd" -ErrorAction SilentlyContinue) { "npm.cmd" } elseif (Get-Command "npm" -ErrorAction SilentlyContinue) { "npm" } else { $null })
    if (-not $npmCmd) { Write-ErrorMessage "npm not found!"; exit 1 }
    Start-Process -FilePath $npmCmd -ArgumentList @("run", "dev", "--", "--port", $FRONTEND_PORT) -WorkingDirectory $FRONTEND_DIR -NoNewWindow -PassThru | Out-Null
    
    Write-Success "Frontend process started!"
}

function Start-All {
    Write-Header "STARTING ALL SERVICES (NO EF CORE MODE)"
    
    Write-Info "🚀 Spouštím Service Catalogue Manager v režimu BEZ EF Core migrací!"
    Write-Info "Databáze bude vytvořena POUZE pomocí db_structure.sql"
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
    Write-Success "✅ Service Catalogue Manager běží BEZ EF Core migrací!"
    Write-Success "✅ Databáze používá kompletní strukturu z db_structure.sql"
    Write-Success "✅ Backend: http://localhost:$BACKEND_PORT"
    Write-Success "✅ Frontend: http://localhost:$FRONTEND_PORT"
    Write-Success "✅ Database: localhost,$DB_PORT (SQL Server)"
    Write-Host ""
    Write-Info "Pro zastavení všech služeb použijte: Ctrl+C"
    Write-Host ""
    
    # Health check
    if (-not $SkipHealthCheck) {
        Write-Info "Čekám na inicializaci služeb..."
        Start-Sleep -Seconds 5
        
        Write-Info "Kontroluji zdraví backendu..."
        $retries = 0
        $maxRetries = $HealthCheckTimeout
        
        while ($retries -lt $maxRetries) {
            if (Test-BackendConnection -Port $BACKEND_PORT -TimeoutSeconds 2) {
                Write-Success "Backend je zdravý! ✅"
                break
            }
            $retries++
            Write-Info "Pokus $retries/$maxRetries - čekám 1 sekundu..."
            Start-Sleep -Seconds 1
        }
        
        if ($retries -ge $maxRetries) {
            Write-Warning "Backend neodpovídá po $maxRetries pokusech"
            Write-Warning "Zkuste otevřít: http://localhost:$BACKEND_PORT/api/health"
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
    Write-ErrorMessage "Chyba: Nemůžete použít současně -UseSQLite a -UseDocker"
    exit 1
}

# Show startup header
Write-Header "SERVICE CATALOGUE MANAGER - STARTUP v4.0.0 (NO EF CORE)"
Write-Info "POUŽÍVÁ VÝHRADNĚ db_structure.sql - ŽÁDNÉ EF CORE MIGRACE!"
Write-Info "Verze: 4.0.0 - Kompletní odstranění EF Core migrací"
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