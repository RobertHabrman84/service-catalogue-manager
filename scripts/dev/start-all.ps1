<#
.SYNOPSIS
    Starts all services for local development.
.DESCRIPTION
    Launches frontend, backend, and optionally database services concurrently.
    Includes robust backend health check before starting frontend.
.PARAMETER SkipDatabase
    Skip starting the database container
.PARAMETER FrontendPort
    Port for frontend dev server (default: 5173)
.PARAMETER BackendPort
    Port for backend Functions host (default: 7071)
.PARAMETER SkipHealthCheck
    Skip backend health check (not recommended)
.PARAMETER HealthCheckTimeout
    Maximum time to wait for backend health check in seconds (default: 60)
.EXAMPLE
    .\start-all.ps1
    .\start-all.ps1 -SkipDatabase
    .\start-all.ps1 -HealthCheckTimeout 120
#>

param(
    [switch]$SkipDatabase,
    [int]$FrontendPort = 5173,
    [int]$BackendPort = 7071,
    [switch]$SkipHealthCheck,
    [int]$HealthCheckTimeout = 60
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

# Function: Wait for Backend Health Check
function Wait-BackendHealthy {
    param(
        [int]$Port,
        [int]$TimeoutSeconds = 60
    )
    
    $healthUrl = "http://localhost:$Port/api/health"
    $startTime = Get-Date
    $attempt = 0
    $maxAttempts = [Math]::Ceiling($TimeoutSeconds / 2)
    
    Write-Host ""
    Write-Host "Waiting for backend health check..." -ForegroundColor Yellow
    Write-Host "  URL: $healthUrl" -ForegroundColor Gray
    Write-Host "  Timeout: $TimeoutSeconds seconds" -ForegroundColor Gray
    Write-Host ""
    
    while ($true) {
        $attempt++
        $elapsed = ((Get-Date) - $startTime).TotalSeconds
        
        # Check timeout
        if ($elapsed -ge $TimeoutSeconds) {
            Write-Host ""
            Write-Host "  Backend health check TIMEOUT after $([Math]::Round($elapsed, 1))s" -ForegroundColor Red
            Write-Host "  Backend may still be starting. Check logs with: Get-Job | Receive-Job" -ForegroundColor Yellow
            return $false
        }
        
        try {
            # Progress indicator
            $progressPercent = [Math]::Min(100, ($elapsed / $TimeoutSeconds) * 100)
            Write-Host "`r  Attempt $attempt/$maxAttempts... [" -NoNewline -ForegroundColor Gray
            Write-Host "$([Math]::Round($elapsed, 1))s" -NoNewline -ForegroundColor Cyan
            Write-Host "]" -NoNewline -ForegroundColor Gray
            
            # Make HTTP request with short timeout
            $response = Invoke-WebRequest -Uri $healthUrl -Method Get -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
            
            if ($response.StatusCode -eq 200) {
                Write-Host ""
                Write-Host ""
                Write-Host "  Backend is HEALTHY!" -ForegroundColor Green
                Write-Host "  Response time: $([Math]::Round($elapsed, 1))s" -ForegroundColor Gray
                
                # Try to parse health response
                try {
                    $healthData = $response.Content | ConvertFrom-Json
                    if ($healthData.status) {
                        Write-Host "  Status: $($healthData.status)" -ForegroundColor Gray
                    }
                } catch {
                    # Ignore JSON parse errors
                }
                
                return $true
            }
        }
        catch {
            # Expected errors during startup (connection refused, timeout, etc.)
            # Continue waiting...
        }
        
        # Exponential backoff: 1s, 2s, 3s, 4s, then 5s
        $sleepTime = [Math]::Min(5, $attempt)
        Start-Sleep -Seconds $sleepTime
    }
}

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

    # Wait for backend health check
    if (-not $SkipHealthCheck) {
        $isHealthy = Wait-BackendHealthy -Port $BackendPort -TimeoutSeconds $HealthCheckTimeout
        
        if (-not $isHealthy) {
            Write-Host ""
            Write-Host "WARNING: Backend health check failed!" -ForegroundColor Red
            Write-Host "Frontend will start anyway, but may not work correctly." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "To diagnose, run:" -ForegroundColor Cyan
            Write-Host "  Get-Job -Id $($backendJob.Id) | Receive-Job" -ForegroundColor Gray
            Write-Host "  Invoke-WebRequest http://localhost:$BackendPort/api/health" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Press Enter to continue or Ctrl+C to abort..." -ForegroundColor Yellow
            Read-Host
        }
    }
    else {
        Write-Host "  Skipping health check (not recommended)" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }

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
    Write-Host "Health Check:" -ForegroundColor Cyan
    Write-Host "  curl http://localhost:$BackendPort/api/health" -ForegroundColor Gray
    Write-Host "  curl http://localhost:$BackendPort/api/health/detailed" -ForegroundColor Gray
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
