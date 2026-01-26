<#
.SYNOPSIS
    Runs code quality analysis on the project.
.DESCRIPTION
    Executes linting, type checking, and code analysis tools.
.PARAMETER FixIssues
    Automatically fix fixable issues
.PARAMETER ReportPath
    Path for analysis reports
.PARAMETER SkipFrontend
    Skip frontend analysis
.PARAMETER SkipBackend
    Skip backend analysis
.EXAMPLE
    .\run-code-analysis.ps1
    .\run-code-analysis.ps1 -FixIssues
    .\run-code-analysis.ps1 -ReportPath "./reports"
#>

param(
    [switch]$FixIssues,
    [string]$ReportPath = "",
    [switch]$SkipFrontend,
    [switch]$SkipBackend
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)

# Set report path
if ([string]::IsNullOrEmpty($ReportPath)) {
    $ReportPath = Join-Path $ProjectRoot "reports/code-analysis"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Code Quality Analysis" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create reports directory
if (-not (Test-Path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null
}

$results = @()

# Frontend Analysis
if (-not $SkipFrontend) {
    Write-Host "┌─────────────────────────────────────┐" -ForegroundColor Blue
    Write-Host "│  Frontend Analysis                  │" -ForegroundColor Blue
    Write-Host "└─────────────────────────────────────┘" -ForegroundColor Blue
    Write-Host ""
    
    $frontendPath = Join-Path $ProjectRoot "src/frontend"
    
    if (Test-Path $frontendPath) {
        Push-Location $frontendPath
        
        # ESLint
        Write-Host "Running ESLint..." -ForegroundColor Yellow
        $eslintReport = Join-Path $ReportPath "eslint-report.json"
        $eslintArgs = @("run", "lint")
        
        if ($FixIssues) {
            $eslintArgs += "--", "--fix"
        }
        
        npm @eslintArgs 2>&1 | Tee-Object -Variable eslintOutput
        $eslintStatus = if ($LASTEXITCODE -eq 0) { "Pass" } else { "Fail" }
        $results += @{ Tool = "ESLint"; Status = $eslintStatus }
        
        # TypeScript
        Write-Host ""
        Write-Host "Running TypeScript check..." -ForegroundColor Yellow
        npm run type-check 2>&1 | Tee-Object -Variable tscOutput
        $tscStatus = if ($LASTEXITCODE -eq 0) { "Pass" } else { "Fail" }
        $results += @{ Tool = "TypeScript"; Status = $tscStatus }
        
        # Prettier
        Write-Host ""
        Write-Host "Running Prettier check..." -ForegroundColor Yellow
        $prettierArgs = @("prettier")
        if ($FixIssues) {
            $prettierArgs += "--write"
        }
        else {
            $prettierArgs += "--check"
        }
        $prettierArgs += "src/**/*.{ts,tsx,css,json}"
        
        npx @prettierArgs 2>&1 | Tee-Object -Variable prettierOutput
        $prettierStatus = if ($LASTEXITCODE -eq 0) { "Pass" } else { "Fail" }
        $results += @{ Tool = "Prettier"; Status = $prettierStatus }
        
        # Bundle size check
        Write-Host ""
        Write-Host "Checking bundle size..." -ForegroundColor Yellow
        npm run build 2>&1 | Out-Null
        
        $distPath = Join-Path $frontendPath "dist"
        if (Test-Path $distPath) {
            $bundleSize = (Get-ChildItem -Path $distPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
            $bundleSizeKB = [math]::Round($bundleSize / 1KB, 2)
            Write-Host "  Bundle size: $bundleSizeKB KB" -ForegroundColor Cyan
            
            # Warn if bundle is too large (>500KB)
            if ($bundleSizeKB -gt 500) {
                Write-Host "  Warning: Bundle size exceeds 500KB" -ForegroundColor Yellow
            }
        }
        
        Pop-Location
    }
}

# Backend Analysis
if (-not $SkipBackend) {
    Write-Host ""
    Write-Host "┌─────────────────────────────────────┐" -ForegroundColor Blue
    Write-Host "│  Backend Analysis                   │" -ForegroundColor Blue
    Write-Host "└─────────────────────────────────────┘" -ForegroundColor Blue
    Write-Host ""
    
    $backendPath = Join-Path $ProjectRoot "src/backend"
    
    if (Test-Path $backendPath) {
        Push-Location $backendPath
        
        # .NET Format
        Write-Host "Running .NET Format check..." -ForegroundColor Yellow
        $formatArgs = @("format", "--verify-no-changes")
        if ($FixIssues) {
            $formatArgs = @("format")
        }
        
        dotnet @formatArgs 2>&1 | Tee-Object -Variable formatOutput
        $formatStatus = if ($LASTEXITCODE -eq 0) { "Pass" } else { "Fail" }
        $results += @{ Tool = ".NET Format"; Status = $formatStatus }
        
        # Build with warnings as errors
        Write-Host ""
        Write-Host "Building with strict warnings..." -ForegroundColor Yellow
        dotnet build --configuration Release /warnaserror 2>&1 | Tee-Object -Variable buildOutput
        $buildStatus = if ($LASTEXITCODE -eq 0) { "Pass" } else { "Fail" }
        $results += @{ Tool = "Build (strict)"; Status = $buildStatus }
        
        # Security audit
        Write-Host ""
        Write-Host "Running security audit..." -ForegroundColor Yellow
        dotnet list package --vulnerable 2>&1 | Tee-Object -Variable auditOutput
        
        Pop-Location
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Analysis Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$tableFormat = "{0,-20} {1,-10}"
Write-Host ($tableFormat -f "Tool", "Status") -ForegroundColor Cyan
Write-Host ("-" * 35) -ForegroundColor Gray

$hasFailures = $false
foreach ($result in $results) {
    $statusColor = if ($result.Status -eq "Pass") { "Green" } else { "Red"; $hasFailures = $true }
    Write-Host ($tableFormat -f $result.Tool, $result.Status) -ForegroundColor $statusColor
}

Write-Host ""
Write-Host "Reports saved to: $ReportPath" -ForegroundColor Gray

if ($hasFailures) {
    Write-Host ""
    Write-Host "Some checks failed!" -ForegroundColor Red
    if (-not $FixIssues) {
        Write-Host "Run with -FixIssues to auto-fix some issues" -ForegroundColor Yellow
    }
    exit 1
}
else {
    Write-Host ""
    Write-Host "All checks passed!" -ForegroundColor Green
}
Write-Host ""
