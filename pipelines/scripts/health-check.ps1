<#
.SYNOPSIS
    Performs health checks on deployed application.
.DESCRIPTION
    Checks health of frontend and backend after deployment.
.PARAMETER Environment
    Target environment
.PARAMETER FrontendUrl
    Frontend URL
.PARAMETER BackendUrl
    Backend API URL
.EXAMPLE
    .\health-check.ps1 -Environment "Staging" -FrontendUrl "https://app.com" -BackendUrl "https://api.com"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Development","Staging","Production")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [string]$FrontendUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$BackendUrl,
    
    [int]$Timeout = 30,
    [int]$RetryCount = 3
)

$ErrorActionPreference = "Stop"
$results = @()

function Test-Endpoint {
    param(
        [string]$Url, 
        [string]$Name, 
        [int]$ExpectedStatus = 200
    )
    
    for ($i = 1; $i -le $RetryCount; $i++) {
        try {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec $Timeout -UseBasicParsing
            $stopwatch.Stop()
            
            $success = $response.StatusCode -eq $ExpectedStatus
            return @{
                Name = $Name
                Url = $Url
                Status = $response.StatusCode
                ResponseTime = $stopwatch.ElapsedMilliseconds
                Success = $success
                Message = if ($success) { "OK" } else { "Unexpected status" }
            }
        }
        catch {
            if ($i -eq $RetryCount) {
                return @{
                    Name = $Name
                    Url = $Url
                    Status = 0
                    ResponseTime = 0
                    Success = $false
                    Message = $_.Exception.Message
                }
            }
            Write-Host "  Retry $i/$RetryCount..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
    }
}

Write-Host "=== Health Check: $Environment ===" -ForegroundColor Cyan
Write-Host "Frontend: $FrontendUrl"
Write-Host "Backend:  $BackendUrl"
Write-Host ""

# Frontend check
Write-Host "Checking Frontend..." -ForegroundColor Yellow
$results += Test-Endpoint -Url $FrontendUrl -Name "Frontend App"

# Backend health endpoint
Write-Host "Checking Backend Health API..." -ForegroundColor Yellow
$results += Test-Endpoint -Url "$BackendUrl/api/health" -Name "Backend Health"

# Backend readiness check
Write-Host "Checking Backend Readiness..." -ForegroundColor Yellow
$results += Test-Endpoint -Url "$BackendUrl/api/health/ready" -Name "Backend Ready"

# Backend liveness check
Write-Host "Checking Backend Liveness..." -ForegroundColor Yellow
$results += Test-Endpoint -Url "$BackendUrl/api/health/live" -Name "Backend Live"

# Display results
Write-Host ""
Write-Host "=== Health Check Results ===" -ForegroundColor Cyan
$allPassed = $true

foreach ($result in $results) {
    $color = if ($result.Success) { "Green" } else { "Red"; $allPassed = $false }
    $icon = if ($result.Success) { "[PASS]" } else { "[FAIL]" }
    
    Write-Host "$icon $($result.Name)" -ForegroundColor $color
    Write-Host "      URL: $($result.Url)"
    Write-Host "      Status: $($result.Status)"
    Write-Host "      Response Time: $($result.ResponseTime)ms"
    Write-Host "      Message: $($result.Message)"
    Write-Host ""
}

# Summary
Write-Host "=== Summary ===" -ForegroundColor Cyan
$passedCount = ($results | Where-Object { $_.Success }).Count
$totalCount = $results.Count

Write-Host "Passed: $passedCount / $totalCount"
Write-Host "Overall: $(if ($allPassed) { 'PASSED' } else { 'FAILED' })" -ForegroundColor $(if ($allPassed) { "Green" } else { "Red" })

# Set Azure DevOps variable
Write-Host "##vso[task.setvariable variable=HealthCheckPassed;isOutput=true]$allPassed"

# Exit with error if any check failed
if (-not $allPassed) {
    Write-Host "##vso[task.logissue type=error]Health check failed for $Environment"
    exit 1
}

Write-Host ""
Write-Host "Health check completed successfully!" -ForegroundColor Green
