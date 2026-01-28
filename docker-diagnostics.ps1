#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Docker Diagnostics
# ============================================================================
# Diagnostický skript pro kontrolu Docker kontejneru
# ============================================================================

$ErrorActionPreference = "Continue"

Write-Host "🔍 Docker Diagnostics" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# Kontrola Docker
Write-Host "ℹ️  Checking Docker installation..." -ForegroundColor Cyan
try {
    docker --version
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Kontrola běžících kontejnerů
Write-Host "ℹ️  Checking running containers..." -ForegroundColor Cyan
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""

# Kontrola specifického kontejneru
Write-Host "ℹ️  Checking SQL Server container..." -ForegroundColor Cyan
$container = docker ps --filter "name=scm-sqlserver" --format "{{.Names}}"

if ($container -eq "scm-sqlserver") {
    Write-Host "✅ SQL Server container is running" -ForegroundColor Green
    
    # Zkontrolovat logy
    Write-Host "ℹ️  Container logs (last 20 lines):" -ForegroundColor Cyan
    docker logs --tail 20 scm-sqlserver
    
    Write-Host ""
    Write-Host "ℹ️  Testing SQL Server connection..." -ForegroundColor Cyan
    try {
        $result = docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" -h -1 2>&1
        if ($result -match "1") {
            Write-Host "✅ SQL Server is accepting connections" -ForegroundColor Green
            
            # Zkontrolovat databáze
            Write-Host "ℹ️  Checking databases..." -ForegroundColor Cyan
            docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')" -h -1 2>&1
            
        } else {
            Write-Host "⚠️  SQL Server connection test failed" -ForegroundColor Yellow
            Write-Host "Result: $result" -ForegroundColor Gray
        }
    } catch {
        Write-Host "⚠️  SQL Server connection test failed: $_" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "⚠️  SQL Server container is not running" -ForegroundColor Yellow
    Write-Host "ℹ️  All containers:" -ForegroundColor Cyan
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.State}}"
}

Write-Host ""
Write-Host "ℹ️  Docker system info:" -ForegroundColor Cyan
Write-Host "   Docker version: $(docker --version)" -ForegroundColor Gray
try {
    $dockerInfo = docker system info --format "{{.ServerVersion}}"
    Write-Host "   Server version: $dockerInfo" -ForegroundColor Gray
} catch {}

Write-Host ""
Write-Host "🎯 Diagnostics complete!" -ForegroundColor Cyan