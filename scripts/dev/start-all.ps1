<#
.SYNOPSIS
    Starts all services for local development.
.DESCRIPTION
    Launches frontend, backend, and optionally database services concurrently.
.PARAMETER SkipDatabase
    Skip starting the database container
.PARAMETER FrontendPort
    Port for frontend dev server (default: 5173)
.PARAMETER BackendPort
    Port for backend Functions host (default: 7071)
.EXAMPLE
    .\start-all.ps1
    .\start-all.ps1 -SkipDatabase
#>

param(
    [switch]$SkipDatabase,
    [int]$FrontendPort = 5173,
    [int]$BackendPort = 7071
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Service Catalogue Manager" -ForegroundColor Cyan
Write-Host "  Starting All Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Store background jobs
$jobs = @()

try {
    # Start Database (Docker)
    if (-not $SkipDatabase) {
        Write-Host "Starting Database..." -ForegroundColor Yellow
        $dockerComposePath = Join-Path $ProjectRoot "docker-compose.yml"
        
        if (Test-Path $dockerComposePath) {
            Push-Location $ProjectRoot
            docker-compose up -d sqlserver 2>$null
            Pop-Location
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  SQL Server container started" -ForegroundColor Green
                Write-Host "  Waiting for database to be ready..." -ForegroundColor Gray
                Start-Sleep -Seconds 10
            }
            else {
                Write-Host "  Docker not available, skipping database" -ForegroundColor Yellow
            }
        }
    }

    # Start Backend as background job
    Write-Host ""
    Write-Host "Starting Backend (port $BackendPort)..." -ForegroundColor Yellow
    $backendJob = Start-Job -ScriptBlock {
        param($path, $port)
        Set-Location $path
        & "$path/scripts/dev/start-backend.ps1" -Port $port
    } -ArgumentList $ProjectRoot, $BackendPort
    $jobs += $backendJob
    Write-Host "  Backend starting in background (Job ID: $($backendJob.Id))" -ForegroundColor Green

    # Wait for backend to start
    Start-Sleep -Seconds 5

    # Start Frontend as background job
    Write-Host ""
    Write-Host "Starting Frontend (port $FrontendPort)..." -ForegroundColor Yellow
    $frontendJob = Start-Job -ScriptBlock {
        param($path, $port)
        Set-Location $path
        & "$path/scripts/dev/start-frontend.ps1" -Port $port
    } -ArgumentList $ProjectRoot, $FrontendPort
    $jobs += $frontendJob
    Write-Host "  Frontend starting in background (Job ID: $($frontendJob.Id))" -ForegroundColor Green

    # Display status
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  All Services Started!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Services:" -ForegroundColor Cyan
    Write-Host "  Frontend: http://localhost:$FrontendPort" -ForegroundColor White
    Write-Host "  Backend:  http://localhost:$BackendPort" -ForegroundColor White
    Write-Host "  Health:   http://localhost:$BackendPort/api/health" -ForegroundColor White
    if (-not $SkipDatabase) {
        Write-Host "  Database: localhost:1433" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  View logs:     Get-Job | Receive-Job" -ForegroundColor Gray
    Write-Host "  Stop all:      Get-Job | Stop-Job | Remove-Job" -ForegroundColor Gray
    Write-Host "  Or press Ctrl+C to stop" -ForegroundColor Gray
    Write-Host ""

    # Keep script running and show logs
    Write-Host "Streaming logs (Ctrl+C to stop)..." -ForegroundColor Yellow
    Write-Host ""
    
    while ($true) {
        foreach ($job in $jobs) {
            $output = Receive-Job -Job $job -ErrorAction SilentlyContinue
            if ($output) {
                Write-Host $output
            }
        }
        Start-Sleep -Milliseconds 500
    }
}
finally {
    # Cleanup on exit
    Write-Host ""
    Write-Host "Stopping services..." -ForegroundColor Yellow
    
    foreach ($job in $jobs) {
        Stop-Job -Job $job -ErrorAction SilentlyContinue
        Remove-Job -Job $job -ErrorAction SilentlyContinue
    }
    
    if (-not $SkipDatabase) {
        Push-Location $ProjectRoot
        docker-compose stop sqlserver 2>$null
        Pop-Location
    }
    
    Write-Host "All services stopped" -ForegroundColor Green
}
