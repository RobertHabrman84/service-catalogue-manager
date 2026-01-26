<#
.SYNOPSIS
    Updates project dependencies to their latest versions.
.DESCRIPTION
    Updates npm packages (frontend) and NuGet packages (backend).
.PARAMETER Frontend
    Update only frontend dependencies
.PARAMETER Backend
    Update only backend dependencies
.PARAMETER DryRun
    Show what would be updated without making changes
.PARAMETER Major
    Include major version updates (breaking changes)
.EXAMPLE
    .\update-dependencies.ps1
    .\update-dependencies.ps1 -DryRun
    .\update-dependencies.ps1 -Frontend -Major
#>

param(
    [switch]$Frontend,
    [switch]$Backend,
    [switch]$DryRun,
    [switch]$Major
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptRoot)

# Default to updating both if neither specified
if (-not $Frontend -and -not $Backend) {
    $Frontend = $true
    $Backend = $true
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Update Dependencies" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Frontend Dependencies
if ($Frontend) {
    Write-Host "┌─────────────────────────────────────┐" -ForegroundColor Blue
    Write-Host "│  Frontend (npm)                     │" -ForegroundColor Blue
    Write-Host "└─────────────────────────────────────┘" -ForegroundColor Blue
    Write-Host ""
    
    $frontendPath = Join-Path $ProjectRoot "src/frontend"
    
    if (Test-Path $frontendPath) {
        Push-Location $frontendPath
        
        # Check for outdated packages
        Write-Host "Checking for outdated packages..." -ForegroundColor Yellow
        $outdated = npm outdated --json 2>$null | ConvertFrom-Json
        
        if ($outdated) {
            Write-Host ""
            Write-Host "Outdated packages:" -ForegroundColor Cyan
            
            $tableFormat = "{0,-30} {1,-15} {2,-15} {3,-15}"
            Write-Host ($tableFormat -f "Package", "Current", "Wanted", "Latest") -ForegroundColor Gray
            Write-Host ("-" * 75) -ForegroundColor Gray
            
            $outdated.PSObject.Properties | ForEach-Object {
                $pkg = $_.Name
                $info = $_.Value
                
                $currentColor = "White"
                $isMajorUpdate = $info.current.Split('.')[0] -ne $info.latest.Split('.')[0]
                
                if ($isMajorUpdate) {
                    $currentColor = "Yellow"
                }
                
                Write-Host ($tableFormat -f $pkg, $info.current, $info.wanted, $info.latest) -ForegroundColor $currentColor
            }
            
            if (-not $DryRun) {
                Write-Host ""
                
                if ($Major) {
                    Write-Host "Updating all packages (including major)..." -ForegroundColor Yellow
                    npx npm-check-updates -u
                    npm install
                }
                else {
                    Write-Host "Updating packages (minor/patch only)..." -ForegroundColor Yellow
                    npm update
                }
                
                Write-Host "  Frontend dependencies updated" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  All packages are up to date" -ForegroundColor Green
        }
        
        # Security audit
        Write-Host ""
        Write-Host "Running security audit..." -ForegroundColor Yellow
        npm audit 2>&1 | Select-Object -First 20
        
        if (-not $DryRun) {
            Write-Host ""
            Write-Host "Attempting to fix vulnerabilities..." -ForegroundColor Yellow
            npm audit fix
        }
        
        Pop-Location
    }
}

# Backend Dependencies
if ($Backend) {
    Write-Host ""
    Write-Host "┌─────────────────────────────────────┐" -ForegroundColor Blue
    Write-Host "│  Backend (NuGet)                    │" -ForegroundColor Blue
    Write-Host "└─────────────────────────────────────┘" -ForegroundColor Blue
    Write-Host ""
    
    $backendPath = Join-Path $ProjectRoot "src/backend"
    
    if (Test-Path $backendPath) {
        Push-Location $backendPath
        
        # Check for outdated packages
        Write-Host "Checking for outdated packages..." -ForegroundColor Yellow
        $outdated = dotnet list package --outdated 2>&1
        
        Write-Host $outdated
        
        if (-not $DryRun -and $outdated -match "has the following updates") {
            Write-Host ""
            Write-Host "Updating NuGet packages..." -ForegroundColor Yellow
            
            # Get all csproj files
            $projects = Get-ChildItem -Path $backendPath -Filter "*.csproj" -Recurse
            
            foreach ($project in $projects) {
                Write-Host "  Updating $($project.Name)..." -ForegroundColor Gray
                
                # Update packages using dotnet-outdated tool
                dotnet tool install --global dotnet-outdated-tool 2>$null
                
                if ($Major) {
                    dotnet outdated --upgrade $project.FullName
                }
                else {
                    dotnet outdated --upgrade --version-lock Minor $project.FullName
                }
            }
            
            # Restore after updates
            dotnet restore
            
            Write-Host "  Backend dependencies updated" -ForegroundColor Green
        }
        
        # Security check
        Write-Host ""
        Write-Host "Checking for vulnerable packages..." -ForegroundColor Yellow
        dotnet list package --vulnerable
        
        Pop-Location
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Update Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if ($DryRun) {
    Write-Host "This was a dry run. Run without -DryRun to apply updates." -ForegroundColor Yellow
}
else {
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Review changes in package.json / *.csproj" -ForegroundColor Gray
    Write-Host "  2. Run tests: npm test / dotnet test" -ForegroundColor Gray
    Write-Host "  3. Test application manually" -ForegroundColor Gray
    Write-Host "  4. Commit changes if everything works" -ForegroundColor Gray
}
Write-Host ""
