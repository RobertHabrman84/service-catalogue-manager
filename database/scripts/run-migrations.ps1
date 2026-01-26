<#
.SYNOPSIS
    Runs database migrations for Service Catalogue Manager.

.DESCRIPTION
    This script executes SQL migration scripts against the target database
    in version order.

.PARAMETER Environment
    Target environment: Development, Staging, Production

.PARAMETER ConnectionString
    Optional. Override connection string.

.EXAMPLE
    ./run-migrations.ps1 -Environment Development

.EXAMPLE
    ./run-migrations.ps1 -Environment Production -ConnectionString "Server=..."
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Development", "Staging", "Production")]
    [string]$Environment,

    [Parameter(Mandatory = $false)]
    [string]$ConnectionString
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$MigrationsPath = Join-Path $ScriptRoot "..\migrations"
$SchemaPath = Join-Path $ScriptRoot "..\schema"

# Connection strings by environment
$ConnectionStrings = @{
    "Development" = "Server=localhost;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
    "Staging"     = "Server=scm-staging-weu-sql.database.windows.net;Database=ServiceCatalogueManager;Authentication=Active Directory Default;"
    "Production"  = "Server=scm-prod-weu-sql.database.windows.net;Database=ServiceCatalogueManager;Authentication=Active Directory Default;"
}

# Use provided connection string or lookup by environment
if ([string]::IsNullOrEmpty($ConnectionString)) {
    $ConnectionString = $ConnectionStrings[$Environment]
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Database Migration Runner" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Function to execute SQL file
function Invoke-SqlFile {
    param(
        [string]$FilePath,
        [string]$ConnectionString
    )

    Write-Host "Executing: $(Split-Path -Leaf $FilePath)" -ForegroundColor Yellow

    try {
        $SqlContent = Get-Content -Path $FilePath -Raw
        Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $SqlContent -ErrorAction Stop
        Write-Host "  Success" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  Failed: $_" -ForegroundColor Red
        return $false
    }
}

# Create migration history table if not exists
$CreateHistoryTable = @"
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = '__MigrationHistory')
BEGIN
    CREATE TABLE __MigrationHistory (
        MigrationId NVARCHAR(150) PRIMARY KEY,
        AppliedOn DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        AppliedBy NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER
    );
END
"@

Write-Host "`nCreating migration history table if not exists..." -ForegroundColor Yellow
Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $CreateHistoryTable

# Get applied migrations
$GetAppliedMigrations = "SELECT MigrationId FROM __MigrationHistory ORDER BY MigrationId"
$AppliedMigrations = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $GetAppliedMigrations | Select-Object -ExpandProperty MigrationId

# Get migration files
$MigrationFiles = Get-ChildItem -Path $MigrationsPath -Filter "V*.sql" | Sort-Object Name

Write-Host "`nFound $($MigrationFiles.Count) migration file(s)" -ForegroundColor Cyan

$MigrationsApplied = 0
$MigrationsFailed = 0

foreach ($File in $MigrationFiles) {
    $MigrationId = $File.BaseName

    if ($AppliedMigrations -contains $MigrationId) {
        Write-Host "Skipping (already applied): $MigrationId" -ForegroundColor Gray
        continue
    }

    Write-Host "`nApplying migration: $MigrationId" -ForegroundColor Cyan

    $Success = Invoke-SqlFile -FilePath $File.FullName -ConnectionString $ConnectionString

    if ($Success) {
        # Record migration
        $RecordMigration = "INSERT INTO __MigrationHistory (MigrationId) VALUES ('$MigrationId')"
        Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $RecordMigration
        $MigrationsApplied++
    }
    else {
        $MigrationsFailed++
        if ($Environment -eq "Production") {
            Write-Host "Migration failed in Production. Stopping." -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Migration Summary:" -ForegroundColor Cyan
Write-Host "  Applied: $MigrationsApplied" -ForegroundColor Green
Write-Host "  Failed:  $MigrationsFailed" -ForegroundColor $(if ($MigrationsFailed -gt 0) { "Red" } else { "Green" })
Write-Host "============================================" -ForegroundColor Cyan

if ($MigrationsFailed -gt 0) {
    exit 1
}
