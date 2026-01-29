#!/usr/bin/env pwsh
# ==============================================================================
# Service Catalogue Manager - Start Script
# ==============================================================================
# This script:
# 1. Creates MS SQL Server database in Docker
# 2. Builds backend (.NET)
# 3. Builds frontend (React + Vite)
# 4. Starts both backend and frontend in separate processes
# ==============================================================================

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# Configuration
$CONTAINER_NAME = "scm-sqlserver"
$DB_PASSWORD = "YourStrong@Passw0rd"
$DB_NAME = "ServiceCatalogueManager"
$SQL_PORT = 1433
$BACKEND_PATH = "src/backend/ServiceCatalogueManager.Api"
$FRONTEND_PATH = "src/frontend"
$SQL_SCRIPT = "db_structure.sql"

Write-Info "===================================================================="
Write-Info "Service Catalogue Manager - Startup"
Write-Info "===================================================================="

# ==============================================================================
# 1. CHECK PREREQUISITES
# ==============================================================================
Write-Info "`n[1/6] Checking prerequisites..."

# Check Docker
try {
    docker --version | Out-Null
    Write-Success "✓ Docker is installed"
} catch {
    Write-Error "✗ Docker is not installed or not running"
    exit 1
}

# Check .NET
try {
    dotnet --version | Out-Null
    Write-Success "✓ .NET SDK is installed"
} catch {
    Write-Error "✗ .NET SDK is not installed"
    exit 1
}

# Check Node.js
try {
    node --version | Out-Null
    Write-Success "✓ Node.js is installed"
} catch {
    Write-Error "✗ Node.js is not installed"
    exit 1
}

# Check Azure Functions Core Tools
try {
    func --version | Out-Null
    Write-Success "✓ Azure Functions Core Tools is installed"
} catch {
    Write-Warning "✗ Azure Functions Core Tools not found"
    Write-Info "  Installing globally..."
    npm install -g azure-functions-core-tools@4 --unsafe-perm true
}

# ==============================================================================
# 2. DATABASE SETUP
# ==============================================================================
Write-Info "`n[2/6] Setting up SQL Server database..."

# Check if container already exists
$existingContainer = docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.Names}}"

if ($existingContainer -eq $CONTAINER_NAME) {
    Write-Warning "Container '$CONTAINER_NAME' already exists"
    
    # Check if running
    $runningContainer = docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}"
    
    if ($runningContainer -eq $CONTAINER_NAME) {
        Write-Info "Container is already running"
    } else {
        Write-Info "Starting existing container..."
        docker start $CONTAINER_NAME
        Start-Sleep -Seconds 10
    }
} else {
    Write-Info "Creating new SQL Server container..."
    docker run -e "ACCEPT_EULA=Y" `
               -e "MSSQL_SA_PASSWORD=$DB_PASSWORD" `
               -p ${SQL_PORT}:1433 `
               --name $CONTAINER_NAME `
               -d mcr.microsoft.com/mssql/server:2022-latest
    
    Write-Info "Waiting for SQL Server to start (30 seconds)..."
    Start-Sleep -Seconds 30
}

# Check if database exists
Write-Info "Checking database status..."
$dbCheck = docker exec $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $DB_PASSWORD `
    -C -Q "SELECT name FROM sys.databases WHERE name = '$DB_NAME'" -h -1 2>&1

if ($dbCheck -match $DB_NAME) {
    Write-Warning "Database '$DB_NAME' already exists - skipping initialization"
} else {
    Write-Info "Creating database and schema..."
    
    # Copy SQL script to container
    if (Test-Path $SQL_SCRIPT) {
        docker cp $SQL_SCRIPT ${CONTAINER_NAME}:/tmp/db_structure.sql
        
        # Create database
        docker exec $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd `
            -S localhost -U sa -P $DB_PASSWORD `
            -C -Q "CREATE DATABASE $DB_NAME"
        
        # Execute schema
        docker exec $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd `
            -S localhost -U sa -P $DB_PASSWORD `
            -C -d $DB_NAME `
            -i /tmp/db_structure.sql
        
        Write-Success "✓ Database initialized successfully"
    } else {
        Write-Warning "SQL script '$SQL_SCRIPT' not found - database created but not initialized"
    }
}

# ==============================================================================
# 3. BUILD BACKEND
# ==============================================================================
Write-Info "`n[3/6] Building backend..."

if (Test-Path $BACKEND_PATH) {
    Push-Location $BACKEND_PATH
    
    Write-Info "Restoring NuGet packages..."
    dotnet restore
    
    Write-Info "Building .NET project..."
    dotnet build --configuration Release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Backend built successfully"
    } else {
        Write-Error "✗ Backend build failed"
        Pop-Location
        exit 1
    }
    
    Pop-Location
} else {
    Write-Error "Backend path not found: $BACKEND_PATH"
    exit 1
}

# ==============================================================================
# 4. BUILD FRONTEND
# ==============================================================================
Write-Info "`n[4/6] Building frontend..."

if (Test-Path $FRONTEND_PATH) {
    Push-Location $FRONTEND_PATH
    
    Write-Info "Installing npm packages..."
    npm install
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Frontend dependencies installed"
    } else {
        Write-Error "✗ npm install failed"
        Pop-Location
        exit 1
    }
    
    Pop-Location
} else {
    Write-Error "Frontend path not found: $FRONTEND_PATH"
    exit 1
}

# ==============================================================================
# 5. START BACKEND
# ==============================================================================
Write-Info "`n[5/6] Starting backend..."

$backendJob = Start-Process pwsh -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$BACKEND_PATH'; Write-Host 'Starting Azure Functions...' -ForegroundColor Green; func start"
) -PassThru

Write-Success "✓ Backend started in new process (PID: $($backendJob.Id))"
Write-Info "  Backend will be available at: http://localhost:7071"

# ==============================================================================
# 6. START FRONTEND
# ==============================================================================
Write-Info "`n[6/6] Starting frontend..."

Start-Sleep -Seconds 3

$frontendJob = Start-Process pwsh -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$FRONTEND_PATH'; Write-Host 'Starting Vite dev server...' -ForegroundColor Green; npm run dev"
) -PassThru

Write-Success "✓ Frontend started in new process (PID: $($frontendJob.Id))"
Write-Info "  Frontend will be available at: http://localhost:5173 (or next available port)"

# ==============================================================================
# SUMMARY
# ==============================================================================
Write-Info "`n===================================================================="
Write-Success "Service Catalogue Manager started successfully!"
Write-Info "===================================================================="
Write-Info "Database:  SQL Server in Docker (container: $CONTAINER_NAME)"
Write-Info "           Connection: localhost,$SQL_PORT"
Write-Info "           Database: $DB_NAME"
Write-Info ""
Write-Info "Backend:   http://localhost:7071"
Write-Info "           Process ID: $($backendJob.Id)"
Write-Info ""
Write-Info "Frontend:  http://localhost:5173"
Write-Info "           Process ID: $($frontendJob.Id)"
Write-Info "===================================================================="
Write-Info ""
Write-Warning "To stop all services:"
Write-Info "  1. Close the backend and frontend terminal windows"
Write-Info "  2. Stop Docker container: docker stop $CONTAINER_NAME"
Write-Info "  3. Remove container (optional): docker rm $CONTAINER_NAME"
Write-Info "===================================================================="
